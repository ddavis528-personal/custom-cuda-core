module chk (input logic clk, input logic rst, input logic a, input logic b);
  a_bound: assert property (@(posedge clk) disable iff (rst) a |-> b)
    else $error("17: bound checker fired");
endmodule

bind dut chk u_chk (.clk(clk), .rst(rst), .a(a), .b(b));
