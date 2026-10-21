// Clock-gating scenarios for ccv_common_clk (tools/check-cg.py, unit clk):
// the block clock gate at its parameters' defaults, two wake sources, the
// hysteresis CSRs at 4 quiesced and 6 stalled cycles.
//
//   +scenario=idle    the block stays quiesced and nothing wakes it: the
//                     gate closes once and stays closed
//   +scenario=medium  busy and quiet periods of about 40 cycles each, a wake
//                     at the start of each busy period, a stall now and then
//   +scenario=high    busy and quiet periods of a few cycles, wakes and
//                     stalls often, the override toggled now and then
//   +vcd=<file> +n=<cycles>
//
// Inputs change just after the falling edge; the rising edge samples them.
module tb_cg_clk;
  logic       clk = 1'b0, rst_n = 1'b0;
  logic       quiesced = 1'b1, stalled = 1'b0, cg_override = 1'b0, te = 1'b0;
  logic [1:0] wake = '0;
  logic [ccv_prov_pkg::CCV_CG_HYST_W-1:0] hyst_quiesce = 4, hyst_stall = 6;
  wire        gclk, gated;

  ccv_common_clk #(.NWAKE(2)) dut (.*);

  logic [31:0] rng = 32'h1b873593;
  function automatic logic [31:0] next(input logic [31:0] x);
    x = x ^ (x << 13); x = x ^ (x >> 17); return x ^ (x << 5);
  endfunction
  function automatic logic chance(input int per_1024);
    rng = next(rng);
    return rng[9:0] < per_1024[9:0];
  endfunction

  task automatic cycle();
    #5 clk = 1'b1;
    #5 clk = 1'b0;
  endtask

  string scen, vcd;
  int n = 3000;
  initial begin
    if (!$value$plusargs("scenario=%s", scen)) $fatal(1, "no +scenario");
    if (!$value$plusargs("vcd=%s", vcd)) $fatal(1, "no +vcd");
    void'($value$plusargs("n=%d", n));
    $dumpfile(vcd);
    $dumpvars(0, tb_cg_clk);
    repeat (4) cycle();
    rst_n = 1'b1;
    for (int t = 0; t < n; t++) begin
      wake = '0;
      case (scen)
        "idle": begin
          quiesced = 1'b1; stalled = 1'b0;
        end
        "medium": begin
          if (chance(25)) begin
            quiesced = ~quiesced;
            if (!quiesced) wake[0] = 1'b1;
          end
          stalled = !quiesced && chance(100);
        end
        "high": begin
          if (chance(300)) begin
            quiesced = ~quiesced;
            if (!quiesced) wake[0] = 1'b1;
          end
          stalled = !quiesced && chance(400);
          wake[1] = chance(150);
          if (chance(20)) cg_override = ~cg_override;
        end
        default: $fatal(1, "unknown scenario %s", scen);
      endcase
      cycle();
    end
    $finish;
  end
endmodule
