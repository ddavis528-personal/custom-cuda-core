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
// The free state and the preselected entry (fr, psel, pre) are queue state
// at 01; the payload array is the queue's, written at 01 and tagged 02. The
// free ports are decoded to an entry's bit before their flop (rel), and the
// payload's mem_op (a bulk discard) chooses last between next states
// computed both ways from flops, so the payload's no-flop end reaches state
// through a compare and a mux.
//
// Inputs are capture flops' or no-flop ends (arrival 0); every enable comes
// from this module's own flops (CG-5): the memop's valid and the freed
// entries are flopped first. Every output comes straight from a flop.
//
// The reference is the MIU model (sim/miu/miu_block.cpp: an entry per memop
// from arrival to freeEntry, the credit on its arrival slot, a bulk
// discard's credit as it takes it), and test/miu/mq_tb.cpp holds this
// module to a value model of it.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK miu_core_clk
`define CCV_RST rst_r01h
module miu_mq #(
  parameter  int NS = ccv_params_pkg::CCV_MIU_PIPES,          // arrival slots, 4
  parameter  int NC = ccv_prov_pkg::CCV_MEMOP_CREDITS,        // entries a slot, 10
  parameter  int NF = ccv_params_pkg::CCV_MIU_PIPES,          // free ports, 4
  localparam int NE = NS * NC,                                 // entries, 40
  localparam int EW = $clog2(NE),
  // The memop payload (ccv_ooe_miu_memop_t, packed, its first field the
  // most significant), seen as two views of the same flops: HI, the echo
  // R1 reads (rob_tag, done_row, rs_idx, phys_dst, dst_pos, phys_pred,
  // issue_mask), the top HW bits; and A1, what miu_pair reads (warp_id down
  // to xfer_signed), the bottom AW bits. test/miu/mq_tb.cpp holds these
  // to the generated layout (sim/generated/ccv_skel_wiring.h).
  localparam int HW = ccv_prov_pkg::CCV_P_W_ROB_TAG + 2 + ccv_prov_pkg::CCV_P_W_RS_IDX +
                      ccv_prov_pkg::CCV_P_W_PHYS_REG + ccv_params_pkg::CCV_W_PHYS_POS +
                      ccv_prov_pkg::CCV_P_W_PHYS_PRED + ccv_params_pkg::CCV_W_LANE_MASK,   // 63
  // mem_op's LSB in A1: below it chwidth, pipes, disp, scale_en, space,
  // ordering, slot_form, arg_slot (4), local_form, xfer_size (2), xfer_signed.
  localparam int MOP = ccv_params_pkg::CCV_W_CHWIDTH + ccv_params_pkg::CCV_MIU_PIPES +
                       ccv_params_pkg::CCV_W_DISP + 1 + ccv_params_pkg::CCV_L_W_SPACE +
                       ccv_params_pkg::CCV_L_W_ORDERING + 1 + 4 + 1 + 2 + 1,              // 51
  localparam int MW = ccv_prelim_pkg::CCV_L_W_MEM_OP,
  localparam int AW = MOP + MW + ccv_prov_pkg::CCV_P_W_CTA_SLOT + ccv_params_pkg::CCV_W_WARP_ID,  // 63
  localparam int PL = HW + AW,                                                          // 126
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
  // The held payloads, entry e's at [e*W +: W] of each view.
  output logic [NE*AW-1:0] a1_cm02h,
  output logic [NE*HW-1:0] hi_cm02h,
  // ccv_ooe_miu_memop's credit return, a pulse a slot.
  output logic [NS-1:0]    cr_cm02h
);

  // rst_n flopped before any use (RST-1), inverted after the flop.
  logic rst_cr01h_n;
  always_ff @(posedge miu_core_clk) begin
    rst_cr01h_n <= rst_n;
  end
  wire rst_r01h = !rst_cr01h_n;

  // ---- The memop's valid and the freed entries, a cycle on (CG-5) --------
  // The free ports are decoded to one bit an entry before the flop: rel[e],
  // entry e is freed now.
  logic [NS-1:0] mv_q_cm01h;
  logic [NE-1:0] rel_cm00h, rel_cm01h;
  always_comb begin
    rel_cm00h = '0;
    for (int e = 0; e < NE; e++)
      for (int p = 0; p < NF; p++)
        rel_cm00h[e] = rel_cm00h[e] | (fv_cm00h[p] & (fe_cm00h[p*EW +: EW] == EW'(e)));
  end
  always_ff @(posedge miu_core_clk) begin
    if (rst_r01h) begin
      mv_q_cm01h <= '0;
      rel_cm01h  <= '0;
    end else begin
      mv_q_cm01h <= mv_cm00h;
      rel_cm01h  <= rel_cm00h;
    end
  end

  // A bulk discard on slot j (its mem_op on the wire now) takes no entry.
  // The payload's only path to state: everything it steers is computed both
  // ways from flops and chosen by it last.
  logic [NS-1:0] dis_cm01h;
  always_comb begin
    for (int j = 0; j < NS; j++)
      dis_cm01h[j] = mv_q_cm01h[j] &
                     (pay_cm01h[j*PL + MOP +: MW] == {MW{1'b1}});   // 0xF
  end

  // ---- Each slot's free entries and its preselected one ------------------
  // fr[j][l]: slot j's entry j*NC + l is free. pre[j]: the entry its next
  // memop takes, the lowest free one, chosen a cycle ahead from flops, held
  // one-hot (psel) for the queue and encoded (pre) for miu_pair: two
  // registers, each (* keep *), so the output's copy starts no inner path.
  logic [NC-1:0] fr_cm01h   [NS];
  logic [NC-1:0] psel_cm01h [NS];
  logic [EW-1:0] pre_cm01h  [NS];
  for (genvar j = 0; j < NS; j++) begin : g_slot
    wire [NC-1:0] relj_cm01h = rel_cm01h[j*NC +: NC];
    // The next free set and its lowest entry, with no take (n) and with the
    // memop's take (t); the payload chooses.
    logic [NC-1:0] frnn_cm01h, frnt_cm01h, psnn_cm01h, psnt_cm01h;
    logic [EW-1:0] prnn_cm01h, prnt_cm01h;
    always_comb begin
      frnn_cm01h = fr_cm01h[j] | relj_cm01h;
      frnt_cm01h = (fr_cm01h[j] & ~psel_cm01h[j]) | relj_cm01h;
      psnn_cm01h = frnn_cm01h & ~(frnn_cm01h - NC'(1));      // lowest set bit
      psnt_cm01h = frnt_cm01h & ~(frnt_cm01h - NC'(1));
      prnn_cm01h = '0;                                      // 0 when full
      prnt_cm01h = '0;
      for (int l = 0; l < NC; l++) begin
        if (psnn_cm01h[l]) prnn_cm01h = prnn_cm01h | EW'(j*NC + l);
        if (psnt_cm01h[l]) prnt_cm01h = prnt_cm01h | EW'(j*NC + l);
      end
    end
    // Clocked when the slot takes a memop or frees an entry: the free set
    // changes then, but for a bulk discard alone (rare).
    wire fr_en_cm01h = mv_q_cm01h[j] | (|relj_cm01h);
    (* keep *) logic [NC-1:0] ps_q_cm01h;
    (* keep *) logic [EW-1:0] pr_q_cm01h;
    always_ff @(posedge miu_core_clk) begin
      if (rst_r01h) begin
        fr_cm01h[j] <= '1;
        ps_q_cm01h  <= NC'(1);
        pr_q_cm01h  <= EW'(j*NC);
      end else if (fr_en_cm01h) begin
        fr_cm01h[j] <= (mv_q_cm01h[j] & ~dis_cm01h[j]) ? frnt_cm01h : frnn_cm01h;
        ps_q_cm01h  <= (mv_q_cm01h[j] & ~dis_cm01h[j]) ? psnt_cm01h : psnn_cm01h;
        pr_q_cm01h  <= (mv_q_cm01h[j] & ~dis_cm01h[j]) ? prnt_cm01h : prnn_cm01h;
      end
    end
    assign psel_cm01h[j] = ps_q_cm01h;
    assign pre_cm01h[j]  = pr_q_cm01h;
    assign me_cm01h[j*EW +: EW] = pr_q_cm01h;
  end

  // ---- The payloads -------------------------------------------------------
  // Entry j*NC + l is written when slot j's memop takes it. A bulk discard
  // writes its preselected entry too: the entry is free, and stays so.
  logic [PL-1:0] mq_cm02h [NE];
  for (genvar e = 0; e < NE; e++) begin : g_ent
    localparam int J = e / NC;
    localparam int L = e % NC;
    wire wr_en_cm01h = mv_q_cm01h[J] & psel_cm01h[J][L];
    always_ff @(posedge miu_core_clk) begin
      if (wr_en_cm01h) mq_cm02h[e] <= pay_cm01h[J*PL +: PL];
    end
    assign a1_cm02h[e*AW +: AW] = mq_cm02h[e][AW-1:0];
    assign hi_cm02h[e*HW +: HW] = mq_cm02h[e][PL-1:AW];
  end

  // ---- The credits ---------------------------------------------------------
  // Slot j returns a credit for each entry of its freed and each bulk
  // discard it took, one a cycle; the excess waits in ow[j] (at most NC:
  // OOE holds no more of the slot's credits than that). With s = ow + the
  // entries freed, the next count is s with a discard (its credit and this
  // cycle's pulse cancel) and s - 1, floored at 0, without.
  logic [NS-1:0] cr_q_cm02h;
  logic [OW-1:0] ow_cm02h [NS];
  for (genvar j = 0; j < NS; j++) begin : g_cred
    logic [OW-1:0] c_cm01h;                 // the slot's entries freed now
    always_comb begin
      c_cm01h = '0;
      for (int l = 0; l < NC; l++) c_cm01h = c_cm01h + OW'(rel_cm01h[j*NC + l]);
    end
    // Pulses and a rare count: outside the gates, within the allowance.
    // Each reads the slot's owed count, state of its own stage.
    always_ff @(posedge miu_core_clk) begin
      if (rst_r01h) begin
        cr_q_cm02h[j] <= 1'b0;
        ow_cm02h[j]   <= '0;
      end else begin
        cr_q_cm02h[j] <= (ow_cm02h[j] != '0) | (c_cm01h != '0) | dis_cm01h[j];
        ow_cm02h[j]   <= dis_cm01h[j] ? ow_cm02h[j] + c_cm01h :
                         (ow_cm02h[j] + c_cm01h != '0) ? ow_cm02h[j] + c_cm01h - OW'(1) : '0;
      end
    end
  end
  assign cr_cm02h = cr_q_cm02h;

  // ---- Checks ---------------------------------------------------------------
  // Per slot, folded into one property each (one label a module):
  //   a memop finds its slot's preselected entry free (its credit);
  //   a free port names a held entry;
  //   the credits owed stay within the slot's credits.
  //   the one-hot and the encoded preselection agree.
  logic [NS-1:0] take_ok_cm01h, free_ok_cm01h, owed_ok_cm02h, pre_ok_cm01h;
  always_comb begin
    for (int j = 0; j < NS; j++) begin
      take_ok_cm01h[j] = !(mv_q_cm01h[j] & ~dis_cm01h[j]) ||
                         ((psel_cm01h[j] & fr_cm01h[j]) != '0);
      pre_ok_cm01h[j] = psel_cm01h[j] == '0;              // full
      for (int l = 0; l < NC; l++)
        if (psel_cm01h[j] == NC'(1) << l && pre_cm01h[j] == EW'(j*NC + l)) pre_ok_cm01h[j] = 1'b1;
      free_ok_cm01h[j] = (rel_cm01h[j*NC +: NC] & fr_cm01h[j]) == '0;
      owed_ok_cm02h[j] = ow_cm02h[j] < OW'(NC + 1);
    end
  end
  `CCV_ASSERT(mq_take_free, &take_ok_cm01h)
  `CCV_ASSERT(mq_free_held, &free_ok_cm01h)
  `CCV_ASSERT(mq_owed_bound, &owed_ok_cm02h)
  `CCV_ASSERT(mq_pre_onehot, &pre_ok_cm01h)

endmodule
`undef CCV_CLK
`undef CCV_RST
