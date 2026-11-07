//===-- rcu_lanes.sv - RCU lane path: lane message, bypass, write-back ----===//
//
// Spec: docs/design-snapshots/rcu-arch-lane-memory.md (live: CCV RCU
//       Architecture, Lane and memory paths tab: Lane message assembly,
//       Bypass tracker, Lane write-back);
//       docs/design-snapshots/rcu-arch-partition.md (rcu_lanes's row, the
//       issue lead slice, the lane-message field groups);
//       docs/design-snapshots/rcu-arch-done-kill-reset.md (done slots 0-4,
//       the lane-op wakes).
//
// The S slots S0-S3: slot s's op has lead section s and owns the sections
// of its footprint, disjoint between slots (own[k], the owner of section
// k). An op reaches the lanes when the op-class decode calls it a lane op,
// an SFU op or a GPR copy; a predicate-only copy, a memop, an R op and a
// cont slot send nothing (class 0).
//
// COPIES lane copies c_l, lane l = copy c (32 in the block; 4 in the loop
// unit). Every copy carries the whole message: the per-section control is
// the same on every copy, the operands and the predicate bits its lane's.
//
// Port timing (local stages, cr01h = A-1, cr02h = A, cr03h = A+1, and so
// on; CCV_LAT_LANE 7, CCV_LAT_SFU 12 as the port names have them; the
// pipes follow the parameters):
//   cr01h  the S slots' issue valid lead and lead slice (RA-31): section
//          mask, sources, imm and merge used. Registered as iss_lead_q.
//   cr02h  A: each slot's payload and op-class decode, and rcu_pred's
//          active (the guard read in A). Section ownership from the
//          footprints; the bypass compare (stage I); the lane message's
//          lead fields (section_en, sec_pred_bit) and valid into their
//          flops; each section's control, its owner's lead bits and its
//          bypass selects into sec_a1 (byp_a); the history and the
//          descriptors' first stage.
//   cr03h  A+1: the bank slices' L0-L3 reads (each bank k's ports read the
//          rows of section k's owner) and rcu_pred's gv_a (the pdata guard)
//          and active_a. The payload into every copy's flops.
//   cr04h  A+2: the payload on the wire.
//   cr06h  A+4: LW and PL ports' valids (the slices' and rcu_pred's write
//          ports: valid, then row, then the write cycle).
//   cr07h  A+5: LW's row and sections; PL's rows and merge.
//   cr08h  A+6 = A + CCV_LAT_LANE - 1: the write cycle. LW's lane mask; PL's
//          new-value mask (active). The lanes' results land now (their data
//          goes straight to the slices and to rcu_pred). Lane done slots
//          0-3: valid now, payload in A+7 (cr09h).
//   cr11h  A+9, cr12h A+10, cr13h A+11: SW's valid, row and sections, write
//          cycle; SFU done (slot 4) valid in A+11, payload in A+12 (cr14h).
//
// The issue lead slice (RA-31). Every field group of the message loads
// only when its op uses it, from the lead bits a cycle ahead, carried with
// the op: the per-section control when the section is owned, operand port
// i's byte when the owner's lead says source i (or the immediate in port
// i, or merge for port 3), the bypass selects when a select or the one
// they replace is non-zero. A group the op does not use holds its old
// value: the spec's "0 when merge_en = 0" and the zero of an unused port
// are don't-care on the wire (payload spec: merge_data is don't-care
// without merge_en; a lane reads only its opcode's operands). The bypass
// selects are the exception: a section with no forward must carry zeros.
// What the payload uses is a subset of what the lead promised (asserted).
//
// Departures, each for RA (RI tab):
//   - sec_pred_bit is loaded at A's edge from rcu_pred's active in A
//     (act_cr02h): rcu_pred has it only from a flop at A+1, so the guard
//     read's A path crosses into this module (no budget in the Partition
//     tab).
//   - The descriptors carry rows binary (the slices predecode their write
//     ports), and active from rcu_pred's active_a at A+1, not from A.
//   - SW's data (RA-3's field) and its lane mask (all ones) are wired at
//     assembly; this module drives SW's valid, row and sections.
//
// The reference is the RCU model (sim/rcu/rcu_core.cpp: cycle()'s lane
// message, the bypass and the descriptors; gatherWrites for the lane
// results); test/rcu/lanes_tb.cpp holds this module to a value model of
// it, cycle by cycle.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK rcu_core_clk
`define CCV_RST rst_r01h
module rcu_lanes #(
  parameter  int COPIES = 32,                                // lane copies (lanes)
  localparam int N  = COPIES,
  localparam int NK = ccv_params_pkg::CCV_SECTIONS,          // S slots, sections, banks: 4
  localparam int NP = ccv_prelim_pkg::CCV_L_OPERANDS_PER_LANE + 1,   // ports: src0-2, merge
  localparam int WR = 8,                                     // a GPR row (CCV_P_W_PHYS_REG)
  localparam int WP = ccv_prov_pkg::CCV_P_W_PHYS_PRED,       // a predicate row
  localparam int WT = ccv_prov_pkg::CCV_P_W_ROB_TAG,
  localparam int WO = ccv_prelim_pkg::CCV_L_W_OPCODE,        // 9
  localparam int WB = ccv_prov_pkg::CCV_P_W_LANE_BYP_SEL,    // a bypass select, 5
  localparam int LAT = ccv_prov_pkg::CCV_LAT_LANE,           // 7
  localparam int BYP = ccv_prov_pkg::CCV_LAT_LANE_BYP,       // 4
  localparam int LSF = ccv_prov_pkg::CCV_LAT_SFU,            // 12
  localparam int DH = LAT - 2,                               // history: ages 1 .. LAT-2
  localparam int DL = LAT - 1,                               // lwb_d: A+1 .. A+LAT-1
  localparam int DS = LSF - 1,                               // swb_d: A+1 .. A+LSF-1
  localparam int NWK = (COPIES + 7) / 8                      // wake flops, one per 8 copies
) (
  input  logic                    rcu_core_clk,
  input  logic                    rcu_rst_r00h,
  input  logic                    iw_cr01h,        // ooe_rcu_issue_wake
  // The S slots' lead (A-1).
  input  logic [NK-1:0]           iv_cr01h,        // slot s issues next cycle
  input  logic [NK*NK-1:0]        lsec_cr01h,      // lead_sec_mask
  input  logic [NK*3-1:0]         lsrc_cr01h,      // lead_src_used
  input  logic [NK-1:0]           limm_cr01h,      // lead_imm_used
  input  logic [NK-1:0]           lmrg_cr01h,      // lead_merge_used
  // The payload and its op-class decode (A).
  input  logic [NK*2-1:0]         cls_cr02h,       // 0 nothing to the lanes, 1 lane, 2 SFU, 3 GPR copy
  input  logic [NK-1:0]           gdst_cr02h,      // class: writes a GPR
  input  logic [NK*3-1:0]         rds_cr02h,       // class: GPR source ports read
  input  logic [NK*2-1:0]         isl_cr02h,       // class: the immediate's port, 3 none
  input  logic [NK-1:0]           immu_cr02h,      // class: the immediate is read
  input  logic [NK-1:0]           pdt_cr02h,       // class: pdata
  input  logic [NK*NK-1:0]        foot_cr02h,      // footprint
  input  logic [NK*WO-1:0]        opc_cr02h,       // opcode
  input  logic [NK*32-1:0]        imm_cr02h,
  input  logic [NK*3*WR-1:0]      src_cr02h,       // source rows 0-2 (phys_src[15:8], [7:0], phys_src2)
  input  logic [NK*6-1:0]         spos_cr02h,      // src_pos, port i at 2i
  input  logic [NK*6-1:0]         swid_cr02h,      // src_width
  input  logic [NK*WR-1:0]        dst_cr02h,       // phys_dst
  input  logic [NK*WR-1:0]        odst_cr02h,      // phys_old_dst
  input  logic [NK*2-1:0]         dpos_cr02h,      // dst_pos
  input  logic [NK*2-1:0]         dwid_cr02h,      // dst_width
  input  logic [NK*2-1:0]         opos_cr02h,      // old_dst_pos
  input  logic [NK-1:0]           mrg_cr02h,       // merge_en
  input  logic [NK-1:0]           pwe_cr02h,       // pred_we
  input  logic [NK*WP-1:0]        pd_cr02h,        // phys_pred_dst
  input  logic [NK*WP-1:0]        pod_cr02h,       // phys_pred_old_dst
  input  logic [NK*WT-1:0]        tag_cr02h,       // rob_tag
  input  logic [NK*2-1:0]         drow_cr02h,      // done_row
  input  logic [NK*N-1:0]         act_cr02h,       // rcu_pred: active, in A
  // A+1.
  input  logic [NK*N-1:0]         acta_cr03h,      // rcu_pred: active_a
  input  logic [NK*N-1:0]         gv_cr03h,        // rcu_pred: gv_a, the guard, negated
  input  logic [NK*NP*N*8-1:0]    rd_cr03h,        // bank k port i lane l: ((k*NP + i)*N + l)*8
  // The lanes' results, in their write cycle (A+6): the lockstep checks.
  input  logic [N-1:0]            lrv_cr08h,       // copy c's result lands
  input  logic [N*NK-1:0]         lsv_cr08h,       //   its sec_valid
  // ccv_rcu_lane_ops, each copy.
  output logic [NWK-1:0]          lwk_cr02h,       // wake (copy c from flop c/8)
  output logic [N-1:0]            lv_cr03h,        // valid
  output logic [N*NK-1:0]         sen_cr03h,       // section_en (lead)
  output logic [N*NK-1:0]         spb_cr03h,       // sec_pred_bit (lead)
  output logic [N*NK*WO-1:0]      sop_cr04h,       // sec_opcode
  output logic [N*NP*32-1:0]      opd_cr04h,       // operand 0-2, then merge_data
  output logic [N*NK*2-1:0]       sown_cr04h,      // sec_owner
  output logic [N*NK-1:0]         spd_cr04h,       // sec_pred_data
  output logic [N*NK*NP*2-1:0]    sopos_cr04h,     // sec_opnd_pos, entry k*NP + i
  output logic [N*NK*NP*2-1:0]    sowid_cr04h,     // sec_opnd_width
  output logic [N*NK*2-1:0]       sdpos_cr04h,     // sec_dst_pos
  output logic [N*NK*2-1:0]       sdwid_cr04h,     // sec_dst_width
  output logic [N*NK*NP*WB-1:0]   sbyp_cr04h,      // operand_byp
  // LW, bank k's lane write port.
  output logic [NK-1:0]           lwv_cr06h,
  output logic [NK*WR-1:0]        lwrow_cr07h,
  output logic [NK*NK-1:0]        lwsec_cr07h,
  output logic [NK*N-1:0]         lwlm_cr08h,
  // PL, rcu_pred's lane port for lead section k.
  output logic [NK-1:0]           plv_cr06h,
  output logic [NK*WP-1:0]        plrow_cr07h,
  output logic [NK*WP-1:0]        plorow_cr07h,
  output logic [NK-1:0]           plmrg_cr07h,
  output logic [NK*N-1:0]         plmm_cr08h,
  // SW, the SFU's write port.
  output logic                    swv_cr11h,
  output logic [WR-1:0]           swrow_cr12h,
  output logic [NK-1:0]           swsec_cr12h,
  // Done slots 0-3 (a lane op's lead section) and 4 (SFU).
  output logic [NK-1:0]           dnv_cr08h,
  output logic [NK*WT-1:0]        dntag_cr09h,
  output logic [NK*2-1:0]         dnrow_cr09h,
  output logic                    sdv_cr13h,
  output logic [WT-1:0]           sdtag_cr14h,
  output logic [1:0]              sdrow_cr14h
);

  localparam logic [WR-1:0] ZROW = WR'(ccv_prov_pkg::CCV_P_PHYS_ZERO);
  localparam int WS = $clog2(NK);       // a section index

  logic rst_r01h;
  always_ff @(posedge rcu_core_clk) begin
    rst_r01h <= rcu_rst_r00h;
  end

  function automatic logic [NK-1:0] secmask(input logic [1:0] w, input logic [1:0] pos);
    logic [NK-1:0] span;
    span = (w == 2'd0) ? NK'(4'b1111) : (w == 2'd1) ? NK'(4'b0011) : NK'(4'b0001);
    secmask = span << pos;
  endfunction
  function automatic logic [WS-1:0] enc(input logic [NK-1:0] oh);
    enc = '0;
    for (int s = 0; s < NK; s++) if (oh[s]) enc = enc | WS'(s);
  endfunction

  // ---- A-1: the issue valid and the lead slice (iss_lead_q) -------------
  // Loaded every cycle: the module's ungated allowance (Partition tab).
  logic [NK-1:0]    v_cr02h;
  logic [NK*NK-1:0] lsec_cr02h;
  logic [NK*3-1:0]  lsrc_cr02h;
  logic [NK-1:0]    limm_cr02h, lmrg_cr02h;
  logic [NWK-1:0]   wk_cr02h;
  always_ff @(posedge rcu_core_clk) begin
    if (rst_r01h) begin
      v_cr02h  <= '0;
      wk_cr02h <= '0;
    end else begin
      v_cr02h  <= iv_cr01h;
      wk_cr02h <= {NWK{iw_cr01h}};
    end
    lsec_cr02h <= lsec_cr01h;
    lsrc_cr02h <= lsrc_cr01h;
    limm_cr02h <= limm_cr01h;
    lmrg_cr02h <= lmrg_cr01h;
  end
  assign lwk_cr02h = wk_cr02h;
  wire any_v_cr02h = |v_cr02h;

  // ---- A: ownership ----------------------------------------------------
  logic [NK-1:0]    lmsg_cr02h, lane_cr02h, sfu_cr02h, cpy_cr02h;
  logic [NK*NK-1:0] own_cr02h;    // own[k*NK + s]: slot s owns section k
  logic [NK-1:0]    sen_cr02h;
  always_comb begin
    for (int s = 0; s < NK; s++) begin
      lmsg_cr02h[s] = v_cr02h[s] & (cls_cr02h[2*s +: 2] != 2'd0);
      lane_cr02h[s] = v_cr02h[s] & (cls_cr02h[2*s +: 2] == 2'd1);
      sfu_cr02h[s]  = v_cr02h[s] & (cls_cr02h[2*s +: 2] == 2'd2);
      cpy_cr02h[s]  = v_cr02h[s] & (cls_cr02h[2*s +: 2] == 2'd3);
    end
    for (int k = 0; k < NK; k++) begin
      for (int s = 0; s < NK; s++) own_cr02h[k*NK + s] = lmsg_cr02h[s] & foot_cr02h[s*NK + k];
      sen_cr02h[k] = |own_cr02h[k*NK +: NK];
    end
  end
  // A section's group loads when a lead claims it (the lead's mask is the
  // footprint, or a superset of it).
  logic [NK-1:0] lcl_cr02h;
  always_comb begin
    for (int k = 0; k < NK; k++) begin
      lcl_cr02h[k] = 1'b0;
      for (int s = 0; s < NK; s++) lcl_cr02h[k] |= v_cr02h[s] & lsec_cr02h[s*NK + k];
    end
  end

  // ---- A: the bypass compare (stage I) ----------------------------------
  // History: entry (a, e), a = 1 .. DH the age, e the producer's lead
  // section: {valid, dst row, dst pos}, pushed in A for a lane op that
  // writes a GPR (never a copy or an SFU op).
  logic [DH*NK-1:0]    hv_cr03h;
  logic [DH*NK*WR-1:0] hrow_cr03h;
  logic [DH*NK*2-1:0]  hpos_cr03h;
  // Each slot's ports: read, row, position.
  logic [NK*NP-1:0]    rdp_cr02h;
  logic [NK*NP*WR-1:0] prow_cr02h;
  logic [NK*NP*2-1:0]  ppos_cr02h;
  logic [NK*NP*WB-1:0] bsel_cr02h;     // each slot's selects
  logic [NK*NP-1:0]    young_cr02h, multi_cr02h;
  always_comb begin
    for (int s = 0; s < NK; s++) begin
      for (int i = 0; i < 3; i++) begin
        rdp_cr02h[s*NP + i] = lmsg_cr02h[s] & ~cpy_cr02h[s] & rds_cr02h[s*3 + i];
        prow_cr02h[(s*NP + i)*WR +: WR] = src_cr02h[(s*3 + i)*WR +: WR];
        ppos_cr02h[(s*NP + i)*2 +: 2]   = spos_cr02h[s*6 + 2*i +: 2];
      end
      rdp_cr02h[s*NP + NP-1] = lmsg_cr02h[s] & mrg_cr02h[s];
      prow_cr02h[(s*NP + NP-1)*WR +: WR] = odst_cr02h[s*WR +: WR];
      ppos_cr02h[(s*NP + NP-1)*2 +: 2]   = opos_cr02h[2*s +: 2];
    end
    for (int p = 0; p < NK*NP; p++) begin
      logic [WR-1:0] r_cr02h;
      int            hits;
      r_cr02h = prow_cr02h[p*WR +: WR];
      bsel_cr02h[p*WB +: WB] = '0;
      young_cr02h[p] = 1'b0;
      hits = 0;
      for (int a = 1; a < DH + 1; a++) begin
        for (int e = 0; e < NK; e++) begin
          logic hit_cr02h;
          hit_cr02h = rdp_cr02h[p] && r_cr02h != ZROW && hv_cr03h[(a-1)*NK + e] &&
                      hrow_cr03h[((a-1)*NK + e)*WR +: WR] == r_cr02h;
          if (a < BYP) begin
            young_cr02h[p] |= hit_cr02h;
          end else if (hit_cr02h && hpos_cr03h[((a-1)*NK + e)*2 +: 2] == ppos_cr02h[p*2 +: 2]) begin
            bsel_cr02h[p*WB +: WB] |= WB'(1) | (WB'(e) << 1) | (WB'(a - BYP) << (1 + WS));
            hits = hits + 1;
          end
        end
      end
      multi_cr02h[p] = hits > 1;
    end
  end

  // ---- A: each section's control into sec_a1 ----------------------------
  // The owner's fields, its lead bits for the payload's enables, and its
  // bypass selects (byp_a).
  logic [NK*WO-1:0]  opc_s_cr02h;
  logic [NK*NP*2-1:0] opos_s_cr02h, owid_s_cr02h;
  logic [NK*2-1:0]   dpos_s_cr02h, dwid_s_cr02h, isl_s_cr02h;
  logic [NK*8-1:0]   immb_s_cr02h;
  logic [NK*NP-1:0]  rdm_s_cr02h, use_s_cr02h;
  logic [NK-1:0]     pdt_s_cr02h;
  logic [NK*NP*WB-1:0] byp_s_cr02h;
  logic [NK*N-1:0]   spb_s_cr02h;        // sec_pred_bit, lane l of section k at k*N + l
  always_comb begin
    for (int k = 0; k < NK; k++) begin
      opc_s_cr02h[k*WO +: WO] = '0;
      opos_s_cr02h[k*NP*2 +: NP*2] = '0;
      owid_s_cr02h[k*NP*2 +: NP*2] = '0;
      dpos_s_cr02h[2*k +: 2] = '0;
      dwid_s_cr02h[2*k +: 2] = '0;
      isl_s_cr02h[2*k +: 2] = '0;
      immb_s_cr02h[8*k +: 8] = '0;
      rdm_s_cr02h[k*NP +: NP] = '0;
      use_s_cr02h[k*NP +: NP] = '0;
      pdt_s_cr02h[k] = 1'b0;
      byp_s_cr02h[k*NP*WB +: NP*WB] = '0;
      spb_s_cr02h[k*N +: N] = '0;
      for (int s = 0; s < NK; s++) begin
        logic          o_cr02h;
        logic [NP-1:0] u_cr02h;
        logic [31:0]   ish_cr02h;
        o_cr02h = own_cr02h[k*NK + s];
        // The immediate placed at the op's lead section s: byte k - s.
        ish_cr02h = imm_cr02h[32*s +: 32] << (8 * s);
        for (int i = 0; i < 3; i++)
          u_cr02h[i] = lsrc_cr02h[s*3 + i] | (limm_cr02h[s] & isl_cr02h[2*s +: 2] == 2'(i));
        u_cr02h[NP-1] = lmrg_cr02h[s];
        opc_s_cr02h[k*WO +: WO]   |= {WO{o_cr02h}} & opc_cr02h[s*WO +: WO];
        for (int i = 0; i < 3; i++) begin
          opos_s_cr02h[(k*NP + i)*2 +: 2] |= {2{o_cr02h}} &
            ((isl_cr02h[2*s +: 2] == 2'(i)) ? 2'(s) : spos_cr02h[s*6 + 2*i +: 2]);
          owid_s_cr02h[(k*NP + i)*2 +: 2] |= {2{o_cr02h}} & swid_cr02h[s*6 + 2*i +: 2];
        end
        opos_s_cr02h[(k*NP + NP-1)*2 +: 2] |= {2{o_cr02h}} & opos_cr02h[2*s +: 2];
        owid_s_cr02h[(k*NP + NP-1)*2 +: 2] |= {2{o_cr02h}} & dwid_cr02h[2*s +: 2];
        dpos_s_cr02h[2*k +: 2] |= {2{o_cr02h}} & dpos_cr02h[2*s +: 2];
        dwid_s_cr02h[2*k +: 2] |= {2{o_cr02h}} & dwid_cr02h[2*s +: 2];
        isl_s_cr02h[2*k +: 2]  |= {2{o_cr02h}} & isl_cr02h[2*s +: 2];
        immb_s_cr02h[8*k +: 8] |= {8{o_cr02h}} & ish_cr02h[8*k +: 8];
        rdm_s_cr02h[k*NP +: NP] |= {NP{o_cr02h}} & rdp_cr02h[s*NP +: NP];
        use_s_cr02h[k*NP +: NP] |= {NP{o_cr02h}} & u_cr02h;
        pdt_s_cr02h[k] |= o_cr02h & pdt_cr02h[s];
        byp_s_cr02h[k*NP*WB +: NP*WB] |= {NP*WB{o_cr02h}} & bsel_cr02h[s*NP*WB +: NP*WB];
        spb_s_cr02h[k*N +: N] |= {N{o_cr02h}} & act_cr02h[s*N +: N];
      end
      // The immediate's port of a section whose owner has none: 3.
      if (!sen_cr02h[k]) isl_s_cr02h[2*k +: 2] = 2'd3;
    end
  end

  // sv_a1: section k owned, at A+1 (ungated: 4 flops).
  logic [NK-1:0] sv_cr03h;
  always_ff @(posedge rcu_core_clk) begin
    if (rst_r01h) sv_cr03h <= '0;
    else          sv_cr03h <= sen_cr02h;
  end
  // sec_a1, one group a section, loaded when a lead claims it.
  logic [NK*NK-1:0]    own_cr03h;
  logic [NK*WO-1:0]    opc_cr03h;
  logic [NK*NP*2-1:0]  opos_cr03h, owid_cr03h;
  logic [NK*2-1:0]     dpos_cr03h, dwid_cr03h, isl_cr03h;
  logic [NK*8-1:0]     immb_cr03h;
  logic [NK*NP-1:0]    rdm_cr03h, use_cr03h;
  logic [NK-1:0]       pdt_cr03h;
  logic [NK*NP*WB-1:0] byp_cr03h;
  for (genvar k = 0; k < NK; k++) begin : g_seca
    wire sa_en_cr02h = lcl_cr02h[k];
    always_ff @(posedge rcu_core_clk) begin
      if (sa_en_cr02h) begin
        own_cr03h[k*NK +: NK]       <= own_cr02h[k*NK +: NK];
        opc_cr03h[k*WO +: WO]       <= opc_s_cr02h[k*WO +: WO];
        opos_cr03h[k*NP*2 +: NP*2]  <= opos_s_cr02h[k*NP*2 +: NP*2];
        owid_cr03h[k*NP*2 +: NP*2]  <= owid_s_cr02h[k*NP*2 +: NP*2];
        dpos_cr03h[2*k +: 2]        <= dpos_s_cr02h[2*k +: 2];
        dwid_cr03h[2*k +: 2]        <= dwid_s_cr02h[2*k +: 2];
        isl_cr03h[2*k +: 2]         <= isl_s_cr02h[2*k +: 2];
        immb_cr03h[8*k +: 8]        <= immb_s_cr02h[8*k +: 8];
        rdm_cr03h[k*NP +: NP]       <= rdm_s_cr02h[k*NP +: NP];
        use_cr03h[k*NP +: NP]       <= use_s_cr02h[k*NP +: NP];
        pdt_cr03h[k]                <= pdt_s_cr02h[k];
        byp_cr03h[k*NP*WB +: NP*WB] <= byp_s_cr02h[k*NP*WB +: NP*WB];
      end
    end
  end

  // ---- A: the lane message's lead fields, every copy ---------------------
  // section_en, sec_pred_bit and valid: loaded when any S slot issues, or
  // to clear what the last message left.
  for (genvar c = 0; c < N; c++) begin : g_lead
    wire ld_en_cr02h = any_v_cr02h | lv_cr03h[c];
    always_ff @(posedge rcu_core_clk) begin
      if (rst_r01h) begin
        lv_cr03h[c]            <= 1'b0;
        sen_cr03h[c*NK +: NK]  <= '0;
        spb_cr03h[c*NK +: NK]  <= '0;
      end else if (ld_en_cr02h) begin
        lv_cr03h[c]            <= |sen_cr02h;
        sen_cr03h[c*NK +: NK]  <= sen_cr02h;
        for (int k = 0; k < NK; k++) spb_cr03h[c*NK + k] <= spb_s_cr02h[k*N + c];
      end
    end
  end

  // ---- A+1: the payload, every copy --------------------------------------
  // Whether a section's selects are non-zero, now and as last loaded: the
  // selects load when either is (a section with no forward carries zeros).
  logic [NK-1:0] bnz_cr03h, bnzh_cr04h;
  always_comb begin
    for (int k = 0; k < NK; k++) bnz_cr03h[k] = |byp_cr03h[k*NP*WB +: NP*WB];
  end
  wire [NK-1:0] bnzh_en_cr03h = sv_cr03h;
  always_ff @(posedge rcu_core_clk) begin
    if (rst_r01h) bnzh_cr04h <= '0;
    else for (int k = 0; k < NK; k++) if (bnzh_en_cr03h[k]) bnzh_cr04h[k] <= bnz_cr03h[k];
  end
  // Each section's operand bytes for lane c and its pdata bit.
  logic [N*NP*32-1:0] opd_n_cr03h;
  logic [N*NK-1:0]    spd_n_cr03h;
  always_comb begin
    for (int c = 0; c < N; c++)
      for (int k = 0; k < NK; k++) begin
        for (int i = 0; i < NP; i++) begin
          logic [7:0] b_cr03h;
          b_cr03h = rd_cr03h[((k*NP + i)*N + c)*8 +: 8] & {8{rdm_cr03h[k*NP + i]}};
          if (i < 3 && isl_cr03h[2*k +: 2] == 2'(i)) b_cr03h = immb_cr03h[8*k +: 8];
          opd_n_cr03h[(c*NP + i)*32 + 8*k +: 8] = b_cr03h;
        end
        spd_n_cr03h[c*NK + k] = 1'b0;
        for (int s = 0; s < NK; s++)
          spd_n_cr03h[c*NK + k] |= pdt_cr03h[k] & own_cr03h[k*NK + s] & gv_cr03h[s*N + c];
      end
  end
  for (genvar c = 0; c < N; c++) begin : g_pay
    for (genvar k = 0; k < NK; k++) begin : g_sec
      // The section's control: opcode, owner, port and destination
      // positions and widths, pdata.
      wire ct_en_cr03h = sv_cr03h[k];
      always_ff @(posedge rcu_core_clk) begin
        if (ct_en_cr03h) begin
          sop_cr04h[(c*NK + k)*WO +: WO]          <= opc_cr03h[k*WO +: WO];
          sown_cr04h[(c*NK + k)*2 +: 2]           <= 2'(enc(own_cr03h[k*NK +: NK]));
          sopos_cr04h[(c*NK + k)*NP*2 +: NP*2]    <= opos_cr03h[k*NP*2 +: NP*2];
          sowid_cr04h[(c*NK + k)*NP*2 +: NP*2]    <= owid_cr03h[k*NP*2 +: NP*2];
          sdpos_cr04h[(c*NK + k)*2 +: 2]          <= dpos_cr03h[2*k +: 2];
          sdwid_cr04h[(c*NK + k)*2 +: 2]          <= dwid_cr03h[2*k +: 2];
          spd_cr04h[c*NK + k]                     <= spd_n_cr03h[c*NK + k];
        end
      end
      wire by_en_cr03h = sv_cr03h[k] & (bnz_cr03h[k] | bnzh_cr04h[k]);
      always_ff @(posedge rcu_core_clk) begin
        if (by_en_cr03h) sbyp_cr04h[(c*NK + k)*NP*WB +: NP*WB] <= byp_cr03h[k*NP*WB +: NP*WB];
      end
      for (genvar i = 0; i < NP; i++) begin : g_port
        wire op_en_cr03h = sv_cr03h[k] & use_cr03h[k*NP + i];
        always_ff @(posedge rcu_core_clk) begin
          if (op_en_cr03h) opd_cr04h[(c*NP + i)*32 + 8*k +: 8] <= opd_n_cr03h[(c*NP + i)*32 + 8*k +: 8];
        end
      end
    end
  end

  // ---- The bypass history ------------------------------------------------
  // Valids: one group, loaded while anything is in it or a slot issues.
  logic [NK-1:0] push_cr02h;
  always_comb begin
    for (int e = 0; e < NK; e++) push_cr02h[e] = lane_cr02h[e] & gdst_cr02h[e];
  end
  wire hv_en_cr02h = any_v_cr02h | (|hv_cr03h);
  always_ff @(posedge rcu_core_clk) begin
    if (rst_r01h) hv_cr03h <= '0;
    else if (hv_en_cr02h) hv_cr03h <= {hv_cr03h[(DH-1)*NK-1:0], push_cr02h};
  end
  for (genvar e = 0; e < NK; e++) begin : g_hist
    wire h1_en_cr02h = v_cr02h[e];
    always_ff @(posedge rcu_core_clk) begin
      if (h1_en_cr02h) begin
        hrow_cr03h[e*WR +: WR] <= dst_cr02h[e*WR +: WR];
        hpos_cr03h[e*2 +: 2]   <= dpos_cr02h[2*e +: 2];
      end
    end
    for (genvar a = 2; a < DH + 1; a++) begin : g_age
      wire hn_en_cr03h = hv_cr03h[(a-2)*NK + e];
      always_ff @(posedge rcu_core_clk) begin
        if (hn_en_cr03h) begin
          hrow_cr03h[((a-1)*NK + e)*WR +: WR] <= hrow_cr03h[((a-2)*NK + e)*WR +: WR];
          hpos_cr03h[((a-1)*NK + e)*2 +: 2]   <= hpos_cr03h[((a-2)*NK + e)*2 +: 2];
        end
      end
    end
  end

  // ---- Lane write-back: lwb_d ---------------------------------------------
  // Stage d = 1 .. DL holds the ops issued in A = now - d.
  //   per section k: ov (owned: the lanes return it), wv (LW writes bank
  //     k), row, cp (a copy: lanes ~active), oi (the owner slot);
  //   per lead slot s: dv (a done on slot s), pv (PL writes), cs (a copy:
  //     active needed), tag, done_row, pd, pod, merge; dpos and dwid at
  //     stage 1 only (for an SFU op's secmask); active from stage 2, from
  //     rcu_pred's active_a.
  logic [DL*NK-1:0] ov_cr03h, wv_cr03h, dv_cr03h, pv_cr03h, cs_cr03h;
  logic [NK-1:0] ov_n_cr02h, wv_n_cr02h, cp_n_cr02h;
  logic [NK*WS-1:0] oi_n_cr02h;
  logic [NK*WR-1:0] row_n_cr02h;
  always_comb begin
    for (int k = 0; k < NK; k++) begin
      ov_n_cr02h[k] = 1'b0;
      wv_n_cr02h[k] = 1'b0;
      cp_n_cr02h[k] = 1'b0;
      row_n_cr02h[k*WR +: WR] = '0;
      for (int s = 0; s < NK; s++) begin
        logic o_cr02h;
        o_cr02h = own_cr02h[k*NK + s];
        ov_n_cr02h[k] |= o_cr02h & ~sfu_cr02h[s];
        wv_n_cr02h[k] |= o_cr02h & ~sfu_cr02h[s] & (gdst_cr02h[s] | cpy_cr02h[s]);
        cp_n_cr02h[k] |= o_cr02h & cpy_cr02h[s];
        row_n_cr02h[k*WR +: WR] |= {WR{o_cr02h}} & dst_cr02h[s*WR +: WR];
      end
      oi_n_cr02h[k*WS +: WS] = enc(own_cr02h[k*NK +: NK]);
    end
  end
  wire [NK-1:0] dv_n_cr02h = lane_cr02h;
  wire [NK-1:0] pv_n_cr02h = lane_cr02h & pwe_cr02h;
  wire lwv_en_cr02h = any_v_cr02h | (|ov_cr03h) | (|dv_cr03h) | (|pv_cr03h) | (|cs_cr03h);
  always_ff @(posedge rcu_core_clk) begin
    if (rst_r01h) begin
      ov_cr03h <= '0;
      wv_cr03h <= '0;
      dv_cr03h <= '0;
      pv_cr03h <= '0;
      cs_cr03h <= '0;
    end else if (lwv_en_cr02h) begin
      ov_cr03h <= {ov_cr03h[(DL-1)*NK-1:0], ov_n_cr02h};
      wv_cr03h <= {wv_cr03h[(DL-1)*NK-1:0], wv_n_cr02h};
      dv_cr03h <= {dv_cr03h[(DL-1)*NK-1:0], dv_n_cr02h};
      pv_cr03h <= {pv_cr03h[(DL-1)*NK-1:0], pv_n_cr02h};
      cs_cr03h <= {cs_cr03h[(DL-1)*NK-1:0], cpy_cr02h};
    end
  end
  logic [DL*NK*WR-1:0] lrow_cr03h;
  logic [DL*NK-1:0]    lcp_cr03h;
  logic [DL*NK*WS-1:0] loi_cr03h;
  logic [DL*NK*WT-1:0] ltag_cr03h;
  logic [DL*NK*2-1:0]  ldrow_cr03h;
  logic [DL*NK*WP-1:0] lpd_cr03h, lpod_cr03h;
  logic [DL*NK-1:0]    lmrg_cr03h;
  logic [NK*2-1:0]     ldpos_cr03h, ldwid_cr03h;    // stage 1 only
  logic [(DL-1)*NK*N-1:0] lact_cr03h;               // stages 2 .. DL, stage d at d-2
  for (genvar k = 0; k < NK; k++) begin : g_lwb
    // Stage 1, from the payload.
    wire l1s_en_cr02h = lcl_cr02h[k];
    wire l1l_en_cr02h = v_cr02h[k];
    always_ff @(posedge rcu_core_clk) begin
      if (l1s_en_cr02h) begin
        lrow_cr03h[k*WR +: WR] <= row_n_cr02h[k*WR +: WR];
        lcp_cr03h[k]           <= cp_n_cr02h[k];
        loi_cr03h[k*WS +: WS]  <= oi_n_cr02h[k*WS +: WS];
      end
      if (l1l_en_cr02h) begin
        ltag_cr03h[k*WT +: WT] <= tag_cr02h[k*WT +: WT];
        ldrow_cr03h[k*2 +: 2]  <= drow_cr02h[2*k +: 2];
        lpd_cr03h[k*WP +: WP]  <= pd_cr02h[k*WP +: WP];
        lpod_cr03h[k*WP +: WP] <= pod_cr02h[k*WP +: WP];
        lmrg_cr03h[k]          <= mrg_cr02h[k];
        ldpos_cr03h[2*k +: 2]  <= dpos_cr02h[2*k +: 2];
        ldwid_cr03h[2*k +: 2]  <= dwid_cr02h[2*k +: 2];
      end
    end
    // Stages 2 .. DL, under the previous stage's valids.
    for (genvar d = 2; d < DL + 1; d++) begin : g_st
      wire ls_en_cr03h = ov_cr03h[(d-2)*NK + k];
      wire ll_en_cr03h = dv_cr03h[(d-2)*NK + k] | pv_cr03h[(d-2)*NK + k] | cs_cr03h[(d-2)*NK + k];
      always_ff @(posedge rcu_core_clk) begin
        if (ls_en_cr03h) begin
          lrow_cr03h[((d-1)*NK + k)*WR +: WR] <= lrow_cr03h[((d-2)*NK + k)*WR +: WR];
          lcp_cr03h[(d-1)*NK + k]             <= lcp_cr03h[(d-2)*NK + k];
          loi_cr03h[((d-1)*NK + k)*WS +: WS]  <= loi_cr03h[((d-2)*NK + k)*WS +: WS];
        end
        if (ll_en_cr03h) begin
          ltag_cr03h[((d-1)*NK + k)*WT +: WT] <= ltag_cr03h[((d-2)*NK + k)*WT +: WT];
          ldrow_cr03h[((d-1)*NK + k)*2 +: 2]  <= ldrow_cr03h[((d-2)*NK + k)*2 +: 2];
          lpd_cr03h[((d-1)*NK + k)*WP +: WP]  <= lpd_cr03h[((d-2)*NK + k)*WP +: WP];
          lpod_cr03h[((d-1)*NK + k)*WP +: WP] <= lpod_cr03h[((d-2)*NK + k)*WP +: WP];
          lmrg_cr03h[(d-1)*NK + k]            <= lmrg_cr03h[(d-2)*NK + k];
        end
      end
      // active: rcu_pred's active_a into stage 2, then on, in the stage's
      // descriptor gate (ll_en): only a pdata write or a copy reads it, but a
      // gate of its own idles on a run of ops with one active mask (CG-3).
      if (d == 2) begin : g_a2
        always_ff @(posedge rcu_core_clk) begin
          if (ll_en_cr03h) lact_cr03h[k*N +: N] <= acta_cr03h[k*N +: N];
        end
      end else begin : g_an
        always_ff @(posedge rcu_core_clk) begin
          if (ll_en_cr03h) lact_cr03h[((d-2)*NK + k)*N +: N] <= lact_cr03h[((d-3)*NK + k)*N +: N];
        end
      end
    end
  end
  // The done payload a cycle after its valid (A+LAT).
  for (genvar s = 0; s < NK; s++) begin : g_dn
    wire dn_en_cr08h = dv_cr03h[(DL-1)*NK + s];
    always_ff @(posedge rcu_core_clk) begin
      if (dn_en_cr08h) begin
        dntag_cr09h[s*WT +: WT] <= ltag_cr03h[((DL-1)*NK + s)*WT +: WT];
        dnrow_cr09h[s*2 +: 2]   <= ldrow_cr03h[((DL-1)*NK + s)*2 +: 2];
      end
    end
  end
  // The ports.
  localparam int SV = DL - 2, SR = DL - 1, SW = DL;   // stages of valid, row, write
  always_comb begin
    for (int k = 0; k < NK; k++) begin
      logic [WS-1:0] oi_cr08h;
      lwv_cr06h[k] = wv_cr03h[(SV-1)*NK + k];
      lwrow_cr07h[k*WR +: WR] = lrow_cr03h[((SR-1)*NK + k)*WR +: WR];
      lwsec_cr07h[k*NK +: NK] = NK'(wv_cr03h[(SR-1)*NK + k]) << k;
      oi_cr08h = loi_cr03h[((SW-1)*NK + k)*WS +: WS];
      lwlm_cr08h[k*N +: N] = lcp_cr03h[(SW-1)*NK + k] ? ~lact_cr03h[((SW-2)*NK + 32'(oi_cr08h))*N +: N]
                                                      : {N{1'b1}};
      plv_cr06h[k] = pv_cr03h[(SV-1)*NK + k];
      plrow_cr07h[k*WP +: WP]  = lpd_cr03h[((SR-1)*NK + k)*WP +: WP];
      plorow_cr07h[k*WP +: WP] = lpod_cr03h[((SR-1)*NK + k)*WP +: WP];
      plmrg_cr07h[k] = lmrg_cr03h[(SR-1)*NK + k];
      plmm_cr08h[k*N +: N] = lact_cr03h[((SW-2)*NK + k)*N +: N];
      dnv_cr08h[k] = dv_cr03h[(SW-1)*NK + k];
    end
  end

  // ---- SFU write-back: swb_d ---------------------------------------------
  // Stage 1: the valids and the SFU's slot; its fields come from lwb_d's
  // stage 1 at stage 2. Stage DS+1 holds the done payload.
  logic [DS-1:0]    ssv_cr03h, sdv_cr03h;    // SW writes; a done on slot 4
  logic [DS*NK-1:0] sov_cr03h;               // sections the lanes return
  logic [NK-1:0]    ssl_cr03h;               // stage 1: the SFU's slot
  wire any_sfu_cr02h = |sfu_cr02h;
  logic [NK-1:0] sfo_cr02h;
  always_comb begin
    sfo_cr02h = '0;
    for (int s = 0; s < NK; s++) sfo_cr02h |= {NK{sfu_cr02h[s]}} & foot_cr02h[s*NK +: NK];
  end
  // Stage 1 loads every cycle (10 flops, the ungated allowance): its only
  // enable would be an SFU issue, which is an input. Stages 2 on shift while
  // anything is in flight.
  wire sv_en_cr02h = (|ssv_cr03h) | (|sdv_cr03h) | (|sov_cr03h);
  always_ff @(posedge rcu_core_clk) begin
    if (rst_r01h) begin
      ssv_cr03h[0]       <= 1'b0;
      sdv_cr03h[0]       <= 1'b0;
      sov_cr03h[0 +: NK] <= '0;
      ssl_cr03h          <= '0;
    end else begin
      ssv_cr03h[0]       <= |(sfu_cr02h & gdst_cr02h);
      sdv_cr03h[0]       <= any_sfu_cr02h;
      sov_cr03h[0 +: NK] <= sfo_cr02h;
      ssl_cr03h          <= sfu_cr02h;
    end
  end
  always_ff @(posedge rcu_core_clk) begin
    if (rst_r01h) begin
      ssv_cr03h[DS-1:1]       <= '0;
      sdv_cr03h[DS-1:1]       <= '0;
      sov_cr03h[DS*NK-1:NK]   <= '0;
    end else if (sv_en_cr02h) begin
      ssv_cr03h[DS-1:1]       <= ssv_cr03h[DS-2:0];
      sdv_cr03h[DS-1:1]       <= sdv_cr03h[DS-2:0];
      sov_cr03h[DS*NK-1:NK]   <= sov_cr03h[(DS-1)*NK-1:0];
    end
  end
  logic [(DS-2)*WR-1:0] srow_cr03h;    // stages 2 .. DS-1 (SW's row and sections), stage d at d-2
  logic [(DS-2)*NK-1:0] ssec_cr03h;
  logic [(DS-1)*WT-1:0] stag_cr03h;
  logic [(DS-1)*2-1:0]  sdro_cr03h;
  logic [WR-1:0] srow_n_cr03h;
  logic [NK-1:0] ssec_n_cr03h;
  logic [WT-1:0] stag_n_cr03h;
  logic [1:0]    sdro_n_cr03h;
  always_comb begin
    srow_n_cr03h = '0;
    ssec_n_cr03h = '0;
    stag_n_cr03h = '0;
    sdro_n_cr03h = '0;
    for (int s = 0; s < NK; s++) begin
      srow_n_cr03h |= {WR{ssl_cr03h[s]}} & lrow_cr03h[s*WR +: WR];
      ssec_n_cr03h |= {NK{ssl_cr03h[s]}} & secmask(ldwid_cr03h[2*s +: 2], ldpos_cr03h[2*s +: 2]);
      stag_n_cr03h |= {WT{ssl_cr03h[s]}} & ltag_cr03h[s*WT +: WT];
      sdro_n_cr03h |= {2{ssl_cr03h[s]}} & ldrow_cr03h[2*s +: 2];
    end
  end
  wire sw2_en_cr03h = sdv_cr03h[0];
  always_ff @(posedge rcu_core_clk) begin
    if (sw2_en_cr03h) begin
      srow_cr03h[0 +: WR] <= srow_n_cr03h;
      ssec_cr03h[0 +: NK] <= ssec_n_cr03h;
      stag_cr03h[0 +: WT] <= stag_n_cr03h;
      sdro_cr03h[0 +: 2]  <= sdro_n_cr03h;
    end
  end
  for (genvar d = 3; d < DS + 1; d++) begin : g_swb
    wire sw_en_cr03h = sdv_cr03h[d-2];
    if (d < DS) begin : g_rs   // SW's row and sections end at stage DS-1
      always_ff @(posedge rcu_core_clk) begin
        if (sw_en_cr03h) begin
          srow_cr03h[(d-2)*WR +: WR] <= srow_cr03h[(d-3)*WR +: WR];
          ssec_cr03h[(d-2)*NK +: NK] <= ssec_cr03h[(d-3)*NK +: NK];
        end
      end
    end
    always_ff @(posedge rcu_core_clk) begin
      if (sw_en_cr03h) begin
        stag_cr03h[(d-2)*WT +: WT] <= stag_cr03h[(d-3)*WT +: WT];
        sdro_cr03h[(d-2)*2 +: 2]   <= sdro_cr03h[(d-3)*2 +: 2];
      end
    end
  end
  wire sd_en_cr13h = sdv_cr03h[DS-1];
  always_ff @(posedge rcu_core_clk) begin
    if (sd_en_cr13h) begin
      sdtag_cr14h <= stag_cr03h[(DS-2)*WT +: WT];
      sdrow_cr14h <= sdro_cr03h[(DS-2)*2 +: 2];
    end
  end
  assign swv_cr11h   = ssv_cr03h[DS-3];
  assign swrow_cr12h = srow_cr03h[(DS-3)*WR +: WR];
  assign swsec_cr12h = ssec_cr03h[(DS-3)*NK +: NK];
  assign sdv_cr13h   = sdv_cr03h[DS-1];

  // ---- Checks --------------------------------------------------------------
  // At most one owner a section (footprints are disjoint), and a lane op's
  // lead section is its slot: no section below it.
  logic own_bad_cr02h, lead_bad_cr02h, foot_bad_cr02h, cpy_bad_cr02h;
  always_comb begin
    own_bad_cr02h = 1'b0;
    lead_bad_cr02h = 1'b0;
    foot_bad_cr02h = 1'b0;
    cpy_bad_cr02h = 1'b0;
    for (int k = 0; k < NK; k++) own_bad_cr02h |= $countones(own_cr02h[k*NK +: NK]) > 1;
    for (int s = 0; s < NK; s++) begin
      // The superset rule (RA-31): what the payload uses is within the lead.
      if (v_cr02h[s] && cls_cr02h[2*s +: 2] != 2'd0)
        lead_bad_cr02h |= |(foot_cr02h[s*NK +: NK] & ~lsec_cr02h[s*NK +: NK]) |
                          (cls_cr02h[2*s +: 2] != 2'd3 && |(rds_cr02h[s*3 +: 3] & ~lsrc_cr02h[s*3 +: 3])) |
                          (immu_cr02h[s] & ~limm_cr02h[s]) | (mrg_cr02h[s] & ~lmrg_cr02h[s]);
      if (lmsg_cr02h[s])
        foot_bad_cr02h |= !foot_cr02h[s*NK + s] || (foot_cr02h[s*NK +: NK] & ((NK'(1) << s) - NK'(1))) != '0;
      // A copy has old destination to merge, a GPR to write and no predicate.
      cpy_bad_cr02h |= cpy_cr02h[s] & (~mrg_cr02h[s] | pwe_cr02h[s] | dst_cr02h[s*WR +: WR] == ZROW);
    end
  end
  `CCV_ASSERT(lanes_own, !own_bad_cr02h)
  `CCV_ASSERT(lanes_lead_promise, !lead_bad_cr02h)
  `CCV_ASSERT(lanes_foot, !foot_bad_cr02h)
  `CCV_ASSERT(lanes_copy, !cpy_bad_cr02h)
  // A source a lane producer younger than CCV_LAT_LANE_BYP has yet to
  // write: the scheduler never issues it (A-59). Never two producers.
  `CCV_ASSERT(lanes_byp_young, young_cr02h == '0)
  `CCV_ASSERT(lanes_byp_multi, multi_cr02h == '0)
  // One SFU op a cycle (swb_d has one entry a stage).
  `CCV_ASSERT(lanes_sfu_one, $countones(sfu_cr02h) < 2)
  // The lanes' results: every copy in the same cycle (lockstep), exactly
  // when results are due, holding exactly the sections due (CG-5: never an
  // enable, only checked).
  wire [NK-1:0] due_cr08h = ov_cr03h[(DL-1)*NK +: NK] | sov_cr03h[(DS-1)*NK +: NK];
  logic lres_bad_cr08h;
  always_comb begin
    lres_bad_cr08h = 1'b0;
    for (int c = 0; c < N; c++)
      lres_bad_cr08h |= lrv_cr08h[c] != (|due_cr08h) || (lrv_cr08h[c] && lsv_cr08h[c*NK +: NK] != due_cr08h);
  end
  `CCV_ASSERT(lanes_lockstep, !lres_bad_cr08h)

endmodule
`undef CCV_CLK
`undef CCV_RST
