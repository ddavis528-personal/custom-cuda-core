//===-- ooe_rat.sv - OOE register alias tables and branch checkpoints ---===//
//
// Spec: the design doc's Register alias tables (one GPR RAT of 16 and one
//       predicate RAT of 4 per tier-1 warp; the guard and the predicate
//       destination renamed apart, Q-21; three GPR sources, Q-20; four
//       checkpoints per warp, GPR and predicate together, under FET's
//       checkpoint_id, taken when the branch renames and restored in one
//       cycle), Retire, squash and recovery (squash to retirement restores
//       the committed maps), Warp activation (A-64: a launched or freed
//       slot maps every register to the zero registers), OA's response
//       OI-41 (restore-allocate takes its registers through rename's ports,
//       writing both maps) and OA's response OI-46 (reopened: the read is
//       Rename 1's logic in ooe_rename, ooe_ratread; ooe_rat drives its maps
//       straight out).
//
// Per tier-1 slot: the speculative maps (rat, prat), the committed maps
// (crat, cprat) and C checkpoints of the speculative maps. A GPR name is a
// row and a position (GW bits); a predicate name is PW bits.
//
// Every write is applied an edge after the model makes it, from registers,
// so each gate's enable is this module's own flop (OA's response OI-58,
// V-75):
//   - rename's group writes the speculative maps two edges after its go
//     (OI-83 (b), OA's rev 259): rename's register of the group (pw_*,
//     data) is captured here first (po_*, from no logic, so a late name
//     costs nothing), and the maps are written from the capture at the
//     next edge. The capture leaves as po_* for the reads, which take it as
//     the older of two pending groups. The enable is this module's flop of
//     the go per slot (a take, or a restore-allocate), a cycle on, and each
//     checkpoint's its flop of "a taken branch names it", formed from
//     rename's take counts and decq's head fields (L2). A branch's
//     checkpoint is the maps as they stand after its own port's writes and
//     the lower ports' of its slot.
//   - retirement writes the committed maps from the ROB's retire-stage
//     register, each slot's GPRs and its predicates one gate, enabled by
//     this module's copy of that register's gwe and pwe (from the ROB's
//     decision, a cycle ahead; L2); a restore-allocate's ports write both
//     maps.
//   - a checkpoint restore (a mispredict), a squash to retirement (a
//     demotion or kill: the speculative maps take the committed ones) and a
//     release (every map to the zero registers) are registered here and
//     applied at the next edge (L4), in that order of precedence.
// Rename never names a slot such an event names, in its cycle or the next
// (a mispredict's epoch drops the warp's queued uops; a demoting, killed
// or freed slot does not rename): asserted for the edge they share. A
// captured group, a cycle older, can meet its slot's event at the edge it
// would write: the event wins and the slot's captured writes are dropped
// (OI-83 (b) (3)). The
// reads are not here: ooe_ratread reads rat_cq02h, the flops, with the
// pending group's writes and the in-group override in front.
//
// Checkpoint live bits are not kept here: branch resolution owns them.
//
// The reference is the model's Slot maps and checkpoints, which log what
// reached them each cycle (Core::ratLog); test/ooe/rat_tb.cpp drives this
// module and ooe_ratread together (test/ooe/ooe_rat_read.sv) from the log
// and compares every read, and after the edge every map and every live
// checkpoint with the model's an edge before.
//
// Reset line (decision 6): the four maps reset to the zero registers, as a
// freed slot's; the checkpoints are payload, read only through a live
// branch. The reset is flopped (RST-1). Local clock gating
// (docs/rtl-coding-style.md): each slot's speculative maps are one gate,
// each slot's committed GPRs one and its committed predicates one, each
// checkpoint one. The leads' and the events' flops are outside any gate,
// within the module's allowance.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK ooe_core_clk
`define CCV_RST rst_r01h
module ooe_rat #(
  parameter int S  = 4,                  // tier-1 slots (CCV_TIER1_WARPS)
  parameter int A  = 4,                  // rename ports (CCV_ISSUE_WIDTH)
  parameter int R  = 2,                  // retire ports per slot (CCV_RETIRE_PER_ROB)
  parameter int C  = 4,                  // checkpoints per slot (CCV_P_BR_CKPTS)
  parameter int GW = 10,                 // GPR name: row (CCV_P_W_PHYS_REG) and position (CCV_W_PHYS_POS)
  parameter int PW = 6,                  // predicate name (CCV_P_W_PHYS_PRED)
  parameter logic [GW-1:0] GZERO = '1,   // the zero GPR's name (CCV_P_PHYS_ZERO, position 0)
  parameter logic [PW-1:0] PZERO = '1,   // the zero predicate (CCV_P_PRED_ZERO)
  localparam int NG = 16,                // architectural GPRs
  localparam int NP = 4,                 // architectural predicates
  localparam int LS = (S > 1) ? $clog2(S) : 1,
  localparam int LC = (C > 1) ? $clog2(C) : 1,
  localparam int MW = NG * GW + NP * PW  // one slot's maps, GPRs then predicates
) (
  input  logic              ooe_core_clk,
  input  logic              ooe_rst_r00h,
  // The go's cycle: what rename takes from each slot (a thermometer per
  // slot, in take order), the branch flags and checkpoints of the slot's
  // next uops (decq's head fields), and a restore-allocate per slot.
  input  logic [S*A-1:0]    tk_cq00h,
  input  logic [S*A-1:0]    hbr_cq00h,
  input  logic [S*A*LC-1:0] hck_cq00h,
  input  logic [S-1:0]      rstl_cq00h,
  // The next cycle: rename's register of that group, in rename order.
  input  logic [A-1:0]      pw_v_cq01h,
  input  logic [A*LS-1:0]   pw_slot_cq01h,
  input  logic [A-1:0]      pw_rst_cq01h,      // a restore-allocate write: both maps
  input  logic [A*4-1:0]    pw_dst_cq01h,
  input  logic [A-1:0]      pw_gwe_cq01h,      // writes its GPR destination
  input  logic [A*GW-1:0]   pw_gname_cq01h,    // with this name
  input  logic [A*2-1:0]    pw_pdst_cq01h,
  input  logic [A-1:0]      pw_pwe_cq01h,      // writes its predicate destination
  input  logic [A*PW-1:0]   pw_pname_cq01h,
  input  logic [A-1:0]      pw_br_cq01h,       // a branch: takes a checkpoint
  input  logic [A*LC-1:0]   pw_ckpt_cq01h,     // FET's checkpoint_id
  // The ROB's retire decision, a cycle ahead of its retire-stage register:
  // each retire port's gwe and pwe.
  input  logic [S*R-1:0]    rgl_cq00h,
  input  logic [S*R-1:0]    rpl_cq00h,
  // The retire-stage register, per slot, in retirement order.
  input  logic [S*R-1:0]    ret_gwe_cq01h,
  input  logic [S*R*4-1:0]  ret_dst_cq01h,
  input  logic [S*R*GW-1:0] ret_gname_cq01h,
  input  logic [S*R-1:0]    ret_pwe_cq01h,
  input  logic [S*R*2-1:0]  ret_pdst_cq01h,
  input  logic [S*R*PW-1:0] ret_pname_cq01h,
  // Whole-map events, per slot, registered here.
  input  logic [S-1:0]      restore_cq00h,     // a mispredict: the speculative maps take a checkpoint
  input  logic [S*LC-1:0]   restore_ckpt_cq00h,
  input  logic [S-1:0]      squash_cq00h,      // a squash to retirement
  input  logic [S-1:0]      release_cq00h,     // the slot freed
`ifdef CCV_CHECK_RAT
  // Read only by the benches (CCV_CHECK_RAT): the control pend-over-event
  // lets a captured group's writes win over its slot's event.
  input  logic              ctl_pkeep,
