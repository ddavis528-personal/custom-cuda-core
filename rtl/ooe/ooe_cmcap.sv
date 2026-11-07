//===-- ooe_cmcap.sv - OOE capture of ccv_miu_ooe_cmpl for the ROB ------===//
//
// Spec: C9 (DA 114; OA rev 363, 364, 372 in the register): OOE's end of
//       ccv_miu_ooe_cmpl is a capture of the first kind, no interface flop
//       before it. The completion's lead valid (cmpl_l) lands raw on three
//       pins: this capture, ooe_rs and ooe_wake (their bypasses, which act
//       on a hit in its arrival cycle). Its payload lands raw on this
//       capture's C copies, ooe_rs and ooe_wake. The ROB's slices act a
//       cycle later, from this capture (the model's cmpl_split bit 1).
//
// The capture: the lead flopped (cv), and each completion's payload
// captured raw under it, in C copies (* keep *), each read by R / C slices:
// a slice compares the payload against each of its D entries, so one
// register for all R would put R * D loads on each bit. The raw payload's
// pins are the C copies, ooe_rs and ooe_wake (C 2: OA 364's 4). The valid
// needs no copy: each slice takes cv as its lead, into one flop of its own
// (ooe_rob_w's cm_q), so cv drives R loads.
//
// Every input goes straight into a flop (0 NGD), and every output leaves
// from one.
//
// Local clock gating (docs/rtl-coding-style.md): cv is NC lead flops, under
// the 8-flop floor. The payload capture and its copies are clocked only by
// a completion, by cv (this module's own flop of the lead, CG-5).
//
// Reset line: cv resets; the payload is un-reset, read only under
// its valid (ooe_rob_w reads its copy only under its cm_q).
//
// The reference is the model's cmpl_split bit 1 (sim/ooe/ooe_core.cpp,
// takeCompletions): test/ooe/cmcap_tb.cpp drives this module with the live
// model's completions and checks each output is its input a cycle later.
//===----------------------------------------------------------------------===//
module ooe_cmcap #(
  parameter int NC = 4,                  // completions a cycle (ccv_miu_ooe_cmpl's rate)
  parameter int PW = 7,                  // the payload the ROB reads (the ROB tag)
  parameter int R  = 4,                  // ROB slices (CCV_TIER1_WARPS)
  parameter int C  = 2                   // payload copies, each for R / C slices
) (
  input  logic                ooe_core_clk,
  input  logic                ooe_rst_r00h,
  input  logic [NC-1:0]       cmpl_l_cq00h,   // a completion's payload arrives next cycle (raw)
  input  logic [NC*PW-1:0]    cmpl_pay_cq01h, // its payload (raw)
  output logic [NC-1:0]       cv_cq01h,       // the lead, flopped: the slices' lead
  output logic [R*NC*PW-1:0]  pay_cq02h       // each slice's payload, a cycle after cv
);
  logic rst_r01h;
  always_ff @(posedge ooe_core_clk) rst_r01h <= ooe_rst_r00h;

  logic cap_en_cq01h;
  assign cap_en_cq01h = cv_cq01h != '0;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) cv_cq01h <= '0;
    else          cv_cq01h <= cmpl_l_cq00h;
  end
  for (genvar k = 0; k < C; k++) begin : g_cp
    (* keep *) logic [NC*PW-1:0] cp_cq02h;
    always_ff @(posedge ooe_core_clk)
      if (cap_en_cq01h) cp_cq02h <= cmpl_pay_cq01h;
    for (genvar r = k * R / C; r < (k + 1) * R / C; r++) begin : g_s
      assign pay_cq02h[r * NC * PW +: NC * PW] = cp_cq02h;
    end
  end
endmodule
