//===-- ccv_common_csa.sv - a multi-operand adder: carry-save, then one add -===//
//
// Spec: docs/ooe-rtl-plan.md, ooe_rename, slice 7b (rename's counters,
//       OI-73 to OI-76); a shared cell by TI's response OI-76 (TI tab rev
//       164), rtl/common/ being TI's: OI edits it, then notifies TI.
//
// An inner helper (ccv_common_csa.ngd.json): combinational, no flops,
// timed in its parent. The sum of N operands of W bits, modulo 2^W (two's
// complement: a negative operand is its W-bit complement plus one). Each
// level of the tree takes the operands three at a time through a row of
// 3:2 compressors (full adders, bit by bit: a sum and a carry one bit up)
// and passes the rest through, so N operands become 2 floor(N / 3) + N mod
// 3; at two, one carry-propagate add (sum), or none (pair: the two
// operands that are left, for a parent that registers the redundant form
// and adds it later). The depth is the compressors' levels, about
// log1.5(N / 2), and one W-bit add, against a tree of adds' log2(N) adds.
//
// Each level's operand count is an elaboration constant (ops_at), so the
// tree is built by generate, not unrolled from a loop.
//
// Where the operands are counts (none negative) summing under 2^W, no
// compressor drops a carry, so pair's two sum to it exactly, not just
// modulo 2^W (a carry out of the top bit needs two operands' top bits).
//
// DUAL (Daniel's ruling, TI's response OI-76): 0 is single rail, this
// body, which OOE uses. DUAL = 1, each operand in both rails (the caller
// registering the complement in (* keep *) flops) so the compressors need
// no inverters, is TI's to add, with its own test and control; until then
// DUAL is 0 in every instance.
//
// Used by ooe_freelist (each slot's frees, a pair) and ooe_rename (each
// slot's remainders, the names' pools); the same structure suits a wider
// reduction, a lane's multiply among them.
//===----------------------------------------------------------------------===//
module ccv_common_csa #(
  parameter int N = 3,                   // operands, 1 or more
  parameter int W = 8,                   // their width, and the sum's
  parameter int DUAL = 0                 // 0: single rail, the only form built (see above)
) (
  input  logic [N*W-1:0] op,
  output logic [W-1:0]   sum,           // the sum
  output logic [2*W-1:0] pair           // and before the final add: two operands that sum to it
);
  // Operands after l compressor levels, and the levels to reach two.
  function automatic int ops_at(input int n, input int l);
    int m;
    m = n;
    for (int i = 0; i < l; i++) if (m > 2) m = 2 * (m / 3) + m % 3;
    ops_at = m;
  endfunction
  function automatic int levels(input int n);
    int c, m;
    c = 0;
    m = n;
    for (int i = 0; i < 64; i++)
      if (m > 2) begin
        m = 2 * (m / 3) + m % 3;
        c = c + 1;
      end
    levels = c;
  endfunction
  localparam int L  = levels(N);
  localparam int NM = (N > 2) ? N : 2;   // operands at the widest level

  // The single-rail form (DUAL = 0); DUAL = 1's branch is TI's to come.
  if (DUAL == 0) begin : g_single
    // Level l's operands, packed; level 0 is the input.
    logic [NM*W-1:0] lv [L+1];
    assign lv[0] = (NM*W)'(op);
    for (genvar l = 0; l < L; l++) begin : g_l
      localparam int NI = ops_at(N, l);    // operands in
      localparam int NG = NI / 3;          // compressor rows
      localparam int NO = 2 * NG + NI % 3; // operands out
      logic [NM*W-1:0] nx;
      for (genvar g = 0; g < NG; g++) begin : g_g
        logic [W-1:0] a, b, c, m;
        assign a = lv[l][(3 * g) * W +: W];
        assign b = lv[l][(3 * g + 1) * W +: W];
        assign c = lv[l][(3 * g + 2) * W +: W];
        assign m = (a & b) | (a & c) | (b & c);
        assign nx[(2 * g) * W +: W]     = a ^ b ^ c;
        assign nx[(2 * g + 1) * W +: W] = {m[W-2:0], 1'b0};
      end
      // The operands no row takes pass through.
      for (genvar r = 0; r < NI % 3; r++) begin : g_r
        assign nx[(2 * NG + r) * W +: W] = lv[l][(3 * NG + r) * W +: W];
      end
      if (NO < NM) begin : g_z
        assign nx[NM*W-1 : NO * W] = '0;
      end
      assign lv[l + 1] = nx;
    end
    assign pair = lv[L][0 +: 2 * W];
    if (N >= 2) begin : g_add
      assign sum = lv[L][0 +: W] + lv[L][W +: W];
    end else begin : g_one
      assign sum = lv[L][0 +: W];
    end
  end
endmodule
