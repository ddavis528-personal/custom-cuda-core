`timescale 1ns/1ps
module tb;
  logic [1:0] sel;
  logic [3:0] y_opt, y_tm, y_xm;
  xprop_diff u_dut (.sel(sel), .y_optimistic(y_opt),
                    .y_tmerge(y_tm), .y_xmerge(y_xm));
  initial begin
    $display("SPIKE_BEGIN");
    sel = 2'bxx; #1; $display("XPROP xx %b %b %b", y_opt, y_tm, y_xm);
    sel = 2'b1x; #1; $display("XPROP 1x %b %b %b", y_opt, y_tm, y_xm);
    sel = 2'd2;  #1; $display("XPROP 10 %b %b %b", y_opt, y_tm, y_xm);
    $display("SPIKE_END");
    $finish;
  end
endmodule
