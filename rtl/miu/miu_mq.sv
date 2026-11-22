//===-- miu_mq.sv - MIU memop queue: entries, their payloads, the credits ---===//
//
// Spec: docs/design-snapshots/miu-spec.md (live: CCV per-block architecture
//       specs, MIU tab, "MA's Phase 2", slice 1 (rev 161): the module
//       partition's miu_mq row; "One memop queue (MQ), 40 entries"; MA-5's
//       credits, CCV_MEMOP_CREDITS in ccv_prov_pkg).
//
// Slice 1's part of the MQ: an entry for each memop as it arrives, its
// ccv_ooe_miu_memop payload held for the memop's life, the entry freed when
// the memop is done, and the memop credit returned on its arrival slot. The
// lines, lane map and lost flag that A2 writes come with miu_a2.
//
// The 40 entries are split by arrival slot, CCV_MEMOP_CREDITS (10) a slot:
// slot j owns entries j*NC .. j*NC + NC - 1. A memop holds its slot's
// credit until its entry frees, so a memop never finds its slot's entries
// full, and a credit is returned on the slot that owns the entry, which is
// its arrival slot (the spec's credit check). The split costs nothing the
// credits do not already impose, and makes the allocation one slot's own
// lowest free entry: no arbitration across slots.
//
// Stages (tags _cmNNh), the memop's arrival M = 00, as miu_pair counts:
//   00 M   the memop's valid on slot j (mv); a free port's valid and entry
//   01     the payload on the wire (no-flop end, A-61); the entry, named by
//          pre a cycle ahead, is taken and its payload written; me tells
//          miu_pair which; a free port's flopped request frees its entry;
//          a bulk discard (mem_op 0xF, A-41) takes no entry
//   02     the entry's payload held (mq), read by miu_pair at 04 and by R1;
//          the credit returns (cr), one a slot a cycle, any excess owed to
//          the next cycles
// The free state and the preselected entry (fr, pre) are queue state at
// 01; the payload array is the queue's, written at 01 and tagged 02.
//
// Inputs are capture flops' or no-flop ends (arrival 0); every enable comes
// from this module's own flops (CG-5): the memop's valid and the free ports
// are flopped first. Every output comes straight from a flop.
//
// The reference is the MIU model (sim/miu/miu_block.cpp: an entry per memop
// from arrival to freeEntry, the credit on its arrival slot, a bulk
// discard's credit as it takes it), and test/miu/mq_tb.cpp holds this
// module to a value model of it.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`include "ccv_interfaces.svh"
`define CCV_CLK miu_core_clk
`define CCV_RST rst_r01h
module miu_mq #(
  parameter  int NS = ccv_params_pkg::CCV_MIU_PIPES,          // arrival slots, 4
  parameter  int NC = ccv_prov_pkg::CCV_MEMOP_CREDITS,        // entries a slot, 10
  parameter  int NF = ccv_params_pkg::CCV_MIU_PIPES,          // free ports, 4
  localparam int NE = NS * NC,                                 // entries, 40
  localparam int EW = $clog2(NE),
  localparam int PL = $bits(ccv_ooe_miu_memop_t),              // payload, 126
  localparam int HW = miu_pkg::HI_W,
  localparam int AW = miu_pkg::A1_W,
  localparam int OW = $clog2(NC + 1) + 1                       // credits owed a slot
) (
  input  logic             miu_core_clk,
  input  logic             rst_n,
  // ccv_ooe_miu_memop: slot j's valid at M, its payload at M + 1.
  input  logic [NS-1:0]    mv_cm00h,
  input  logic [NS*PL-1:0] pay_cm01h,    // slot j's at [j*PL +: PL]
  // Free ports: entry fe[p] is done (each port names a held entry).
  input  logic [NF-1:0]    fv_cm00h,
  input  logic [NF*EW-1:0] fe_cm00h,     // port p's at [p*EW +: EW]
  // The entry each slot's memop takes, with its payload (miu_pair).
  output logic [NS*EW-1:0] me_cm01h,     // slot j's at [j*EW +: EW]
  // The held payloads, entry e's at [e*W +: W] of each view (miu_pkg).
  output logic [NE*AW-1:0] a1_cm02h,
  output logic [NE*HW-1:0] hi_cm02h,
  // ccv_ooe_miu_memop's credit return, a pulse a slot.
  output logic [NS-1:0]    cr_cm02h
);

  if (HW + AW != PL) begin : g_layout
    $error("miu_mq: miu_pkg's views (%0d + %0d) are not the memop payload (%0d)", HW, AW, PL);
  end

  // rst_n flopped before any use (RST-1), inverted after the flop.
  logic rst_cr01h_n;
  always_ff @(posedge miu_core_clk) begin
    rst_cr01h_n <= rst_n;
  end
  wire rst_r01h = !rst_cr01h_n;

  // ---- The memop's valid and the free ports, a cycle on (CG-5) -----------
  logic [NS-1:0]    mv_q_cm01h;
  logic [NF-1:0]    fv_q_cm01h;
  logic [NF*EW-1:0] fe_q_cm01h;
  always_ff @(posedge miu_core_clk) begin
    if (rst_r01h) begin
      mv_q_cm01h <= '0;
      fv_q_cm01h <= '0;
    end else begin
      mv_q_cm01h <= mv_cm00h;
      fv_q_cm01h <= fv_cm00h;
    end
  end
  // The entry is data under its valid; no reset.
  always_ff @(posedge miu_core_clk) begin
    fe_q_cm01h <= fe_cm00h;
  end

  // A bulk discard on slot j (its mem_op on the wire now) takes no entry.
  logic [NS-1:0] dis_cm01h;
  always_comb begin
    for (int j = 0; j < NS; j++)
      dis_cm01h[j] = mv_q_cm01h[j] &
                     (pay_cm01h[j*PL + miu_pkg::A1_MEM_OP +: ccv_prelim_pkg::CCV_L_W_MEM_OP] ==
                      miu_pkg::MEM_OP_DISCARD);
  end

  // ---- Each slot's free entries and its preselected one ------------------
  // fr[j][l]: slot j's entry j*NC + l is free. pre[j]: the entry its next
  // memop takes, the lowest free one, chosen a cycle ahead from flops.
  logic [NC-1:0]  fr_cm01h  [NS];
  logic [EW-1:0]  pre_cm01h [NS];
  logic [NS-1:0]  tk_cm01h;               // slot j's memop takes pre[j]
  logic [NC-1:0]  rel_cm01h [NS];         // slot j's entries freed now
  logic [NS-1:0]  fhit_cm01h;             // a free port names one of slot j's
  for (genvar j = 0; j < NS; j++) begin : g_slot
    always_comb begin
      rel_cm01h[j] = '0;
      for (int p = 0; p < NF; p++)
        for (int l = 0; l < NC; l++)
          if (fv_q_cm01h[p] && fe_q_cm01h[p*EW +: EW] == EW'(j*NC + l)) rel_cm01h[j][l] = 1'b1;
      fhit_cm01h[j] = |rel_cm01h[j];
      tk_cm01h[j]   = mv_q_cm01h[j] & ~dis_cm01h[j];
    end
    // The next free set, and its lowest entry.
    logic [NC-1:0] frn_cm01h;
    logic [EW-1:0] pren_cm01h;
    always_comb begin
      frn_cm01h = fr_cm01h[j] | rel_cm01h[j];
      for (int l = 0; l < NC; l++)
        if (tk_cm01h[j] && pre_cm01h[j] == EW'(j*NC + l)) frn_cm01h[l] = 1'b0;
      pren_cm01h = EW'(j*NC);
      for (int l = NC - 1; l >= 0; l--)
        if (frn_cm01h[l]) pren_cm01h = EW'(j*NC + l);
    end
    // Clocked when the slot takes a memop or frees an entry: the free set
    // changes then, but for a bulk discard alone (rare).
    wire fr_en_cm01h = mv_q_cm01h[j] | fhit_cm01h[j];
    always_ff @(posedge miu_core_clk) begin
      if (rst_r01h) begin
        fr_cm01h[j]  <= '1;
        pre_cm01h[j] <= EW'(j*NC);
      end else if (fr_en_cm01h) begin
        fr_cm01h[j]  <= frn_cm01h;
        pre_cm01h[j] <= pren_cm01h;
      end
    end
    assign me_cm01h[j*EW +: EW] = pre_cm01h[j];
  end

  // ---- The payloads -------------------------------------------------------
  // Entry j*NC + l is written when slot j's memop takes it. A bulk discard
  // writes its preselected entry too: the entry is free, and stays so.
  logic [PL-1:0] mq_cm02h [NE];
  for (genvar e = 0; e < NE; e++) begin : g_ent
    localparam int J = e / NC;
    wire wr_en_cm01h = mv_q_cm01h[J] & (pre_cm01h[J] == EW'(e));
    always_ff @(posedge miu_core_clk) begin
      if (wr_en_cm01h) mq_cm02h[e] <= pay_cm01h[J*PL +: PL];
    end
    assign a1_cm02h[e*AW +: AW] = mq_cm02h[e][AW-1:0];
    assign hi_cm02h[e*HW +: HW] = mq_cm02h[e][PL-1:AW];
  end

  // ---- The credits ---------------------------------------------------------
  // Slot j returns a credit for each entry of its freed and each bulk
  // discard it took, one a cycle; the excess waits in ow[j] (at most NC:
  // OOE holds no more of the slot's credits than that).
  logic [NS-1:0] cr_q_cm02h;
  logic [OW-1:0] ow_cm02h [NS];
  for (genvar j = 0; j < NS; j++) begin : g_cred
    // Returns this cycle: the slot's freed entries and its bulk discard.
    logic [OW-1:0] ret_cm01h;
    always_comb begin
      ret_cm01h = OW'(dis_cm01h[j]);
      for (int l = 0; l < NC; l++) ret_cm01h = ret_cm01h + OW'(rel_cm01h[j][l]);
    end
    // Pulses and a rare count: outside the gates, within the allowance.
    // Each reads the slot's owed count, state of its own stage.
    always_ff @(posedge miu_core_clk) begin
      if (rst_r01h) begin
        cr_q_cm02h[j] <= 1'b0;
        ow_cm02h[j]   <= '0;
      end else begin
        cr_q_cm02h[j] <= (ow_cm02h[j] != '0) | (ret_cm01h != '0);
        ow_cm02h[j]   <= (ow_cm02h[j] + ret_cm01h != '0) ? ow_cm02h[j] + ret_cm01h - OW'(1) : '0;
      end
    end
  end
  assign cr_cm02h = cr_q_cm02h;

  // ---- Checks ---------------------------------------------------------------
  for (genvar j = 0; j < NS; j++) begin : g_chk
    // A memop finds its slot's preselected entry free (its credit).
    logic pre_free_cm01h;
    always_comb begin
      pre_free_cm01h = 1'b0;
      for (int l = 0; l < NC; l++)
        if (pre_cm01h[j] == EW'(j*NC + l)) pre_free_cm01h = fr_cm01h[j][l];
    end
    `CCV_ASSERT(mq_take_free, !tk_cm01h[j] || pre_free_cm01h)
    // A free port names a held entry.
    `CCV_ASSERT(mq_free_held, (rel_cm01h[j] & fr_cm01h[j]) == '0)
    `CCV_ASSERT(mq_owed_bound, ow_cm02h[j] <= OW'(NC))
  end

endmodule
`undef CCV_CLK
`undef CCV_RST