`endif
  // The captured group (OI-83 (b)): rename's register of the group a cycle
  // on, written into the maps at the next edge; the reads' older pending.
  output logic [A-1:0]      po_v_cq02h,
  output logic [A*LS-1:0]   po_slot_cq02h,
  output logic [A*4-1:0]    po_dst_cq02h,
  output logic [A-1:0]      po_gwe_cq02h,
  output logic [A*GW-1:0]   po_gname_cq02h,
  output logic [A*2-1:0]    po_pdst_cq02h,
  output logic [A-1:0]      po_pwe_cq02h,
  output logic [A*PW-1:0]   po_pname_cq02h,
  // The maps after the last edge.
  output logic [S*MW-1:0]   rat_cq02h,         // speculative
  output logic [S*MW-1:0]   crat_cq02h,        // committed (the demotion map)
  output logic [S*C*MW-1:0] ckpt_cq02h
);

  // The reset, flopped before any use (RST-1).
  logic rst_r01h;
  always_ff @(posedge ooe_core_clk) begin
    rst_r01h <= ooe_rst_r00h;
  end

  // Each signal on its own: Icarus takes $isunknown of a concatenation of
  // known ports as unknown (TI's note, 2026-10-21).
  `CCV_ASSERT_KNOWN(tk_known, tk_cq00h)
  `CCV_ASSERT_KNOWN(rstl_known, rstl_cq00h)
  `CCV_ASSERT_KNOWN(pw_v_known, pw_v_cq01h)
  `CCV_ASSERT_KNOWN(rgl_known, rgl_cq00h)
  `CCV_ASSERT_KNOWN(rpl_known, rpl_cq00h)
  `CCV_ASSERT_KNOWN(ret_gwe_known, ret_gwe_cq01h)
  `CCV_ASSERT_KNOWN(ret_pwe_known, ret_pwe_cq01h)
  `CCV_ASSERT_KNOWN(restore_known, restore_cq00h)
  `CCV_ASSERT_KNOWN(squash_known, squash_cq00h)
  `CCV_ASSERT_KNOWN(release_known, release_cq00h)

  // -- leads and events, this module's flops ----------------------------------
  // wl: slot s's group writes its maps at the next edge (a take or a
  // restore-allocate); rw: a restore-allocate, which writes the committed
  // maps too; ck: a taken branch of slot s names checkpoint c. rg, rp: the
  // retire-stage register's gwe and pwe, a copy. The events, registered.
  logic [S-1:0]    wl_cq01h, rw_cq01h;
  logic [S*C-1:0]  ck_cq01h;
  logic [S*R-1:0]  rg_cq01h, rp_cq01h;
  logic [S-1:0]    rs_cq01h, sq_cq01h, rl_cq01h;
  logic [S*LC-1:0] rsc_cq01h;
  logic [S*C-1:0]  ck_d_cq00h;
  always_comb begin
    ck_d_cq00h = '0;
    for (int t = 0; t < S; t++)
      for (int j = 0; j < A; j++)
        for (int c = 0; c < C; c++)
          if (tk_cq00h[t * A + j] && hbr_cq00h[t * A + j] && hck_cq00h[(t * A + j) * LC +: LC] == LC'(c))
            ck_d_cq00h[t * C + c] = 1'b1;
  end
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      wl_cq01h <= '0;
      rw_cq01h <= '0;
      ck_cq01h <= '0;
      rg_cq01h <= '0;
      rp_cq01h <= '0;
      rs_cq01h <= '0;
      sq_cq01h <= '0;
      rl_cq01h <= '0;
    end else begin
      for (int t = 0; t < S; t++) wl_cq01h[t] <= tk_cq00h[t * A] || rstl_cq00h[t];
      rw_cq01h <= rstl_cq00h;
      ck_cq01h <= ck_d_cq00h;
      rg_cq01h <= rgl_cq00h;
      rp_cq01h <= rpl_cq00h;
      rs_cq01h <= restore_cq00h;
      sq_cq01h <= squash_cq00h;
      rl_cq01h <= release_cq00h;
    end
  end
  always_ff @(posedge ooe_core_clk) begin
    rsc_cq01h <= restore_ckpt_cq00h;     // payload, read only with rs
  end

  // -- the captured group (OI-83 (b)) -----------------------------------------
  // Rename's register of the group, captured as it arrives, clocked on this
  // module's lead of it (some slot's write); its leads a cycle on.
  logic [S-1:0]    wl_cq02h, rw_cq02h;
  logic [S*C-1:0]  ck_cq02h;
  logic            po_en_cq01h;
  // Its valid, slot, destination and write bits twice, each (* keep *)
  // (NGD-7): one leaves for the reads, one drives this module's writes.
  (* keep *) logic [A-1:0]    pi_v_cq02h, pi_gwe_cq02h;
  (* keep *) logic [A*LS-1:0] pi_slot_cq02h;
  (* keep *) logic [A*4-1:0]  pi_dst_cq02h;
  (* keep *) logic [A-1:0]    pq_v_cq02h, pq_gwe_cq02h;
  (* keep *) logic [A*LS-1:0] pq_slot_cq02h;
  (* keep *) logic [A*4-1:0]  pq_dst_cq02h;
  assign po_v_cq02h    = pq_v_cq02h;
  assign po_gwe_cq02h  = pq_gwe_cq02h;
  assign po_slot_cq02h = pq_slot_cq02h;
  assign po_dst_cq02h  = pq_dst_cq02h;
  logic [A-1:0]    po_rst_cq02h, po_br_cq02h;
  logic [A*LC-1:0] po_ckpt_cq02h;
  assign po_en_cq01h = wl_cq01h != '0;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      wl_cq02h <= '0;
      rw_cq02h <= '0;
      ck_cq02h <= '0;
    end else begin
      wl_cq02h <= wl_cq01h;
      rw_cq02h <= rw_cq01h;
      ck_cq02h <= ck_cq01h;
    end
  end
  // The valid bits every cycle (A flops): no group arrives as no write.
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      pi_v_cq02h <= '0;
      pq_v_cq02h <= '0;
    end else begin
      pi_v_cq02h <= pw_v_cq01h;
      pq_v_cq02h <= pw_v_cq01h;
    end
  end
  always_ff @(posedge ooe_core_clk) begin
    if (po_en_cq01h) begin
      pi_slot_cq02h  <= pw_slot_cq01h;
      pq_slot_cq02h  <= pw_slot_cq01h;
      po_rst_cq02h   <= pw_rst_cq01h;
      pi_dst_cq02h   <= pw_dst_cq01h;
      pq_dst_cq02h   <= pw_dst_cq01h;
      pi_gwe_cq02h   <= pw_gwe_cq01h;
      pq_gwe_cq02h   <= pw_gwe_cq01h;
      po_gname_cq02h <= pw_gname_cq01h;
      po_pdst_cq02h  <= pw_pdst_cq01h;
      po_pwe_cq02h   <= pw_pwe_cq01h;
      po_pname_cq02h <= pw_pname_cq01h;
      po_br_cq02h    <= pw_br_cq01h;
      po_ckpt_cq02h  <= pw_ckpt_cq01h;
    end
  end

  // A slot's speculative maps as they stand after the group's port k's own
  // writes and those of the lower ports naming the same slot: what a branch
  // on port k checkpoints.
  function automatic logic [MW-1:0] map_after(input logic [S*MW-1:0] q, input int k);
    logic [MW-1:0]  m;
    logic [LS-1:0]  t;
    t = pi_slot_cq02h[k * LS +: LS];
    m = '0;
    for (int u = 0; u < S; u++) if (t == LS'(u)) m = q[u * MW +: MW];
    // Every write as a decoder: no index computed and written through.
    for (int p = 0; p < A; p++)
      if (p <= k && pi_v_cq02h[p] && !po_rst_cq02h[p] && pi_slot_cq02h[p * LS +: LS] == t) begin
        for (int a = 0; a < NG; a++)
          if (pi_gwe_cq02h[p] && pi_dst_cq02h[p * 4 +: 4] == 4'(a)) m[a * GW +: GW] = po_gname_cq02h[p * GW +: GW];
        for (int a = 0; a < NP; a++)
          if (po_pwe_cq02h[p] && po_pdst_cq02h[p * 2 +: 2] == 2'(a)) m[NG * GW + a * PW +: PW] = po_pname_cq02h[p * PW +: PW];
      end
    map_after = m;
  endfunction

  // The speculative maps are two copies, each (* keep *) (OA-20 (b), DA
  // 2026-10-21): rto_cq02h leaves as rat_cq02h, read only by Rename 1's
  // RAT read at its budget of 4; rin_cq02h is this module's own, driving
  // the hold and the checkpoints' capture (NGD-7: one register for both
  // measured 11.7 NGD to the capture against the output's 4).
  (* keep *) logic [S*MW-1:0] rto_cq02h, rin_cq02h;
  assign rat_cq02h = rto_cq02h;

  // Each branch port's checkpoint.
  logic [A*MW-1:0] ck_map_cq02h;
  always_comb
    for (int k = 0; k < A; k++) ck_map_cq02h[k * MW +: MW] = map_after(rin_cq02h, k);

  // -- the speculative maps --------------------------------------------------
  // A registered whole-map event's map, per slot: release, else squash,
  // else restore. An entry the group writes takes the last such port's name
  // over it.
  logic [S-1:0]       whole_cq01h;
  logic               pkeep;                   // the control pend-over-event
`ifdef CCV_CHECK_RAT
  assign pkeep = ctl_pkeep;
