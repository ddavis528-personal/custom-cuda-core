//===-- bad_conn2.sv - lint fixture for register-closed loops and helpers ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OA 481-490,
//       OI-207)
//
// Every violation is intentional. tools/check-1d.sh fails if any stops
// firing here. DO NOT FIX THE VIOLATIONS IN THIS FILE.
//
// Each is reference_pp.sv's with one thing broken, nets prefixed by its
// letter: r's second register reads an input, not the first, so the hop is
// not traced; h's helper output also feeds another register, so its
// deficit of 1 is not a self-loop and is reported.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_rpc (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic v_cy01h,
  output logic e_cy02h
);
  always_ff @(posedge reference_core_clk) e_cy02h <= v_cy01h;
endmodule

module reference_rph (
  input  logic [3:0] a,
  output logic [3:0] y
);
  assign y = a + 4'd1;
endmodule

module reference_rpp (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic       rx_cy03h,
  output logic       re_cy02h,
  output logic [3:0] rq_cy03h,
  output logic [3:0] rz_cy03h
);
  logic rm_cy03h;
  logic rm_cy04h;
  reference_rpc u_c (.reference_core_clk, .ref_rst_r00h, .v_cy01h(rm_cy04h), .e_cy02h(re_cy02h));
  always_ff @(posedge reference_core_clk) begin
    rm_cy03h <= re_cy02h;
    rm_cy04h <= rx_cy03h;
  end
  `CCV_ASSERT(conn_m_fresh, !(rm_cy04h && re_cy02h))
  // A register-free helper in a same-stage self-loop: its output feeds only
  // the register its input reads.
  logic [3:0] rqn_cy02h;
  reference_rph u_h (.a(rq_cy03h), .y(rqn_cy02h));
  always_ff @(posedge reference_core_clk) rq_cy03h <= rqn_cy02h;
  always_ff @(posedge reference_core_clk) rz_cy03h <= rq_cy03h;
endmodule

module reference_hpc (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic v_cy01h,
  output logic e_cy02h
);
  always_ff @(posedge reference_core_clk) e_cy02h <= v_cy01h;
endmodule

module reference_hph (
  input  logic [3:0] a,
  output logic [3:0] y
);
  assign y = a + 4'd1;
endmodule

module reference_hpp (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic       hx_cy03h,
  output logic       he_cy02h,
  output logic [3:0] hq_cy03h,
  output logic [3:0] hz_cy03h
);
  logic hm_cy03h;
  logic hm_cy04h;
  reference_hpc u_c (.reference_core_clk, .ref_rst_r00h, .v_cy01h(hm_cy04h), .e_cy02h(he_cy02h));
  always_ff @(posedge reference_core_clk) begin
    hm_cy03h <= he_cy02h;
    hm_cy04h <= hm_cy03h;
  end
  `CCV_ASSERT(conn_m_fresh, !(hm_cy04h && he_cy02h))
  // A register-free helper in a same-stage self-loop: its output feeds only
  // the register its input reads.
  logic [3:0] hqn_cy02h;
  reference_hph u_h (.a(hq_cy03h), .y(hqn_cy02h));
  always_ff @(posedge reference_core_clk) hq_cy03h <= hqn_cy02h;
  always_ff @(posedge reference_core_clk) hz_cy03h <= hqn_cy02h;
endmodule


`undef CCV_CLK
`undef CCV_RST
