// check-cg fixture: a hardening wrapper whose 2% holds its repeater's
// control pulses. Two cg_fx_wide (257 flops each, v_q written every cycle)
// and a one-stage repeater of a 16-bit slot (21 flops, of them valid, wake,
// credit, stall and the flopped reset): 535 flops, 2% is 10.7, used 2 + 5.
// tools/check-cg.py --selftest.
module cg_fx_wrap_ok (
  input  logic        clk,
  input  logic        rst,
  input  logic        in_v,
  input  logic [15:0] in_d,
  output logic        out_v,
  output logic [15:0] out_d
);
  wire        v0, v1, rv, cr, st, wk;
  wire [15:0] d0, d1, rd;
  cg_fx_wide u_w0 (.clk, .rst, .in_v, .in_d,        .out_v(v0), .out_d(d0));
  cg_fx_wide u_w1 (.clk, .rst, .in_v, .in_d(~in_d), .out_v(v1), .out_d(d1));
  ccv_common_rpt #(.STAGES(1), .SLOTS(1), .PAYLOAD_W(16)) u_rpt (
    .clk, .rst_n(!rst),
    .src_valid(v0), .src_payload(d0), .src_wake(in_d[0]), .src_credit(cr), .src_stall(st),
    .dst_valid(rv), .dst_payload(rd), .dst_wake(wk), .dst_credit(v1), .dst_stall(in_d[1]));
  assign out_v = rv ^ cr ^ st ^ wk;
  assign out_d = rd ^ d1;
endmodule
