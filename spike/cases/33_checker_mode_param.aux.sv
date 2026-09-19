module chk #(parameter int MODE = 0) (   // 0=ASSERT 1=ASSUME 2=COVER_ONLY
  input logic clk, input logic rst, input logic a, input logic b
);
  generate
    if (MODE == 0) begin : g_assert
      always @(posedge clk) if (!rst) assert (!(a && !b));
    end else if (MODE == 1) begin : g_assume
      always @(posedge clk) if (!rst) assume (!(a && !b));
    end else begin : g_cover
      always @(posedge clk) if (!rst) cover (a && b);
    end
  endgenerate
endmodule
