//===-- ooe_rs.sv - OOE reservation stations: valid, allocation, matrix -===//
//
// Spec: the design doc's Reservation stations and dependency matrix
//       (A-62, A-73: a cell per ordered pair, its dependency bit and its
//       2-bit wake-line select), the RS classes (30 RCU, 15 MIU), the reset
//       line (OI-36 (6): valid bits reset; the cells are payload guarded by
//       their row's valid, every one written at allocation) and DA's
//       response OI-39 (the RS keeps same-edge reuse unless its RTL
//       measures over the stage).
//
// The RS valid bits and the dependency matrix. Each class, RCU entries
// [0, NR) and MIU entries [NR, N), has A allocation ports, used in order.
// Port k takes the free entry with exactly k free entries below it in its
// class: first fit, as the model's rsAlloc. An entry freed this cycle (a
// confirmation or a squash) counts as free: the RS keeps same-edge reuse.
// The free count below each entry saturates at A and is kept as a
// thermometer, so two counts add as an AND-OR with no carry; the counts
// come from a Sklansky prefix tree, log2 of the class size deep.
//
// An allocation writes the entry's whole row: its dependency bits and line
// selects for entries already in the RS, and for entries granted this
// cycle to another port (an older producer renamed in the same group, in
// either class), named by port. A free clears the entry's column in every row, so a dependant
// never waits on, nor confirms behind, the entry's next occupant.
//
// The reference is the model's rsAlloc, rsFree and dependency cells, which
// log each cycle's allocations in order and its frees (Core::wakeLog:
// ralloc, rfree). test/ooe/rs_tb.cpp drives this module from them and
// compares the grants before the edge and, after it, the valid bits and
// every valid row's dependency bits and line selects.
//
// State is one register, its next value a function of it and this cycle's
// inputs (CCV-L23); the flop takes one function, step(), with reset folded
// in.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK ooe_core_clk
`define CCV_RST ooe_rst_r00h
module ooe_rs #(
  parameter int N  = 45,                 // RS entries (CCV_P_RS_RCU + CCV_P_RS_MIU)
  parameter int NR = 30,                 // RCU-class entries, [0, NR)
  parameter int A  = 4,                  // allocation ports per class (CCV_ISSUE_WIDTH)
  localparam int P  = 2 * A,             // ports: RCU's 0..A-1, then MIU's
  localparam int W  = $clog2(N)
) (
  input  logic             ooe_core_clk,
  input  logic             ooe_rst_r00h,
  input  logic [P-1:0]     req_cq01h,    // port p allocates
  input  logic [P*N-1:0]   row_dep_cq01h,  // port p's row: entries already in the RS
  input  logic [2*P*N-1:0] row_code_cq01h, // and each one's line select
  input  logic [P*P-1:0]   grp_dep_cq01h,  // port p's row: port q's entry, granted this cycle
  input  logic [2*P*P-1:0] grp_code_cq01h, // and its line select
  input  logic [N-1:0]     free_cq01h,   // entries freed this cycle
  output logic [P-1:0]     gnt_v_cq02h,  // port p granted
  output logic [P*W-1:0]   gnt_idx_cq02h, // port p's entry
  output logic [N-1:0]     valid_cq02h,
  output logic [N*N-1:0]   dep_cq02h,    // row i, column j: i waits on j
  output logic [2*N*N-1:0] code_cq02h    // the cell's wake-line select
);

  // The state's fields.
  localparam int OVAL  = 0;
  localparam int ODEP  = OVAL + N;
  localparam int OCODE = ODEP + N * N;
  localparam int SW    = OCODE + 2 * N * N;

  `CCV_ASSERT_KNOWN(req_known, req_cq01h)
  `CCV_ASSERT_KNOWN(free_known, free_cq01h)

  // A free count saturating at A, as a thermometer: bit k set when the count
  // exceeds k. Two counts add as an AND-OR, with no carry chain.
  function automatic logic [A-1:0] tadd(input logic [A-1:0] a, input logic [A-1:0] b);
    logic [A-1:0] c;
    for (int k = 0; k < A; k++) begin
      c[k] = a[k] || b[k];
      for (int i = 0; i < k; i++) c[k] = c[k] || (a[i] && b[k - 1 - i]);
    end
    tadd = c;
  endfunction

  // Each entry's free count below it, within its class [lo, lo + M): an
  // inclusive prefix by a Sklansky tree, log2(M) levels of tadd, then
  // shifted by one entry.
  function automatic logic [N*A-1:0] below(input logic [N-1:0] av);
    logic [N*A-1:0] pf, nx, bl;
    int             lo, m, pos, src;
    pf = '0;
    for (int e = 0; e < N; e++) pf[e * A] = av[e];
    for (int l = 0; (1 << l) < N; l++) begin
      nx = pf;
      for (int e = 0; e < N; e++) begin
        lo  = (e < NR) ? 0 : NR;
        m   = (e < NR) ? NR : N - NR;
        pos = e - lo;
        src = ((pos >> l) << l) - 1;
        if (((pos >> l) & 1) == 1 && (1 << l) < m)
          nx[e * A +: A] = tadd(pf[(lo + src) * A +: A], pf[e * A +: A]);
      end
      pf = nx;
    end
    bl = '0;
    for (int e = 0; e < N; e++)
      if (e != 0 && e != NR) bl[e * A +: A] = pf[(e - 1) * A +: A];
    below = bl;
  endfunction

  // Port p's grant, one-hot over the entries: in its class, free, with as
  // many free below it as the port's number within the class.
  function automatic logic [P*N-1:0] grants(input logic [SW-1:0] st, input logic [P-1:0] req,
                                            input logic [N-1:0] fr);
    logic [N-1:0]   av;
    logic [N*A-1:0] bl;
    logic [P*N-1:0] g;
    logic           k_ok;
    for (int e = 0; e < N; e++) av[e] = !st[OVAL + e] || fr[e];
    bl = below(av);
    for (int p = 0; p < P; p++)
      for (int e = 0; e < N; e++) begin
        // Exactly p % A free below: the thermometer is set to p % A and no further.
        k_ok = (p % A == 0 || bl[e * A + ((p % A == 0) ? 0 : p % A - 1)]) && !bl[e * A + p % A];
        g[p * N + e] = req[p] && av[e] && ((p < A) == (e < NR)) && k_ok;
      end
    grants = g;
  endfunction

  // Each port's row as it is written: its bits for entries already in the
  // RS, and for each port it names, that port's grant, one-hot over the
  // entries, with the line select it gave. Computed once per port, then
  // written into whichever entry the port takes.
  function automatic logic [3*P*N-1:0] rows_of(input logic [P*N-1:0] g, input logic [P*N-1:0] rd,
                                               input logic [2*P*N-1:0] rc, input logic [P*P-1:0] gd,
                                               input logic [2*P*P-1:0] gc);
    logic [P*N-1:0]   d;
    logic [2*P*N-1:0] cd;
    d  = rd;
    cd = rc;
    for (int p = 0; p < P; p++)
      for (int q = 0; q < P; q++)
        if (q != p)
          for (int j = 0; j < N; j++)
            if (gd[p * P + q] && g[q * N + j]) begin
              d[p * N + j]             = 1'b1;
              cd[(p * N + j) * 2 +: 2] = gc[(p * P + q) * 2 +: 2];
            end
    rows_of = {cd, d};
  endfunction

  function automatic logic [SW-1:0] next_state(input logic [SW-1:0] st, input logic [P-1:0] req,
                                               input logic [P*N-1:0] rd, input logic [2*P*N-1:0] rc,
                                               input logic [P*P-1:0] gd, input logic [2*P*P-1:0] gc,
                                               input logic [N-1:0] fr);
    logic [SW-1:0]    m;
    logic [P*N-1:0]   g, d;
    logic [2*P*N-1:0] cd;
    logic [N-1:0]     row;
    logic [2*N-1:0]   crow;
    logic             hit;
    m = st;
    g = grants(st, req, fr);
    {cd, d} = rows_of(g, rd, rc, gd, gc);
    for (int i = 0; i < N; i++) begin
      hit  = 1'b0;
      row  = '0;
      crow = '0;
      for (int p = 0; p < P; p++)
        if (g[p * N + i]) begin
          hit  = 1'b1;
          row  = d[p * N +: N];
          crow = cd[p * 2 * N +: 2 * N];
        end
      if (hit) begin
        m[ODEP + i * N +: N]           = row;
        m[OCODE + i * 2 * N +: 2 * N] = crow;
      end else begin
        m[ODEP + i * N +: N] = st[ODEP + i * N +: N] & ~fr;
      end
      m[OVAL + i] = hit || (st[OVAL + i] && !fr[i]);
    end
    next_state = m;
  endfunction

  // The reset state: every entry free. The cells are payload.
  function automatic logic [SW-1:0] reset_of(input logic [SW-1:0] st);
    logic [SW-1:0] m;
    m = st;
    m[OVAL +: N] = '0;
    reset_of = m;
  endfunction

  // One edge: reset, or the update.
  function automatic logic [SW-1:0] step(input logic [SW-1:0] st, input logic rst, input logic [P-1:0] req,
                                         input logic [P*N-1:0] rd, input logic [2*P*N-1:0] rc,
                                         input logic [P*P-1:0] gd, input logic [2*P*P-1:0] gc,
                                         input logic [N-1:0] fr);
    step = rst ? reset_of(st) : next_state(st, req, rd, rc, gd, gc, fr);
  endfunction

  logic [SW-1:0]  st_cq02h;
  logic [P*N-1:0] g_cq02h;
  always_comb begin
    g_cq02h = grants(st_cq02h, req_cq01h, free_cq01h);
    for (int p = 0; p < P; p++) begin
      gnt_v_cq02h[p]           = |g_cq02h[p * N +: N];
      gnt_idx_cq02h[p * W +: W] = '0;
      for (int e = 0; e < N; e++) if (g_cq02h[p * N + e]) gnt_idx_cq02h[p * W +: W] = W'(e);
    end
  end
  assign valid_cq02h = st_cq02h[OVAL +: N];
  assign dep_cq02h   = st_cq02h[ODEP +: N * N];
  assign code_cq02h  = st_cq02h[OCODE +: 2 * N * N];

  // Rename checks the RS for room first, so every port that asks is granted.
  `CCV_ASSERT(alloc_granted, (req_cq01h & ~gnt_v_cq02h) == '0)
  // A free names a valid entry.
  `CCV_ASSERT(free_valid, (free_cq01h & ~valid_cq02h) == '0)

  always_ff @(posedge ooe_core_clk) begin
    st_cq02h <= step(st_cq02h, ooe_rst_r00h, req_cq01h, row_dep_cq01h, row_code_cq01h, grp_dep_cq01h,
                     grp_code_cq01h, free_cq01h);
  end

endmodule
`undef CCV_CLK
`undef CCV_RST
