// check-cg fixture: the flop-count cross-check's generate control (OI-89).
// A 2-bit counter in each way of a two-way generate, each way on its own
// named enable: under CCV_CG_MIN_FLOPS, so each way's counter is its own
// CG-4 finding, which the module budget takes (7 loose flops with the
// flopped reset, valid and the second way's enable). The elaboration the
// block budget counts must count each finding's own way, not both:
// counted by its base name, g_way[0].c_q is 4 flops against the replayed
// netlist's 2. tools/check-cg.py --selftest.
module cg_fx_gen (
  input  logic        clk,
  input  logic        rst,
  input  logic        in_v,
  input  logic [15:0] in_d,
  output logic        out_v,
  output logic [15:0] out_d
);
  logic       rst_q, v_q, w_q;
  logic [1:0] way_en;
  logic [3:0] c_all;

  always_ff @(posedge clk) begin
    rst_q <= rst;
    v_q   <= in_v;
    w_q   <= in_v & in_d[0];
  end
  assign way_en = {w_q, v_q};

  for (genvar g = 0; g < 2; g++) begin : g_way
    logic [1:0] c_q;
    wire        cnt_en = way_en[g];
    always_ff @(posedge clk) begin
      if (rst_q)       c_q <= '0;
      else if (cnt_en) c_q <= c_q + 1'b1;
    end
    assign c_all[g * 2 +: 2] = c_q;
  end

  assign out_v = ^in_d;
  assign out_d = 16'(c_all);
endmodule
