//===-- ooe_rat.sv - OOE register alias tables and branch checkpoints ---===//
//
// Spec: the design doc's Register alias tables (one GPR RAT of 16 and one
//       predicate RAT of 4 per tier-1 warp; the guard and the predicate
//       destination renamed apart, Q-21; three GPR sources, Q-20; four
//       checkpoints per warp, GPR and predicate together, under FET's
//       checkpoint_id, taken when the branch renames and restored in one
//       cycle), Retire, squash and recovery (squash to retirement restores
//       the committed maps), Warp activation (A-64: a launched or freed
//       slot maps every register to the zero registers) and OA's response
//       OI-41 (restore-allocate takes its registers through rename's ports,
//       writing both maps).
//
// Per tier-1 slot: the speculative maps (rat, prat), the committed maps
// (crat, cprat) and C checkpoints of the speculative maps. A GPR name is a
// row and a position (GW bits); a predicate name is PW bits.
//
// One edge applies, per slot and in the model's order: a checkpoint
// restore (a mispredict), a squash to retirement (a demotion or kill: the
// speculative maps take the committed ones), a release (every map to the
// zero registers); then the retire ports' writes to the committed maps;
// then the rename ports, in port order. A rename port reads its sources,
// old destinations, guard and predicate-logic sources from the speculative
// maps as the lower ports of its slot left them (the in-group override),
// writes its destinations, and a branch's port takes its checkpoint as the
// maps stand after its own writes. A restore-allocate port (rst) writes
// both maps and reads nothing.
//
// Rename never names a slot that a restore, squash or release names in the
// same cycle: a mispredict's epoch drops the warp's queued uops, and a
// demoting, killed or freed slot does not rename. So the reads come from
// the flops, with only the in-group override in front of them; an
// assertion holds the exclusion.
//
// Checkpoint live bits are not kept here: branch resolution owns them.
//
// The reference is the model's Slot maps and checkpoints, which log what
// reached them each cycle (Core::ratLog); test/ooe/rat_tb.cpp drives this
// module from the log and compares every read, and after the edge every
// map and every live checkpoint.
//
// Reset line (decision 6): the four maps reset to the zero registers, as a
// freed slot's; the checkpoints are payload, read only through a live
// branch. Local clock gating (docs/rtl-coding-style.md): each slot's
// speculative maps are one gate, written on a rename to the slot or a
// whole-map event; each committed GPR entry is its own gate, written on a
// retirement or restore-allocate naming it or a release; each slot's
// committed predicates are one gate; each checkpoint is one gate, written
// when its branch renames.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK ooe_core_clk
`define CCV_RST ooe_rst_r00h
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
  // Rename ports, in rename order.
  input  logic [A-1:0]      ren_v_cq01h,
  input  logic [A*LS-1:0]   ren_slot_cq01h,
  input  logic [A-1:0]      ren_rst_cq01h,     // a restore-allocate write: both maps, no reads
  input  logic [A*3*4-1:0]  ren_src_cq01h,     // three GPR sources
  input  logic [A*4-1:0]    ren_dst_cq01h,
  input  logic [A-1:0]      ren_gwe_cq01h,     // writes its GPR destination
  input  logic [A*GW-1:0]   ren_gname_cq01h,   // with this name
  input  logic [A*2-1:0]    ren_pguard_cq01h,
  input  logic [A*2-1:0]    ren_pdst_cq01h,
  input  logic [A-1:0]      ren_pwe_cq01h,     // writes its predicate destination
  input  logic [A*PW-1:0]   ren_pname_cq01h,
  input  logic [A*2*2-1:0]  ren_pq_cq01h,      // predicate logic's two sources
  input  logic [A-1:0]      ren_br_cq01h,      // a branch: takes a checkpoint
  input  logic [A*LC-1:0]   ren_ckpt_cq01h,    // FET's checkpoint_id
  // What the reads return.
  output logic [A*3*GW-1:0] ren_psrc_cq01h,
  output logic [A*GW-1:0]   ren_pold_cq01h,
  output logic [A*PW-1:0]   ren_ppguard_cq01h,
  output logic [A*PW-1:0]   ren_ppold_cq01h,
  output logic [A*2*PW-1:0] ren_ppq_cq01h,
  // Retire ports, per slot, in retirement order.
  input  logic [S*R-1:0]    ret_gwe_cq01h,
  input  logic [S*R*4-1:0]  ret_dst_cq01h,
  input  logic [S*R*GW-1:0] ret_gname_cq01h,
  input  logic [S*R-1:0]    ret_pwe_cq01h,
  input  logic [S*R*2-1:0]  ret_pdst_cq01h,
  input  logic [S*R*PW-1:0] ret_pname_cq01h,
  // Whole-map events, per slot.
  input  logic [S-1:0]      restore_cq01h,     // a mispredict: the speculative maps take a checkpoint
  input  logic [S*LC-1:0]   restore_ckpt_cq01h,
  input  logic [S-1:0]      squash_cq01h,      // a squash to retirement
  input  logic [S-1:0]      release_cq01h,     // the slot freed
  // The maps after the last edge.
  output logic [S*MW-1:0]   rat_cq02h,         // speculative
  output logic [S*MW-1:0]   crat_cq02h,        // committed (the demotion map)
  output logic [S*C*MW-1:0] ckpt_cq02h
);

  `CCV_ASSERT_KNOWN(ren_v_known, ren_v_cq01h)
  `CCV_ASSERT_KNOWN(ret_known, {ret_gwe_cq01h, ret_pwe_cq01h})
  `CCV_ASSERT_KNOWN(event_known, {restore_cq01h, squash_cq01h, release_cq01h})

  // A slot's speculative maps as rename port k reads them: the flops, with
  // the writes of the lower ports naming the same slot (incl = 0), or as
  // they stand after port k's own writes (incl = 1).
  function automatic logic [MW-1:0] map_at(input logic [S*MW-1:0] q, input int k, input logic incl,
                                           input logic [A-1:0] v, input logic [A*LS-1:0] sl,
                                           input logic [A-1:0] rst, input logic [A*4-1:0] dst,
                                           input logic [A-1:0] gwe, input logic [A*GW-1:0] gname,
                                           input logic [A*2-1:0] pdst, input logic [A-1:0] pwe,
                                           input logic [A*PW-1:0] pname);
    logic [MW-1:0]  m;
    logic [LS-1:0]  s;
    s = sl[k * LS +: LS];
    m = '0;
    for (int t = 0; t < S; t++) if (s == LS'(t)) m = q[t * MW +: MW];
    // Every write as a decoder: no index computed and written through.
    for (int p = 0; p < A; p++)
      if ((p < k || (incl && p == k)) && v[p] && !rst[p] && sl[p * LS +: LS] == s) begin
        for (int a = 0; a < NG; a++) if (gwe[p] && dst[p * 4 +: 4] == 4'(a)) m[a * GW +: GW] = gname[p * GW +: GW];
        for (int a = 0; a < NP; a++)
          if (pwe[p] && pdst[p * 2 +: 2] == 2'(a)) m[NG * GW + a * PW +: PW] = pname[p * PW +: PW];
      end
    map_at = m;
  endfunction

  // A map's entry by architectural index, as an AND-OR over the entries.
  function automatic logic [GW-1:0] gread(input logic [MW-1:0] m, input logic [3:0] a);
    logic [GW-1:0] r;
    r = '0;
    for (int t = 0; t < NG; t++) r = r | (m[t * GW +: GW] & {GW{a == 4'(t)}});
    gread = r;
  endfunction
  function automatic logic [PW-1:0] pread(input logic [MW-1:0] m, input logic [1:0] a);
    logic [PW-1:0] r;
    r = '0;
    for (int t = 0; t < NP; t++) r = r | (m[NG * GW + t * PW +: PW] & {PW{a == 2'(t)}});
    pread = r;
  endfunction

  // The reads, and each branch port's checkpoint.
  logic [A*MW-1:0] rd_map, ck_map;
  always_comb
    for (int k = 0; k < A; k++) begin
      rd_map[k * MW +: MW] = map_at(rat_cq02h, k, 1'b0, ren_v_cq01h, ren_slot_cq01h, ren_rst_cq01h, ren_dst_cq01h,
                                    ren_gwe_cq01h, ren_gname_cq01h, ren_pdst_cq01h, ren_pwe_cq01h,
                                    ren_pname_cq01h);
      ck_map[k * MW +: MW] = map_at(rat_cq02h, k, 1'b1, ren_v_cq01h, ren_slot_cq01h, ren_rst_cq01h, ren_dst_cq01h,
                                    ren_gwe_cq01h, ren_gname_cq01h, ren_pdst_cq01h, ren_pwe_cq01h,
                                    ren_pname_cq01h);
      for (int i = 0; i < 3; i++) ren_psrc_cq01h[(k * 3 + i) * GW +: GW] = gread(rd_map[k * MW +: MW], ren_src_cq01h[(k * 3 + i) * 4 +: 4]);
      ren_pold_cq01h[k * GW +: GW]    = gread(rd_map[k * MW +: MW], ren_dst_cq01h[k * 4 +: 4]);
      ren_ppguard_cq01h[k * PW +: PW] = pread(rd_map[k * MW +: MW], ren_pguard_cq01h[k * 2 +: 2]);
      ren_ppold_cq01h[k * PW +: PW]   = pread(rd_map[k * MW +: MW], ren_pdst_cq01h[k * 2 +: 2]);
      for (int i = 0; i < 2; i++) ren_ppq_cq01h[(k * 2 + i) * PW +: PW] = pread(rd_map[k * MW +: MW], ren_pq_cq01h[(k * 2 + i) * 2 +: 2]);
    end

  // -- the speculative maps --------------------------------------------------
  // A whole-map event's map, per slot: release, else squash, else restore.
  // An entry a rename port writes takes the last such port's name over it.
  logic [S-1:0]      whole;
  logic [S*MW-1:0]   base;
  logic [S*NG-1:0]   g_wr;              // a rename port writes GPR entry (s, a)
  logic [S*NG*GW-1:0] g_name;
  logic [S*NP-1:0]   p_wr;
  logic [S*NP*PW-1:0] p_name;
  always_comb begin
    g_wr   = '0;
    g_name = '0;
    p_wr   = '0;
    p_name = '0;
    for (int s = 0; s < S; s++) begin
      whole[s] = release_cq01h[s] || squash_cq01h[s] || restore_cq01h[s];
      if (release_cq01h[s])     base[s * MW +: MW] = {{NP{PZERO}}, {NG{GZERO}}};
      else if (squash_cq01h[s]) base[s * MW +: MW] = crat_cq02h[s * MW +: MW];
      else begin
        base[s * MW +: MW] = '0;
        for (int c = 0; c < C; c++)
          if (restore_ckpt_cq01h[s * LC +: LC] == LC'(c)) base[s * MW +: MW] = ckpt_cq02h[(s * C + c) * MW +: MW];
      end
      for (int p = 0; p < A; p++)
        if (ren_v_cq01h[p] && 32'(ren_slot_cq01h[p * LS +: LS]) == s) begin
          for (int a = 0; a < NG; a++)
            if (ren_gwe_cq01h[p] && ren_dst_cq01h[p * 4 +: 4] == 4'(a)) begin
              g_wr[s * NG + a]                   = 1'b1;
              g_name[(s * NG + a) * GW +: GW] = ren_gname_cq01h[p * GW +: GW];
            end
          for (int a = 0; a < NP; a++)
            if (ren_pwe_cq01h[p] && ren_pdst_cq01h[p * 2 +: 2] == 2'(a)) begin
              p_wr[s * NP + a]                   = 1'b1;
              p_name[(s * NP + a) * PW +: PW] = ren_pname_cq01h[p * PW +: PW];
            end
        end
    end
  end

  // A slot's speculative maps are one gate, clocked on a rename write to
  // the slot or a whole-map event. Per-entry gates leave a mispredict
  // clocking the entries it does not change (most of a map still holds its
  // checkpoint's names), and telling which it changes is a compare, 12 NGD
  // as an enable, or "written since checkpoint c" bits, 320 flops more. An
  // entry neither written nor in a whole-map event keeps its value, as an
  // AND-OR rather than a held if, so synthesis keeps the slot's enable.
  logic [S-1:0]    rat_en_cq01h;
  logic [S*MW-1:0] rat_nx;
  always_comb
    for (int s = 0; s < S; s++) begin
      rat_en_cq01h[s] = whole[s] || |g_wr[s * NG +: NG] || |p_wr[s * NP +: NP];
      for (int a = 0; a < NG; a++)
        rat_nx[s * MW + a * GW +: GW] =
            ({GW{g_wr[s * NG + a]}} & g_name[(s * NG + a) * GW +: GW]) |
            ({GW{!g_wr[s * NG + a] && whole[s]}} & base[s * MW + a * GW +: GW]) |
            ({GW{!g_wr[s * NG + a] && !whole[s]}} & rat_cq02h[s * MW + a * GW +: GW]);
      for (int a = 0; a < NP; a++)
        rat_nx[s * MW + NG * GW + a * PW +: PW] =
            ({PW{p_wr[s * NP + a]}} & p_name[(s * NP + a) * PW +: PW]) |
            ({PW{!p_wr[s * NP + a] && whole[s]}} & base[s * MW + NG * GW + a * PW +: PW]) |
            ({PW{!p_wr[s * NP + a] && !whole[s]}} & rat_cq02h[s * MW + NG * GW + a * PW +: PW]);
    end

  for (genvar s = 0; s < S; s++) begin : g_rat
    always_ff @(posedge ooe_core_clk) begin
      if (ooe_rst_r00h)       rat_cq02h[s * MW +: MW] <= {{NP{PZERO}}, {NG{GZERO}}};
      else if (rat_en_cq01h[s]) rat_cq02h[s * MW +: MW] <= rat_nx[s * MW +: MW];
    end
  end

  // -- the committed maps ----------------------------------------------------
  // Retire's writes in port order, then a restore-allocate's, which rename's
  // ports carry; a release maps the slot to the zero registers.
  logic [S*NG-1:0]    c_wr;
  logic [S*NG*GW-1:0] c_name;
  logic [S*NP-1:0]    cp_wr;
  logic [S*NP*PW-1:0] cp_name;
  always_comb begin
    c_wr    = '0;
    c_name  = '0;
    cp_wr   = '0;
    cp_name = '0;
    for (int s = 0; s < S; s++) begin
      for (int r = 0; r < R; r++) begin
        for (int a = 0; a < NG; a++)
          if (ret_gwe_cq01h[s * R + r] && ret_dst_cq01h[(s * R + r) * 4 +: 4] == 4'(a)) begin
            c_wr[s * NG + a]                   = 1'b1;
            c_name[(s * NG + a) * GW +: GW] = ret_gname_cq01h[(s * R + r) * GW +: GW];
          end
        for (int a = 0; a < NP; a++)
          if (ret_pwe_cq01h[s * R + r] && ret_pdst_cq01h[(s * R + r) * 2 +: 2] == 2'(a)) begin
            cp_wr[s * NP + a]                   = 1'b1;
            cp_name[(s * NP + a) * PW +: PW] = ret_pname_cq01h[(s * R + r) * PW +: PW];
          end
      end
      for (int p = 0; p < A; p++)
        if (ren_v_cq01h[p] && ren_rst_cq01h[p] && 32'(ren_slot_cq01h[p * LS +: LS]) == s) begin
          for (int a = 0; a < NG; a++)
            if (ren_gwe_cq01h[p] && ren_dst_cq01h[p * 4 +: 4] == 4'(a)) begin
              c_wr[s * NG + a]                   = 1'b1;
              c_name[(s * NG + a) * GW +: GW] = ren_gname_cq01h[p * GW +: GW];
            end
          for (int a = 0; a < NP; a++)
            if (ren_pwe_cq01h[p] && ren_pdst_cq01h[p * 2 +: 2] == 2'(a)) begin
              cp_wr[s * NP + a]                   = 1'b1;
              cp_name[(s * NP + a) * PW +: PW] = ren_pname_cq01h[p * PW +: PW];
            end
        end
    end
  end

  logic [S*NG-1:0]    crat_g_en_cq01h;
  logic [S-1:0]       crat_p_en_cq01h;
  logic [S*NP*PW-1:0] crat_p_nx;
  always_comb
    for (int s = 0; s < S; s++) begin
      for (int a = 0; a < NG; a++) crat_g_en_cq01h[s * NG + a] = release_cq01h[s] || c_wr[s * NG + a];
      crat_p_en_cq01h[s] = release_cq01h[s] || |cp_wr[s * NP +: NP];
      for (int a = 0; a < NP; a++)
        crat_p_nx[(s * NP + a) * PW +: PW] =
            ({PW{cp_wr[s * NP + a]}} & cp_name[(s * NP + a) * PW +: PW]) |
            ({PW{!cp_wr[s * NP + a] && release_cq01h[s]}} & PZERO) |
            ({PW{!cp_wr[s * NP + a] && !release_cq01h[s]}} & crat_cq02h[s * MW + NG * GW + a * PW +: PW]);
    end

  for (genvar s = 0; s < S; s++) begin : g_crat
    for (genvar a = 0; a < NG; a++) begin : g_gpr
      always_ff @(posedge ooe_core_clk) begin
        if (ooe_rst_r00h) crat_cq02h[s * MW + a * GW +: GW] <= GZERO;
        else if (crat_g_en_cq01h[s * NG + a])
          crat_cq02h[s * MW + a * GW +: GW] <= c_wr[s * NG + a] ? c_name[(s * NG + a) * GW +: GW] : GZERO;
      end
    end
    always_ff @(posedge ooe_core_clk) begin
      if (ooe_rst_r00h) crat_cq02h[s * MW + NG * GW +: NP * PW] <= {NP{PZERO}};
      else if (crat_p_en_cq01h[s]) crat_cq02h[s * MW + NG * GW +: NP * PW] <= crat_p_nx[s * NP * PW +: NP * PW];
    end
  end

  // -- the checkpoints -------------------------------------------------------
  // Checkpoint (s, c) is written when a branch port of slot s takes it, with
  // the maps as they stand after that port's writes.
  logic [S*C-1:0]  ckpt_en_cq01h;
  logic [S*C*MW-1:0] ckpt_nx;
  always_comb begin
    ckpt_en_cq01h = '0;
    ckpt_nx       = '0;
    for (int p = 0; p < A; p++)
      for (int i = 0; i < S * C; i++)
        if (ren_v_cq01h[p] && !ren_rst_cq01h[p] && ren_br_cq01h[p] &&
            ren_slot_cq01h[p * LS +: LS] == LS'(i / C) && ren_ckpt_cq01h[p * LC +: LC] == LC'(i % C)) begin
          ckpt_en_cq01h[i]          = 1'b1;
          ckpt_nx[i * MW +: MW] = ck_map[p * MW +: MW];
        end
  end
  for (genvar i = 0; i < S * C; i++) begin : g_ckpt
    always_ff @(posedge ooe_core_clk) begin
      if (ckpt_en_cq01h[i]) ckpt_cq02h[i * MW +: MW] <= ckpt_nx[i * MW +: MW];
    end
  end

  // Rename names no slot a whole-map event names this cycle (see above).
  logic [S-1:0] renamed_cq01h;
  always_comb begin
    renamed_cq01h = '0;
    for (int p = 0; p < A; p++)
      for (int s = 0; s < S; s++)
        if (ren_v_cq01h[p] && !ren_rst_cq01h[p] && ren_slot_cq01h[p * LS +: LS] == LS'(s)) renamed_cq01h[s] = 1'b1;
  end
  `CCV_ASSERT(rename_excludes_events, (renamed_cq01h & whole) == '0)

endmodule
`undef CCV_CLK
`undef CCV_RST
