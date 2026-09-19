//===-- ccv_clockgate_map.v - enable flop -> ICG + flop -----------*- V -*-===//
//
// A techmap rule standing in for the `clockgate` pass Yosys does not have.
// Applied after `synth`, it rewrites every enable flop into a plain flop
// driven by a gated clock.
//
// ON ITS OWN THIS IS WORSE THAN NO GATING. techmap is per-cell, so it
// instantiates one ICG PER FLOP -- eight for an 8-bit register. Real gating
// shares one ICG across every flop with the same enable, and the sharing is
// the whole benefit; per-bit gating adds area and clock load and saves
// nothing.
//
// `opt_merge -share_all` does the sharing, and must follow. It is not the
// default flag: plain `opt_merge` leaves blackboxed ICGs alone, because it
// cannot know a blackbox is free of side effects.
//
// That sharing step is also the reason a proper Yosys pass would be more than
// a map file -- see docs/stage1a-findings.md F-18.
//===----------------------------------------------------------------------===//
(* techmap_celltype = "$_DFFE_PP_" *)
module ccv_map_dffe_pp (input D, input C, input E, output Q);
  wire gclk;
  ccv_icg u_icg (.clk(C), .en(E), .gclk(gclk));
  \$_DFF_P_ u_ff (.D(D), .C(gclk), .Q(Q));
endmodule

(* techmap_celltype = "$_SDFFE_PP0P_" *)
module ccv_map_sdffe_pp0p (input D, input C, input E, input R, output Q);
  wire gclk;
  wire d_rst;
  // The reset must stay on the DATA path, never on the enable: gating a flop
  // off during reset would leave it holding whatever it came up with.
  assign d_rst = R ? 1'b0 : D;
  ccv_icg u_icg (.clk(C), .en(E | R), .gclk(gclk));
  \$_DFF_P_ u_ff (.D(d_rst), .C(gclk), .Q(Q));
endmodule
