module chk (input logic clk, input logic rst, input logic a, input logic b);
  always @(posedge clk) if (!rst) begin
    assert (!(a && !b));
  end
endmodule
