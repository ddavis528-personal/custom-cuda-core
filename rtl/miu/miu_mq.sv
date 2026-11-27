//===-- miu_mq.sv - MIU memop queue: entries, their payloads, the credits ---===//
//
// Spec: docs/design-snapshots/miu-spec.md (live: CCV per-block architecture
//       specs, MIU tab, "MA's Phase 2", slice 1 (rev 161): the module
//       partition's miu_mq row; "One memop queue (MQ), 40 entries"; MA-5's
//       credits, CCV_MEMOP_CREDITS in ccv_prov_pkg).
//
// Slice 1's part of the MQ: an entry for each memop as it arrives, its
// ccv_ooe_miu_memop payload held for the memop's life, the entry freed when
// the memop is done, the memop credit returned on its arrival slot, and the
// lane map A2 writes.
//
// The lane map (A2's MQ write; MIU tab, the stage table's H+1 row): per
// lane, its formed address's bits [6:0], the word in its line and the byte
// in the word, which R1 reads by entry for the lane's selects. The line is
// not kept: on the hit path a lane reads its group's line, and its group is
// fixed by its position and F (MA rev 203), wiring at R1. The formed
// address by the form (miu_agu8's flags, an octet's copy each): ordinary,
// the sum's S[6:0]; interleaved (O-83), {lane, S[1:0]}; local (O-69),
// C[6:0] | lane << 2, C miu_form's (miu_a2 forms the page offset the same
// way). Address slot s's memop, at entry ae (miu_pair's), writes at A2
// (tag 06) into the flops tagged 07. Not here yet: the lines a pass looks
// up and the lost flag, with slice 2's passes (and OA-486's assertion with
// them); a predicate transfer's map (one word a warp, lane d's b), with its
// single address from miu_lead.
//
// The 40 entries are split by arrival slot, CCV_MEMOP_CREDITS (10) a slot:
// slot j owns entries j*NC .. j*NC + NC - 1. A memop holds its slot's
// credit until its entry frees, so a memop never finds its slot's entries
// full, and a credit is returned on the slot that owns the entry, which is
// its arrival slot (the spec's credit check). The split costs nothing the
// credits do not already impose, and makes the allocation one slot's own
// lowest free entry: no arbitration across slots.
//
// Stages (tags _cmNNh), the memop's arrival M = 00, as miu_pair counts
// (and for the lane map, the address's V = 03, H = 05, A2 = 06):
//   00 M   the memop's valid on slot j (mv); a free port's valid and entry
//   01     the payload on the wire (no-flop end, A-61); the entry, named by
//          pre a cycle ahead, is taken and its payload written; me tells
//          miu_pair which; a free port's flopped request frees its entry;
//          a bulk discard (mem_op 0xF, A-41) takes no entry
//   02     the entry's payload held (mq), read by miu_pair at 04 and by R1;
//          the credit returns (cr), one a slot a cycle, any excess owed to
//          the next cycles
//   04     the lane map: miu_cap's valid a cycle on (av), flopped
//   05 H   miu_pair's entry for each valid address slot (ae), flopped
//   06 A2  each lane's formed bits (lo, the forms), written by entry into
//   07     the lane map (lm), read by R1
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
  localparam int OW = $clog2(NC + 1) + 1,                      // credits owed a slot
  localparam int NL = ccv_params_pkg::CCV_W_LANE_MASK,         // a slot's lanes, 32
  localparam int NQ = NL / 8,                                  // lane octets
  localparam int LB = 7                                        // a lane's map: address [6:0]
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
  output logic [NS-1:0]    cr_cm02h,
  // ---- The lane map, A2's write, per address slot s ------------------------
  input  logic [NS-1:0]       av_cm04h,     // miu_cap's valid a cycle on
  input  logic [NS*EW-1:0]    ae_cm05h,     // the memop's entry (miu_pair's A1 flops)
  input  logic [NS*NL*LB-1:0] lo_cm06h,     // each lane's sum S[6:0] (miu_agu8's flops)
  input  logic [NS*NQ-1:0]    ilv_cm06h,    // interleaved, each octet's (miu_agu8's)
  input  logic [NS*NQ-1:0]    loc_cm06h,    // local, each octet's (miu_agu8's)
  input  logic [NS*LB-1:0]    cl_cm06h,     // the local form's C[6:0] (miu_form's)
  // The lane maps, entry e's at [e*NL*LB +: NL*LB], lane l's LB bits at l*LB.
  output logic [NE*NL*LB-1:0] lm_cm07h
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

  // ---- The lane map (A2's write) -------------------------------------------
  // av a cycle on enables the entry's flop; the valid a cycle on again names
  // the slots that write (a pulse, outside the gates, within the allowance).
  logic [NS-1:0]    av_q_cm05h, wv_cm06h;
  logic [EW-1:0]    we_cm06h [NS];
  wire              ae_en_cm05h = |av_q_cm05h;
  always_ff @(posedge miu_core_clk) begin
    if (rst_r01h) begin
      av_q_cm05h <= '0;
      wv_cm06h   <= '0;
    end else begin
      av_q_cm05h <= av_cm04h;
      wv_cm06h   <= av_q_cm05h;
    end
  end
  always_ff @(posedge miu_core_clk) begin
    if (ae_en_cm05h)
      for (int a = 0; a < NS; a++) we_cm06h[a] <= ae_cm05h[a*EW +: EW];
  end

  // Each slot's lanes' formed bits: the word, then the byte.
  logic [NL*LB-1:0] lf_cm06h [NS];
  always_comb
    for (int a = 0; a < NS; a++)
      for (int l = 0; l < NL; l++) begin
        logic [LB-1:0] s, c;
        logic          iv, lc;
        s  = lo_cm06h[(a*NL + l)*LB +: LB];
        c  = cl_cm06h[a*LB +: LB];
        iv = ilv_cm06h[a*NQ + l/8];
        lc = loc_cm06h[a*NQ + l/8];
        lf_cm06h[a][l*LB +: LB] = lc ? (c | LB'(l << 2)) : iv ? {5'(l), s[1:0]} : s;
      end

  // Entry e takes the slot that names it (at most one: mq_a2_one).
  logic [NS-1:0] ws_cm06h [NE];
  logic [NE-1:0] lm_en_cm06h;
  always_comb
    for (int e = 0; e < NE; e++) begin
      for (int a = 0; a < NS; a++) ws_cm06h[e][a] = wv_cm06h[a] && we_cm06h[a] == EW'(e);
      lm_en_cm06h[e] = |ws_cm06h[e];
    end
  logic [NL*LB-1:0] lm_q_cm07h [NE];
  for (genvar e = 0; e < NE; e++) begin : g_lm
    logic [NL*LB-1:0] d_cm06h;
    always_comb begin
      d_cm06h = '0;
      for (int a = 0; a < NS; a++) d_cm06h = d_cm06h | ({NL*LB{ws_cm06h[e][a]}} & lf_cm06h[a]);
    end
    always_ff @(posedge miu_core_clk) begin
      if (lm_en_cm06h[e]) lm_q_cm07h[e] <= d_cm06h;
    end
    assign lm_cm07h[e*NL*LB +: NL*LB] = lm_q_cm07h[e];
  end

  // ---- Checks ---------------------------------------------------------------
  // Per slot, folded into one property each (one label a module):
  //   a memop finds its slot's preselected entry free (its credit);
  //   a free port names a held entry;
  //   the credits owed stay within the slot's credits.
  //   the one-hot and the encoded preselection agree.
  //   no two address slots write one entry's lane map in a cycle.
  logic [NS-1:0] take_ok_cm01h, free_ok_cm01h, owed_ok_cm02h, pre_ok_cm01h;
  logic [NE-1:0] a2_ok_cm06h;
  always_comb
    for (int e = 0; e < NE; e++) a2_ok_cm06h[e] = (ws_cm06h[e] & (ws_cm06h[e] - NS'(1))) == '0;
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
  `CCV_ASSERT(mq_a2_one, &a2_ok_cm06h)

endmodule
`undef CCV_CLK
`undef CCV_RST
