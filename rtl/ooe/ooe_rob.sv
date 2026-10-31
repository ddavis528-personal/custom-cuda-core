//===-- ooe_rob.sv - OOE reorder buffers: allocation, completion, retire ---===//
//
// Spec: the design doc's Retire, squash and recovery (four per-warp ROBs of
// CCV_P_ROB_DEPTH entries, retiring in order up to CCV_RETIRE_PER_ROB a warp
// a cycle; V-19), A ROB entry outlives its RS entries (OI-11, V-58);
// docs/ooe-rtl-plan.md, the ROB, slice 1 (OI-85, OA's rev 277).
//
// Slice 1: storage, allocation, completion and in-order retire, with the
// frees and the retire-stage register, and the room rename's go reads.
// Branches, squash and deferred free (slice 2), memop commit (3), faults
// (4), barriers (5) and demotion (6) follow; until then a core with any of
// them is not driven here (test/ooe/rob_tb.cpp stops it).
//
// Per tier-1 slot s, a circular buffer of D entries: head (the oldest),
// tail (the next to allocate) and the fill pointer (the next Rename 2
// fills: the tail less the entries allocated and not yet filled, uf, so a
// release, which returns head and tail to 0 as the model's fresh slot,
// leaves the fills still in flight to land behind it). An entry is allocated at the go's edge, as the model renames it:
// rename's go names each slot's entries and which are no-ops (an exit, a
// cause from DEC, a barrier no-op: neither class bit), and a no-op is
// complete at once. Rename 2 fills the rest two cycles on, in program order
// per slot, at the fill pointer: the names to commit and to free, the
// sections the old GPR name frees, its kind and its RS entries. Nothing
// completes an entry before its fill: its RS entries issue after it.
//
// Completion (the model's complete(), OA's rev 277 (b)): an entry is
// complete when its RS entries have all freed (rc, a count set at the fill
// and taken down by every free of its in a cycle), no done it owes RCU is
// in flight (ow: up at each issue that owes one, down at each done), and
// its result is in: a lane or RCU op's done (dn), a memop's MIU completion
// (md) with no copy in flight (cp). A cancel needs no input: the cancelled
// issue's entry frees only once its reissue confirms, and that issue owes
// a done of its own, so rc and ow hold the entry until its last done
// (control no-cancel, which dropped them, changed nothing). The RS's events come decoded per entry (it holds
// each entry's rob_tag); RCU's dones and MIU's completions by rob_tag.
//
// Retire (OA's rev 277 (a)): each slot's head window, CCV_RETIRE_PER_ROB
// bits of "retires this cycle", is a register, so the decision is the
// window itself and every lead it drives (ooe_rat's, the free lists') is
// from flops. The window is formed at the edge from the entries at the next
// head with this cycle's events in: an entry completed in a cycle retires
// in the next (the model's retire_lag 1). The retire-stage register then
// carries what ooe_rat writes and what the free lists free.
//
// The room rename's go reads: each slot's free run from the tail as the
// cycle starts, D less the entries it holds (held head to tail without a
// hole, so the run always reaches the head), and this cycle's
// retirements, the window's count.
//
// Timing (OA's rev 279): RCU sends at most one done per rob_tag a cycle (a
// contract on ccv_rcu_ooe_done, asserted here), so an entry's dones owed
// fall by one or none. Head, tail and fill pointers have one-hot copies, so
// the window and the decodes need no adder; the go's allocations, which
// arrive at its take's 14, reach the window apart from the entries.
//
// The reference is the model's ROB (Core::robLog); test/ooe/rob_tb.cpp
// drives this module from it every cycle and compares the retirements, the
// frees and the room.
//
// Reset line: valid bits, pointers, counts, the window and the completion
// terms (cleared again as each entry retires) reset; an entry's fields and
// its complete bit are payload, read only while it is valid and filled.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK ooe_core_clk
`define CCV_RST rst_r01h
module ooe_rob #(
  parameter int S  = 4,                  // tier-1 slots (CCV_TIER1_WARPS)
  parameter int D  = 32,                 // entries a slot (CCV_P_ROB_DEPTH)
  parameter int RP = 2,                  // retirements a slot a cycle (CCV_RETIRE_PER_ROB)
  parameter int A  = 4,                  // entries a cycle, across slots (CCV_ISSUE_WIDTH)
  parameter int ND = 7,                  // RCU dones a cycle (ccv_rcu_ooe_done's rate)
  parameter int NM = 4,                  // MIU completions a cycle (ccv_miu_ooe_cmpl's rate)
  parameter int GW = 10,                 // a GPR name: row and position
  parameter int GR = 8,                  // its row
  parameter int NG = 192,                // GPR rows (CCV_P_PHYS_REGS)
  parameter int NS = 4,                  // sections a row (0: whole rows)
  parameter int PW = 6,                  // a predicate name
  parameter int NP = 48,                 // predicate names (CCV_P_PRED_REGS)
  parameter int LB = 6,                  // the go's run width
  parameter int LT = 3,                  // the go's retire count width
  localparam int NSB = (NS > 0) ? NS : 1,
  localparam int LS = (S > 1) ? $clog2(S) : 1,
  localparam int LD = $clog2(D),
  localparam int TW = LS + LD,           // a rob_tag
  localparam int LA = $clog2(A + 1),
  localparam int NR = 4,                 // an entry's rows (OA's rev 282): the op or A1, the copy, A2, A3
  localparam int RCW = 2                 // dones in flight, a row: 3 at most (OI-90, OA rev 286; ooe_rs holds the fourth)
) (
  input  logic                ooe_core_clk,
  input  logic                ooe_rst_r00h,
  // The go's allocations: per slot, how many entries this cycle and which
  // are no-ops (bit j: its j-th). Each slot's lead: some allocation next cycle.
  input  logic [S-1:0]        al_l_cq01h,
  input  logic [S*LA-1:0]     al_n_cq02h,
  input  logic [S*A-1:0]      al_nop_cq02h,
  // Rename 2's fills, per lane, in program order within each slot; the lead:
  // some fill next cycle.
  input  logic                fl_l_cq01h,
  input  logic [A-1:0]        fl_v_cq02h,
  input  logic [A*LS-1:0]     fl_slot_cq02h,
  input  logic [A-1:0]        fl_nop_cq02h,
  input  logic [A-1:0]        fl_mem_cq02h,
  input  logic [A*2-1:0]      fl_rs_cq02h,     // its RS entries
  input  logic [A-1:0]        fl_gwe_cq02h,
  input  logic [A*4-1:0]      fl_dst_cq02h,
  input  logic [A*GW-1:0]     fl_gname_cq02h,
  input  logic [A*GW-1:0]     fl_gold_cq02h,
  input  logic [A*NSB-1:0]    fl_gsec_cq02h,   // the sections the old name frees
  input  logic [A-1:0]        fl_pwe_cq02h,
  input  logic [A*2-1:0]      fl_pdst_cq02h,
  input  logic [A*PW-1:0]     fl_pname_cq02h,
  input  logic [A*PW-1:0]     fl_pold_cq02h,
  input  logic [A-1:0]        fl_pfree_cq02h,  // the old predicate name is freed (not the zero one)
  // The RS's events, decoded per entry (bit s * D + i): an issue owing RCU a
  // done (per row, bit (s * D + i) * NR + r), a copy issued, a copy landed,
  // and how many of its RS entries freed. Each slot's lead: some event next
  // cycle.
  input  logic [S-1:0]        ev_l_cq01h,
  input  logic [S*D*NR-1:0]   ev_owe_cq02h,
  input  logic [S*D-1:0]      ev_cpi_cq02h,
  input  logic [S*D-1:0]      ev_cpl_cq02h,
  input  logic [S*D*2-1:0]    ev_rsf_cq02h,
  // RCU's dones and MIU's completions, by rob_tag; the channels' valid
  // leads their payload by a cycle (OA's response OI-58, L1).
  input  logic [ND-1:0]       dn_l_cq01h,
  input  logic [ND*TW-1:0]    dn_tag_cq02h,
  input  logic [ND*2-1:0]     dn_row_cq02h,    // the row each completes (OA's rev 282)
  input  logic [NM-1:0]       cm_l_cq01h,
  input  logic [NM*TW-1:0]    cm_tag_cq02h,
  // A slot released (its ROB empty): its pointers return to 0. Its lead.
  input  logic [S-1:0]        rel_l_cq01h,
  // The retire decision, a cycle ahead of the retire-stage register: per
  // slot and port, it writes a GPR, a predicate; and a free next cycle.
  output logic [S*RP-1:0]     rgl_cq02h,
  output logic [S*RP-1:0]     rpl_cq02h,
  output logic                gfree_l_cq02h,
  output logic                pfree_l_cq02h,
  // The retire-stage register: per slot and port, what ooe_rat commits.
  output logic [S*RP-1:0]     ret_gwe_cq03h,
  output logic [S*RP*4-1:0]   ret_dst_cq03h,
  output logic [S*RP*GW-1:0]  ret_gname_cq03h,
  output logic [S*RP-1:0]     ret_pwe_cq03h,
  output logic [S*RP*2-1:0]   ret_pdst_cq03h,
  output logic [S*RP*PW-1:0]  ret_pname_cq03h,
  // And the frees: per GPR row its sections (row r's at r * NS), or with NS
  // 0 the rows; the predicate names.
  output logic [NG*NSB-1:0]   gfree_cq03h,
  output logic [NP-1:0]       pfree_cq03h,
  // The room rename's go reads: each slot's free run from the tail
  // (saturated), whether it reaches the head, and this cycle's retirements.
  output logic [S*LB-1:0]     run_cq02h,
  output logic [S-1:0]        reach_cq02h,
  output logic [S*LT-1:0]     ret_cq02h
);
  logic rst_r01h;
  always_ff @(posedge ooe_core_clk) begin
    rst_r01h <= ooe_rst_r00h;
  end

  // -- The leads, flopped: each slot's state is clocked on them (CG-5) --------
  logic [S-1:0] al_q_cq02h, ev_q_cq02h, rel_q_cq02h;
  logic         fl_q_cq02h;
  logic [ND-1:0] dn_q_cq02h;                  // each port's valid
  logic [NM-1:0] cm_q_cq02h;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      al_q_cq02h  <= '0;
      ev_q_cq02h  <= '0;
      rel_q_cq02h <= '0;
      fl_q_cq02h  <= 1'b0;
      dn_q_cq02h  <= '0;
      cm_q_cq02h  <= '0;
    end else begin
      al_q_cq02h  <= al_l_cq01h;
      ev_q_cq02h  <= ev_l_cq01h;
      rel_q_cq02h <= rel_l_cq01h;
      fl_q_cq02h  <= fl_l_cq01h;
      dn_q_cq02h  <= dn_l_cq01h;
      cm_q_cq02h  <= cm_l_cq01h;
    end
  end

  // -- The state ----------------------------------------------------------------
  // Per entry: valid, a no-op, complete; the completion terms; the kind
  // (an RCU or lane op: its done; a memop: its completion); the fields.
  logic [S*D-1:0]      v_cq02h, cmp_q_cq02h;
  logic [S*D-1:0]      dn_cq02h, md_cq02h, cp_cq02h, kr_cq02h, km_cq02h;
  logic [S*D*NR*RCW-1:0] oc_cq02h;           // per row, its dones in flight
  logic [S*D*2-1:0]    rc_cq02h;
  logic [S*D-1:0]      gwe_cq02h, pwe_cq02h, pfr_cq02h;
  logic [S*D*4-1:0]    dst_cq02h;
  logic [S*D*GW-1:0]   gname_cq02h, gold_cq02h;
  logic [S*D*NSB-1:0]  gsec_cq02h;
  logic [S*D*2-1:0]    pdst_cq02h;
  logic [S*D*PW-1:0]   pname_cq02h, pold_cq02h;
  logic [S*LD-1:0]     head_cq02h;
  // The head window: per slot and port, it retires this cycle, and what
  // the leads read of it.
  logic [S*RP-1:0]     w_cq02h, wg_cq02h, wp_cq02h, wgf_cq02h, wpf_cq02h;

  // One-hot copies of the pointers (bit i: entry i), beside the binary ones,
  // so the window, the allocations and the fills decode without an adder:
  // each is its pointer's rotations, picked by a count.
  logic [S*D-1:0]      hoh_cq02h, toh_cq02h, woh_cq02h;
  // Each slot's entries held, so the room is D less it.
  // Per slot, one-hot counts (bit n: n entries): those held, and those
  // allocated and not yet filled. One-hot, the go's late count moves them
  // by a shift, which synthesis cannot fold back into a carry chain.
  localparam int NC = D + 1;
  logic [S*NC-1:0]     och_cq02h, ufh_cq02h;
  // And, registered with it, whether more than j are unfilled (j < A): the
  // fill candidates' enables read it, not the count (CG-2).
  logic [S*A-1:0]      ugt_cq02h;
  // Per entry: the old GPR name frees some section (its gsec nonzero).
  logic [S*D-1:0]      gsn_cq02h;
  // The window's copies that drive the outputs (NGD-7), each (* keep *).
  logic [S*RP-1:0] w_o_cq02h, wg_o_cq02h, wp_o_cq02h, wgf_o_cq02h, wpf_o_cq02h;

  function automatic logic [D-1:0] rotl(input logic [D-1:0] x, input int k);
    logic [D-1:0] r;
    r = x;
    for (int i = 0; i < k; i++) r = {r[D-2:0], r[D-1]};
    rotl = r;
  endfunction

  // -- Retire, from the window ----------------------------------------------------
  // The window's ports retire in order (port k only with every port before
  // it), so a slot's count is its highest port retiring.
  logic [S*LA-1:0] nret_cq02h;                 // per slot, entries retiring
  logic [S*LA-1:0] nret_o_cq02h;               // the same, from the outputs' copy
  always_comb
    for (int s = 0; s < S; s++) begin
      nret_cq02h[s * LA +: LA]   = '0;
      nret_o_cq02h[s * LA +: LA] = '0;
      for (int k = 0; k < RP; k++) begin
        if (w_cq02h[s * RP + k])   nret_cq02h[s * LA +: LA]   = LA'(k + 1);
        if (w_o_cq02h[s * RP + k]) nret_o_cq02h[s * LA +: LA] = LA'(k + 1);
      end
    end
  assign rgl_cq02h     = w_o_cq02h & wg_o_cq02h;
  assign rpl_cq02h     = w_o_cq02h & wp_o_cq02h;
  assign gfree_l_cq02h = |(w_o_cq02h & wgf_o_cq02h);
  assign pfree_l_cq02h = |(w_o_cq02h & wpf_o_cq02h);
  always_comb
    for (int s = 0; s < S; s++) ret_cq02h[s * LT +: LT] = LT'(nret_o_cq02h[s * LA +: LA]);

  // -- Allocation and fill: which entries each writes -----------------------------
  // Allocation: slot s's entries tail .. tail + n - 1, its j-th a no-op by
  // al_nop. Fill: lane l writes its slot's entry wf + (its rank among the
  // lanes of its slot before it).
  logic [S*D-1:0]  al_e_cq02h;
  logic [S*D*A-1:0] fl_e_cq02h;                // entry e takes lane l's fill
  logic [S*LA-1:0] nfl_cq02h;                  // per slot, entries filled
  logic [LA-1:0]   rk_cq02h;
  logic [D-1:0]    sel_cq02h;
  always_comb begin
    al_e_cq02h     = '0;
    sel_cq02h      = '0;
    rk_cq02h       = '0;
    for (int s = 0; s < S; s++)
      for (int j = 0; j < A; j++)
        if (LA'(j) < al_n_cq02h[s * LA +: LA]) begin
          sel_cq02h = rotl(toh_cq02h[s * D +: D], j);
          al_e_cq02h[s * D +: D]     = al_e_cq02h[s * D +: D] | sel_cq02h;
        end
    fl_e_cq02h = '0;
    nfl_cq02h  = '0;
    for (int l = 0; l < A; l++) begin
      rk_cq02h = '0;
      for (int m = 0; m < l; m++)
        if (fl_v_cq02h[m] && fl_slot_cq02h[m * LS +: LS] == fl_slot_cq02h[l * LS +: LS]) rk_cq02h = rk_cq02h + 1'b1;
      if (fl_v_cq02h[l])
        for (int s = 0; s < S; s++)
          if (fl_slot_cq02h[l * LS +: LS] == LS'(s)) begin
            sel_cq02h = '0;
            for (int r = 0; r < A; r++)
              if (rk_cq02h == LA'(r)) sel_cq02h = rotl(woh_cq02h[s * D +: D], r);
            for (int i = 0; i < D; i++) fl_e_cq02h[(s * D + i) * A + l] = sel_cq02h[i];
            nfl_cq02h[s * LA +: LA] = nfl_cq02h[s * LA +: LA] + 1'b1;
          end
    end
  end

  // -- Where an allocation and a fill can land, from flops (CG-5) -----------------
  // An allocation lands on free entries from the tail (cand_al), a fill on
  // its slot's unfilled entries from the fill pointer (cand_fl). Each is a
  // superset, built from this module's flops, so the write enables are; an
  // entry in it that takes nothing this cycle writes don't-care data: free,
  // it is payload under its valid bit, and unfilled, its own fill rewrites
  // every field. The no-op and complete bits an allocation writes need no
  // count (nop_d: lane j's bit at tail + j).
  logic [S*D-1:0] cand_al_cq02h, cand_fl_cq02h, nop_d_cq02h, ufm_cq02h;
  logic [D-1:0]   cw_cq02h;
  always_comb begin
    cand_al_cq02h = '0;
    cand_fl_cq02h = '0;
    ufm_cq02h     = '0;
    nop_d_cq02h   = '0;
    cw_cq02h      = '0;
    for (int s = 0; s < S; s++)
      for (int j = 0; j < A; j++) begin
        cw_cq02h = rotl(toh_cq02h[s * D +: D], j);
        cand_al_cq02h[s * D +: D] = cand_al_cq02h[s * D +: D] | (cw_cq02h & ~v_cq02h[s * D +: D]);
        nop_d_cq02h[s * D +: D]   = nop_d_cq02h[s * D +: D] | (cw_cq02h & {D{al_nop_cq02h[s * A + j]}});
        cand_fl_cq02h[s * D +: D] = cand_fl_cq02h[s * D +: D] | ({D{ugt_cq02h[s * A + j]}} & rotl(woh_cq02h[s * D +: D], j));
      end
    // Every unfilled entry: at most two cycles' allocations (asserted).
    for (int s = 0; s < S; s++)
      for (int r = 0; r < 2 * A; r++)
        if ((ufh_cq02h[s * NC +: NC] >> (r + 1)) != '0)
          ufm_cq02h[s * D +: D] = ufm_cq02h[s * D +: D] | rotl(woh_cq02h[s * D +: D], r);
  end
  // Each entry's fill, lane by lane (none: zeros). A no-op writes nothing.
  logic [S*D-1:0]     fd_kr_cq02h, fd_km_cq02h, fd_gwe_cq02h, fd_pwe_cq02h, fd_pfr_cq02h, fd_gsn_cq02h;
  logic [S*D*2-1:0]   fd_rs_cq02h, fd_pdst_cq02h;
  logic [S*D*4-1:0]   fd_dst_cq02h;
  logic [S*D*GW-1:0]  fd_gname_cq02h, fd_gold_cq02h;
  logic [S*D*NSB-1:0] fd_gsec_cq02h;
  logic [S*D*PW-1:0]  fd_pname_cq02h, fd_pold_cq02h;
  logic               ft_cq02h;
  always_comb begin
    fd_kr_cq02h = '0; fd_km_cq02h = '0; fd_gwe_cq02h = '0; fd_pwe_cq02h = '0; fd_pfr_cq02h = '0;
    fd_gsn_cq02h = '0; fd_rs_cq02h = '0; fd_pdst_cq02h = '0; fd_dst_cq02h = '0; fd_gname_cq02h = '0;
    fd_gold_cq02h = '0; fd_gsec_cq02h = '0; fd_pname_cq02h = '0; fd_pold_cq02h = '0;
    ft_cq02h = 1'b0;
    for (int e = 0; e < S * D; e++)
      for (int l = 0; l < A; l++) begin
        ft_cq02h = fl_e_cq02h[e * A + l];
        fd_kr_cq02h[e]  = fd_kr_cq02h[e]  | (ft_cq02h & ~fl_nop_cq02h[l] & ~fl_mem_cq02h[l]);
        fd_km_cq02h[e]  = fd_km_cq02h[e]  | (ft_cq02h & ~fl_nop_cq02h[l] & fl_mem_cq02h[l]);
        fd_gwe_cq02h[e] = fd_gwe_cq02h[e] | (ft_cq02h & ~fl_nop_cq02h[l] & fl_gwe_cq02h[l]);
        fd_pwe_cq02h[e] = fd_pwe_cq02h[e] | (ft_cq02h & ~fl_nop_cq02h[l] & fl_pwe_cq02h[l]);
        fd_pfr_cq02h[e] = fd_pfr_cq02h[e] | (ft_cq02h & fl_pfree_cq02h[l]);
        fd_gsn_cq02h[e] = fd_gsn_cq02h[e] | (ft_cq02h & (fl_gsec_cq02h[l * NSB +: NSB] != '0));
        fd_rs_cq02h[e * 2 +: 2]       = fd_rs_cq02h[e * 2 +: 2]       | ({2{ft_cq02h}} & fl_rs_cq02h[l * 2 +: 2]);
        fd_pdst_cq02h[e * 2 +: 2]     = fd_pdst_cq02h[e * 2 +: 2]     | ({2{ft_cq02h}} & fl_pdst_cq02h[l * 2 +: 2]);
        fd_dst_cq02h[e * 4 +: 4]      = fd_dst_cq02h[e * 4 +: 4]      | ({4{ft_cq02h}} & fl_dst_cq02h[l * 4 +: 4]);
        fd_gname_cq02h[e * GW +: GW]  = fd_gname_cq02h[e * GW +: GW]  | ({GW{ft_cq02h}} & fl_gname_cq02h[l * GW +: GW]);
        fd_gold_cq02h[e * GW +: GW]   = fd_gold_cq02h[e * GW +: GW]   | ({GW{ft_cq02h}} & fl_gold_cq02h[l * GW +: GW]);
        fd_gsec_cq02h[e * NSB +: NSB] = fd_gsec_cq02h[e * NSB +: NSB] | ({NSB{ft_cq02h}} & fl_gsec_cq02h[l * NSB +: NSB]);
        fd_pname_cq02h[e * PW +: PW]  = fd_pname_cq02h[e * PW +: PW]  | ({PW{ft_cq02h}} & fl_pname_cq02h[l * PW +: PW]);
        fd_pold_cq02h[e * PW +: PW]   = fd_pold_cq02h[e * PW +: PW]   | ({PW{ft_cq02h}} & fl_pold_cq02h[l * PW +: PW]);
      end
  end

  // -- The completion terms' next values ------------------------------------------
  // Each entry's done and completion this cycle, by tag. RCU sends at most
  // one done per rob_tag a cycle (OA's rev 279 (a), a contract on
  // ccv_rcu_ooe_done, asserted below), so an entry's dones owed fall by one
  // or none; MIU's completions are one an entry a cycle already.
  logic [S*D-1:0]    dn_e_cq02h, cm_e_cq02h;
  logic [S*D*NR-1:0] dr_e_cq02h;               // a done for row r of entry e
  always_comb begin
    dn_e_cq02h = '0;
    cm_e_cq02h = '0;
    dr_e_cq02h = '0;
    for (int e = 0; e < S * D; e++) begin
      for (int p = 0; p < ND; p++)
        for (int r = 0; r < NR; r++)
          if (dn_q_cq02h[p] && dn_tag_cq02h[p * TW +: TW] == TW'(e) && dn_row_cq02h[p * 2 +: 2] == 2'(r))
            dr_e_cq02h[e * NR + r] = 1'b1;
      dn_e_cq02h[e] = |dr_e_cq02h[e * NR +: NR];
      for (int p = 0; p < NM; p++)
        if (cm_q_cq02h[p] && cm_tag_cq02h[p * TW +: TW] == TW'(e)) cm_e_cq02h[e] = 1'b1;
    end
  end
  // Each row's count after this cycle is zero: none owed now, and its
  // count is the done it takes (one or none, per row a cycle). From flops
  // and the late done, so the completion term stays an AND-OR of it.
  logic [S*D*NR-1:0] oz_nx_cq02h;
  logic [S*D-1:0]    ozall_cq02h;
  always_comb
    for (int e = 0; e < S * D; e++) begin
      for (int r = 0; r < NR; r++)
        oz_nx_cq02h[e * NR + r] = ~ev_owe_cq02h[e * NR + r] &
            ((oc_cq02h[(e * NR + r) * RCW +: RCW] == '0 & ~dr_e_cq02h[e * NR + r]) |
             (oc_cq02h[(e * NR + r) * RCW +: RCW] == RCW'(1) & dr_e_cq02h[e * NR + r]));
      ozall_cq02h[e] = &oz_nx_cq02h[e * NR +: NR];
    end
  // The retirements: entry e leaves this cycle.
  logic [S*D-1:0] rt_e_cq02h;
  always_comb begin
    rt_e_cq02h = '0;
    for (int s = 0; s < S; s++)
      for (int k = 0; k < RP; k++)
        if (w_cq02h[s * RP + k]) rt_e_cq02h[s * D +: D] = rt_e_cq02h[s * D +: D] | rotl(hoh_cq02h[s * D +: D], k);
  end
  logic [S*D-1:0]    v_nx_cq02h, cmp_nx_cq02h, wr_cq02h;
  logic [S*D-1:0]    cmp_old_cq02h;            // complete at the edge, this cycle's allocations aside
  logic [S*D-1:0]    dn_nx_cq02h, md_nx_cq02h, cp_nx_cq02h;
  logic [S*D*NR*RCW-1:0] oc_nx_cq02h;
  logic [S*D*2-1:0]  rc_nx_cq02h;
  always_comb
    for (int e = 0; e < S * D; e++) begin
      v_nx_cq02h[e]     = al_e_cq02h[e] | (v_cq02h[e] & ~rt_e_cq02h[e]);
      // The completion terms clear as the entry retires, from the window's
      // flops, so a free entry holds none and an allocation (the go's late
      // count) sets only valid and complete (OA's rev 279 (b)); a fill
      // candidate takes its fill (wr). The kind needs no clear: it counts
      // only with a done or a completion, which follow the fill.
      wr_cq02h[e]       = fl_q_cq02h & cand_fl_cq02h[e];
      rc_nx_cq02h[e * 2 +: 2] = rt_e_cq02h[e] ? 2'd0 : wr_cq02h[e] ? fd_rs_cq02h[e * 2 +: 2] :
                                rc_cq02h[e * 2 +: 2] - ev_rsf_cq02h[e * 2 +: 2];
      dn_nx_cq02h[e] = ~rt_e_cq02h[e] & (dn_cq02h[e] | dn_e_cq02h[e]);
      md_nx_cq02h[e] = ~rt_e_cq02h[e] & (md_cq02h[e] | cm_e_cq02h[e]);
      cp_nx_cq02h[e] = ~rt_e_cq02h[e] & ((cp_cq02h[e] & ~ev_cpl_cq02h[e]) | ev_cpi_cq02h[e]);
      for (int r = 0; r < NR; r++)
        oc_nx_cq02h[(e * NR + r) * RCW +: RCW] = rt_e_cq02h[e] ? '0 :
            oc_cq02h[(e * NR + r) * RCW +: RCW] - RCW'(dr_e_cq02h[e * NR + r]) + RCW'(ev_owe_cq02h[e * NR + r]);
      // Complete from the registered kind and count: an entry never
      // completes at its fill's edge (its kind, cleared at the last retire, is
      // neither yet, and no done precedes its fill), so the fill stays off
      // this path. Every row's count reaches zero with this cycle's dones.
      // An entry allocated this cycle was free, so its old terms are none.
      cmp_old_cq02h[e] = v_cq02h[e] & ~rt_e_cq02h[e] & (cmp_q_cq02h[e] |
          (ozall_cq02h[e] &&
           rc_cq02h[e * 2 +: 2] == ev_rsf_cq02h[e * 2 +: 2] &&
           ((kr_cq02h[e] & (dn_cq02h[e] | dn_e_cq02h[e])) |
            (km_cq02h[e] & (md_cq02h[e] | cm_e_cq02h[e]) & ~((cp_cq02h[e] & ~ev_cpl_cq02h[e]) | ev_cpi_cq02h[e])))));
      cmp_nx_cq02h[e] = cand_al_cq02h[e] ? nop_d_cq02h[e] : cmp_old_cq02h[e];
    end

  // -- The pointers and the next window ---------------------------------------------
  // The go's count (its take's 14) and the window's own count select among
  // shifts and rotations formed from flops, each as an AND-OR.
  logic [S*LD-1:0] head_nx_cq02h;
  logic [S*D-1:0]  hoh_nx_cq02h, toh_nx_cq02h, woh_nx_cq02h;
  logic [S*NC-1:0] och_nx_cq02h, ufh_nx_cq02h;
  logic [S*LB-1:0] run_nx_cq02h;
  logic [NC-1:0]   ox_cq02h, ux_cq02h;
  logic [S*A-1:0]  ugt_nx_cq02h;
  logic [S*RP-1:0] w_nx_cq02h, wg_nx_cq02h, wp_nx_cq02h, wgf_nx_cq02h, wpf_nx_cq02h;
  logic [D-1:0]    wk_cq02h;
  logic [D-1:0]    gfe_v_cq02h, pfe_v_cq02h;
  logic            wpr_cq02h, nak_cq02h, mkj_cq02h;
  always_comb
    for (int s = 0; s < S; s++) begin
      wpr_cq02h = 1'b1;                        // every older port of the window retires
      head_nx_cq02h[s * LD +: LD] = rel_q_cq02h[s] ? '0 : head_cq02h[s * LD +: LD] + LD'(nret_cq02h[s * LA +: LA]);
      // The counts: down by this cycle's retirements (held) or fills
      // (unfilled), then up by the go's allocations.
      ox_cq02h = '0;
      for (int k = 0; k < RP + 1; k++)
        ox_cq02h = ox_cq02h | ({NC{nret_cq02h[s * LA +: LA] == LA'(k)}} & (och_cq02h[s * NC +: NC] >> k));
      ux_cq02h = '0;
      for (int k = 0; k < A + 1; k++)
        ux_cq02h = ux_cq02h | ({NC{nfl_cq02h[s * LA +: LA] == LA'(k)}} & (ufh_cq02h[s * NC +: NC] >> k));
      och_nx_cq02h[s * NC +: NC] = '0;
      ufh_nx_cq02h[s * NC +: NC] = '0;
      toh_nx_cq02h[s * D +: D]   = '0;
      for (int j = 0; j < A + 1; j++) begin
        och_nx_cq02h[s * NC +: NC] = och_nx_cq02h[s * NC +: NC] | ({NC{al_n_cq02h[s * LA +: LA] == LA'(j)}} & (ox_cq02h << j));
        ufh_nx_cq02h[s * NC +: NC] = ufh_nx_cq02h[s * NC +: NC] | ({NC{al_n_cq02h[s * LA +: LA] == LA'(j)}} & (ux_cq02h << j));
        toh_nx_cq02h[s * D +: D]   = toh_nx_cq02h[s * D +: D] |
                                     ({D{al_n_cq02h[s * LA +: LA] == LA'(j)}} & rotl(toh_cq02h[s * D +: D], j));
      end
      // More than j unfilled after this cycle: the go's count picks which
      // of the fills' thresholds applies (ux more than j - a, for a count a).
      for (int j = 0; j < A; j++) begin
        ugt_nx_cq02h[s * A + j] = 1'b0;
        for (int a = 0; a < A + 1; a++)
          if (al_n_cq02h[s * LA +: LA] == LA'(a))
            ugt_nx_cq02h[s * A + j] = ugt_nx_cq02h[s * A + j] | (a > j ? 1'b1 : ((ux_cq02h >> (j - a + 1)) != '0));
      end
      hoh_nx_cq02h[s * D +: D] = '0;
      for (int k = 0; k < RP + 1; k++)
        hoh_nx_cq02h[s * D +: D] = hoh_nx_cq02h[s * D +: D] |
                                   ({D{nret_cq02h[s * LA +: LA] == LA'(k)}} & rotl(hoh_cq02h[s * D +: D], k));
      woh_nx_cq02h[s * D +: D] = '0;
      for (int k = 0; k < A + 1; k++)
        woh_nx_cq02h[s * D +: D] = woh_nx_cq02h[s * D +: D] |
                                   ({D{nfl_cq02h[s * LA +: LA] == LA'(k)}} & rotl(woh_cq02h[s * D +: D], k));
      if (rel_q_cq02h[s]) begin
        hoh_nx_cq02h[s * D +: D]   = D'(1);
        toh_nx_cq02h[s * D +: D]   = D'(1);
        och_nx_cq02h[s * NC +: NC] = NC'(1);
        // The fill pointer returns behind the tail by the entries still to
        // fill: u unfilled is entry (D - u) mod D, a wiring of the count.
        woh_nx_cq02h[s * D +: D] = '0;
        for (int u = 0; u < NC; u++)
          woh_nx_cq02h[s * D + (D - u) % D] = woh_nx_cq02h[s * D + (D - u) % D] | ufh_nx_cq02h[s * NC + u];
      end
      // The room: D less the entries held, encoded from the count.
      run_nx_cq02h[s * LB +: LB] = '0;
      for (int u = 0; u < NC; u++)
        run_nx_cq02h[s * LB +: LB] = run_nx_cq02h[s * LB +: LB] | ({LB{och_nx_cq02h[s * NC + u]}} & LB'(D - u));
      // The write bits an entry completing at this edge reads are its
      // fill's, a cycle or more before (a no-op's are none). An entry not
      // yet filled (a no-op retires before its fill lands) or free at the
      // cycle's start (allocated in it) holds an older entry's: masked.
      gfe_v_cq02h = gwe_cq02h[s * D +: D] & v_cq02h[s * D +: D] & ~ufm_cq02h[s * D +: D];
      pfe_v_cq02h = pwe_cq02h[s * D +: D] & v_cq02h[s * D +: D] & ~ufm_cq02h[s * D +: D];
      for (int k = 0; k < RP; k++) begin
        wk_cq02h = rotl(hoh_nx_cq02h[s * D +: D], k);
        // This cycle's allocations reach the window apart from the entries
        // (the go's take arrives late, OA's rev 279 (b)): which allocation
        // lane lands on port k is known from the pointers (one lane at
        // most), and al_nop is zero past the count, so the count itself
        // stays out. An allocated no-op is complete at once.
        nak_cq02h = 1'b0;
        for (int j = 0; j < A; j++) begin
          mkj_cq02h = |(rotl(toh_cq02h[s * D +: D], j) & wk_cq02h);
          nak_cq02h = nak_cq02h | (mkj_cq02h & al_nop_cq02h[s * A + j]);
        end
        w_nx_cq02h[s * RP + k]   = ((|(wk_cq02h & cmp_old_cq02h[s * D +: D])) | nak_cq02h) && wpr_cq02h;
        wpr_cq02h                = w_nx_cq02h[s * RP + k];
        wg_nx_cq02h[s * RP + k]  = |(wk_cq02h & gfe_v_cq02h);
        wgf_nx_cq02h[s * RP + k] = |(wk_cq02h & gfe_v_cq02h & gsn_cq02h[s * D +: D]);
        wp_nx_cq02h[s * RP + k]  = |(wk_cq02h & pfe_v_cq02h);
        wpf_nx_cq02h[s * RP + k] = |(wk_cq02h & pfe_v_cq02h & pfr_cq02h[s * D +: D]);
      end
    end

  // -- The room ------------------------------------------------------------------
  // Entries are held head to tail without a hole, so the free run from the
  // tail is D less those held and always reaches the head.
  assign reach_cq02h = '1;

  // -- The registers ---------------------------------------------------------------
  // Each slot's state is clocked on its own leads and flops: an allocation,
  // a fill where it has unfilled entries, an RS event, a done or a
  // completion where it has an entry waiting for one, a retirement (its
  // window) or a release, split by what each changes.
  logic [S-1:0] wt_cq02h;                      // an entry valid and not complete
  logic [S-1:0] ptr_en_cq02h, tl_en_cq02h, fp_en_cq02h, cm_en_cq02h, win_en_cq02h;
  always_comb
    for (int s = 0; s < S; s++) begin
      wt_cq02h[s]     = |(v_cq02h[s * D +: D] & ~cmp_q_cq02h[s * D +: D]);
      ptr_en_cq02h[s] = al_q_cq02h[s] | (|w_cq02h[s * RP +: RP]) | rel_q_cq02h[s];
      tl_en_cq02h[s]  = al_q_cq02h[s] | rel_q_cq02h[s];
      fp_en_cq02h[s]  = (fl_q_cq02h & ~ufh_cq02h[s * NC]) | al_q_cq02h[s] | rel_q_cq02h[s];
      cm_en_cq02h[s]  = (((|dn_q_cq02h) | (|cm_q_cq02h)) & wt_cq02h[s]) | ev_q_cq02h[s] |
                        (|w_cq02h[s * RP +: RP]) | (fl_q_cq02h & ~ufh_cq02h[s * NC]) | al_q_cq02h[s];
      win_en_cq02h[s] = ptr_en_cq02h[s] | fp_en_cq02h[s] | cm_en_cq02h[s];
    end
  for (genvar gs = 0; gs < S; gs++) begin : g_slot
    always_ff @(posedge ooe_core_clk) begin
      if (rst_r01h) begin
        v_cq02h[gs * D +: D]            <= '0;
        head_cq02h[gs * LD +: LD]       <= '0;
        och_cq02h[gs * NC +: NC]        <= NC'(1);
        run_cq02h[gs * LB +: LB]        <= LB'(D);
        hoh_cq02h[gs * D +: D]          <= D'(1);
      end else if (ptr_en_cq02h[gs]) begin
        v_cq02h[gs * D +: D]            <= v_nx_cq02h[gs * D +: D];
        head_cq02h[gs * LD +: LD]       <= head_nx_cq02h[gs * LD +: LD];
        och_cq02h[gs * NC +: NC]        <= och_nx_cq02h[gs * NC +: NC];
        run_cq02h[gs * LB +: LB]        <= run_nx_cq02h[gs * LB +: LB];
        hoh_cq02h[gs * D +: D]          <= hoh_nx_cq02h[gs * D +: D];
      end
    end
    always_ff @(posedge ooe_core_clk) begin
      if (rst_r01h)                toh_cq02h[gs * D +: D] <= D'(1);
      else if (tl_en_cq02h[gs])    toh_cq02h[gs * D +: D] <= toh_nx_cq02h[gs * D +: D];
    end
    always_ff @(posedge ooe_core_clk) begin
      if (rst_r01h) begin
        ufh_cq02h[gs * NC +: NC]        <= NC'(1);
        ugt_cq02h[gs * A +: A]          <= '0;
        woh_cq02h[gs * D +: D]          <= D'(1);
      end else if (fp_en_cq02h[gs]) begin
        ufh_cq02h[gs * NC +: NC]        <= ufh_nx_cq02h[gs * NC +: NC];
        ugt_cq02h[gs * A +: A]          <= ugt_nx_cq02h[gs * A +: A];
        woh_cq02h[gs * D +: D]          <= woh_nx_cq02h[gs * D +: D];
      end
    end
    // The completion terms: reset, and cleared as their entry retires, so
    // a free entry holds none; complete, payload under the valid bits.
    always_ff @(posedge ooe_core_clk) begin
      if (cm_en_cq02h[gs]) cmp_q_cq02h[gs * D +: D] <= cmp_nx_cq02h[gs * D +: D];
    end
    always_ff @(posedge ooe_core_clk) begin
      if (rst_r01h) begin
        dn_cq02h[gs * D +: D]           <= '0;
        md_cq02h[gs * D +: D]           <= '0;
        cp_cq02h[gs * D +: D]           <= '0;
        oc_cq02h[gs * D * NR * RCW +: D * NR * RCW] <= '0;
        rc_cq02h[gs * D * 2 +: D * 2]   <= '0;
      end else if (cm_en_cq02h[gs]) begin
        dn_cq02h[gs * D +: D]           <= dn_nx_cq02h[gs * D +: D];
        md_cq02h[gs * D +: D]           <= md_nx_cq02h[gs * D +: D];
        cp_cq02h[gs * D +: D]           <= cp_nx_cq02h[gs * D +: D];
        oc_cq02h[gs * D * NR * RCW +: D * NR * RCW] <= oc_nx_cq02h[gs * D * NR * RCW +: D * NR * RCW];
        rc_cq02h[gs * D * 2 +: D * 2]   <= rc_nx_cq02h[gs * D * 2 +: D * 2];
      end
    end
    // The window and its copies, on everything its next value reads: the
    // slot's own registers, so every flow counts one gate a slot.
    (* keep *) logic [RP-1:0] w_s_cq02h, wg_s_cq02h, wp_s_cq02h, wgf_s_cq02h, wpf_s_cq02h;
    (* keep *) logic [RP-1:0] w_so_cq02h, wg_so_cq02h, wp_so_cq02h, wgf_so_cq02h, wpf_so_cq02h;
    always_ff @(posedge ooe_core_clk) begin
      if (rst_r01h) begin
        w_s_cq02h    <= '0;
        wg_s_cq02h   <= '0;
        wp_s_cq02h   <= '0;
        wgf_s_cq02h  <= '0;
        wpf_s_cq02h  <= '0;
        w_so_cq02h   <= '0;
        wg_so_cq02h  <= '0;
        wp_so_cq02h  <= '0;
        wgf_so_cq02h <= '0;
        wpf_so_cq02h <= '0;
      end else if (win_en_cq02h[gs]) begin
        w_s_cq02h    <= w_nx_cq02h[gs * RP +: RP];
        wg_s_cq02h   <= wg_nx_cq02h[gs * RP +: RP];
        wp_s_cq02h   <= wp_nx_cq02h[gs * RP +: RP];
        wgf_s_cq02h  <= wgf_nx_cq02h[gs * RP +: RP];
        wpf_s_cq02h  <= wpf_nx_cq02h[gs * RP +: RP];
        w_so_cq02h   <= w_nx_cq02h[gs * RP +: RP];
        wg_so_cq02h  <= wg_nx_cq02h[gs * RP +: RP];
        wp_so_cq02h  <= wp_nx_cq02h[gs * RP +: RP];
        wgf_so_cq02h <= wgf_nx_cq02h[gs * RP +: RP];
        wpf_so_cq02h <= wpf_nx_cq02h[gs * RP +: RP];
      end
    end
    assign w_cq02h[gs * RP +: RP]     = w_s_cq02h;
    assign wg_cq02h[gs * RP +: RP]    = wg_s_cq02h;
    assign wp_cq02h[gs * RP +: RP]    = wp_s_cq02h;
    assign wgf_cq02h[gs * RP +: RP]   = wgf_s_cq02h;
    assign wpf_cq02h[gs * RP +: RP]   = wpf_s_cq02h;
    assign w_o_cq02h[gs * RP +: RP]   = w_so_cq02h;
    assign wg_o_cq02h[gs * RP +: RP]  = wg_so_cq02h;
    assign wp_o_cq02h[gs * RP +: RP]  = wp_so_cq02h;
    assign wgf_o_cq02h[gs * RP +: RP] = wgf_so_cq02h;
    assign wpf_o_cq02h[gs * RP +: RP] = wpf_so_cq02h;
  end
  // Each entry's fields, clocked on a fill candidate (CG-5: from this
  // module's flops). Payload: the window reads the write bits only of a
  // valid, filled entry.
  logic [S*D-1:0] fd_en_cq02h;
  assign fd_en_cq02h = wr_cq02h;
  for (genvar ge = 0; ge < S * D; ge++) begin : g_ent
    always_ff @(posedge ooe_core_clk) begin
      if (fd_en_cq02h[ge]) begin
        gwe_cq02h[ge]               <= fd_gwe_cq02h[ge];
        pwe_cq02h[ge]               <= fd_pwe_cq02h[ge];
        kr_cq02h[ge]                <= fd_kr_cq02h[ge];
        km_cq02h[ge]                <= fd_km_cq02h[ge];
        gsn_cq02h[ge]               <= fd_gsn_cq02h[ge];
        pfr_cq02h[ge]               <= fd_pfr_cq02h[ge];
        dst_cq02h[ge * 4 +: 4]      <= fd_dst_cq02h[ge * 4 +: 4];
        gname_cq02h[ge * GW +: GW]  <= fd_gname_cq02h[ge * GW +: GW];
        gold_cq02h[ge * GW +: GW]   <= fd_gold_cq02h[ge * GW +: GW];
        gsec_cq02h[ge * NSB +: NSB] <= fd_gsec_cq02h[ge * NSB +: NSB];
        pdst_cq02h[ge * 2 +: 2]     <= fd_pdst_cq02h[ge * 2 +: 2];
        pname_cq02h[ge * PW +: PW]  <= fd_pname_cq02h[ge * PW +: PW];
        pold_cq02h[ge * PW +: PW]   <= fd_pold_cq02h[ge * PW +: PW];
      end
    end
  end
  // -- The retire-stage register ----------------------------------------------------
  // What each retiring entry commits and frees, read through the head, and
  // the frees decoded to the free lists' masks; clocked while the window
  // retires or last did (to clear it).
  logic [S*RP-1:0]    r_gwe_nx_cq02h, r_pwe_nx_cq02h;
  logic [S*RP*4-1:0]  r_dst_nx_cq02h;
  logic [S*RP*GW-1:0] r_gname_nx_cq02h;
  logic [S*RP*2-1:0]  r_pdst_nx_cq02h;
  logic [S*RP*PW-1:0] r_pname_nx_cq02h;
  logic [NG*NSB-1:0]  gfree_nx_cq02h;
  logic [NP-1:0]      pfree_nx_cq02h;
  logic [LD-1:0]      hi_cq02h;
  logic [GR-1:0]      grow_cq02h;
  always_comb begin
    gfree_nx_cq02h = '0;
    pfree_nx_cq02h = '0;
    for (int s = 0; s < S; s++)
      for (int k = 0; k < RP; k++) begin
        hi_cq02h = head_cq02h[s * LD +: LD] + LD'(k);
        r_gwe_nx_cq02h[s * RP + k]               = rgl_cq02h[s * RP + k];
        r_pwe_nx_cq02h[s * RP + k]               = rpl_cq02h[s * RP + k];
        r_dst_nx_cq02h[(s * RP + k) * 4 +: 4]    = dst_cq02h[(s * D + 32'(hi_cq02h)) * 4 +: 4];
        r_gname_nx_cq02h[(s * RP + k) * GW +: GW] = gname_cq02h[(s * D + 32'(hi_cq02h)) * GW +: GW];
        r_pdst_nx_cq02h[(s * RP + k) * 2 +: 2]   = pdst_cq02h[(s * D + 32'(hi_cq02h)) * 2 +: 2];
        r_pname_nx_cq02h[(s * RP + k) * PW +: PW] = pname_cq02h[(s * D + 32'(hi_cq02h)) * PW +: PW];
        grow_cq02h = gold_cq02h[(s * D + 32'(hi_cq02h)) * GW + (GW - GR) +: GR];
        if (w_cq02h[s * RP + k] && wgf_cq02h[s * RP + k])
          for (int r = 0; r < NG; r++)
            if (grow_cq02h == GR'(r))
              gfree_nx_cq02h[r * NSB +: NSB] = gfree_nx_cq02h[r * NSB +: NSB] | gsec_cq02h[(s * D + 32'(hi_cq02h)) * NSB +: NSB];
        if (w_cq02h[s * RP + k] && wpf_cq02h[s * RP + k])
          for (int p = 0; p < NP; p++)
            if (pold_cq02h[(s * D + 32'(hi_cq02h)) * PW +: PW] == PW'(p)) pfree_nx_cq02h[p] = 1'b1;
      end
  end
  // The write bits clock while the window retires or last did (to clear
  // them); the fields, payload under them, only as it retires; the free
  // masks as it frees or last did.
  logic rb_en_cq02h, rf_en_cq02h, rm_en_cq02h, r_live_cq03h, m_live_cq03h;
  assign rf_en_cq02h = |w_cq02h;
  assign rb_en_cq02h = rf_en_cq02h | r_live_cq03h;
  assign rm_en_cq02h = (|(w_cq02h & (wgf_cq02h | wpf_cq02h))) | m_live_cq03h;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      r_live_cq03h <= 1'b0;
      m_live_cq03h <= 1'b0;
    end else begin
      r_live_cq03h <= rf_en_cq02h;
      m_live_cq03h <= |(w_cq02h & (wgf_cq02h | wpf_cq02h));
    end
  end
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      ret_gwe_cq03h <= '0;
      ret_pwe_cq03h <= '0;
    end else if (rb_en_cq02h) begin
      ret_gwe_cq03h <= r_gwe_nx_cq02h;
      ret_pwe_cq03h <= r_pwe_nx_cq02h;
    end
  end
  always_ff @(posedge ooe_core_clk) begin
    if (rf_en_cq02h) begin
      ret_dst_cq03h   <= r_dst_nx_cq02h;
      ret_gname_cq03h <= r_gname_nx_cq02h;
      ret_pdst_cq03h  <= r_pdst_nx_cq02h;
      ret_pname_cq03h <= r_pname_nx_cq02h;
    end
  end
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      gfree_cq03h <= '0;
      pfree_cq03h <= '0;
    end else if (rm_en_cq02h) begin
      gfree_cq03h <= gfree_nx_cq02h;
      pfree_cq03h <= pfree_nx_cq02h;
    end
  end

  // -- Checks -----------------------------------------------------------------------
  // V-58's count never underflows, and an entry retires with it at zero and
  // no done owed (OA's rev 277 (b)); a done names an entry that owes one.
  logic [S*D-1:0] rc_uf_cq02h, ow_uf_cq02h, ow_of_cq02h, rt_bad_cq02h;
  always_comb
    for (int e = 0; e < S * D; e++) begin
      rc_uf_cq02h[e]  = v_cq02h[e] && !al_e_cq02h[e] && rc_cq02h[e * 2 +: 2] < ev_rsf_cq02h[e * 2 +: 2];
      ow_uf_cq02h[e]  = 1'b0;
      ow_of_cq02h[e]  = 1'b0;
      for (int r = 0; r < NR; r++) begin
        if (v_cq02h[e] && !al_e_cq02h[e] && dr_e_cq02h[e * NR + r] && !ev_owe_cq02h[e * NR + r] &&
            oc_cq02h[(e * NR + r) * RCW +: RCW] == '0) ow_uf_cq02h[e] = 1'b1;
        if (ev_owe_cq02h[e * NR + r] && !dr_e_cq02h[e * NR + r] && oc_cq02h[(e * NR + r) * RCW +: RCW] == '1)
          ow_of_cq02h[e] = 1'b1;
      end
      rt_bad_cq02h[e] = rt_e_cq02h[e] && (rc_cq02h[e * 2 +: 2] != 2'd0 || oc_cq02h[e * NR * RCW +: NR * RCW] != '0);
    end
  `CCV_ASSERT(rs_count_no_underflow, rc_uf_cq02h == '0)
  `CCV_ASSERT(owed_no_underflow, ow_uf_cq02h == '0)
  `CCV_ASSERT(owed_no_overflow, ow_of_cq02h == '0)
  `CCV_ASSERT(retire_with_nothing_owed, rt_bad_cq02h == '0)
  // RCU's contract (OA's rev 282): at most one done per rob_tag and row a
  // cycle, so each row's count falls by one or none.
  logic [ND-1:0] dn_two_cq02h;
  always_comb
    for (int p = 0; p < ND; p++) begin
      dn_two_cq02h[p] = 1'b0;
      for (int m = 0; m < p; m++)
        if (dn_q_cq02h[p] && dn_q_cq02h[m] && dn_tag_cq02h[p * TW +: TW] == dn_tag_cq02h[m * TW +: TW] &&
            dn_row_cq02h[p * 2 +: 2] == dn_row_cq02h[m * 2 +: 2]) dn_two_cq02h[p] = 1'b1;
    end
  `CCV_ASSERT(one_done_per_row, dn_two_cq02h == '0)
  // The go's no-op bits are zero past its count (the window reads them
  // without it), and at most two cycles' allocations wait for their fill.
  logic [S-1:0] nop_past_cq02h, uf_over_cq02h;
  always_comb
    for (int s = 0; s < S; s++) begin
      nop_past_cq02h[s] = 1'b0;
      for (int j = 0; j < A; j++)
        if (LA'(j) >= al_n_cq02h[s * LA +: LA] && al_nop_cq02h[s * A + j]) nop_past_cq02h[s] = 1'b1;
      uf_over_cq02h[s] = (ufh_cq02h[s * NC +: NC] >> (2 * A + 1)) != '0;
    end
  `CCV_ASSERT(nop_within_count, nop_past_cq02h == '0)
  `CCV_ASSERT(unfilled_bounded, uf_over_cq02h == '0)
  logic [S*A-1:0] ugt_chk_cq02h;
  always_comb
    for (int s = 0; s < S; s++)
      for (int j = 0; j < A; j++)
        ugt_chk_cq02h[s * A + j] = ugt_cq02h[s * A + j] != ((ufh_cq02h[s * NC +: NC] >> (j + 1)) != '0);
  `CCV_ASSERT(unfilled_threshold, ugt_chk_cq02h == '0)
  // Allocation never overruns a slot (rename's go holds its room).
  logic [S-1:0] al_over_cq02h;
  always_comb
    for (int s = 0; s < S; s++)
      al_over_cq02h[s] = al_n_cq02h[s * LA +: LA] != '0 && (LB + 1)'(al_n_cq02h[s * LA +: LA]) > {1'b0, run_cq02h[s * LB +: LB]} +
                         (LB + 1)'(reach_cq02h[s] ? nret_cq02h[s * LA +: LA] : '0);
  `CCV_ASSERT(alloc_within_room, al_over_cq02h == '0)
endmodule
`undef CCV_CLK
`undef CCV_RST
