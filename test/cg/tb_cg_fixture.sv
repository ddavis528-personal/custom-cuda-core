// The scenarios for tools/check-cg.py's fixtures (test/cg/fixtures/): every
// measured one on the same inputs, each its own instance, so one run per scenario
// serves every fixture. A unit reads its fixture's ports by scope.
//
//   +scenario=idle    nothing arrives; the inputs hold
//   +scenario=medium  a valid on about 3 cycles in 10, new data with each
//   +scenario=high    a valid every cycle, new data every cycle
//   +vcd=<file> +n=<cycles>
//
// Inputs change just after the falling edge; the rising edge samples them.
module tb_cg_fixture;
  logic        clk = 1'b0, rst = 1'b1, in_v = 1'b0, v_prev = 1'b0;
  logic [15:0] in_d = 16'h1234;
  wire         good_v, form_v, deep_v, dcge_v, small_v, wide_v, big_v, name_v;
  wire  [15:0] good_d, form_d, deep_d, dcge_d, small_d, wide_d, big_d, name_d;

  cg_fx_good u_good (.clk, .rst, .in_v, .in_d, .out_v(good_v), .out_d(good_d));
  cg_fx_form u_form (.clk, .rst, .in_v, .in_d, .out_v(form_v), .out_d(form_d));
  cg_fx_deep u_deep (.clk, .rst, .in_v, .in_d, .out_v(deep_v), .out_d(deep_d));
  cg_fx_dcge u_dcge (.clk, .rst, .in_v, .in_d, .out_v(dcge_v), .out_d(dcge_d));
  cg_fx_small u_small (.clk, .rst, .in_v, .in_d, .out_v(small_v), .out_d(small_d));
  cg_fx_wide u_wide (.clk, .rst, .in_v, .in_d, .out_v(wide_v), .out_d(wide_d));
  cg_fx_big u_big (.clk, .rst, .in_v, .in_d, .out_v(big_v), .out_d(big_d));
  cg_fx_name u_name (.clk, .rst, .in_v, .in_d, .out_v(name_v), .out_d(name_d));

  logic [31:0] rng = 32'h2545f491;
  function automatic logic [31:0] next(input logic [31:0] x);
    x = x ^ (x << 13); x = x ^ (x >> 17); return x ^ (x << 5);
  endfunction

  task automatic cycle();
    #5 clk = 1'b1;
    #5 clk = 1'b0;
  endtask

  string scen, vcd;
  int n = 2000;
  initial begin
    if (!$value$plusargs("scenario=%s", scen)) $fatal(1, "no +scenario");
    if (!$value$plusargs("vcd=%s", vcd)) $fatal(1, "no +vcd");
    void'($value$plusargs("n=%d", n));
    $dumpfile(vcd);
    $dumpvars(0, tb_cg_fixture);
    repeat (4) cycle();
    rst = 1'b0;
    for (int t = 0; t < n; t++) begin
      rng = next(rng);
      case (scen)
        "idle":   in_v = 1'b0;
        "medium": in_v = (rng[9:0] < 10'd300);
        "high":   in_v = 1'b1;
        default:  $fatal(1, "unknown scenario %s", scen);
      endcase
      // The data follows its valid by a cycle, which every fixture flops
      // first and uses as the enable (CG-5).
      if (v_prev) in_d = rng[31:16];
      v_prev = in_v;
      cycle();
    end
    $finish;
  end
endmodule
