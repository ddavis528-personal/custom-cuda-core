//===-- ooe_ready.sv - OOE ready from the dependency matrix --------===//
//
// Block: ooe
// Spec: docs/design-snapshots/ooe-microarchitecture.md, Scheduling: Wakeup
//       (live: OOE microarchitecture, Wakeup and the scheduler timing
//       estimate, OA-1; A-62, A-73, OA-4)
//
// The ready stage. Every producer drives W wake lines: its fastest bypass
// point plus each bypass penalty, and last the PRF read (late). Each matrix
// cell holds a dependency bit and the index of the line it waits on, set at
// rename from the bypass table, so ready is a per-cell select and a
// row-wide AND: no comparison, no timer, nothing on this path but gates.
//
// The model's Core::cellCode and Core::wakeLine give the same structure,
// and the model checks every cycle that it reproduces rowReady
// ("ready-structure"); test/ooe/ready_tb.cpp drives this module from the
// live model through the random unit tests.
//
// dep[i*N + j]: entry i waits on entry j. A cleared bit is "no wait", so an
// invalid entry's row reads ready and the caller masks it with valid; an
// invalid producer's column is cleared when it frees.
// code[(i*N + j)*CW +: CW]: the line cell (i, j) selects; read only where
// dep is set.
// wake[j*W + k]: producer j's line k.
//===----------------------------------------------------------------------===//

module ooe_ready #(
  parameter int N  = 45,   // RS entries, both classes (CCV_P_RS_RCU + CCV_P_RS_MIU)
  parameter int W  = 4,    // wake lines per producer: three bypass points and late
  parameter int CW = 2     // bits per cell's line select, clog2(W)
) (
  input  logic [N*N-1:0]    dep_cq02h,
  input  logic [N*N*CW-1:0] code_cq02h,
  input  logic [N*W-1:0]    wake_cq02h,
  output logic [N-1:0]      ready_cq02h
);

  always_comb begin
    for (int i = 0; i < N; i++) begin
      logic row;
      row = 1'b1;
      for (int j = 0; j < N; j++) begin
        logic [CW-1:0] k;
        logic [W-1:0]  lines;
        logic          line;
        k     = code_cq02h[(i*N + j)*CW +: CW];
        lines = wake_cq02h[j*W +: W];
        line  = lines[k];
        row  = row & (~dep_cq02h[i*N + j] | line);
      end
      ready_cq02h[i] = row;
    end
  end

endmodule
