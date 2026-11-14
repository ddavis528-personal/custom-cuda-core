// The scenarios for the hard-macro fixture (sram_fx.sv), as check-cg's
// selftest measures it: tb_cg_fixture.sv's traffic on one instance.
//
//   +scenario=idle    nothing arrives; the inputs hold
//   +scenario=medium  a valid on about 3 cycles in 10, a new word with each
//   +scenario=high    a valid every cycle, a new word every cycle
//   +vcd=<file> +n=<cycles>
//
// Inputs change just after the falling edge; the rising edge samples them.
module tb_sram_fx;
  logic        clk = 1'b0, rst = 1'b1, in_v = 1'b0, v_prev = 1'b0;
  logic [15:0] in_d = 16'h1234;
  wire         out_v;
  wire  [15:0] out_d;

  sram_fx u_fx (.clk, .rst, .in_v, .in_d, .out_v, .out_d);

  logic [31:0] rng = 32'h2545f491;
  function automatic logic [31:0] next(input logic [31:0] x);
    x = x ^ (x << 13); x = x ^ (x >> 17); return x ^ (x << 5);
  endfunction

  task automatic cycle();
    #5 clk = 1'b1;
    #5 clk = 1'b0;
  endtask

  string scen, vcd;
  int n = 1500;
  initial begin
    if (!$value$plusargs("scenario=%s", scen)) $fatal(1, "no +scenario");
    if (!$value$plusargs("vcd=%s", vcd)) $fatal(1, "no +vcd");
    void'($value$plusargs("n=%d", n));
    $dumpfile(vcd);
    $dumpvars(1, tb_sram_fx);
    $dumpvars(1, tb_sram_fx.u_fx);
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
      if (v_prev) in_d = rng[31:16];
      v_prev = in_v;
      cycle();
    end
    $finish;
  end
endmodule
