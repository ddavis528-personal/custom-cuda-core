//===-- bad_conn.sv - lint fixture for connections ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OA 481-483,
//       TI-554..556; MI-35)
//
// Every violation is intentional. tools/check-1d.sh fails if any stops
// firing here. DO NOT FIX THE VIOLATIONS IN THIS FILE.
//
// Each trio is reference_conn.sv's with one thing broken, nets prefixed by
// its letter: u (reference_utop) has no declaration, so its back edge is
// reported; n's reader takes an untagged l0 port; w's declaration says 3
// stages ahead, not 4; o's writer is fed from an input, so the loop does
// not close; a's parent holds no conn_l0_fresh assertion.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_urd (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic a_cy01h,
  input  logic l0_cy02h,
  output logic ms_cy03h
);
  logic a_cy02h;
  logic hit_cy02h;
  always_ff @(posedge reference_core_clk) a_cy02h <= a_cy01h;
  assign hit_cy02h = a_cy02h & l0_cy02h;
  always_ff @(posedge reference_core_clk) ms_cy03h <= hit_cy02h;
endmodule

module reference_uwr (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic ms_cy03h,
  output logic l0_cy06h
);
  logic q_cy04h;
  logic q_cy05h;
  always_ff @(posedge reference_core_clk) begin
    q_cy04h  <= ms_cy03h;
    q_cy05h  <= q_cy04h;
    l0_cy06h <= q_cy05h;
  end
endmodule

module reference_utop (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic ua_cy01h,
  input  logic x_cy03h,
  output logic ums_cy03h,
  output logic ul0_cy06h
);
  reference_urd u_rd (
    .reference_core_clk, .ref_rst_r00h, .a_cy01h(ua_cy01h), .l0_cy02h(ul0_cy06h),
    .ms_cy03h(ums_cy03h));
  reference_uwr u_wr (
    .reference_core_clk, .ref_rst_r00h, .ms_cy03h(ums_cy03h), .l0_cy06h(ul0_cy06h));
  `CCV_ASSERT(conn_l0_fresh, !(ums_cy03h && ul0_cy06h))
endmodule

module reference_nrd (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic a_cy01h,
  input  logic l0,
  output logic ms_cy03h
);
  logic a_cy02h;
  logic hit_cy02h;
  always_ff @(posedge reference_core_clk) a_cy02h <= a_cy01h;
  assign hit_cy02h = a_cy02h & l0;
  always_ff @(posedge reference_core_clk) ms_cy03h <= hit_cy02h;
endmodule

module reference_nwr (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic ms_cy03h,
  output logic l0_cy06h
);
  logic q_cy04h;
  logic q_cy05h;
  always_ff @(posedge reference_core_clk) begin
    q_cy04h  <= ms_cy03h;
    q_cy05h  <= q_cy04h;
    l0_cy06h <= q_cy05h;
  end
endmodule

module reference_ntop (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic na_cy01h,
  input  logic x_cy03h,
  output logic nms_cy03h,
  output logic nl0_cy06h
);
  reference_nrd u_rd (
    .reference_core_clk, .ref_rst_r00h, .a_cy01h(na_cy01h), .l0(nl0_cy06h),
    .ms_cy03h(nms_cy03h));
  reference_nwr u_wr (
    .reference_core_clk, .ref_rst_r00h, .ms_cy03h(nms_cy03h), .l0_cy06h(nl0_cy06h));
  `CCV_ASSERT(conn_l0_fresh, !(nms_cy03h && nl0_cy06h))
endmodule

module reference_wrd (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic a_cy01h,
  input  logic l0_cy02h,
  output logic ms_cy03h
);
  logic a_cy02h;
  logic hit_cy02h;
  always_ff @(posedge reference_core_clk) a_cy02h <= a_cy01h;
  assign hit_cy02h = a_cy02h & l0_cy02h;
  always_ff @(posedge reference_core_clk) ms_cy03h <= hit_cy02h;
