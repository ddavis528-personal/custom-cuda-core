//===-- rcu_q53_chk.sv - RCU's Q-53 checkers, sim only ---------------------===//
//
// The checkers RCU's RTL owes under Q-53 (docs/open-items.md; the RCU
// spec's Partition tab, "Q-53 checkers owed by RCU's RTL",
// docs/design-snapshots/rcu-arch-partition.md), bound into ccv_rcu
// (test/rcu/rcu_q53_bind.svh). Nothing here is synthesised: it reads the
// block's ports, and for A-45 the migration engine's launch, by the bind's
// connections. Each check is a CCV_ASSERT_AT, so a failure reads as any
// other assertion's (the block lock-step, test/rcu/lockstep.py, counts them).
//
//   q53_arrival  every rcu_ooe_done valid comes at A+1 (slots 5, 6), A+6
//                (lane slots 0-3) or A+11 (SFU slot 4) after the issue that
//                names its rob_tag and done_row (the Done tab's table: an
//                issue's valid is on the wire at A-1, its payload at A; a
//                done's valid at A+L, its payload at A+L+1).
//   q53_pair     A-45: every migration launch pairs one map with one command
//                of its warp and direction, both landed and not dropped by a
//                kill (rcu_mig's dl, demotion, and rl, restore).
//   q53_one      one migration a warp: a map or command never lands beside
//                another of the same warp and direction still waiting.
//   q53_rzero,   A-64's restore half: a restore map names no zero register,
//   q53_rdup     and gives each architectural register a row of its own
//                (TI-25 (1)); the model checks the same (sim/rcu/rcu_core.cpp).
//
//   q53_iso      A-35, RCU's half at the block (the model's, rcu_core.cpp: TI-13):
//                a restore's GPR rows and predicates are unwritten from its
//                map's landing until the restore writes them (RS on the
//                slices' RW port, PG on rcu_pred's ports 9-12); an issue in A
//                whose class reads a source row, or its guard predicate, that
//                is still unwritten fails. A write in the same cycle counts.
//                A-35's general form, every newly allocated row written before
//                any read, needs OOE's allocation, which only the SV top shows
//                (RI-42); this is the half RCU itself sees.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK core_clk
`define CCV_RST rst
module rcu_q53_chk #(
  parameter int NS = 9,                                   // issue slots
  parameter int ND = 7,                                   // done slots
  parameter int CW = 27,                                  // rcu_dec_pkg::CLS_W
  parameter logic [8:0] PL = 9'h0ff,                      // slots whose sources are payload fields (else leads)
  localparam int TW = ccv_prov_pkg::CCV_P_W_ROB_TAG,
  localparam int WW = ccv_params_pkg::CCV_W_WARP_ID,
  localparam int NG = ccv_params_pkg::CCV_GPRS,
  localparam int WR = ccv_prov_pkg::CCV_P_W_PHYS_REG,
  localparam int NWP = 1 << WW,
  localparam int NP = ccv_params_pkg::CCV_PREDS,
  localparam int WP = ccv_prov_pkg::CCV_P_W_PHYS_PRED,
  localparam int ROWS = ccv_prov_pkg::CCV_P_PHYS_REGS,
  localparam int PROWS = ccv_prov_pkg::CCV_P_PRED_REGS,
  localparam int H = 12                                   // A-1 .. A-12 kept
) (
  input logic              core_clk,
  input logic              rst_n,
  input logic [NS-1:0]     iv,          // issue valid (A-1)
  input logic [NS*TW-1:0]  itag,        // issue rob_tag (A)
  input logic [NS*2-1:0]   irow,        // issue done_row (A)
  input logic [ND-1:0]     dv,          // done valid (A+L)
  input logic [ND*TW-1:0]  dtag,        // done rob_tag (A+L+1)
  input logic [ND*2-1:0]   drow,        // done done_row (A+L+1)
  input logic              map_v,       // ooe_rcu_map valid (T-1)
  input logic [WW-1:0]     map_w,       // its payload (T)
  input logic              map_d,
  input logic [NG*WR-1:0]  map_g,
  input logic [NP*WP-1:0]  map_p,
  input logic [NS*CW-1:0]  icls,        // each slot's class word (A)
  input logic [NS*2*WR-1:0] isrc,       // phys_src (A)
  input logic [NS*WR-1:0]  isrc2,       // phys_src2 (A)
  input logic [NS*2*WR-1:0] lsrc,       // lead_phys_src (A-1)
  input logic [NS*WR-1:0]  lsrc2,       // lead_phys_src2 (A-1)
  input logic [NS*WP-1:0]  lgp,         // lead_guard_pred (A-1)
  input logic [ROWS*4-1:0] shit,        // slice (0, 0)'s row hits, row r port q at 4r + q
  input logic              sgws,        // ... its RW port carrying a restore row
  input logic [PROWS*17-1:0] phit,      // rcu_pred's row hits, row r port q at 17r + q
  input logic              cmd_v,       // rau_rcu_mig valid (T-1)
  input logic [WW-1:0]     cmd_w,       // its payload (T)
  input logic              cmd_d,
  input logic              kill_valid,  // K-1
  input logic [31:0]       kill_warp_mask, // K
  input logic              dl,          // rcu_mig: a demotion launches at this edge
  input logic [WW-1:0]     dl_w,
  input logic              rl,          // rcu_mig: a restore launches at this edge
  input logic [WW-1:0]     rl_w
);
  wire rst = !rst_n;
  function automatic int lat(int k);
    return (k == 5 || k == 6) ? 1 : (k == 4) ? 11 : 6;
  endfunction

  // ---- q53_arrival -------------------------------------------------------
  // hv[j][s]: slot s's issue had its payload (A) j + 1 cycles ago.
  logic [NS-1:0]    ivq, dvq_s;
  logic [ND-1:0]    dvq;
  logic [NS-1:0]    hv [H];
  logic [NS*TW-1:0] ht [H];
  logic [NS*2-1:0]  hr [H];
  always_ff @(posedge core_clk) begin
    ivq <= rst ? '0 : iv;
    dvq <= rst ? '0 : dv;
    for (int j = H - 1; j > 0; j--) begin
      hv[j] <= hv[j - 1]; ht[j] <= ht[j - 1]; hr[j] <= hr[j - 1];
    end
    hv[0] <= rst ? '0 : ivq; ht[0] <= itag; hr[0] <= irow;
  end
  initial for (int j = 0; j < H; j++) hv[j] = '0;
  // A done's payload is on the wire now (its valid was, a cycle ago): its
  // issue's A is L + 1 cycles back, hv[L].
  logic [ND-1:0] dmiss;
  always_comb
    for (int k = 0; k < ND; k++) begin
      automatic int L = lat(k);
      automatic logic hit = 1'b0;
      for (int s = 0; s < NS; s++)
        hit |= hv[L][s] && ht[L][s*TW +: TW] == dtag[k*TW +: TW] && hr[L][s*2 +: 2] == drow[k*2 +: 2];
      dmiss[k] = dvq[k] && !hit;
    end
  `CCV_ASSERT_AT(core_clk, rst, q53_arrival, dmiss == '0)

  // ---- q53_pair, q53_one ---------------------------------------------------
  // Landed and waiting, per (warp, direction): a map or command lands in its
  // payload cycle; a launch takes one of each; a kill drops a killed warp's
  // at the edge ending K+1, as rcu_mig's entries leave (a launch it already
  // made stands; a land at K+1 stays: rcu_mig drops by the kill's event).
  logic          mapq, cmdq, kvq, kap;
  logic [31:0]   kmq;
  logic [1:0]    mc [NWP][2];
  logic [1:0]    cc [NWP][2];
  always_ff @(posedge core_clk) begin
    mapq <= rst ? 1'b0 : map_v;
    cmdq <= rst ? 1'b0 : cmd_v;
    kvq  <= rst ? 1'b0 : kill_valid;
    kap  <= rst ? 1'b0 : kvq;            // high in K+1
    if (kvq) kmq <= kill_warp_mask;
  end
  wire dbad = dl && (mc[dl_w][0] == 0 || cc[dl_w][0] == 0);
  wire rbad = rl && (mc[rl_w][1] == 0 || cc[rl_w][1] == 0);
  `CCV_ASSERT_AT(core_clk, rst, q53_pair, !dbad && !rbad)
  `CCV_ASSERT_AT(core_clk, rst, q53_one,
                 !(mapq && mc[map_w][map_d] != 0 && !(kap && kmq[map_w])) &&
                 !(cmdq && cc[cmd_w][cmd_d] != 0 && !(kap && kmq[cmd_w])))
  // The counters' next state, combinational (CCV-L04), then flopped.
  logic [1:0] mc_n [NWP][2];
  logic [1:0] cc_n [NWP][2];
  always_comb
    for (int w = 0; w < NWP; w++)
      for (int d = 0; d < 2; d++) begin
        mc_n[w][d] = (kap && kmq[w]) ? 2'd0 : mc[w][d];
        cc_n[w][d] = (kap && kmq[w]) ? 2'd0 : cc[w][d];
        if ((dl && dl_w == w && d == 0) || (rl && rl_w == w && d == 1)) begin
          if (mc_n[w][d] != 0) mc_n[w][d] = mc_n[w][d] - 1'b1;
          if (cc_n[w][d] != 0) cc_n[w][d] = cc_n[w][d] - 1'b1;
        end
        if (mapq && map_w == w && map_d == d && mc_n[w][d] != 2'd3) mc_n[w][d] = mc_n[w][d] + 1'b1;
        if (cmdq && cmd_w == w && cmd_d == d && cc_n[w][d] != 2'd3) cc_n[w][d] = cc_n[w][d] + 1'b1;
      end
  always_ff @(posedge core_clk)
    for (int w = 0; w < NWP; w++)
      for (int d = 0; d < 2; d++) begin
        mc[w][d] <= rst ? 2'd0 : mc_n[w][d];
        cc[w][d] <= rst ? 2'd0 : cc_n[w][d];
      end

  // ---- q53_rzero, q53_rdup ----------------------------------------------
  logic rz, rd;
  always_comb begin
    rz = 1'b0; rd = 1'b0;
    for (int a = 0; a < NG; a++) begin
      rz |= map_g[a*WR +: WR] == WR'(ccv_prov_pkg::CCV_P_PHYS_ZERO);
      for (int b = 0; b < a; b++) rd |= map_g[a*WR +: WR] == map_g[b*WR +: WR];
    end
  end
  `CCV_ASSERT_AT(core_clk, rst, q53_rzero, !(mapq && map_d && rz))
  `CCV_ASSERT_AT(core_clk, rst, q53_rdup, !(mapq && map_d && rd))

  // ---- q53_iso -------------------------------------------------------------
  logic [NS*2*WR-1:0] lsq;
  logic [NS*WR-1:0]   ls2q;
  logic [NS*WP-1:0]   lgq;
  logic [255:0]       ug;       // GPR rows unwritten (index space of the 8-bit row)
  logic [63:0]        up;       // predicates unwritten
  always_ff @(posedge core_clk) begin
    lsq <= lsrc; ls2q <= lsrc2; lgq <= lgp;
  end
  // Written now: the restore's GPR row (every slice writes it; slice (0, 0)
  // stands for all), its predicates on PG.
  logic [255:0] gw;
  logic [63:0]  pw;
  always_comb begin
    gw = '0; pw = '0;
    for (int r = 0; r < ROWS; r++) gw[r] = sgws && shit[r*4 + 2];
    for (int r = 0; r < PROWS; r++)
      for (int q = 9; q < 13; q++) pw[r] |= phit[r*17 + q];
  end
  wire [255:0] ugn = ug & ~gw;
  wire [63:0]  upn = up & ~pw;
  logic [NS-1:0] ibad;
  always_comb
    for (int s = 0; s < NS; s++) begin
      automatic logic [CW-1:0] c = icls[s*CW +: CW];
      automatic logic [2*WR-1:0] ps = PL[s] ? isrc[s*2*WR +: 2*WR] : lsq[s*2*WR +: 2*WR];
      automatic logic [WR-1:0] p2 = PL[s] ? isrc2[s*WR +: WR] : ls2q[s*WR +: WR];
      automatic logic [WR-1:0] src [3];
      src[0] = ps[WR +: WR]; src[1] = ps[0 +: WR]; src[2] = p2;
      ibad[s] = 1'b0;
      for (int i = 0; i < 3; i++)
        ibad[s] |= c[rcu_dec_pkg::CLS_READS + i] && ugn[src[i]];
      ibad[s] |= (c[rcu_dec_pkg::CLS_GUARDED] || c[rcu_dec_pkg::CLS_PDATA]) && upn[lgq[s*WP +: WP]];
      ibad[s] &= ivq[s];
    end
  `CCV_ASSERT_AT(core_clk, rst, q53_iso, ibad == '0)
  logic [255:0] ug_n;
  logic [63:0]  up_n;
  always_comb begin
    ug_n = ugn;
    up_n = upn;
    if (mapq && map_d) begin
      for (int a = 0; a < NG; a++) ug_n[map_g[a*WR +: WR]] = 1'b1;
      for (int q = 0; q < NP; q++) up_n[map_p[q*WP +: WP]] = 1'b1;
    end
  end
  always_ff @(posedge core_clk) begin
    ug <= rst ? '0 : ug_n;
    up <= rst ? '0 : up_n;
  end
endmodule
`undef CCV_CLK
`undef CCV_RST
