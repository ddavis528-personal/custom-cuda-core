//===-- ooe_sched.sv - OOE scheduler: ready, request and grant registers --===//
//
// Spec: the design doc's Select and Stage boundaries sections; OA's
//       responses OI-51 (the ready register), OI-53 (the request register,
//       the split of select's terms) and OI-54 (V-73: the ready register
//       captures every edge after which a line or a valid row it reads
//       changes, the stop lead formed here from the replay rule).
//
// Three stages' registers around two helpers, all three registers gated
// from this module's own flops (CG-5):
//
//   Ready: ooe_ready over the RS's matrix and ooe_wake's lines (as they
//   stand after this edge) into the ready register. Its enable is the flop
//   of the leads: ooe_wake's timer lead (a producer's line changes by
//   timer at the edge after next), of lines some row's cell selects, and
//   its event lead (a miss, or a completion past L1,
//   changes lines at the edge after next: each known a cycle ahead, a
//   completion by its channel's valid), ooe_rs's
//   allocation lead (a row written at this edge), the stop lead,
//   OI-50's replay rule over iss, dep and msd as they stand after this
//   edge (an entry returns to Waiting at the next cycle's hop; a producer
//   granted at this edge is not issued until after it, so the rule's
//   co-grant arm, OI-133, needs no term of its own here), and the
//   replay lead, a producer some row reads replayed at this edge: ooe_wake
//   takes the stop at this edge, so the lines it gives this module drop at
//   the next one, which the stop lead's capture precedes (a grandchild of
//   a missed load, granted on its parent's bypass before the parent's
//   replay was known, stayed ready a cycle and issued twice without it).
//
//   Request: per entry, valid, not issued, its warp active, and a copy's
//   sources confirmed (its row empty), as they stand after this edge. Its
//   enable: the grant register's OR (a grant's not-issued fall, which the
//   grant register masks at select until then), the stop lead (a replay's
//   return on time), and the flop of "the register differs from its next
//   value, and this edge does not capture it", so anything else (a warp's active, a copy's confirmation, a
//   row written) is captured one edge late. A late rise costs a cycle at most; a late fall
//   is safe, since a warp leaves Active only by a squash of all its
//   entries and valid is read live, with past rename (vel_cq03h).
//
//   Select: ooe_select (FB 1) over those registers and the live memop
//   terms, into the grant register. The grant register is three copies,
//   each (* keep *): one leaves (grant_cq04h), one masks the requests
//   (NGD-7), and one goes to ooe_wake alone (grant_w_cq04h), whose timers
//   take it straight into their enables (OA's response OI-58: ooe_wake's
//   CG-5 waiver, the grant at 2 NGD).
//   Its enable is "something may request or something is held": the
//   request and ready registers' AND, or the mask copy's OR.