endmodule

module reference_wwr (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic ms_cy03h,
  output logic l0_cy06h
);
  logic q_cy04h;
  logic q_cy05h;
  always_ff @(posedge reference_core_clk) begin
    q_cy04h  <= ms_cy03h;
    q_cy05h  <= q_cy04h;
    l0_cy06h <= q_cy05h;
  end
endmodule

module reference_wtop (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic wa_cy01h,
  input  logic x_cy03h,
  output logic wms_cy03h,
  output logic wl0_cy06h
);
  reference_wrd u_rd (
    .reference_core_clk, .ref_rst_r00h, .a_cy01h(wa_cy01h), .l0_cy02h(wl0_cy06h),
    .ms_cy03h(wms_cy03h));
  reference_wwr u_wr (
    .reference_core_clk, .ref_rst_r00h, .ms_cy03h(wms_cy03h), .l0_cy06h(wl0_cy06h));
  `CCV_ASSERT(conn_l0_fresh, !(wms_cy03h && wl0_cy06h))
endmodule

module reference_ord (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic a_cy01h,
  input  logic l0_cy02h,
  output logic ms_cy03h
);
  logic a_cy02h;
  logic hit_cy02h;
  always_ff @(posedge reference_core_clk) a_cy02h <= a_cy01h;
  assign hit_cy02h = a_cy02h & l0_cy02h;
  always_ff @(posedge reference_core_clk) ms_cy03h <= hit_cy02h;
endmodule

module reference_owr (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic ms_cy03h,
  output logic l0_cy06h
);
  logic q_cy04h;
  logic q_cy05h;
  always_ff @(posedge reference_core_clk) begin
    q_cy04h  <= ms_cy03h;
    q_cy05h  <= q_cy04h;
    l0_cy06h <= q_cy05h;
  end
endmodule

module reference_otop (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic oa_cy01h,
  input  logic x_cy03h,
  output logic oms_cy03h,
  output logic ol0_cy06h
);
  reference_ord u_rd (
    .reference_core_clk, .ref_rst_r00h, .a_cy01h(oa_cy01h), .l0_cy02h(ol0_cy06h),
    .ms_cy03h(oms_cy03h));
  reference_owr u_wr (
    .reference_core_clk, .ref_rst_r00h, .ms_cy03h(x_cy03h), .l0_cy06h(ol0_cy06h));
  `CCV_ASSERT(conn_l0_fresh, !(oms_cy03h && ol0_cy06h))
endmodule

module reference_ard (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic a_cy01h,
  input  logic l0_cy02h,
  output logic ms_cy03h
);
  logic a_cy02h;
  logic hit_cy02h;
  always_ff @(posedge reference_core_clk) a_cy02h <= a_cy01h;
  assign hit_cy02h = a_cy02h & l0_cy02h;
  always_ff @(posedge reference_core_clk) ms_cy03h <= hit_cy02h;
endmodule

module reference_awr (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic ms_cy03h,
  output logic l0_cy06h
);
  logic q_cy04h;
  logic q_cy05h;
  always_ff @(posedge reference_core_clk) begin
    q_cy04h  <= ms_cy03h;
    q_cy05h  <= q_cy04h;
    l0_cy06h <= q_cy05h;
  end
endmodule

module reference_atop (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic aa_cy01h,
  input  logic x_cy03h,
  output logic ams_cy03h,
  output logic al0_cy06h
);
  reference_ard u_rd (
    .reference_core_clk, .ref_rst_r00h, .a_cy01h(aa_cy01h), .l0_cy02h(al0_cy06h),
    .ms_cy03h(ams_cy03h));
  reference_awr u_wr (
    .reference_core_clk, .ref_rst_r00h, .ms_cy03h(ams_cy03h), .l0_cy06h(al0_cy06h));
endmodule

`undef CCV_CLK
`undef CCV_RST
