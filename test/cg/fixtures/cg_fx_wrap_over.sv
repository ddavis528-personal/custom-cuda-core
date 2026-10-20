// check-cg fixture: a hardening wrapper over its 2% with its repeater's
// control pulses. One cg_fx_wide (257 flops, v_q written every cycle) and a
// two-stage repeater of a 16-bit slot (41 flops, nine of them control): 298
// flops, 2% is 6.0, used 1 + 9. The repeater alone is within its own
// allowance, which no longer holds its control pulses. tools/check-cg.py
// --selftest.
module cg_fx_wrap_over (
  input  logic        clk,
  input  logic        rst,
  input  logic        in_v,
  input  logic [15:0] in_d,
  output logic        out_v,
  output logic [15:0] out_d
);
  wire        v0, rv, cr, st, wk;
  wire [15:0] d0, rd;
  cg_fx_wide u_w0 (.clk, .rst, .in_v, .in_d, .out_v(v0), .out_d(d0));
  ccv_common_rpt #(.STAGES(2), .SLOTS(1), .PAYLOAD_W(16)) u_rpt (
    .clk, .rst_n(!rst),
    .src_valid(v0), .src_payload(d0), .src_wake(in_d[0]), .src_credit(cr), .src_stall(st),
    .dst_valid(rv), .dst_payload(rd), .dst_wake(wk), .dst_credit(in_v), .dst_stall(in_d[1]));
  assign out_v = rv ^ cr ^ st ^ wk;
  assign out_d = rd;
endmodule