`else
  assign pkeep = 1'b0;
`endif
  logic [S*MW-1:0]    base_cq02h;
  logic [S*NG-1:0]    g_wr_cq01h;              // a port of the group writes GPR entry (s, a)
  logic [S*NG*GW-1:0] g_name_cq01h;
  logic [S*NP-1:0]    p_wr_cq01h;
  logic [S*NP*PW-1:0] p_name_cq01h;
  // A slot's checkpoint c, by its registered restore's index.
  function automatic logic [MW-1:0] ck_pick(input logic [C*MW-1:0] ck, input logic [LC-1:0] c);
    ck_pick = '0;
    for (int k = 0; k < C; k++) if (c == LC'(k)) ck_pick = ck[k * MW +: MW];
  endfunction
  always_comb begin
    g_wr_cq01h   = '0;
    g_name_cq01h = '0;
    p_wr_cq01h   = '0;
    p_name_cq01h = '0;
    for (int t = 0; t < S; t++) begin
      whole_cq01h[t] = rl_cq01h[t] || sq_cq01h[t] || rs_cq01h[t];
      base_cq02h[t * MW +: MW] = rl_cq01h[t] ? {{NP{PZERO}}, {NG{GZERO}}} :
                                 sq_cq01h[t] ? crat_cq02h[t * MW +: MW] :
                                 ck_pick(ckpt_cq02h[t * C * MW +: C * MW], rsc_cq01h[t * LC +: LC]);
      // The captured group's writes, but none in a slot whose event this
      // edge applies (OI-83 (b) (3): the event wins).
      for (int p = 0; p < A; p++)
        if (pi_v_cq02h[p] && 32'(pi_slot_cq02h[p * LS +: LS]) == t && (!whole_cq01h[t] || pkeep)) begin
          for (int a = 0; a < NG; a++)
            if (pi_gwe_cq02h[p] && pi_dst_cq02h[p * 4 +: 4] == 4'(a)) begin
              g_wr_cq01h[t * NG + a]                = 1'b1;
              g_name_cq01h[(t * NG + a) * GW +: GW] = po_gname_cq02h[p * GW +: GW];
            end
          for (int a = 0; a < NP; a++)
            if (po_pwe_cq02h[p] && po_pdst_cq02h[p * 2 +: 2] == 2'(a)) begin
              p_wr_cq01h[t * NP + a]                = 1'b1;
              p_name_cq01h[(t * NP + a) * PW +: PW] = po_pname_cq02h[p * PW +: PW];
            end
        end
    end
  end

  // A slot's speculative maps are one gate, clocked on its group's write or
  // a registered whole-map event. Per-entry gates leave a mispredict
  // clocking the entries it does not change (most of a map still holds its
  // checkpoint's names), and telling which it changes is a compare, 12 NGD
  // as an enable, or "written since checkpoint c" bits, 320 flops more. An
  // entry neither written nor in a whole-map event keeps its value, as an
  // AND-OR rather than a held if, so synthesis keeps the slot's enable.
  logic [S-1:0]    rat_en_cq01h;
  logic [S*MW-1:0] rat_nx_cq01h;
  always_comb
    for (int t = 0; t < S; t++) begin
      rat_en_cq01h[t] = wl_cq02h[t] || whole_cq01h[t];
      for (int a = 0; a < NG; a++)
        rat_nx_cq01h[t * MW + a * GW +: GW] =
            ({GW{g_wr_cq01h[t * NG + a]}} & g_name_cq01h[(t * NG + a) * GW +: GW]) |
            ({GW{!g_wr_cq01h[t * NG + a] && whole_cq01h[t]}} & base_cq02h[t * MW + a * GW +: GW]) |
            ({GW{!g_wr_cq01h[t * NG + a] && !whole_cq01h[t]}} & rin_cq02h[t * MW + a * GW +: GW]);
      for (int a = 0; a < NP; a++)
        rat_nx_cq01h[t * MW + NG * GW + a * PW +: PW] =
            ({PW{p_wr_cq01h[t * NP + a]}} & p_name_cq01h[(t * NP + a) * PW +: PW]) |
            ({PW{!p_wr_cq01h[t * NP + a] && whole_cq01h[t]}} & base_cq02h[t * MW + NG * GW + a * PW +: PW]) |
            ({PW{!p_wr_cq01h[t * NP + a] && !whole_cq01h[t]}} & rin_cq02h[t * MW + NG * GW + a * PW +: PW]);
    end

  for (genvar t = 0; t < S; t++) begin : g_rat
    always_ff @(posedge ooe_core_clk) begin
      if (rst_r01h) begin
        rto_cq02h[t * MW +: MW] <= {{NP{PZERO}}, {NG{GZERO}}};
        rin_cq02h[t * MW +: MW] <= {{NP{PZERO}}, {NG{GZERO}}};
      end else if (rat_en_cq01h[t]) begin
        rto_cq02h[t * MW +: MW] <= rat_nx_cq01h[t * MW +: MW];
        rin_cq02h[t * MW +: MW] <= rat_nx_cq01h[t * MW +: MW];
      end
    end
  end

  // -- the committed maps ----------------------------------------------------
  // The retire-stage register's writes in port order, then a
  // restore-allocate's, which the group's ports carry; a release maps the
  // slot to the zero registers, under any write.
  logic [S*NG-1:0]    c_wr_cq01h;
  logic [S*NG*GW-1:0] c_name_cq01h;
  logic [S*NP-1:0]    cp_wr_cq01h;
  logic [S*NP*PW-1:0] cp_name_cq01h;
  always_comb begin
    c_wr_cq01h    = '0;
    c_name_cq01h  = '0;
    cp_wr_cq01h   = '0;
    cp_name_cq01h = '0;
    for (int t = 0; t < S; t++) begin
      for (int r = 0; r < R; r++) begin
        for (int a = 0; a < NG; a++)
          if (ret_gwe_cq01h[t * R + r] && ret_dst_cq01h[(t * R + r) * 4 +: 4] == 4'(a)) begin
            c_wr_cq01h[t * NG + a]                = 1'b1;
            c_name_cq01h[(t * NG + a) * GW +: GW] = ret_gname_cq01h[(t * R + r) * GW +: GW];
          end
        for (int a = 0; a < NP; a++)
          if (ret_pwe_cq01h[t * R + r] && ret_pdst_cq01h[(t * R + r) * 2 +: 2] == 2'(a)) begin
            cp_wr_cq01h[t * NP + a]                = 1'b1;
            cp_name_cq01h[(t * NP + a) * PW +: PW] = ret_pname_cq01h[(t * R + r) * PW +: PW];
          end
      end
      for (int p = 0; p < A; p++)
        if (pi_v_cq02h[p] && po_rst_cq02h[p] && 32'(pi_slot_cq02h[p * LS +: LS]) == t) begin
          for (int a = 0; a < NG; a++)
            if (pi_gwe_cq02h[p] && pi_dst_cq02h[p * 4 +: 4] == 4'(a)) begin
              c_wr_cq01h[t * NG + a]                = 1'b1;
              c_name_cq01h[(t * NG + a) * GW +: GW] = po_gname_cq02h[p * GW +: GW];
            end
          for (int a = 0; a < NP; a++)
            if (po_pwe_cq02h[p] && po_pdst_cq02h[p * 2 +: 2] == 2'(a)) begin
              cp_wr_cq01h[t * NP + a]                = 1'b1;
              cp_name_cq01h[(t * NP + a) * PW +: PW] = po_pname_cq02h[p * PW +: PW];
            end
        end
    end
  end

  // Each slot's committed GPRs one gate, its predicates another: clocked on
  // a retirement writing them (this module's copy of the retire-stage
  // register's gwe, pwe), a restore-allocate or a release. An entry not
  // written holds, as an AND-OR.
  logic [S-1:0]       cg_en_cq01h, cp_en_cq01h;
  logic [S*MW-1:0]    crat_nx_cq01h;
  always_comb
    for (int t = 0; t < S; t++) begin
      cg_en_cq01h[t] = rl_cq01h[t] || rw_cq02h[t] || rg_cq01h[t * R +: R] != '0;
      cp_en_cq01h[t] = rl_cq01h[t] || rw_cq02h[t] || rp_cq01h[t * R +: R] != '0;
      for (int a = 0; a < NG; a++)
        crat_nx_cq01h[t * MW + a * GW +: GW] =
            ({GW{c_wr_cq01h[t * NG + a]}} & c_name_cq01h[(t * NG + a) * GW +: GW]) |
            ({GW{!c_wr_cq01h[t * NG + a] && rl_cq01h[t]}} & GZERO) |
            ({GW{!c_wr_cq01h[t * NG + a] && !rl_cq01h[t]}} & crat_cq02h[t * MW + a * GW +: GW]);
      for (int a = 0; a < NP; a++)
        crat_nx_cq01h[t * MW + NG * GW + a * PW +: PW] =
            ({PW{cp_wr_cq01h[t * NP + a]}} & cp_name_cq01h[(t * NP + a) * PW +: PW]) |
            ({PW{!cp_wr_cq01h[t * NP + a] && rl_cq01h[t]}} & PZERO) |
            ({PW{!cp_wr_cq01h[t * NP + a] && !rl_cq01h[t]}} & crat_cq02h[t * MW + NG * GW + a * PW +: PW]);
    end

  for (genvar t = 0; t < S; t++) begin : g_crat
    always_ff @(posedge ooe_core_clk) begin
      if (rst_r01h)            crat_cq02h[t * MW +: NG * GW] <= {NG{GZERO}};
      else if (cg_en_cq01h[t]) crat_cq02h[t * MW +: NG * GW] <= crat_nx_cq01h[t * MW +: NG * GW];
    end
    always_ff @(posedge ooe_core_clk) begin
      if (rst_r01h)            crat_cq02h[t * MW + NG * GW +: NP * PW] <= {NP{PZERO}};
      else if (cp_en_cq01h[t]) crat_cq02h[t * MW + NG * GW +: NP * PW] <= crat_nx_cq01h[t * MW + NG * GW +: NP * PW];
    end
  end

  // -- the checkpoints -------------------------------------------------------
  // Checkpoint (s, c) is written when a branch port of the group names it,
  // with the maps as they stand after that port's writes; its enable is
  // this module's flop of the same, from the go's cycle.
  logic [S*C-1:0]    ckpt_wr_cq01h;
  logic [S*C*MW-1:0] ckpt_nx_cq01h;
  always_comb begin
    ckpt_wr_cq01h = '0;
    ckpt_nx_cq01h = '0;
    for (int p = 0; p < A; p++)
      for (int i = 0; i < S * C; i++)
        if (pi_v_cq02h[p] && !po_rst_cq02h[p] && po_br_cq02h[p] &&
            pi_slot_cq02h[p * LS +: LS] == LS'(i / C) && po_ckpt_cq02h[p * LC +: LC] == LC'(i % C)) begin
          ckpt_wr_cq01h[i]            = 1'b1;
          ckpt_nx_cq01h[i * MW +: MW] = ck_map_cq02h[p * MW +: MW];
        end
  end
  // A slot's checkpoints are not written at its event's edge: the branch
  // naming one is younger than the event, and its group is dropped.
  logic [S*C-1:0] ckpt_en_cq01h, ck_ev_cq01h;
  always_comb
    for (int i = 0; i < S * C; i++) ck_ev_cq01h[i] = whole_cq01h[i / C] && !pkeep;
  assign ckpt_en_cq01h = ck_cq02h & ~ck_ev_cq01h;
  for (genvar i = 0; i < S * C; i++) begin : g_ckpt
    always_ff @(posedge ooe_core_clk) begin
      if (ckpt_en_cq01h[i]) ckpt_cq02h[i * MW +: MW] <= ckpt_nx_cq01h[i * MW +: MW];
    end
  end

  // The leads are exact: the group writes only the slots its lead named,
  // each checkpoint exactly when its lead says, and the retire-stage
  // register carries the decision copied here; a restore-allocate port only
  // where its lead says.
  logic [S-1:0] grp_sl_cq01h, rst_sl_cq01h;
  always_comb begin
    grp_sl_cq01h = '0;
    rst_sl_cq01h = '0;
    for (int p = 0; p < A; p++)
      for (int t = 0; t < S; t++)
        if (pi_v_cq02h[p] && pi_slot_cq02h[p * LS +: LS] == LS'(t)) begin
          grp_sl_cq01h[t] = 1'b1;
          if (po_rst_cq02h[p]) rst_sl_cq01h[t] = 1'b1;
        end
  end
  `CCV_ASSERT(group_led, (grp_sl_cq01h & ~wl_cq02h) == '0)
  `CCV_ASSERT(restore_alloc_led, rst_sl_cq01h == rw_cq02h)
  `CCV_ASSERT(ckpt_led, ckpt_wr_cq01h == ck_cq02h)
  `CCV_ASSERT(retire_led, ret_gwe_cq01h == rg_cq01h && ret_pwe_cq01h == rp_cq01h)
  // The group names no slot a registered whole-map event names (see above).
  logic [S-1:0] renamed_cq01h;
  always_comb begin
    renamed_cq01h = '0;
    for (int p = 0; p < A; p++)
      for (int t = 0; t < S; t++)
        if (pw_v_cq01h[p] && !pw_rst_cq01h[p] && pw_slot_cq01h[p * LS +: LS] == LS'(t)) renamed_cq01h[t] = 1'b1;
  end
  `CCV_ASSERT(rename_excludes_events, (renamed_cq01h & whole_cq01h) == '0)

endmodule
`undef CCV_CLK
`undef CCV_RST
