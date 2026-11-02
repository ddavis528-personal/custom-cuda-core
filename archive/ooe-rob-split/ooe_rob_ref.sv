//===-- ooe_rob_ref.sv - the ROB before the split, frozen for its miter ----===//
//
// The single ooe_rob of 917752b (slices 1 and 2), renamed: the reference
// archive/ooe-rob-split/fv_rob_split.sv holds the four ooe_rob_w and their OR against
// (OA-24 (a), OA rev 312). Never edited: it is what the split must equal.
// What follows is that file's own description.
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
module ooe_rob_ref #(
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
  parameter int NK = 4,                  // branch checkpoints a slot (CCV_P_BR_CKPTS)
  parameter int PCW = 48,                // a pc
  parameter int BS = ND - 2,             // the done slot RCU-only ops complete on, branches among them (AR's RCU spec rev 14, OA rev 287)
  localparam int NSB = (NS > 0) ? NS : 1,
  localparam int LS = (S > 1) ? $clog2(S) : 1,
  localparam int LD = $clog2(D),
  localparam int TW = LS + LD,           // a rob_tag
  localparam int LA = $clog2(A + 1),
  localparam int LK = (NK > 1) ? $clog2(NK) : 1,
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
  input  logic                fl_brl_cq01h,    // a branch among next cycle's fills (the records' lead)
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
  // A branch's fill (slice 2): its checkpoint and the record its resolution
  // reads: the prediction, its group's lanes, the fall-through and taken
  // targets, a ret's pc[47:32].
  input  logic [A-1:0]        fl_br_cq02h,
  input  logic [A*LK-1:0]     fl_ckpt_cq02h,
  input  logic [A-1:0]        fl_ptaken_cq02h,
  input  logic [A-1:0]        fl_ret_cq02h,
  input  logic [A*32-1:0]     fl_gmask_cq02h,
  input  logic [A*PCW-1:0]    fl_pcn_cq02h,
  input  logic [A*PCW-1:0]    fl_tgt_cq02h,
  input  logic [A*16-1:0]     fl_pchi_cq02h,
  // What a squash frees and discards (slice 2 part b): the sections the new
  // GPR name holds, whether a predicate name was allocated, a store.
  input  logic [A*NSB-1:0]    fl_gnsec_cq02h,
  input  logic [A-1:0]        fl_palloc_cq02h,
  input  logic [A-1:0]        fl_store_cq02h,
  // The RS's events, decoded per entry (bit s * D + i): an issue owing RCU a
  // done (per row, bit (s * D + i) * NR + r), a copy issued, a copy landed,
  // and how many of its RS entries freed. Each slot's lead: some event next
  // cycle.
  input  logic [S-1:0]        ev_l_cq01h,
  input  logic [S*D*NR-1:0]   ev_owe_cq02h,
  input  logic [S*D-1:0]      ev_cpi_cq02h,
  input  logic [S*D-1:0]      ev_cpl_cq02h,
  input  logic [S*D*2-1:0]    ev_rsf_cq02h,
  input  logic [S*D-1:0]      ev_miu_cq02h,    // a memop sent to MIU (at MIU until its completion)
  // RCU's dones and MIU's completions, by rob_tag; the channels' valid
  // leads their payload by a cycle (OA's response OI-58, L1).
  input  logic [ND-1:0]       dn_l_cq01h,
  input  logic [ND*TW-1:0]    dn_tag_cq02h,
  input  logic [ND*2-1:0]     dn_row_cq02h,    // the row each completes (OA's rev 282)
  // The branch outcome, on done slot BS: taken, the lanes that took it, a
  // ret's target offset.
  input  logic                dn_taken_cq02h,
  input  logic [31:0]         dn_mask_cq02h,
  input  logic [31:0]         dn_aux_cq02h,
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
  output logic [S*LT-1:0]     ret_cq02h,
  // Resolution (slice 2, OI-86 (a)): per slot, a mispredict resolved last
  // cycle, the redirect's lead; and the checkpoints right branches free.
  output logic [S-1:0]        rd_l_cq03h,
  output logic [S*NK-1:0]     ckf_cq03h,
  // The redirect, a cycle after its lead: the checkpoint, the lanes that
  // took the branch, the target, a ret's stay.
  output logic [S*LK-1:0]     rd_ckpt_cq04h,
  output logic [S*32-1:0]     rd_tmask_cq04h,
  output logic [S*PCW-1:0]    rd_tgt_cq04h,
  output logic [S-1:0]        rd_stay_cq04h,
  // A squash's bulk discard (A-41, A-53), when it takes a store at MIU:
  // per slot, the branch's index and the youngest allocated entry's.
  output logic [S-1:0]        dc_v_cq03h,
  output logic [S*LD-1:0]     dc_br_cq03h,
  output logic [S*LD-1:0]     dc_disp_cq03h
);
  logic rst_r01h;
  always_ff @(posedge ooe_core_clk) begin
    rst_r01h <= ooe_rst_r00h;
  end

  // -- The leads, flopped: each slot's state is clocked on them (CG-5) --------
  logic [S-1:0] al_q_cq02h, ev_q_cq02h, rel_q_cq02h;
  logic         fl_q_cq02h, fb_q_cq02h;
  logic [ND-1:0] dn_q_cq02h;                  // each port's valid
  logic [NM-1:0] cm_q_cq02h;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      al_q_cq02h  <= '0;
      ev_q_cq02h  <= '0;
      rel_q_cq02h <= '0;
      fl_q_cq02h  <= 1'b0;
      fb_q_cq02h  <= 1'b0;
      dn_q_cq02h  <= '0;
      cm_q_cq02h  <= '0;
    end else begin
      al_q_cq02h  <= al_l_cq01h;
      ev_q_cq02h  <= ev_l_cq01h;
      rel_q_cq02h <= rel_l_cq01h;
      fl_q_cq02h  <= fl_l_cq01h;
      fb_q_cq02h  <= fl_brl_cq01h;
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
  logic [S*D-1:0]      gwe_cq02h, pwe_cq02h, pfr_cq02h, br_cq02h;
  logic [S*D*LK-1:0]   ck_cq02h;              // a branch's checkpoint
  logic [S*D*4-1:0]    dst_cq02h;
  logic [S*D*GW-1:0]   gname_cq02h, gold_cq02h;
  logic [S*D*NSB-1:0]  gsec_cq02h;
  logic [S*D*2-1:0]    pdst_cq02h;
  logic [S*D*PW-1:0]   pname_cq02h, pold_cq02h;
  // Slice 2 part b: the new name's sections, a predicate name allocated, a
  // store (fields); at MIU, and held (a squashed entry with an op in flight).
  logic [S*D*NSB-1:0]  gns_cq02h;
  logic [S*D-1:0]      pal_cq02h, st_cq02h, am_cq02h, hd_cq02h;
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
  // A squash's, a held release's and a killed fill's frees join the
  // retirements' (slice 2 part b), each with its own lead from flops: a
  // squash's covers its cycle (a superset: a squash nearly always frees a
  // name), a held release's any cycle after one with an entry held.
  logic sql_o_cq02h, hdl_o_cq02h, kgl_o_cq02h, kpl_o_cq02h;
  assign gfree_l_cq02h = |(w_o_cq02h & wgf_o_cq02h) | sql_o_cq02h | hdl_o_cq02h | kgl_o_cq02h;
  assign pfree_l_cq02h = |(w_o_cq02h & wpf_o_cq02h) | sql_o_cq02h | hdl_o_cq02h | kpl_o_cq02h;
  always_comb
    for (int s = 0; s < S; s++) ret_cq02h[s * LT +: LT] = LT'(nret_o_cq02h[s * LA +: LA]);

  // -- Allocation and fill: which entries each writes -----------------------------
  // Allocation: slot s's entries tail .. tail + n - 1, its j-th a no-op by
  // al_nop. Fill: lane l writes its slot's entry wf + (its rank among the
  // lanes of its slot before it).
  logic [S*D-1:0]  al_e_cq02h;
  logic [S*D*A-1:0] fl_e_cq02h;                // entry e takes lane l's fill
  logic [S*LA-1:0] nfl_cq02h;                  // per slot, fills arriving
  logic [S*LA-1:0] nlv_cq02h;                  // per slot, fills that land (not killed)
  logic [A-1:0]    fk_cq02h;                   // lane l's fill is killed
  logic [LA-1:0]   rk_cq02h;
  logic [D-1:0]    sel_cq02h;
  // The kill count (slice 2 part b, OI-94 (C)): per slot, one-hot, how many
  // of its next fills are for entries a squash took before their fill (at
  // most two cycles' allocations). A squash kills every fill arriving with
  // it and counts those still owed; each is dropped as it lands (its entry
  // is free) and its names go to the free lists through the kill register.
  localparam int KC = 2 * A + 1;
  logic [S*KC-1:0] kc_cq02h;
  // The squash acting (R + 1): rd_s and sp_s are the window's own state at
  // stage 02 (the squash acts on it), rd_q and sq_p their stage-03 copies
  // for the redirect and the discard (CCV-L23; synthesis merges each pair).
  logic [S-1:0]    rd_s_cq02h, rd_q_cq03h, ckfa_s_cq02h;   // ckfa_s: a checkpoint frees (the register's enable)
  (* keep *) logic [S-1:0] rd_o_cq03h;        // its copy for rd_l (NGD-7)
  logic            kl_cq02h;
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
    nlv_cq02h  = '0;
    fk_cq02h   = '0;
    kl_cq02h   = 1'b0;
    for (int l = 0; l < A; l++) begin
      rk_cq02h = '0;
      for (int m = 0; m < l; m++)
        if (fl_v_cq02h[m] && fl_slot_cq02h[m * LS +: LS] == fl_slot_cq02h[l * LS +: LS]) rk_cq02h = rk_cq02h + 1'b1;
      if (fl_v_cq02h[l])
        for (int s = 0; s < S; s++)
          if (fl_slot_cq02h[l * LS +: LS] == LS'(s)) begin
            // Killed: a squash acting now, or its rank under the kill count.
            // A fill that lands goes to the fill pointer plus its rank less
            // the count.
            kl_cq02h = rd_s_cq02h[s];
            sel_cq02h = '0;
            for (int k = 0; k < KC; k++) begin
              if (kc_cq02h[s * KC + k] && 32'(rk_cq02h) < k) kl_cq02h = 1'b1;
              for (int r = 0; r < A; r++)
                if (kc_cq02h[s * KC + k] && 32'(rk_cq02h) == r + k) sel_cq02h = sel_cq02h | rotl(woh_cq02h[s * D +: D], r);
            end
            sel_cq02h = sel_cq02h & {D{~rd_s_cq02h[s]}};
            for (int i = 0; i < D; i++) fl_e_cq02h[(s * D + i) * A + l] = sel_cq02h[i];
            nfl_cq02h[s * LA +: LA] = nfl_cq02h[s * LA +: LA] + 1'b1;
            if (!kl_cq02h) nlv_cq02h[s * LA +: LA] = nlv_cq02h[s * LA +: LA] + 1'b1;
            fk_cq02h[l] = kl_cq02h;
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
  logic [S*D-1:0]     fd_kr_cq02h, fd_km_cq02h, fd_gwe_cq02h, fd_pwe_cq02h, fd_pfr_cq02h, fd_gsn_cq02h, fd_br_cq02h;
  logic [S*D-1:0]     fd_pal_cq02h, fd_st_cq02h;
  logic [S*D*NSB-1:0] fd_gns_cq02h;
  logic [S*D*LK-1:0]  fd_ck_cq02h;
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
    fd_br_cq02h = '0; fd_ck_cq02h = '0; fd_pal_cq02h = '0; fd_st_cq02h = '0; fd_gns_cq02h = '0;
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
        fd_br_cq02h[e]  = fd_br_cq02h[e]  | (ft_cq02h & ~fl_nop_cq02h[l] & fl_br_cq02h[l]);
        fd_pal_cq02h[e] = fd_pal_cq02h[e] | (ft_cq02h & ~fl_nop_cq02h[l] & fl_palloc_cq02h[l]);
        fd_st_cq02h[e]  = fd_st_cq02h[e]  | (ft_cq02h & ~fl_nop_cq02h[l] & fl_store_cq02h[l]);
        fd_gns_cq02h[e * NSB +: NSB]  = fd_gns_cq02h[e * NSB +: NSB]  | ({NSB{ft_cq02h & ~fl_nop_cq02h[l]}} & fl_gnsec_cq02h[l * NSB +: NSB]);
        fd_ck_cq02h[e * LK +: LK] = fd_ck_cq02h[e * LK +: LK] | ({LK{ft_cq02h}} & fl_ckpt_cq02h[l * LK +: LK]);
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
  // -- The squash (slice 2 part b) --------------------------------------------------
  // A mispredict picked at R (the resolution, below) acts at R + 1 from its
  // registers: rd_q, the slot's squash, and sqm, every entry younger than
  // the branch (the pick's prefix at R, and R's allocations). It takes each
  // valid entry there not already held. One with an op in flight (a done
  // owed, at MIU without its completion, a copy in flight) is held, its
  // slot and names kept until the op lands (V-22); a filled one with none
  // frees its new names now; an unfilled one frees its slot now and its
  // names as its fill lands (the kill count). The model squashes ahead of
  // retire, so nothing behind the branch retires first (the window, below).
  logic [S*D-1:0] sqm_cq02h, sp_s_cq02h, sq_p_cq03h;
  logic [S-1:0]   sq_rt_cq02h;                  // the branch retired at R
  logic [S*D-1:0] pfx_cq02h, pick_cq02h, cw_e_cq02h;
  logic [S*D-1:0] sqe_cq02h, outq_cq02h, hds_cq02h, frel_cq02h, krel_cq02h;
  always_comb
    for (int e = 0; e < S * D; e++) begin
      outq_cq02h[e] = (oc_cq02h[e * NR * RCW +: NR * RCW] != '0) | (am_cq02h[e] & ~md_cq02h[e]) | cp_cq02h[e];
      sqe_cq02h[e]  = rd_s_cq02h[e / D] & sqm_cq02h[e] & v_cq02h[e] & ~hd_cq02h[e];
      // An unfilled entry has issued nothing, so owes nothing (asserted,
      // unfilled_owes_none): the held set needs no unfilled mask, which
      // keeps the fill pointer's decode off the room's path (NGD-1).
      hds_cq02h[e]  = sqe_cq02h[e] & outq_cq02h[e];
      frel_cq02h[e] = sqe_cq02h[e] & ~ufm_cq02h[e] & ~outq_cq02h[e];
      krel_cq02h[e] = sqe_cq02h[e] & ufm_cq02h[e];
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
  logic [S*D-1:0]    dn_nx_cq02h, md_nx_cq02h, cp_nx_cq02h, am_nx_cq02h;
  // A held entry is released once its op has landed, with this cycle's
  // events (a squash's own hold among them, as the model releases in the
  // squash's cycle); its names free a cycle later (release_names_lag 1).
  logic [S*D-1:0]    out_nx_cq02h, hrel_e_cq02h, hd_nx_cq02h, rel_e_cq02h;
  logic [S*D*NR*RCW-1:0] oc_nx_cq02h;
  logic [S*D*2-1:0]  rc_nx_cq02h;
  always_comb
    for (int e = 0; e < S * D; e++) begin
      out_nx_cq02h[e]   = ~ozall_cq02h[e] | ((am_cq02h[e] | ev_miu_cq02h[e]) & ~(md_cq02h[e] | cm_e_cq02h[e])) |
                          (cp_cq02h[e] & ~ev_cpl_cq02h[e]) | ev_cpi_cq02h[e];
      hrel_e_cq02h[e]   = (hd_cq02h[e] | hds_cq02h[e]) & ~out_nx_cq02h[e];
      hd_nx_cq02h[e]    = (hd_cq02h[e] | hds_cq02h[e]) & ~hrel_e_cq02h[e];
      // Leaving this cycle: retired, squashed and freed, or a held release.
      rel_e_cq02h[e]    = rt_e_cq02h[e] | frel_cq02h[e] | krel_cq02h[e] | hrel_e_cq02h[e];
      v_nx_cq02h[e]     = al_e_cq02h[e] | (v_cq02h[e] & ~rel_e_cq02h[e]);
      // The completion terms clear as the entry retires, from the window's
      // flops, so a free entry holds none and an allocation (the go's late
      // count) sets only valid and complete (OA's rev 279 (b)); a fill
      // candidate takes its fill (wr). The kind needs no clear: it counts
      // only with a done or a completion, which follow the fill.
      wr_cq02h[e]       = fl_q_cq02h & cand_fl_cq02h[e];
      rc_nx_cq02h[e * 2 +: 2] = rel_e_cq02h[e] ? 2'd0 : wr_cq02h[e] ? fd_rs_cq02h[e * 2 +: 2] :
                                rc_cq02h[e * 2 +: 2] - ev_rsf_cq02h[e * 2 +: 2];
      dn_nx_cq02h[e] = ~rel_e_cq02h[e] & (dn_cq02h[e] | dn_e_cq02h[e]);
      md_nx_cq02h[e] = ~rel_e_cq02h[e] & (md_cq02h[e] | cm_e_cq02h[e]);
      cp_nx_cq02h[e] = ~rel_e_cq02h[e] & ((cp_cq02h[e] & ~ev_cpl_cq02h[e]) | ev_cpi_cq02h[e]);
      am_nx_cq02h[e] = ~rel_e_cq02h[e] & (am_cq02h[e] | ev_miu_cq02h[e]);
      for (int r = 0; r < NR; r++)
        oc_nx_cq02h[(e * NR + r) * RCW +: RCW] = rel_e_cq02h[e] ? '0 :
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
  logic [S-1:0]    reach_nx_cq02h, reach_q_cq02h;
  logic [S*D-1:0]  hrel_q_cq02h;               // the release register (below)
  logic [S*KC-1:0] kc_nx_cq02h;
  logic [S*NC-1:0] uxa_all_cq02h;              // for the kill count's bound (asserted)
  logic [NC-1:0]   ox_cq02h, ux_cq02h, uxa_cq02h, sc_cq02h;
  logic [D-1:0]    hm_cq02h, xr_cq02h, wok_cq02h;
  logic [D:0]      dt_cq02h, rsel_cq02h, mku_cq02h, mkd_cq02h;
  logic [LB-1:0]   r0u_cq02h, r0d_cq02h, rdf_cq02h;
  logic            rsq_cq02h, rcht_cq02h;
  logic [NC-1:0]   ochs_cq02h;                 // a squash's or release's occupancy, without the count
  logic [S*LB-1:0] r0_cq02h;                   // the run before the count (asserted to cover it)
  logic [2*A:0]    ug_cq02h;
  logic [A-1:0]    uxg_cq02h;
  logic [LA-1:0]   nk_cq02h;
  logic            anyp_cq02h;
  logic [S*A-1:0]  ugt_nx_cq02h;
  logic [S*RP-1:0] w_nx_cq02h, wg_nx_cq02h, wp_nx_cq02h, wgf_nx_cq02h, wpf_nx_cq02h;
  logic [D-1:0]    wk_cq02h;
  // The head's thermometer (bit i: the head at or before entry i), a
  // register beside hoh so the resolution's older-than search starts from
  // flops (NGD-1): each retire count's from hoh, picked as hoh_nx is.
  logic [S*D-1:0]  thq_cq02h, th_nx_cq02h;
  logic [D-1:0]    tk_cq02h;
  logic [D-1:0]    gfe_v_cq02h, pfe_v_cq02h;
  logic            wpr_cq02h, nak_cq02h, mkj_cq02h;
  always_comb begin
    // Defaults: every output and temporary assigned on every path.
    {head_nx_cq02h, hoh_nx_cq02h, toh_nx_cq02h, woh_nx_cq02h} = '0;
    {och_nx_cq02h, ufh_nx_cq02h, run_nx_cq02h, reach_nx_cq02h} = '0;
    {kc_nx_cq02h, uxa_all_cq02h, ugt_nx_cq02h} = '0;
    {w_nx_cq02h, wg_nx_cq02h, wp_nx_cq02h, wgf_nx_cq02h, wpf_nx_cq02h} = '0;
    {ox_cq02h, ux_cq02h, uxa_cq02h, sc_cq02h} = '0;
    {hm_cq02h, xr_cq02h, wok_cq02h, wk_cq02h, gfe_v_cq02h, pfe_v_cq02h} = '0;
    {th_nx_cq02h, tk_cq02h} = '0;
    {dt_cq02h, rsel_cq02h, mku_cq02h, mkd_cq02h, nk_cq02h, ug_cq02h, uxg_cq02h} = '0;
    {r0u_cq02h, r0d_cq02h, rdf_cq02h, rsq_cq02h, rcht_cq02h, ochs_cq02h, r0_cq02h} = '0;
    {anyp_cq02h, wpr_cq02h, nak_cq02h, mkj_cq02h} = '0;
    for (int s = 0; s < S; s++) begin
      wpr_cq02h = 1'b1;                        // every older port of the window retires
      sc_cq02h = '0;
      head_nx_cq02h[s * LD +: LD] = rel_q_cq02h[s] ? '0 : head_cq02h[s * LD +: LD] + LD'(nret_cq02h[s * LA +: LA]);
      // The counts: down by this cycle's retirements (held) or fills
      // (unfilled), then up by the go's allocations.
      ox_cq02h = '0;
      for (int k = 0; k < RP + 1; k++)
        ox_cq02h = ox_cq02h | ({NC{nret_cq02h[s * LA +: LA] == LA'(k)}} & (och_cq02h[s * NC +: NC] >> k));
      // Unfilled after the fills that land (a killed one has no entry), and
      // after every fill arriving (a squash's kill count).
      ux_cq02h = '0;
      uxa_cq02h = '0;
      for (int k = 0; k < A + 1; k++) begin
        ux_cq02h  = ux_cq02h  | ({NC{nlv_cq02h[s * LA +: LA] == LA'(k)}} & (ufh_cq02h[s * NC +: NC] >> k));
        uxa_cq02h = uxa_cq02h | ({NC{nfl_cq02h[s * LA +: LA] == LA'(k)}} & (ufh_cq02h[s * NC +: NC] >> k));
      end
      // The kill count less this cycle's kills.
      nk_cq02h = nfl_cq02h[s * LA +: LA] - nlv_cq02h[s * LA +: LA];
      kc_nx_cq02h[s * KC +: KC] = '0;
      for (int n = 0; n < A + 1; n++)
        kc_nx_cq02h[s * KC +: KC] = kc_nx_cq02h[s * KC +: KC] | ({KC{nk_cq02h == LA'(n)}} & (kc_cq02h[s * KC +: KC] >> n));
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
      // ux more than m is ufh more than m + k for this cycle's k landing
      // fills: each threshold from the flopped count, then picked by the
      // fills' count and the go's (both late; NGD-3).
      for (int t = 0; t < 2 * A + 1; t++) ug_cq02h[t] = (ufh_cq02h[s * NC +: NC] >> t) != '0;
      for (int m = 0; m < A; m++) begin
        uxg_cq02h[m] = 1'b0;
        for (int k = 0; k < A + 1; k++)
          uxg_cq02h[m] = uxg_cq02h[m] | ((nlv_cq02h[s * LA +: LA] == LA'(k)) & ug_cq02h[m + k + 1]);
      end
      for (int j = 0; j < A; j++) begin
        ugt_nx_cq02h[s * A + j] = 1'b0;
        for (int a = 0; a < A + 1; a++)
          if (al_n_cq02h[s * LA +: LA] == LA'(a))
            ugt_nx_cq02h[s * A + j] = ugt_nx_cq02h[s * A + j] | (a > j ? 1'b1 : uxg_cq02h[j - a]);
      end
      hoh_nx_cq02h[s * D +: D] = '0;
      th_nx_cq02h[s * D +: D]  = '0;
      for (int k = 0; k < RP + 1; k++) begin
        hoh_nx_cq02h[s * D +: D] = hoh_nx_cq02h[s * D +: D] |
                                   ({D{nret_cq02h[s * LA +: LA] == LA'(k)}} & rotl(hoh_cq02h[s * D +: D], k));
        tk_cq02h = rotl(hoh_cq02h[s * D +: D], k);
        for (int i = 0; i < D; i++)
          th_nx_cq02h[s * D + i] = th_nx_cq02h[s * D + i] |
                                   ((nret_cq02h[s * LA +: LA] == LA'(k)) & (|(tk_cq02h & D'((64'(1) << (i + 1)) - 1))));
      end
      woh_nx_cq02h[s * D +: D] = '0;
      for (int k = 0; k < A + 1; k++)
        woh_nx_cq02h[s * D +: D] = woh_nx_cq02h[s * D +: D] |
                                   ({D{nlv_cq02h[s * LA +: LA] == LA'(k)}} & rotl(woh_cq02h[s * D +: D], k));
      uxa_all_cq02h[s * NC +: NC] = '0;
      if (rd_s_cq02h[s]) begin
        // The squash (no allocation in its cycle, asserted): the tail and
        // the fill pointer to the branch + 1; held, the entries from the
        // head through the branch (none once it has retired), less this
        // cycle's retirements; nothing unfilled, and the fills still owed
        // counted to be killed.
        toh_nx_cq02h[s * D +: D] = rotl(sp_s_cq02h[s * D +: D], 1);
        woh_nx_cq02h[s * D +: D] = rotl(sp_s_cq02h[s * D +: D], 1);
        ufh_nx_cq02h[s * NC +: NC] = NC'(1);
        ugt_nx_cq02h[s * A +: A] = '0;
        kc_nx_cq02h[s * KC +: KC] = uxa_cq02h[KC-1:0];
        uxa_all_cq02h[s * NC +: NC] = uxa_cq02h;
        sc_cq02h = '0;
        for (int k = 1; k < NC; k++)
          sc_cq02h[k] = |(hoh_cq02h[s * D +: D] & rotl(sp_s_cq02h[s * D +: D], (D - (k - 1)) % D));   // entry h + k - 1
        if (sq_rt_cq02h[s]) sc_cq02h = NC'(1);
        och_nx_cq02h[s * NC +: NC] = '0;
        for (int k = 0; k < RP + 1; k++)
          och_nx_cq02h[s * NC +: NC] = och_nx_cq02h[s * NC +: NC] | ({NC{nret_cq02h[s * LA +: LA] == LA'(k)}} & (sc_cq02h >> k));
        ochs_cq02h = och_nx_cq02h[s * NC +: NC];
      end
      if (rel_q_cq02h[s]) begin
        hoh_nx_cq02h[s * D +: D]   = D'(1);
        th_nx_cq02h[s * D +: D]    = '1;
        toh_nx_cq02h[s * D +: D]   = D'(1);
        och_nx_cq02h[s * NC +: NC] = NC'(1);
        ochs_cq02h = NC'(1);
        // The fill pointer returns behind the tail by the entries still to
        // fill: u unfilled is entry (D - u) mod D, a wiring of the count.
        woh_nx_cq02h[s * D +: D] = '0;
        for (int u = 0; u < NC; u++)
          woh_nx_cq02h[s * D + (D - u) % D] = woh_nx_cq02h[s * D + (D - u) % D] | ufh_nx_cq02h[s * NC + u];
      end
      // The room: with no held entry, D less the entries held, encoded from
      // the count. With held entries (squashed, an op in flight, in the free
      // region past the tail), the run from the next tail to the first of
      // them, which never reaches the head. A held entry released this cycle
      // still counts (the model's held_room_lag 1), and so does one the
      // squash holds now; all from flops. The run from the tail, one-hot (bit
      // k: k free entries), then less the go's late count; a squash's from
      // the branch + 1.
      // Outside a squash's cycle the squash holds nothing (hds is gated by
      // its register), so the run from the tail reads the held flops alone.
      hm_cq02h = hd_cq02h[s * D +: D] | hds_cq02h[s * D +: D];
      reach_nx_cq02h[s] = ~|hm_cq02h;
      rcht_cq02h = ~|hd_cq02h[s * D +: D];
      for (int k = 0; k < D; k++) begin
        xr_cq02h[k] = |(rotl(toh_cq02h[s * D +: D], k) & hd_cq02h[s * D +: D]);
      end
      dt_cq02h = '0;
      for (int k = 0; k < D; k++) begin
        dt_cq02h[k] = xr_cq02h[k] & ~|(xr_cq02h & D'((64'(1) << k) - 1));
      end
      if (rel_q_cq02h[s]) reach_nx_cq02h[s] = 1'b1;
      // The run from flops alone, from the tail before this cycle's
      // allocation (a squash's or a release's from the branch + 1, with no
      // allocation, asserted), one-hot to binary as balanced ORs (ABC keeps
      // an accumulating loop's chain); then less the go's count, which
      // arrives late (al_n, NGD-3) and so enters only the subtract. Exact:
      // the go allocates from the tail within the room, so the run from the
      // next tail is the run less the count (never below it, asserted; the
      // borrow reads 0 as the encoding of a shifted-out run would).
      // A squash's or a release's run from flops alone (no allocation,
      // asserted): reaching the head, the occupancy's (a release's is D);
      // holding entries, 0 for a cycle (the model's squash_held_room_lag 1),
      // the run then read from the held flops the cycle after, its enable
      // the held entries. Otherwise the tail's, less the count.
      rsq_cq02h = rd_s_cq02h[s] | rel_q_cq02h[s];
      // From the tail with held entries, the first one's offset (dt, from
      // the held flops); reaching the head, D less the occupancy (ox; a
      // squash's or a release's, ochs), whose terms are flops only. With no
      // held entry dt is 0, so the two meet in an OR, not a mux.
      rsel_cq02h = rsq_cq02h ? ochs_cq02h : ox_cq02h;
      for (int b = 0; b < LB; b++) begin
        for (int u = 0; u < NC; u++) begin
          mku_cq02h[u] = ((u >> b) & 1) != 0;
          mkd_cq02h[u] = (((D - u) >> b) & 1) != 0;
        end
        r0u_cq02h[b] = |(dt_cq02h & mku_cq02h);
        r0d_cq02h[b] = |(rsel_cq02h & mkd_cq02h);
      end
      r0_cq02h[s * LB +: LB] = r0u_cq02h | ({LB{rcht_cq02h}} & r0d_cq02h);
      rdf_cq02h = r0_cq02h[s * LB +: LB] - LB'(al_n_cq02h[s * LA +: LA]);
      run_nx_cq02h[s * LB +: LB] = rsq_cq02h ? ({LB{reach_nx_cq02h[s]}} & r0d_cq02h) : rdf_cq02h;
      // The write bits an entry completing at this edge reads are its
      // fill's, a cycle or more before (a no-op's are none). An entry not
      // yet filled (a no-op retires before its fill lands) or free at the
      // cycle's start (allocated in it) holds an older entry's: masked.
      // What the next window may take: nothing younger than a mispredict
      // picked now or squashing now, and no held entry; no allocation now
      // either when there is a pick (it is younger).
      wok_cq02h  = ~pfx_cq02h[s * D +: D] & ~({D{rd_s_cq02h[s]}} & sqm_cq02h[s * D +: D]) & ~hd_cq02h[s * D +: D];
      anyp_cq02h = |cw_e_cq02h[s * D +: D];
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
          nak_cq02h = nak_cq02h | (mkj_cq02h & al_nop_cq02h[s * A + j] & ~anyp_cq02h);
        end
        w_nx_cq02h[s * RP + k]   = ((|(wk_cq02h & cmp_old_cq02h[s * D +: D] & wok_cq02h)) | nak_cq02h) && wpr_cq02h;
        // A branch ends its window (the model's branch_ends_window under
        // resolve_lag): nothing younger retires beside it before its
        // resolution acts. Its bit is a filled entry's field (a no-op is no
        // branch).
        wpr_cq02h                = w_nx_cq02h[s * RP + k] && !(|(wk_cq02h & br_cq02h[s * D +: D] &
                                   v_cq02h[s * D +: D] & ~ufm_cq02h[s * D +: D]));
        wg_nx_cq02h[s * RP + k]  = |(wk_cq02h & gfe_v_cq02h);
        wgf_nx_cq02h[s * RP + k] = |(wk_cq02h & gfe_v_cq02h & gsn_cq02h[s * D +: D]);
        wp_nx_cq02h[s * RP + k]  = |(wk_cq02h & pfe_v_cq02h);
        wpf_nx_cq02h[s * RP + k] = |(wk_cq02h & pfe_v_cq02h & pfr_cq02h[s * D +: D]);
      end
    end
  end

  // -- The room ------------------------------------------------------------------
  // Without held entries the free run from the tail reaches the head; with
  // them, it stops at the first (registered with the run).
  assign reach_cq02h = reach_q_cq02h;

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
      // A squash and a held entry move them too, and the cycle after its
      // release (the room then reaches the head), and a kill count waiting
      // for its fills.
      ptr_en_cq02h[s] = al_q_cq02h[s] | (|w_cq02h[s * RP +: RP]) | rel_q_cq02h[s] | rd_s_cq02h[s] | (|hd_cq02h[s * D +: D]) |
                        (|hrel_q_cq02h[s * D +: D]);
      tl_en_cq02h[s]  = al_q_cq02h[s] | rel_q_cq02h[s] | rd_s_cq02h[s];
      fp_en_cq02h[s]  = (fl_q_cq02h & (~ufh_cq02h[s * NC] | ~kc_cq02h[s * KC])) | al_q_cq02h[s] | rel_q_cq02h[s] |
                        rd_s_cq02h[s];
      cm_en_cq02h[s]  = (((|dn_q_cq02h) | (|cm_q_cq02h)) & wt_cq02h[s]) | ev_q_cq02h[s] |
                        (|w_cq02h[s * RP +: RP]) | (fl_q_cq02h & ~ufh_cq02h[s * NC]) | al_q_cq02h[s] |
                        rd_s_cq02h[s] | (|hd_cq02h[s * D +: D]);
      win_en_cq02h[s] = ptr_en_cq02h[s] | fp_en_cq02h[s] | cm_en_cq02h[s];
    end
  for (genvar gs = 0; gs < S; gs++) begin : g_slot
    always_ff @(posedge ooe_core_clk) begin
      if (rst_r01h) begin
        v_cq02h[gs * D +: D]            <= '0;
        head_cq02h[gs * LD +: LD]       <= '0;
        och_cq02h[gs * NC +: NC]        <= NC'(1);
        run_cq02h[gs * LB +: LB]        <= LB'(D);
        reach_q_cq02h[gs]               <= 1'b1;
        hoh_cq02h[gs * D +: D]          <= D'(1);
        thq_cq02h[gs * D +: D]          <= '1;
        hd_cq02h[gs * D +: D]           <= '0;
      end else if (ptr_en_cq02h[gs]) begin
        v_cq02h[gs * D +: D]            <= v_nx_cq02h[gs * D +: D];
        head_cq02h[gs * LD +: LD]       <= head_nx_cq02h[gs * LD +: LD];
        och_cq02h[gs * NC +: NC]        <= och_nx_cq02h[gs * NC +: NC];
        run_cq02h[gs * LB +: LB]        <= run_nx_cq02h[gs * LB +: LB];
        reach_q_cq02h[gs]               <= reach_nx_cq02h[gs];
        hoh_cq02h[gs * D +: D]          <= hoh_nx_cq02h[gs * D +: D];
        thq_cq02h[gs * D +: D]          <= th_nx_cq02h[gs * D +: D];
        hd_cq02h[gs * D +: D]           <= hd_nx_cq02h[gs * D +: D];
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
        kc_cq02h[gs * KC +: KC]         <= KC'(1);
      end else if (fp_en_cq02h[gs]) begin
        ufh_cq02h[gs * NC +: NC]        <= ufh_nx_cq02h[gs * NC +: NC];
        kc_cq02h[gs * KC +: KC]         <= kc_nx_cq02h[gs * KC +: KC];
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
        am_cq02h[gs * D +: D]           <= '0;
        oc_cq02h[gs * D * NR * RCW +: D * NR * RCW] <= '0;
        rc_cq02h[gs * D * 2 +: D * 2]   <= '0;
      end else if (cm_en_cq02h[gs]) begin
        dn_cq02h[gs * D +: D]           <= dn_nx_cq02h[gs * D +: D];
        md_cq02h[gs * D +: D]           <= md_nx_cq02h[gs * D +: D];
        cp_cq02h[gs * D +: D]           <= cp_nx_cq02h[gs * D +: D];
        am_cq02h[gs * D +: D]           <= am_nx_cq02h[gs * D +: D];
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
        br_cq02h[ge]                <= fd_br_cq02h[ge];
        pal_cq02h[ge]               <= fd_pal_cq02h[ge];
        st_cq02h[ge]                <= fd_st_cq02h[ge];
        gns_cq02h[ge * NSB +: NSB]  <= fd_gns_cq02h[ge * NSB +: NSB];
        ck_cq02h[ge * LK +: LK]     <= fd_ck_cq02h[ge * LK +: LK];
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
  // The names a squash frees now (its filled entries with nothing in
  // flight) and a held release frees a cycle after it (hrel_q, the release
  // register): each entry's new names, from its fields (a released entry is
  // not refilled before its fields are read: rename sees it held for a
  // cycle more). And the kill register: the names of last cycle's killed
  // fills.
  logic [S*D-1:0]     frx_cq02h;
  logic [A-1:0]       kv_q_cq02h, kpa_q_cq02h;
  logic [A*GW-1:0]    kg_q_cq02h;
  logic [A*NSB-1:0]   ks_q_cq02h;
  logic [A*PW-1:0]    kp_q_cq02h;
  assign frx_cq02h = frel_cq02h | hrel_q_cq02h;
  always_comb begin
    gfree_nx_cq02h = '0;
    pfree_nx_cq02h = '0;
    for (int e = 0; e < S * D; e++)
      if (frx_cq02h[e]) begin
        for (int r = 0; r < NG; r++)
          if (gname_cq02h[e * GW + (GW - GR) +: GR] == GR'(r))
            gfree_nx_cq02h[r * NSB +: NSB] = gfree_nx_cq02h[r * NSB +: NSB] | gns_cq02h[e * NSB +: NSB];
        for (int p = 0; p < NP; p++)
          if (pal_cq02h[e] && pname_cq02h[e * PW +: PW] == PW'(p)) pfree_nx_cq02h[p] = 1'b1;
      end
    for (int l = 0; l < A; l++)
      if (kv_q_cq02h[l]) begin
        for (int r = 0; r < NG; r++)
          if (kg_q_cq02h[l * GW + (GW - GR) +: GR] == GR'(r))
            gfree_nx_cq02h[r * NSB +: NSB] = gfree_nx_cq02h[r * NSB +: NSB] | ks_q_cq02h[l * NSB +: NSB];
        for (int p = 0; p < NP; p++)
          if (kpa_q_cq02h[l] && kp_q_cq02h[l * PW +: PW] == PW'(p)) pfree_nx_cq02h[p] = 1'b1;
      end
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
  logic rb_en_cq02h, rf_en_cq02h, rm_en_cq02h, r_live_cq03h, m_live_cq02h;
  assign rf_en_cq02h = |w_cq02h;
  assign rb_en_cq02h = rf_en_cq02h | r_live_cq03h;
  // The free masks may take something now: a retirement that frees, a
  // squash acting (its releases, frel, are within it), a held release or a
  // killed fill, each from flops, so the enable stays within CG-2's 8 (the
  // releases themselves are the squash's search, 15.7 deep).
  logic mw_cq02h;
  assign mw_cq02h    = (|(w_cq02h & (wgf_cq02h | wpf_cq02h))) | (|rd_s_cq02h) | (|hrel_q_cq02h) | (|kv_q_cq02h);
  assign rm_en_cq02h = mw_cq02h | m_live_cq02h;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      r_live_cq03h <= 1'b0;
      m_live_cq02h <= 1'b0;
    end else begin
      r_live_cq03h <= rf_en_cq02h;
      m_live_cq02h <= mw_cq02h;
    end
  end
  // The release register, clocked while an entry is held or it holds one.
  logic [S-1:0] hr_en_cq02h;
  always_comb
    for (int s = 0; s < S; s++)
      hr_en_cq02h[s] = rd_s_cq02h[s] | (|hd_cq02h[s * D +: D]) | (|hrel_q_cq02h[s * D +: D]);
  for (genvar gs = 0; gs < S; gs++) begin : g_hrel
    always_ff @(posedge ooe_core_clk) begin
      if (rst_r01h)              hrel_q_cq02h[gs * D +: D] <= '0;
      else if (hr_en_cq02h[gs])  hrel_q_cq02h[gs * D +: D] <= hrel_e_cq02h[gs * D +: D];
    end
  end
  // The kill register: each killed fill's names, clocked while a fill may be
  // killed (a squash now, or a kill count waiting) or it holds one.
  logic kr_en_cq02h, kd_en_cq02h;
  logic [S-1:0] kc0_cq02h;                     // the slot's kill count is zero
  always_comb for (int s = 0; s < S; s++) kc0_cq02h[s] = kc_cq02h[s * KC];
  assign kd_en_cq02h = fl_q_cq02h & ((|rd_s_cq02h) | ~(&kc0_cq02h));
  assign kr_en_cq02h = kd_en_cq02h | (|kv_q_cq02h);
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h)         kv_q_cq02h <= '0;
    else if (kr_en_cq02h) kv_q_cq02h <= fk_cq02h & fl_v_cq02h & {A{fl_q_cq02h}};
  end
  always_ff @(posedge ooe_core_clk) begin
    if (kd_en_cq02h) begin
      kpa_q_cq02h <= fl_palloc_cq02h & ~fl_nop_cq02h;
      kg_q_cq02h  <= fl_gname_cq02h;
      kp_q_cq02h  <= fl_pname_cq02h;
      for (int l = 0; l < A; l++) ks_q_cq02h[l * NSB +: NSB] <= fl_gnsec_cq02h[l * NSB +: NSB] & {NSB{~fl_nop_cq02h[l]}};
    end
  end
  // The leads' own registers (the output's copies, NGD-7).
  logic [S-1:0] hda_cq02h;
  always_comb for (int s = 0; s < S; s++) hda_cq02h[s] = |hd_cq02h[s * D +: D];
  (* keep *) logic sql_q_cq02h, hdl_q_cq02h, kgl_q_cq02h, kpl_q_cq02h;
  logic [S-1:0] rd_nx_cq02h;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      sql_q_cq02h <= 1'b0;
      hdl_q_cq02h <= 1'b0;
      kgl_q_cq02h <= 1'b0;
      kpl_q_cq02h <= 1'b0;
    end else begin
      sql_q_cq02h <= |rd_nx_cq02h;
      hdl_q_cq02h <= (|hda_cq02h) | (|rd_s_cq02h);   // held, or a squash that may hold and release now
      kgl_q_cq02h <= kd_en_cq02h && |(fk_cq02h & fl_v_cq02h & ~fl_nop_cq02h & fl_gwe_cq02h);
      kpl_q_cq02h <= kd_en_cq02h && |(fk_cq02h & fl_v_cq02h & ~fl_nop_cq02h & fl_palloc_cq02h);
    end
  end
  assign sql_o_cq02h = sql_q_cq02h;
  assign hdl_o_cq02h = hdl_q_cq02h;
  assign kgl_o_cq02h = kgl_q_cq02h;
  assign kpl_o_cq02h = kpl_q_cq02h;
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

  // -- Branches (slice 2): records, outcomes, resolution ------------------------------
  // Each (slot, checkpoint) record holds what a branch's resolution reads.
  // It is written a cycle after the branch's fill, from a register of the
  // fill's branch fields, so its enable is from this module's flops (CG-5);
  // a done reads it no earlier than two cycles after the fill (asserted).
  localparam int RW = 1 + 1 + 32 + PCW + PCW + 16;   // ptaken, ret, gmask, pcn, tgt, pchi
  logic [A-1:0]      fp_v_cq02h;                    // the fill register: a branch lane
  logic [A*LS-1:0]   fp_slot_cq02h;
  logic [A*LK-1:0]   fp_ck_cq02h;
  logic [A*RW-1:0]   fp_rec_cq02h;
  logic              fp_q_cq02h;                    // the register holds a branch
  // Clocked on the branch-fill lead (a fill without a branch leaves it).
  logic              fbr_en_cq02h;
  assign fbr_en_cq02h = fb_q_cq02h;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h)        fp_q_cq02h <= 1'b0;
    else                 fp_q_cq02h <= fb_q_cq02h;
  end
  always_ff @(posedge ooe_core_clk) begin
    if (fbr_en_cq02h) begin
      fp_v_cq02h    <= fl_v_cq02h & fl_br_cq02h & ~fl_nop_cq02h & ~fk_cq02h;   // a killed fill writes no record
      fp_slot_cq02h <= fl_slot_cq02h;
      fp_ck_cq02h   <= fl_ckpt_cq02h;
      for (int l = 0; l < A; l++)
        fp_rec_cq02h[l * RW +: RW] <= {fl_ptaken_cq02h[l], fl_ret_cq02h[l], fl_gmask_cq02h[l * 32 +: 32],
                                       fl_pcn_cq02h[l * PCW +: PCW], fl_tgt_cq02h[l * PCW +: PCW],
                                       fl_pchi_cq02h[l * 16 +: 16]};
    end
  end
  logic [S*NK-1:0]    rw_en_cq02h;                  // record (s, c) written at this edge
  logic [S*NK*RW-1:0] rw_nx_cq02h, rec_cq02h;
  always_comb begin
    rw_en_cq02h = '0;
    rw_nx_cq02h = '0;
    for (int r = 0; r < S * NK; r++)
      for (int l = 0; l < A; l++)
        if (fp_v_cq02h[l] && fp_slot_cq02h[l * LS +: LS] == LS'(r / NK) && fp_ck_cq02h[l * LK +: LK] == LK'(r % NK)) begin
          rw_en_cq02h[r] = fp_q_cq02h;
          rw_nx_cq02h[r * RW +: RW] = rw_nx_cq02h[r * RW +: RW] | fp_rec_cq02h[l * RW +: RW];
        end
  end
  for (genvar gr = 0; gr < S * NK; gr++) begin : g_rec
    always_ff @(posedge ooe_core_clk) begin
      if (rw_en_cq02h[gr]) rec_cq02h[gr * RW +: RW] <= rw_nx_cq02h[gr * RW +: RW];
    end
  end
  // A record's fields.
  function automatic logic rec_pt(input logic [RW-1:0] r); rec_pt = r[RW-1]; endfunction
  function automatic logic rec_rt(input logic [RW-1:0] r); rec_rt = r[RW-2]; endfunction
  function automatic logic [31:0] rec_gm(input logic [RW-1:0] r); rec_gm = r[RW-3 -: 32]; endfunction
  function automatic logic [PCW-1:0] rec_pn(input logic [RW-1:0] r); rec_pn = r[16 + PCW +: PCW]; endfunction
  function automatic logic [PCW-1:0] rec_tg(input logic [RW-1:0] r); rec_tg = r[16 +: PCW]; endfunction
  function automatic logic [15:0] rec_ph(input logic [RW-1:0] r); rec_ph = r[15:0]; endfunction

  // The outcome register: the done on slot BS, its entry's checkpoint and
  // whether it mispredicts (V-41: predicted taken is right only if every
  // lane of the group took it), formed from the done as it arrives, in
  // parallel with the tag's decode. One branch done a cycle (the fixed
  // slot), so one register. The slot carries RCU's other RCU-only ops too:
  // only a branch's done is an outcome.
  logic            bo_v_cq02h, bo_taken_cq02h, bo_wrong_cq02h;
  logic [TW-1:0]   bo_tag_cq02h;
  logic [S*D-1:0]  bo_oh_cq02h;                     // the done's entry, one-hot (off the resolution's path)
  logic [LK-1:0]   bo_ck_cq02h;
  logic [31:0]     bo_mask_cq02h, bo_aux_cq02h;
  logic [LK-1:0]   bo_ck_nx_cq02h;
  logic [RW-1:0]   bo_rec_cq02h;
  logic            bo_wrong_nx_cq02h, bo_br_nx_cq02h;
  always_comb begin
    // One-hot selects as AND-OR (a priority if over the entries is a
    // chain of S * D muxes).
    bo_ck_nx_cq02h = '0;
    bo_br_nx_cq02h = 1'b0;
    for (int e = 0; e < S * D; e++) begin
      bo_ck_nx_cq02h = bo_ck_nx_cq02h | ({LK{dn_tag_cq02h[BS * TW +: TW] == TW'(e)}} & ck_cq02h[e * LK +: LK]);
      bo_br_nx_cq02h = bo_br_nx_cq02h | (dn_tag_cq02h[BS * TW +: TW] == TW'(e) && br_cq02h[e]);
    end
    // The verdict against every record at once, from the done's outcome
    // and the records' flops, then the one the tag names: the mask's
    // compare is off the tag's path (its decode, the checkpoint's select).
    bo_wrong_nx_cq02h = 1'b0;
    for (int r = 0; r < S * NK; r++) begin
      bo_rec_cq02h = rec_cq02h[r * RW +: RW];
      bo_wrong_nx_cq02h = bo_wrong_nx_cq02h |
        (dn_tag_cq02h[BS * TW + LD +: LS] == LS'(r / NK) && bo_ck_nx_cq02h == LK'(r % NK) &&
         (rec_pt(bo_rec_cq02h) ? !(dn_taken_cq02h && dn_mask_cq02h == rec_gm(bo_rec_cq02h)) : dn_taken_cq02h));
    end
  end
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) bo_v_cq02h <= 1'b0;
    else          bo_v_cq02h <= dn_q_cq02h[BS] && bo_br_nx_cq02h;
  end
  logic bo_en_cq02h;
  assign bo_en_cq02h = dn_q_cq02h[BS];
  always_ff @(posedge ooe_core_clk) begin
    if (bo_en_cq02h) begin
      bo_tag_cq02h   <= dn_tag_cq02h[BS * TW +: TW];
      for (int e = 0; e < S * D; e++) bo_oh_cq02h[e] <= dn_tag_cq02h[BS * TW +: TW] == TW'(e);
      bo_ck_cq02h    <= bo_ck_nx_cq02h;
      bo_taken_cq02h <= dn_taken_cq02h;
      bo_mask_cq02h  <= dn_mask_cq02h;
      bo_aux_cq02h   <= dn_aux_cq02h;
      bo_wrong_cq02h <= bo_wrong_nx_cq02h;
    end
  end
  // Each record's outcome, a cycle after its done, from the outcome
  // register: the wrong bit, and for a wrong branch its taken, mask and aux
  // (the redirect's). Only a write that changes the wrong bit is made: a
  // wrong done, or a right one after a wrong one (a reissue's, OI-90, the
  // later wins); a set wrong bit is cleared at the record's next fill. A
  // right branch's record is never written.
  localparam int OWD = 1 + 1 + 32 + 32;
  logic [S*NK-1:0]     ow_hit_cq02h, ow_en_cq02h, ow_w_cq02h;
  logic [S*NK*OWD-1:0] out_cq02h;
  always_comb
    for (int r = 0; r < S * NK; r++) begin
      ow_w_cq02h[r]   = out_cq02h[r * OWD + OWD - 1];
      ow_hit_cq02h[r] = bo_v_cq02h && bo_tag_cq02h[LD +: LS] == LS'(r / NK) && bo_ck_cq02h == LK'(r % NK);
      ow_en_cq02h[r]  = (rw_en_cq02h[r] && ow_w_cq02h[r]) || (ow_hit_cq02h[r] && (bo_wrong_cq02h || ow_w_cq02h[r]));
    end
  for (genvar gr = 0; gr < S * NK; gr++) begin : g_out
    always_ff @(posedge ooe_core_clk) begin
      if (ow_en_cq02h[gr]) out_cq02h[gr * OWD +: OWD] <= rw_en_cq02h[gr] ? OWD'(0)
                                                       : {bo_wrong_cq02h, bo_taken_cq02h, bo_mask_cq02h, bo_aux_cq02h};
    end
  end

  // The resolution's candidates (cand): branches that completed at the
  // last edge, not yet resolved. Each entry's resolved bit (rsv) is set the
  // cycle it is a candidate and cleared where a fill rewrites its branch
  // bit (a fill candidate), so the candidates come from flops. An unfilled
  // entry (a no-op before its fill) can hold a stale branch bit, but its
  // last occupant was resolved, or reset set its rsv, or a squash took it
  // (the squash sets it for the entries it takes), so its rsv is set
  // (asserted below). A held entry and one a squash takes now are no
  // candidate: neither resolves (the model's branch.under_squash).
  logic [S*D-1:0] rsv_cq02h, cand_cq02h, rsv_nx_cq02h;
  // Gated by half slot (RH entries): the enable's OR stays within CG-2's 8.
  localparam int RH = (D >= 16) ? D / 2 : D;
  logic [S*D/RH-1:0] rsv_en_cq02h;
  logic [S-1:0]   rs_en_cq02h;
  logic [S*D-1:0] sqa_cq02h;                       // in the squash acting now
  always_comb
    for (int e = 0; e < S * D; e++) sqa_cq02h[e] = rd_s_cq02h[e / D] & sqm_cq02h[e];
  assign cand_cq02h   = v_cq02h & cmp_q_cq02h & br_cq02h & ~rsv_cq02h & ~hd_cq02h & ~sqa_cq02h;
  assign rsv_nx_cq02h = (rsv_cq02h | cand_cq02h | sqe_cq02h) & ~fd_en_cq02h;
  always_comb
    for (int h = 0; h < S * D / RH; h++)
      rsv_en_cq02h[h] = |(cand_cq02h[h * RH +: RH] | sqe_cq02h[h * RH +: RH] |
                          (fd_en_cq02h[h * RH +: RH] & rsv_cq02h[h * RH +: RH]));
  for (genvar gh = 0; gh < S * D / RH; gh++) begin : g_rsv
    always_ff @(posedge ooe_core_clk) begin
      if (rst_r01h)              rsv_cq02h[gh * RH +: RH] <= '1;   // every entry's stale branch bit counts as resolved
      else if (rsv_en_cq02h[gh]) rsv_cq02h[gh * RH +: RH] <= rsv_nx_cq02h[gh * RH +: RH];
    end
  end
  // At R, per slot: each candidate's wrong bit (from the outcome register
  // when its done was last cycle's, else its record's); the oldest wrong
  // one from the head is the mispredict, and every right one older than it
  // frees its checkpoint.
  logic [S*D-1:0] wr_e_cq02h, crt_e_cq02h, free_cq02h;
  logic [D-1:0]   th_cq02h, w1_cq02h, w0_cq02h;
  logic           any1_cq02h, p1_cq02h, p0_cq02h;
  always_comb
    for (int s = 0; s < S; s++) begin
      for (int i = 0; i < D; i++) begin
        // Its record's wrong bit, by checkpoint: a select over NK, each
        // index constant (a computed index over the records is a shifter).
        wr_e_cq02h[s * D + i] = 1'b0;
        for (int c = 0; c < NK; c++)
          wr_e_cq02h[s * D + i] = wr_e_cq02h[s * D + i] |
                                  (ck_cq02h[(s * D + i) * LK +: LK] == LK'(c) && out_cq02h[(s * NK + c) * OWD + OWD - 1]);
        if (bo_v_cq02h && bo_oh_cq02h[s * D + i]) wr_e_cq02h[s * D + i] = bo_wrong_cq02h;
        cw_e_cq02h[s * D + i]  = cand_cq02h[s * D + i] & wr_e_cq02h[s * D + i];
        crt_e_cq02h[s * D + i] = cand_cq02h[s * D + i] & ~wr_e_cq02h[s * D + i];
      end
      // Older than entry i, circularly from the head: a thermometer of the
      // head (at or past it), then the wrong candidates on each side.
      th_cq02h = thq_cq02h[s * D +: D];
      w1_cq02h = cw_e_cq02h[s * D +: D] & th_cq02h;
      w0_cq02h = cw_e_cq02h[s * D +: D] & ~th_cq02h;
      any1_cq02h = |w1_cq02h;
      for (int i = 0; i < D; i++) begin
        p1_cq02h = |(w1_cq02h & D'((64'(1) << i) - 1));
        p0_cq02h = |(w0_cq02h & D'((64'(1) << i) - 1));
        pfx_cq02h[s * D + i] = th_cq02h[i] ? p1_cq02h : (any1_cq02h | p0_cq02h);
      end
      pick_cq02h[s * D +: D] = cw_e_cq02h[s * D +: D] & ~pfx_cq02h[s * D +: D];
      free_cq02h[s * D +: D] = crt_e_cq02h[s * D +: D] & ~pfx_cq02h[s * D +: D];
    end
  // Each checkpoint's free: a balanced OR over the slot's entries (ABC
  // keeps an accumulating loop's chain, 32 deep).
  logic [S*NK-1:0] ckf_nx_cq02h;
  logic [D-1:0]    ckm_cq02h;
  always_comb begin
    ckf_nx_cq02h = '0;
    ckm_cq02h = '0;
    for (int s = 0; s < S; s++)
      for (int c = 0; c < NK; c++) begin
        for (int i = 0; i < D; i++) ckm_cq02h[i] = free_cq02h[s * D + i] && ck_cq02h[(s * D + i) * LK +: LK] == LK'(c);
        ckf_nx_cq02h[s * NK + c] = |ckm_cq02h;
      end
  end
  // The resolution registers: the mispredict's one-hot entry, the entries
  // its squash takes (the pick's prefix: every position after the branch
  // up to the head, and this cycle's allocations, which may land on an
  // entry retiring now), whether the branch retires now, and the redirect's
  // lead, which is the squash's at R + 1; the checkpoint frees.
  logic [S*D-1:0] sqm_nx_cq02h;
  logic [S-1:0]   sq_rt_nx_cq02h;
  always_comb
    for (int s = 0; s < S; s++) begin
      sqm_nx_cq02h[s * D +: D] = pfx_cq02h[s * D +: D] | al_e_cq02h[s * D +: D];
      sq_rt_nx_cq02h[s]        = |(pick_cq02h[s * D +: D] & rt_e_cq02h[s * D +: D]);
    end
  // Clocked on a superset of the candidates, without the held and squash
  // terms (a pick is within the candidates, and a register loaded with no
  // pick holds no squash), so the enable stays within CG-2's 8.
  logic [S*D-1:0] cnx_cq02h;
  assign cnx_cq02h = v_cq02h & cmp_q_cq02h & br_cq02h & ~rsv_cq02h;
  always_comb
    for (int s = 0; s < S; s++) begin
      rs_en_cq02h[s] = (|cnx_cq02h[s * D +: D]) | rd_s_cq02h[s] | ckfa_s_cq02h[s];
    end
  for (genvar gs = 0; gs < S; gs++) begin : g_res
    always_ff @(posedge ooe_core_clk) begin
      if (rst_r01h) begin
        rd_s_cq02h[gs]                <= 1'b0;
        rd_q_cq03h[gs]                <= 1'b0;
        rd_o_cq03h[gs]                <= 1'b0;
        ckf_cq03h[gs * NK +: NK]      <= '0;
        ckfa_s_cq02h[gs]              <= 1'b0;
      end else if (rs_en_cq02h[gs]) begin
        rd_s_cq02h[gs]                <= |pick_cq02h[gs * D +: D];
        rd_q_cq03h[gs]                <= |pick_cq02h[gs * D +: D];
        rd_o_cq03h[gs]                <= |pick_cq02h[gs * D +: D];
        ckf_cq03h[gs * NK +: NK]      <= ckf_nx_cq02h[gs * NK +: NK];
        ckfa_s_cq02h[gs]              <= |ckf_nx_cq02h[gs * NK +: NK];
      end
    end
    always_ff @(posedge ooe_core_clk) begin
      if (rs_en_cq02h[gs]) begin
        sp_s_cq02h[gs * D +: D] <= pick_cq02h[gs * D +: D];
        sq_p_cq03h[gs * D +: D] <= pick_cq02h[gs * D +: D];
        sqm_cq02h[gs * D +: D]  <= sqm_nx_cq02h[gs * D +: D];
        sq_rt_cq02h[gs]         <= sq_rt_nx_cq02h[gs];
      end
    end
  end
  assign rd_l_cq03h = rd_o_cq03h;
  always_comb
    for (int s = 0; s < S; s++) rd_nx_cq02h[s] = rs_en_cq02h[s] ? |pick_cq02h[s * D +: D] : rd_s_cq02h[s];
  // The squash's bulk discard (A-41, A-53): when it takes a store at MIU
  // (uncommitted: commit is at retire), the circular range (branch, tail]
  // goes to MIU at once, its loads with it (TI-21); a cycle after the squash.
  function automatic logic [LD-1:0] enc(input logic [D-1:0] oh);
    enc = '0;
    for (int i = 0; i < D; i++) enc = enc | ({LD{oh[i]}} & LD'(i));
  endfunction
  logic [S-1:0]    dc_nx_cq02h, dc_en_cq02h, dcp_en_cq02h;
  logic [S*LD-1:0] dcb_nx_cq02h, dcd_nx_cq02h;
  always_comb
    for (int s = 0; s < S; s++) begin
      dc_nx_cq02h[s] = |(sqe_cq02h[s * D +: D] & st_cq02h[s * D +: D] & am_cq02h[s * D +: D]);
      dcb_nx_cq02h[s * LD +: LD] = enc(sp_s_cq02h[s * D +: D]);
      dcd_nx_cq02h[s * LD +: LD] = enc(rotl(toh_cq02h[s * D +: D], D - 1));
      dc_en_cq02h[s] = rd_s_cq02h[s] | dc_v_cq03h[s];
      dcp_en_cq02h[s] = rd_s_cq02h[s];            // the payload, with a squash
    end
  for (genvar gs = 0; gs < S; gs++) begin : g_dc
    always_ff @(posedge ooe_core_clk) begin
      if (rst_r01h)             dc_v_cq03h[gs] <= 1'b0;
      else if (dc_en_cq02h[gs]) dc_v_cq03h[gs] <= dc_nx_cq02h[gs];
    end
    always_ff @(posedge ooe_core_clk) begin
      if (dcp_en_cq02h[gs]) begin
        dc_br_cq03h[gs * LD +: LD]   <= dcb_nx_cq02h[gs * LD +: LD];
        dc_disp_cq03h[gs * LD +: LD] <= dcd_nx_cq02h[gs * LD +: LD];
      end
    end
  end
  // The redirect's payload, a cycle after its lead, from the mispredict's
  // record: its checkpoint, the lanes that took it, the target (taken: the
  // taken target, else the fall-through; a ret: {pc[47:32], aux}), stay for
  // a ret (AR-24 (b)).
  logic [LK-1:0]  rp_ck_cq03h;
  logic [RW-1:0]  rp_rec_cq03h;
  logic [OWD-1:0] rp_out_cq03h;
  logic [S*LK-1:0]  rd_ckpt_nx_cq03h;
  logic [S*32-1:0]  rd_tmask_nx_cq03h;
  logic [S*PCW-1:0] rd_tgt_nx_cq03h;
  logic [S-1:0]     rd_stay_nx_cq03h;
  always_comb
    for (int s = 0; s < S; s++) begin
      rp_ck_cq03h = '0;
      for (int i = 0; i < D; i++)
        rp_ck_cq03h = rp_ck_cq03h | ({LK{sq_p_cq03h[s * D + i]}} & ck_cq02h[(s * D + i) * LK +: LK]);
      rp_rec_cq03h = '0;
      rp_out_cq03h = '0;
      for (int c = 0; c < NK; c++) begin
        rp_rec_cq03h = rp_rec_cq03h | ({RW{rp_ck_cq03h == LK'(c)}} & rec_cq02h[(s * NK + c) * RW +: RW]);
        rp_out_cq03h = rp_out_cq03h | ({OWD{rp_ck_cq03h == LK'(c)}} & out_cq02h[(s * NK + c) * OWD +: OWD]);
      end
      rd_ckpt_nx_cq03h[s * LK +: LK]   = rp_ck_cq03h;
      rd_tmask_nx_cq03h[s * 32 +: 32]  = rp_out_cq03h[63:32];
      rd_stay_nx_cq03h[s]              = rec_rt(rp_rec_cq03h);
      rd_tgt_nx_cq03h[s * PCW +: PCW]  = rec_rt(rp_rec_cq03h) ? {rec_ph(rp_rec_cq03h), rp_out_cq03h[31:0]}
                                       : rp_out_cq03h[64] ? rec_tg(rp_rec_cq03h) : rec_pn(rp_rec_cq03h);
    end
  logic [S-1:0] rdp_en_cq03h;
  assign rdp_en_cq03h = rd_q_cq03h;
  for (genvar gs = 0; gs < S; gs++) begin : g_rdp
    always_ff @(posedge ooe_core_clk) begin
      if (rdp_en_cq03h[gs]) begin
        rd_ckpt_cq04h[gs * LK +: LK]    <= rd_ckpt_nx_cq03h[gs * LK +: LK];
        rd_tmask_cq04h[gs * 32 +: 32]   <= rd_tmask_nx_cq03h[gs * 32 +: 32];
        rd_tgt_cq04h[gs * PCW +: PCW]   <= rd_tgt_nx_cq03h[gs * PCW +: PCW];
        rd_stay_cq04h[gs]               <= rd_stay_nx_cq03h[gs];
      end
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
  // A branch completes only on slot BS (its outcome is that slot's), and
  // its done never reads a record whose write is still pending (the fill a
  // cycle before; an issue is two cycles past its fill at the least).
  logic [ND-1:0] dn_brx_cq02h;
  logic          bo_early_cq02h;
  always_comb begin
    for (int p = 0; p < ND; p++) begin
      dn_brx_cq02h[p] = 1'b0;
      for (int e = 0; e < S * D; e++)
        if (p != BS && dn_q_cq02h[p] && dn_tag_cq02h[p * TW +: TW] == TW'(e) && v_cq02h[e] && br_cq02h[e] &&
            !ufm_cq02h[e]) dn_brx_cq02h[p] = 1'b1;
    end
    bo_early_cq02h = 1'b0;
    for (int l = 0; l < A; l++)
      if (dn_q_cq02h[BS] && bo_br_nx_cq02h && fp_q_cq02h && fp_v_cq02h[l] &&
          fp_slot_cq02h[l * LS +: LS] == dn_tag_cq02h[BS * TW + LD +: LS] && fp_ck_cq02h[l * LK +: LK] == bo_ck_nx_cq02h)
        bo_early_cq02h = 1'b1;
  end
  `CCV_ASSERT(branch_done_on_bs, dn_brx_cq02h == '0)
  // A resolution candidate is a filled entry (no stale branch bit).
  `CCV_ASSERT(candidate_filled, (cand_cq02h & ufm_cq02h) == '0)
  // One resolution a cycle across the ROB (OA's revs 293-294): one
  // outcome register, so at most one candidate. With rets at resolve_lag 1
  // and branches at 0 (once RCU's branch lead lands), a branch done the
  // cycle after a ret's would make two; Issue's ret hold keeps it off RCU.
  `CCV_ASSERT(one_resolution, (cand_cq02h & (cand_cq02h - 1'b1)) == '0)
  `CCV_ASSERT(unfilled_owes_none, (v_cq02h & ufm_cq02h & outq_cq02h) == '0)
  // The head's thermometer register is hoh's (the resolution's search).
  logic [S*D-1:0] thc_cq02h;
  always_comb
    for (int s = 0; s < S; s++)
      for (int i = 0; i < D; i++) thc_cq02h[s * D + i] = |(hoh_cq02h[s * D +: D] & D'((64'(1) << (i + 1)) - 1));
  `CCV_ASSERT(head_thermometer, thq_cq02h == thc_cq02h)
  // A fill with a branch had its lead (the records are clocked on it).
  `CCV_ASSERT(branch_fill_lead, !(fl_q_cq02h && |(fl_v_cq02h & fl_br_cq02h & ~fl_nop_cq02h)) || fb_q_cq02h)
  `CCV_ASSERT(branch_record_written, !bo_early_cq02h)
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
  // The next run is the run less the count: the run from flops covers it.
  logic [S-1:0] r0_short_cq02h;
  always_comb
    for (int s = 0; s < S; s++)
      r0_short_cq02h[s] = (LB + 1)'(al_n_cq02h[s * LA +: LA]) > {1'b0, r0_cq02h[s * LB +: LB]};
  `CCV_ASSERT(run_covers_count, r0_short_cq02h == '0)
  // A squash's cycle allocates nothing in its slot (the go holds it: the
  // model drops the warp's decode queue first); the fills it leaves owed fit
  // the kill count; a held entry never retires; a retirement and a squash
  // never meet on an entry.
  logic [S-1:0] sq_al_cq02h, kc_over_cq02h;
  always_comb
    for (int s = 0; s < S; s++) begin
      sq_al_cq02h[s]   = rd_s_cq02h[s] && al_n_cq02h[s * LA +: LA] != '0;
      kc_over_cq02h[s] = rd_s_cq02h[s] && (uxa_all_cq02h[s * NC +: NC] >> KC) != '0;
    end
  `CCV_ASSERT(squash_allocates_nothing, sq_al_cq02h == '0)
  `CCV_ASSERT(kill_count_bounded, kc_over_cq02h == '0)
  `CCV_ASSERT(held_never_retires, (rt_e_cq02h & (hd_cq02h | sqe_cq02h)) == '0)
  // Every fill lands two cycles after its allocation (OA's rev 295, OI-94):
  // per slot, the fills arriving now are the go's allocations two cycles
  // ago, killed ones included. The kill count and the model's
  // kill_free_lag (a killed entry's names at alloc + 3) both rest on it; a
  // stall between the go and Rename 2 would break it.
  `CCV_ASSERT_T(fill_at_alloc_2, nfl_cq02h == `CCV_PAST(`CCV_PAST(al_n_cq02h)))
endmodule
`undef CCV_CLK
`undef CCV_RST
