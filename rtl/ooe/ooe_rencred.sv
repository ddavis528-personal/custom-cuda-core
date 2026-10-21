//===-- ooe_rencred.sv - OOE rename's credit counters, their next state ---===//
//
// Spec: the design doc's Stage boundaries (rename's go decision, OA-21,
//       OA-22, OI-65: "rename's credit counters take TI-19's free counts
//       (free_th, ld_conf_th, ret_n) as registered pulses at the edge, and
//       no free count is on the go's path"; the per-cycle shares are split
//       from them); docs/ooe-rtl-plan.md, ooe_rename, slice 3.
//
// An inner helper (ooe_rencred.ngd.json): combinational, no flops, timed in
// its parent, ooe_rename, whose counters it gives the next value of. The
// shared credits are RS room per class and the free GPR and predicate
// names; each slot's is its ROB room. A counter falls by what rename's go
// takes in the cycle and by any other draw, and rises by the frees of the
// cycle, which rename sees from the next: an RS free within ooe_rs's
// prompt count (its free thermometer, by class, capped at F) at this edge,
// the rest (a squash's, or past the cap) at the next, from ooe_rs's
// register of them. So each counter is exact for the registered go: what
// rename may still take, without this cycle's frees.
//
// The reference is the model's renCredits and renEvents
// (fits_stale 6): test/ooe/rencred_tb.cpp holds the counters, drives this
// helper with the model's events after every cycle, and compares the next
// value with the model's credits, from its state, at the next edge.
//
// The go's takes arrive late (the take counts, then each warp's prefix
// needs by its take), so each counter's next value is formed for every
// count the late inputs may give, in parallel (a carry-save step and one
// prefix add each), and the takes select one.
//===----------------------------------------------------------------------===//
module ooe_rencred #(
  parameter int S  = 4,                  // tier-1 slots (CCV_TIER1_WARPS)
  parameter int A  = 4,                  // rename width, and allocation ports per RS class (CCV_ISSUE_WIDTH)
  parameter int NR = 30,                 // RS RCU entries (CCV_P_RS_RCU)
  parameter int NM = 15,                 // RS MIU entries (CCV_P_RS_MIU)
  parameter int NG = 192,                // GPR names (CCV_P_PHYS_REGS)
  parameter int NP = 48,                 // predicate names (CCV_P_PRED_REGS)
  parameter int RD = 32,                 // ROB slots per warp (CCV_P_ROB_DEPTH)
  parameter int F  = 4,                  // ooe_rs's prompt free count, per class (TI-19's cap)
  localparam int LR = $clog2(NR + 1),
  localparam int LM = $clog2(NM + 1),
  localparam int LG = $clog2(NG + 1),
  localparam int LP = $clog2(NP + 1),
  localparam int LD = $clog2(RD + 1)
) (
  // The counters, as rename's flops hold them.
  input  logic [LR-1:0]   rc_cq02h,      // RS RCU room
  input  logic [LM-1:0]   mc_cq02h,      // RS MIU room
  input  logic [LG-1:0]   gc_cq02h,      // free GPR names
  input  logic [LP-1:0]   pc_cq02h,      // free predicate names
  input  logic [S*LD-1:0] robc_cq02h,    // each slot's ROB room
  // This cycle's frees and draws.
  input  logic [F-1:0]    fpr_cq01h,     // RS RCU frees within the prompt count: a thermometer
  input  logic [F-1:0]    fpm_cq01h,     // and RS MIU
  input  logic [LR-1:0]   flr_cq01h,     // last cycle's RS RCU frees past it
  input  logic [LM-1:0]   flm_cq01h,     // and RS MIU
  input  logic [LG:0]     gn_cq01h,      // GPR names freed less those drawn other than by the go
                                         // (a restore-allocate), two's complement
  input  logic [LP:0]     pn_cq01h,      // and predicate names
  input  logic [S*LD-1:0] robf_cq01h,    // each slot's ROB slots freed (retired, squashed or killed)
  // The go's takes, thermometers by A: RS entries per class, names, and
  // each slot's uops.
  input  logic [A-1:0]    tkr_cq01h,
  input  logic [A-1:0]    tkm_cq01h,
  input  logic [A-1:0]    tkg_cq01h,
  input  logic [A-1:0]    tkp_cq01h,
  input  logic [S*A-1:0]  tku_cq01h,
  output logic [LR-1:0]   rc_nx,
  output logic [LM-1:0]   mc_nx,
  output logic [LG-1:0]   gc_nx,
  output logic [LP-1:0]   pc_nx,
  output logic [S*LD-1:0] robc_nx
);

  // A W-bit add by a Sklansky prefix tree: log2(W) levels of carry.
  localparam int W = LG + 2;             // the widest counter, a sign bit and a guard bit
  function automatic logic [W-1:0] padd(input logic [W-1:0] a, input logic [W-1:0] b);
    logic [W-1:0] g, p, gn, pn;
    g = a & b;
    p = a ^ b;
    for (int l = 0; (1 << l) < W; l++) begin
      gn = g;
      pn = p;
      for (int i = 0; i < W; i++)
        if (((i >> l) & 1) == 1) begin
          gn[i] = g[i] | (p[i] & g[((i >> l) << l) - 1]);
          pn[i] = p[i] & p[((i >> l) << l) - 1];
        end
      g = gn;
      p = pn;
    end
    padd = (a ^ b) ^ {g[W-2:0], 1'b0};
  endfunction
  // a + b + k for a constant k: a carry-save step folds k in, then one add.
  function automatic logic [W-1:0] add3k(input logic [W-1:0] a, input logic [W-1:0] b, input int k);
    logic [W-1:0] kk, sm, cy;
    kk = W'(k);
    sm = a ^ b ^ kk;
    cy = (a & b) | (a & kk) | (b & kk);
    add3k = padd(sm, {cy[W-2:0], 1'b0});
  endfunction
  // A thermometer's value, one-hot: bit j when exactly j are set.
  function automatic logic [A:0] onehot(input logic [A-1:0] t);
    for (int j = 0; j <= A; j++)
      onehot[j] = (j == 0 || t[j == 0 ? 0 : j - 1]) && (j == A || !t[j == A ? 0 : j]);
  endfunction
  function automatic logic [F:0] fonehot(input logic [F-1:0] t);
    for (int j = 0; j <= F; j++)
      fonehot[j] = (j == 0 || t[j == 0 ? 0 : j - 1]) && (j == F || !t[j == F ? 0 : j]);
  endfunction

  // Each counter's next value for every count the late inputs may give,
  // formed in parallel, then one selected. An RS class: c + late + p - k,
  // for the prompt frees p (0 to F) and the take k (0 to A), selected by
  // d = p - k. Names: c + net - k. A slot's ROB: c + freed - k.
  localparam int ND = F + A + 1;
  function automatic logic [ND-1:0] dsel(input logic [F-1:0] fp, input logic [A-1:0] tk);
    logic [F:0] po;
    logic [A:0] ko;
    po = fonehot(fp);
    ko = onehot(tk);
    dsel = '0;
    for (int pp = 0; pp <= F; pp++)
      for (int k = 0; k <= A; k++)
        if (po[pp] && ko[k]) dsel[pp - k + A] = 1'b1;
  endfunction
  function automatic logic [W-1:0] rs_next(input logic [W-1:0] c, input logic [W-1:0] late,
                                           input logic [F-1:0] fp, input logic [A-1:0] tk);
    logic [ND-1:0] d;
    d = dsel(fp, tk);
    rs_next = '0;
    for (int j = 0; j < ND; j++) if (d[j]) rs_next = rs_next | add3k(c, late, j - A);
  endfunction
  function automatic logic [W-1:0] take_next(input logic [W-1:0] c, input logic [W-1:0] up, input logic [A-1:0] tk);
    logic [A:0] ko;
    ko = onehot(tk);
    take_next = '0;
    for (int k = 0; k <= A; k++) if (ko[k]) take_next = take_next | add3k(c, up, -k);
  endfunction

  logic [W-1:0] r_nx, m_nx, g_nx, p_nx;
  logic [W-1:0] o_nx [S];
  always_comb begin
    r_nx = rs_next(W'(rc_cq02h), W'(flr_cq01h), fpr_cq01h, tkr_cq01h);
    m_nx = rs_next(W'(mc_cq02h), W'(flm_cq01h), fpm_cq01h, tkm_cq01h);
    g_nx = take_next(W'(gc_cq02h), W'($signed(gn_cq01h)), tkg_cq01h);
    p_nx = take_next(W'(pc_cq02h), W'($signed(pn_cq01h)), tkp_cq01h);
    for (int s = 0; s < S; s++) begin
      o_nx[s] = take_next(W'(robc_cq02h[s * LD +: LD]), W'(robf_cq01h[s * LD +: LD]), tku_cq01h[s * A +: A]);
      robc_nx[s * LD +: LD] = o_nx[s][LD-1:0];
    end
  end
  assign rc_nx = r_nx[LR-1:0];
  assign mc_nx = m_nx[LM-1:0];
  assign gc_nx = g_nx[LG-1:0];
  assign pc_nx = p_nx[LP-1:0];

endmodule
