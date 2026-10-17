// Clock-gating scenarios for ccv_common_rpt (tools/check-cg.py, unit rpt):
// two stages, two slots, a 16-bit payload with an 8-bit lead slice.
//
//   +scenario=idle    the link carries nothing: no valid, wake, credit or stall
//   +scenario=medium  each slot sends on about 3 cycles in 10, a new payload
//                     with each message (the lead slice with its valid, the
//                     rest a cycle later); credits return as often; a wake now
//                     and then, a stall rarely
//   +scenario=high    each slot sends every cycle with a new payload; the
//                     credit and stall lines move every few cycles
//   +vcd=<file> +n=<cycles>
//
// Inputs change just after the falling edge; the rising edge samples them.
module tb_cg_rpt;
  localparam int S = 2, W = 16;
  logic             clk = 1'b0, rst_n = 1'b0;
  logic [S-1:0]     src_valid = '0, dst_credit = '0, dst_stall = '0;
  logic [S*W-1:0]   src_payload = '0;
  logic             src_wake = 1'b0;
  logic [S-1:0]     sent = '0;
  wire  [S-1:0]     src_credit, src_stall, dst_valid;
  wire  [S*W-1:0]   dst_payload;
  wire              dst_wake;

  ccv_common_rpt #(.STAGES(2), .SLOTS(S), .PAYLOAD_W(W), .LEAD_MASK(16'h00ff)) dut (.*);

  logic [31:0] rng = 32'h6d2b79f5;
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
    $dumpvars(0, tb_cg_rpt);
    repeat (4) cycle();
    rst_n = 1'b1;
    for (int t = 0; t < n; t++) begin
      for (int j = 0; j < S; j++) begin
        case (scen)
          "idle": begin
            src_valid[j] = 1'b0; dst_credit[j] = 1'b0; dst_stall[j] = 1'b0;
          end
          "medium": begin
            src_valid[j]  = chance(300);
            dst_credit[j] = chance(300);
            dst_stall[j]  = chance(10) ? ~dst_stall[j] : dst_stall[j];
          end
          "high": begin
            src_valid[j]  = 1'b1;
            dst_credit[j] = chance(700);
            dst_stall[j]  = chance(150) ? ~dst_stall[j] : dst_stall[j];
          end
          default: $fatal(1, "unknown scenario %s", scen);
        endcase
        // The lead slice travels with valid, the rest of the payload a
        // cycle behind it (docs/physical.md), each new with its message.
        rng = next(rng);
        if (src_valid[j]) src_payload[j*W +: 8] = rng[23:16];
        if (sent[j])      src_payload[j*W + 8 +: 8] = rng[31:24];
        sent[j] = src_valid[j];
      end
      src_wake = (scen == "medium") ? chance(50) : (scen == "high") ? chance(200) : 1'b0;
      cycle();
    end
    $finish;
  end
endmodule