//   The ret hold (OA's rev 293): no branch or call is selected for RCU the
//   cycle after a ret is, so the ROB's one outcome path never resolves a
//   branch beside a ret (a ret resolves a cycle after its done). A
//   register of the RCU entries' ret bits (ret_cq03h), on the grant
//   register's enable, is ANDed with the grant register after the edge
//   (not before it: the grant is select's deepest path, from vel_cq03h),
//   and its OR takes this cycle's branches and calls (brk_cq03h) from
//   select. It is the model's rule exactly (a ret's grant, not its
//   request), the hold's OR at select's request.
//
//   The idle-R force (RA-17, OA's revs 298-299; IRK, 0 = off): a migration
//   takes R's PRF ports a row a cycle R holds no op, so while one is in
//   flight (mig_cq02h, a lead: the next cycle's) select holds every RCU
//   entry whose footprint has R (res bit 4) in a cycle whose cycle before
//   last ended IRK - 2 cycles running with R granted: never IRK running.
//   The run is the model's r_run_, R's grants running whether or not a
//   migration is in flight: a register of the RCU entries' R bits
//   (rrq_cq04h, as rtq_cq04h) gives "R granted last cycle", and a count of
//   the cycles before it (rrun_cq04h) completes it. The force is a
//   register (force_cq04h) decided a cycle ahead, so select reads a flop:
//   deciding it on the last cycle's grant, an OR over the entries after
//   the edge, put vel_cq03h at 25.2. The three are the grant register's
//   clock gate, its enable adding a run or force to end.
//
// The reference is the model's ready and request registers and its
// sectioned select (Core::readyRegister, Core::requestRegister,
// Core::selectSectioned); test/ooe/trio_tb.cpp drives this module with
// ooe_rs and ooe_wake, assembled, from the model and compares the ready
// register, the request register and the grants (OA's response OI-45). It
// is this module's clock-gating bench too: its enables are leads of its
// neighbours' state, which only they give in their own frame.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK ooe_core_clk
`define CCV_RST rst_r01h
module ooe_sched #(
  parameter int N  = 45,     // RS entries (CCV_P_RS_RCU + CCV_P_RS_MIU)
  parameter int NR = 30,     // RCU-class entries, [0, NR)
  parameter int S  = 4,      // tier-1 warp slots (CCV_TIER1_WARPS)
  parameter int FB = 1,      // the RCU class's section fallback (OA's response IS-9)
  parameter int IRK = 0,     // RA-17's idle-R run, idle_r_k (0: no force)
  localparam int NM = N - NR,
  localparam int LS = $clog2(S),
  localparam int W  = $clog2(N),
  localparam int WL = 4,     // wake lines per producer
  localparam int CW = 2      // a cell's line select
) (
  input  logic              ooe_core_clk,
  input  logic              ooe_rst_r00h,
  // The ready and request registers' next values, and the stop lead's
  // terms: the RS's matrix and ooe_wake's lines, and each entry's state
  // (issued counting the grant leaving now and this edge's hop), as they
  // stand after this edge.
  input  logic [N*N-1:0]    dep_cq02h,
  input  logic [N*N*CW-1:0] code_cq02h,
  input  logic [N*WL-1:0]   wake_cq02h,
  input  logic [N-1:0]      valid_cq02h,
  input  logic [N-1:0]      iss_cq02h,
  input  logic [N*LS-1:0]   slot_cq02h,
  input  logic [S-1:0]      active_cq02h,
  input  logic [N-1:0]      copy_cq02h,
  // Leads, into the enable flops.
  input  logic [N-1:0]      msd_cq02h,     // missed: the replay rule's (OI-50)
  input  logic [N-1:0]      mis_cq02h,     // ooe_wake: missed at the last edge, held from the next cycle
  input  logic [N-1:0]      fin_cq02h,     // ooe_wake: the result is final
  input  logic [N-1:0]      prod_cq02h,    // ooe_rs: the entry writes a register some entry may wake on
  input  logic [N*WL-1:0]   wtl_cq02h,     // ooe_wake: a producer's line changes by timer at the edge after next
  input  logic              wml_cq02h,     // ooe_wake: a miss or a completion does
  input  logic              alloc_cq02h,   // ooe_rs: a row is written at this edge
  // Select's live terms.
  input  logic [N-1:0]      vel_cq03h,     // valid and past rename's stages (ooe_rs)
  input  logic [N-1:0]      siss_cq03h,
  input  logic [N*N-1:0]    sdep_cq03h,
  input  logic [N*LS-1:0]   sslot_cq03h,
  input  logic [N*9-1:0]    res_cq03h,
  input  logic [N-1:0]      chas_cq03h,
  input  logic [N*W-1:0]    cidx_cq03h,
  input  logic [NR*NR-1:0]  older_r_cq03h,
  input  logic [NM*NM-1:0]  older_m_cq03h,
  input  logic [3:0]        busy_cq03h,    // MIU pipes a bulk discard took
  input  logic [S-1:0]      block_cq03h,
  input  logic [3:0]        cret_cq02h,    // MA-5: a credit back per memop slot next cycle (a lead)
  input  logic [NR-1:0]     ret_cq03h,     // an RCU entry is a ret (not a copy)
  input  logic [NR-1:0]     brk_cq03h,     // an RCU entry is a branch or call, not a ret (not a copy)
  input  logic              mig_cq02h,     // a migration is in flight next cycle (RA-17; a lead)
  output logic [N-1:0]      grant_cq04h,
  output logic [N-1:0]      grant_w_cq04h, // the same, for ooe_wake's timers
  output logic              gnt_l_cq04h    // the grant register is clocked at the next edge (ooe_rs's issue register)
);

  logic rst_r01h;
  always_ff @(posedge ooe_core_clk) begin
    rst_r01h <= ooe_rst_r00h;
  end

  // -- Leads ----------------------------------------------------------------
  // The stop lead: OI-50's replay rule, an issued entry with a producer
  // not issued or missed, over the state after this edge (a producer
  // granted with it at this edge counts as not issued here: the co-grant
  // arm, OI-133, which ooe_rs and ooe_wake decide from their last grant).
  // The same rule gives this cycle's replays (rep): ooe_rs and ooe_wake
  // take them at this edge, so issued after it is iss less rep (OA's
  // response OI-45: the model's order, a replayed entry requesting at
  // once; V-65 holds it to ooe_rs's issued register an edge later).
  // The stop lead is the next cycle's replays, so the request register
  // captures them on their edge: the rule over issued after this cycle's
  // stops, the matrix as it stands and the held misses with this cycle's
  // pulses. Next cycle's issued and matrix only shrink by then, and its held
  // misses only grow by the pulses, so the lead is a superset.
  logic         stop_cq02h;
  (* keep *) logic [N-1:0] gnt_cq04h;      // the grant register's mask copy
  logic [N-1:0] rep_cq02h, ise_cq02h, gon_cq02h, isg_cq02h, cnf_cq02h;
  logic [N*N-1:0] dpm_cq02h;                      // the matrix less this cycle's confirmations' columns
  always_comb begin
    // Issued counts the grant leaving now (the grant register), which
    // ooe_wake takes at this edge.
    isg_cq02h = iss_cq02h | gnt_cq04h;
    // A producer's issued bit before this edge's grants, as ooe_rs's rule
    // reads it (V-65): an entry issued on a producer replayed and granted
    // again at this edge is replayed.
    for (int i = 0; i < N; i++)
      rep_cq02h[i] = isg_cq02h[i] && (dep_cq02h[i * N +: N] & (~iss_cq02h | msd_cq02h)) != '0;
    ise_cq02h  = isg_cq02h & ~rep_cq02h;
    // This cycle's confirmations (OA's response OI-45 (1)): ooe_rs and
    // ooe_wake free them at this edge; their columns clear in the matrix an
    // edge later, so the ready and request terms read the matrix less them.
    for (int i = 0; i < N; i++)
      cnf_cq02h[i] = isg_cq02h[i] && dep_cq02h[i * N +: N] == '0 && (fin_cq02h[i] || !prod_cq02h[i]);
    for (int i = 0; i < N; i++) dpm_cq02h[i * N +: N] = dep_cq02h[i * N +: N] & ~cnf_cq02h;
    gon_cq02h        = ~ise_cq02h | msd_cq02h | mis_cq02h;
    stop_cq02h = 1'b0;
    for (int i = 0; i < N; i++)
      stop_cq02h = stop_cq02h | (ise_cq02h[i] && (dpm_cq02h[i * N +: N] & gon_cq02h) != '0);
  end

  // The timer lead, of lines some row reads: a line no cell selects
  // changes no row.
  logic tl_cq02h;
  always_comb begin
    logic [N*WL-1:0] read;
    read = '0;
    for (int i = 0; i < N; i++)
      for (int j = 0; j < N; j++)
        for (int k = 0; k < WL; k++)
          read[j * WL + k] = read[j * WL + k] | (dep_cq02h[i * N + j] && code_cq02h[(i * N + j) * CW +: CW] == CW'(k));
    tl_cq02h = (wtl_cq02h & read) != '0;
  end

  // The replay lead: a producer replayed at this edge, of a column some
  // row reads. ooe_wake takes the stop at this edge, so its lines as this
  // module reads them drop at the next edge (the model's ready_rep_late),
  // after the stop lead's capture at this one.
  logic rl_cq02h;
  always_comb begin
    logic [N-1:0] col;
    col = '0;
    for (int i = 0; i < N; i++) col = col | dep_cq02h[i * N +: N];
    rl_cq02h = (rep_cq02h & col) != '0;
  end

  // -- Ready register ---------------------------------------------------------
  logic [N-1:0] ready_cq02h;
  logic [N-1:0] ready_cq03h;
  logic         ready_en_cq03h, stop_cq03h, alc_cq03h;
  logic         gl_cq05h;                   // a grant some row depends on left at the last edge
  logic         ready_en_cq02h;
  // A row not valid reads not ready (only a valid row requests): a row
  // written ready then changes its bit, so the allocation lead clocks a change.
  ooe_ready #(.N(N), .W(WL), .CW(CW)) u_ready (.dep_cq02h(dpm_cq02h), .code_cq02h(code_cq02h),
                                             .wake_cq02h(wake_cq02h), .ready_cq02h(ready_cq02h));

  // -- Request register -------------------------------------------------------
  logic [N-1:0] rq_cq02h;
  (* keep *) logic [N-1:0] rq_cq03h;      // kept apart from its copy rq_l (gnt_l)
  logic         chg_cq04h, rq_en_cq02h, gnt_en_cq03h;
  always_comb
    for (int e = 0; e < N; e++)
      rq_cq02h[e] = valid_cq02h[e] && !ise_cq02h[e] && active_cq02h[slot_cq02h[e * LS +: LS]] &&
                    (!copy_cq02h[e] || dpm_cq02h[e * N +: N] == '0);
  assign rq_en_cq02h  = chg_cq04h || stop_cq03h || gnt_cq04h != '0 || alc_cq03h;

  // -- Select -----------------------------------------------------------------
  logic [N-1:0] cand_cq03h, grant_cq03h, lost_cq03h;
  // The ret hold: a ret granted last cycle holds this cycle's branches and
  // calls off RCU.
  logic [NR-1:0] rtq_cq04h;                // the RCU entries' ret bits, last cycle
  logic [NR-1:0] hold_cq04h;
  assign hold_cq04h = (gnt_cq04h[NR-1:0] & rtq_cq04h) != '0 ? brk_cq03h : '0;
  // The idle-R force (RA-17): R granted last cycle (rg) and the run before
  // it (rrun) give the run as last cycle ended (rnx); the force register
  // takes it a cycle ahead, beside the migration's lead, so select reads a
  // flop (R's grant last cycle is select's own deepest path, and its OR
  // over the entries put vel_cq03h at 25.2). The three registers are the
  // grant register's clock gate, whose enable adds a run or force to end.
  logic [NR-1:0] rrq_cq04h;                // the RCU entries' R bits, last cycle
  logic [NR-1:0] rbit_cq03h;
  always_comb
    for (int e = 0; e < NR; e++) rbit_cq03h[e] = res_cq03h[e * 9 + 4];
  localparam int RW = IRK > 2 ? $clog2(IRK) : 1;
  logic          rg_cq04h;
  (* keep *) logic force_cq04h;          // kept apart from its copy force_l (gnt_l)
  // and a copy per RCU entry for select (fcp), each (* keep *): one force
  // register's inverse fed every RCU request, 750 loads, 4 NGD of fanout
  // at the head of the flop-to-flop path.
  (* keep *) logic [NR-1:0] fcp_cq04h;
  (* keep *) logic [RW-1:0] rrun_cq04h;  // and rrun_l
  logic [RW-1:0] rnx_cq04h;
  assign rg_cq04h  = (gnt_cq04h[NR-1:0] & rrq_cq04h) != '0;
  assign rnx_cq04h = !rg_cq04h ? '0 : 32'(rrun_cq04h) >= IRK - 1 ? rrun_cq04h : rrun_cq04h + 1'b1;

  // MA-5 (AR 345/347, OA-412): MIU's credits per memop channel slot,
  // P0-P3, CCV_MEMOP_CREDITS each; a memop goes on the lowest credited slot
  // of its footprint. cnx is A, the credits left once this cycle's
  // departures (last cycle's grants, and a bulk discard on P0) are out,
  // with this cycle's returns in. The flag select reads is registered:
  // set for the next cycle when A covers a grant made now, A >= 2, or
  // A == 1 with no grant possible now (flag clear). At A == 1 and no event
  // it alternates, so the enable takes A == 1 too.
  localparam int MCW = $clog2(ccv_prov_pkg::CCV_MEMOP_CREDITS + 1);
  logic [3:0]    cret_cq03h;              // a credit back on each slot this cycle
  logic [3:0]    cok_cq03h;               // the slots select may grant on
  logic [3:0]    cokd_cq04h;              // the flags last cycle's grants read (held between grants)
  logic          dsc_cq04h;               // last cycle's bulk discard (P0)
  logic [3:0]    used_cq04h, cok_nx_cq02h, cfp_cq04h;
  logic [MCW-1:0] ccnt_cq04h [4];          // last cycle's A
  logic [MCW-1:0] cnx_cq03h [4];
  logic          cone_cq04h, cc_en_cq03h;
  always_comb begin
    used_cq04h = {3'b0, dsc_cq04h};
    for (int e = NR; e < N; e++) begin
      cfp_cq04h = res_cq03h[e * 9 + 5 +: 4] & cokd_cq04h;
      if (gnt_cq04h[e]) used_cq04h = used_cq04h | (cfp_cq04h & (~cfp_cq04h + 4'd1));
    end
    cone_cq04h = 1'b0;
    for (int s = 0; s < 4; s++) begin
      cnx_cq03h[s] = ccnt_cq04h[s] - MCW'(used_cq04h[s]) + MCW'(cret_cq03h[s]);
      cone_cq04h   = cone_cq04h || ccnt_cq04h[s] == MCW'(1);
    end
  end
  // The flag's next value reads the same A, apart: the counter is a
  // stage-04 register (its own state, with the grants that leave it), the
  // flag a stage-03 one select reads beside ready, so A reaches the flag
  // only through the select loop (CCV-L23's declared feedback).
  logic [MCW-1:0] ca_cq04h [4];
  always_comb
    for (int s = 0; s < 4; s++) begin
      ca_cq04h[s]     = ccnt_cq04h[s] - MCW'(used_cq04h[s]) + MCW'(cret_cq03h[s]);
      cok_nx_cq02h[s] = ca_cq04h[s] >= MCW'(2) || (ca_cq04h[s] == MCW'(1) && !cok_cq03h[s]);
    end
  assign cc_en_cq03h = gnt_cq04h[N-1:NR] != '0 || dsc_cq04h || cret_cq03h != '0 || cone_cq04h || rst_r01h;
  // cret and dsc capture pulses from outside (CG-5: no enable of this
  // module's own flops can know of them); cokd is read only the cycle
  // after a grant, so it rides the grant register's enable.
  always_ff @(posedge ooe_core_clk) begin
    cret_cq03h <= cret_cq02h;
    dsc_cq04h  <= busy_cq03h[0];
  end
  always_ff @(posedge ooe_core_clk)
    if (gnt_en_cq03h) cokd_cq04h <= cok_cq03h;
  always_ff @(posedge ooe_core_clk)
    if (cc_en_cq03h)
      for (int s = 0; s < 4; s++) begin
        ccnt_cq04h[s] <= rst_r01h ? MCW'(ccv_prov_pkg::CCV_MEMOP_CREDITS) : cnx_cq03h[s];
        cok_cq03h[s]  <= rst_r01h ? 1'b1 : cok_nx_cq02h[s];
      end
  ooe_select #(.N(N), .NR(NR), .S(S), .FB(FB)) u_select (
    .rq_cq03h(rq_cq03h), .ready_cq03h(ready_cq03h), .gnt_cq03h(gnt_cq04h), .hold_cq03h(hold_cq04h), .rhold_cq03h(fcp_cq04h),
    .vel_cq03h(vel_cq03h),
    .iss_cq03h(siss_cq03h), .dep_cq03h(sdep_cq03h), .slot_cq03h(sslot_cq03h), .res_cq03h(res_cq03h),
    .chas_cq03h(chas_cq03h), .cidx_cq03h(cidx_cq03h), .older_r_cq03h(older_r_cq03h),
    .older_m_cq03h(older_m_cq03h), .busy_cq03h(busy_cq03h), .block_cq03h(block_cq03h), .cok_cq03h(cok_cq03h),
    .cand_cq03h(cand_cq03h), .grant_cq03h(grant_cq03h), .lost_cq03h(lost_cq03h));
  (* keep *) logic [N-1:0] gnt_out_cq04h;  // the grant register's leaving copy
  (* keep *) logic [N-1:0] gnt_w_cq04h;    // and ooe_wake's
  assign gnt_en_cq03h      = (rq_cq03h & ready_cq03h) != '0 || gnt_cq04h != '0 || force_cq04h || rrun_cq04h != '0;
  assign ready_en_cq02h    = ready_en_cq03h || gl_cq05h;
  // A grant moves a ready bit at the edge it arrives only through the lead
  // line (WL - 1) of a producer of latency LEAD + 1, threshold age 1; every
  // other line's threshold is age 2 or later, which ooe_wake's timer lead
  // foresees. So the columns some row reads by the lead line.
  logic [N-1:0] dcol_cq02h;
  always_comb begin
    dcol_cq02h = '0;
    for (int i = 0; i < N; i++)
      for (int j = 0; j < N; j++)
        dcol_cq02h[j] = dcol_cq02h[j] | (dep_cq02h[i * N + j] && code_cq02h[(i * N + j) * CW +: CW] == CW'(WL - 1));
  end
  assign grant_cq04h   = gnt_out_cq04h;
  assign grant_w_cq04h = gnt_w_cq04h;
  // gnt_l, a superset of the grant register's enable for ooe_rs's issue
  // register: a request pending, ready or not, in the term gnt_en reads
  // as a ready request. From copies of its registers that drive nothing
  // else (NGD-7: the originals start select's paths; a copy of the ready
  // register too put vel_cq03h over its cap), the grant term from the
  // output's own copy.
  (* keep *) logic [N-1:0]  rq_l_cq03h;
  (* keep *) logic          force_l_cq04h;
  (* keep *) logic [RW-1:0] rrun_l_cq04h;
  assign gnt_l_cq04h = rq_l_cq03h != '0 || gnt_out_cq04h != '0 || force_l_cq04h || rrun_l_cq04h != '0;
  `CCV_ASSERT(gnt_l_covers, gnt_l_cq04h || !((rq_cq03h & ready_cq03h) != '0 || gnt_cq04h != '0 || force_cq04h || rrun_cq04h != '0))

  // -- Registers --------------------------------------------------------------
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      ready_en_cq03h <= 1'b0;
      gl_cq05h       <= 1'b0;
      stop_cq03h     <= 1'b0;
      alc_cq03h      <= 1'b0;

      chg_cq04h      <= 1'b0;
    end else begin
      // A grant leaving now: ooe_wake takes it at this edge, and its lead
      // line may rise there (a latency of LEAD + 1, OA's response OI-45),
      // which no timer lead of ooe_wake's foresees.
      ready_en_cq03h <= tl_cq02h || wml_cq02h || alloc_cq02h || stop_cq02h || rl_cq02h;
      gl_cq05h       <= (gnt_cq04h & dcol_cq02h) != '0;
      stop_cq03h     <= stop_cq02h;
      alc_cq03h      <= alloc_cq02h;
      chg_cq04h      <= !rq_en_cq02h && rq_cq02h != rq_cq03h;
    end
  end
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      ready_cq03h   <= '0;
      rq_cq03h      <= '0;
      rq_l_cq03h    <= '0;
    end else begin
      if (ready_en_cq02h) ready_cq03h <= ready_cq02h & valid_cq02h;
      if (rq_en_cq02h) begin
        rq_cq03h   <= rq_cq02h;
        rq_l_cq03h <= rq_cq02h;
      end
    end
  end
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      gnt_cq04h     <= '0;
      gnt_out_cq04h <= '0;
      gnt_w_cq04h   <= '0;
      rtq_cq04h     <= '0;
    end else if (gnt_en_cq03h) begin
      gnt_cq04h     <= grant_cq03h;
      gnt_out_cq04h <= grant_cq03h;
      gnt_w_cq04h   <= grant_cq03h;
      rtq_cq04h     <= ret_cq03h;
    end
  end
  // The idle-R registers (RA-17), on the grant register's enable: the R
  // bits beside it (rg reads them only with it), the run as of the cycle
  // before last, saturating at IRK - 1, and the force. With nothing to
  // grant and no grant to clear, rg is 0, so the run and the force go to
  // 0, which their own terms in the enable cover.
  if (IRK == 0) begin : g_no_idle_r
    assign force_cq04h   = 1'b0;
    assign rrq_cq04h     = '0;
    assign rrun_cq04h    = '0;
    assign force_l_cq04h = 1'b0;
    assign fcp_cq04h     = '0;
    assign rrun_l_cq04h  = '0;
  end else begin : g_idle_r
    always_ff @(posedge ooe_core_clk) begin
      if (rst_r01h) begin
        rrq_cq04h     <= '0;
        rrun_cq04h    <= '0;
        force_cq04h   <= 1'b0;
        rrun_l_cq04h  <= '0;
        force_l_cq04h <= 1'b0;
        fcp_cq04h     <= '0;
      end else if (gnt_en_cq03h) begin
        rrq_cq04h     <= rbit_cq03h;
        rrun_cq04h    <= rnx_cq04h;
        force_cq04h   <= mig_cq02h && 32'(rnx_cq04h) >= IRK - 2;
        rrun_l_cq04h  <= rnx_cq04h;
        force_l_cq04h <= mig_cq02h && 32'(rnx_cq04h) >= IRK - 2;
        fcp_cq04h     <= {NR{mig_cq02h && 32'(rnx_cq04h) >= IRK - 2}};
      end
    end
  end

  // -- The input contract ------------------------------------------------------
  // What ooe_rs and ooe_wake give this module (test/ooe/trio_tb.cpp drives
  // them assembled): issued and the held misses name valid entries, and
  // every row written was led by alloc_cq02h the cycle before (the ready
  // and request registers' enables). A row not valid is don't-care: ooe_rs
  // leaves a freed row's bits in place.
  `CCV_ASSERT(iss_valid, (iss_cq02h & ~valid_cq02h) == '0)
  `CCV_ASSERT(msd_issued, (msd_cq02h & ~iss_cq02h) == '0)
  // RA-17: no cycle a migration is in flight ends IRK cycles running with
  // R granted (the model's check; with the force in place it never fires).
  // The run counts R's grants whether or not one is in flight, so the
  // force holds R at once for a migration that starts in a run. IRK 1 and
  // 2 would need the force from the lead alone, ungated: not built.
  `CCV_ASSERT(irk_range, IRK == 0 || IRK >= 3)
  `CCV_ASSERT_T(idle_r, IRK == 0 || !(`CCV_PAST(`CCV_PAST(mig_cq02h)) && rg_cq04h && 32'(rrun_cq04h) >= IRK - 1))
  `CCV_ASSERT_T(alloc_led, (valid_cq02h & ~`CCV_PAST(valid_cq02h)) == '0 || `CCV_PAST(alloc_cq02h))

endmodule
`undef CCV_CLK
`undef CCV_RST
