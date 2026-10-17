// Clean: Yosys reads it exactly as written, so the strict shim must accept it.
module ys_clean (
  input  logic       clk,
  input  logic       rst_n,
  input  logic [3:0] a,
  output logic [3:0] q
);
  always_ff @(posedge clk) begin
    if (!rst_n) q <= '0;
    else        q <= a[3:0] + 4'd1;
  end
endmodule
