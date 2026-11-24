//===-- miu_agu8.sv - MIU A1 address generation, 8 lanes of one slot ------===//
//
// Spec: docs/design-snapshots/miu-spec.md (live: CCV per-block architecture
//       specs, MIU tab, "MA's Phase 2", slice 1 (rev 163): the stage table's
//       H row, the module partition's miu_agu8 row and the port budgets).
//
// One instance per address slot s and lane octet u (16). In A1 (H, tag 05)
// each of its 8 lanes forms the AGU's 3-input sum (section 5.1, O-79, O-80):
//
//   .global: (base << 16) + (index << scale) + disp
//   .shared:  base        + (index << scale) + disp   (modulo 2^32)
//
// base and index are the lane's 32-bit words from miu_cap (a narrow register
// arrives zero-extended, O-79); disp is the memop's, sign-extended from
// CCV_W_DISP; scale is log2 of the transfer, when scale_en, the transfer
// being xfer_size's (1 or 2 bytes, O-80) or else chwidth's span. The sum is
// exact: kept to VW = 50 bits, two's complement, which covers every value
// the three can make ((-2^28, 2^48 + 2^34)), so A2 raises F-ADDR on a
// .global lane whose bits [49:48] are not 0 (O-75: the sum is never
// wrapped) and reports its address in full, the 50 bits sign-extended
// (section 12.6). F-ALIGN (O-58) is checked here, beside the sum: an active
// lane whose low address bits are not 0 at the transfer's size; a byte is
// always aligned.
//
// Flops (tag 06, A2): the 8 lanes' sums and their align faults, 408 at the
// default sizes, one clock gate enabled by this module's flop of miu_cap's
// valid (CG-5): a new address is in A1 exactly the cycle after it. A lane's
// sum is held whether or not it is active; A2 reads only active lanes.
//
// Not here yet (MI-21, MA): the slot, local and private-window forms (O-45,
// O-69, O-83) and their carry-save level, whose operands and owner MA is
// asked for. Until then this is the ordinary and sized forms' AGU.
//
// Inputs are miu_cap's and miu_pair's flops (arrival 0; MIU tab, "Port NGD
// budgets": the adders take the whole 25), and every output comes straight
// from a flop.
//
// The reference is the MIU model's AGU (sim/miu/miu_block.cpp, "The AGU
// (section 5.1)"), and test/miu/agu8_tb.cpp holds this module to a value
// model of it.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK miu_core_clk
`define CCV_RST rst_r01h
module miu_agu8 #(
  parameter  int NL = 8,                                  // lanes, one octet
  parameter  int WL = 32,                                 // a lane's base and index
  parameter  int DW = ccv_params_pkg::CCV_W_DISP,         // disp, 29
  parameter  int CW = ccv_params_pkg::CCV_W_CHWIDTH,      // chwidth, 2
  parameter  int VW = 50                                  // the exact sum
) (
  input  logic             miu_core_clk,
  input  logic             rst_n,
  // miu_cap's valid a cycle on: the slot's address lands in its flops now.
  input  logic             v_cm04h,
  // A1: the octet's lanes from miu_cap, held from H.
  input  logic [NL-1:0]    am_cm05h,      // active_mask
  input  logic [NL*WL-1:0] base_cm05h,    // base_per_lane
  input  logic [NL*WL-1:0] idx_cm05h,     // index_per_lane
  // A1: the slot's memop fields from miu_pair, held from H.
  input  logic [DW-1:0]    disp_cm05h,
  input  logic             shared_cm05h,  // space: 0 .global, 1 .shared
  // The transfer, decoded by miu_pair a stage earlier (from xfer_size,
  // chwidth and scale_en): sh1/sh2 the index's scale (one-hot with 0, both
  // clear for 0), b4/b2 a 4- or 2-byte transfer (else 1), for F-ALIGN.
  input  logic             sh1_cm05h,
  input  logic             sh2_cm05h,
  input  logic             b4_cm05h,
  input  logic             b2_cm05h,
  // A2: each lane's exact sum and its align fault.
  output logic [NL*VW-1:0] va_cm06h,
  output logic [NL-1:0]    fal_cm06h
);

  // rst_n flopped before any use (RST-1), inverted after the flop.
  logic rst_cr01h_n;
  always_ff @(posedge miu_core_clk) begin
    rst_cr01h_n <= rst_n;
  end
  wire rst_r01h = !rst_cr01h_n;

  // ---- The valid, a cycle on: an address in A1 (CG-5) --------------------
  logic v_q_cm05h;
  always_ff @(posedge miu_core_clk) begin
    if (rst_r01h) v_q_cm05h <= 1'b0;
    else          v_q_cm05h <= v_cm04h;
  end

  // A Kogge-Stone carry-propagate add: log2(VW) prefix levels, fanout 2,
  // so the mapper keeps a shallow carry tree rather than a ripple.
  function automatic logic [VW-1:0] ks_add(input logic [VW-1:0] a, input logic [VW-1:0] b);
    logic [VW-1:0] g, p, gn, pn;
    g = a & b;
    p = a ^ b;
    for (int d = 1; d < VW; d = d * 2) begin
      gn = g;
      pn = p;
      for (int i = d; i < VW; i = i + 1) begin
        gn[i] = g[i] | (p[i] & g[i-d]);
        pn[i] = p[i] & p[i-d];
      end
      g = gn;
      p = pn;
    end
    ks_add = (a ^ b) ^ {g[VW-2:0], 1'b0};
  endfunction

  // ---- Per lane: the 3-input sum and F-ALIGN -----------------------------
  logic [NL*VW-1:0] va_d_cm05h;
  logic [NL-1:0]    fal_d_cm05h;
  for (genvar l = 0; l < NL; l = l + 1) begin : g_lane
    logic [WL-1:0] b_cm05h, x_cm05h;
    logic [VW-1:0] ob_cm05h, ox_cm05h, od_cm05h, s_cm05h, cs_cm05h, cc_cm05h;
    always_comb begin
      b_cm05h  = base_cm05h[l*WL +: WL];
      x_cm05h  = idx_cm05h[l*WL +: WL];
      ob_cm05h = shared_cm05h ? VW'(b_cm05h) : VW'({b_cm05h, 16'b0});
      ox_cm05h = ({VW{sh2_cm05h}} & (VW'(x_cm05h) << 2)) |
                 ({VW{sh1_cm05h}} & (VW'(x_cm05h) << 1)) |
                 ({VW{!sh1_cm05h && !sh2_cm05h}} & VW'(x_cm05h));
      od_cm05h = VW'(signed'(disp_cm05h));
      // One carry-save level, then one carry-propagate add.
      cs_cm05h = ob_cm05h ^ ox_cm05h ^ od_cm05h;
      cc_cm05h = ((ob_cm05h & ox_cm05h) | (ob_cm05h & od_cm05h) | (ox_cm05h & od_cm05h)) << 1;
      s_cm05h  = ks_add(cs_cm05h, cc_cm05h);
      va_d_cm05h[l*VW +: VW] = s_cm05h;
      fal_d_cm05h[l] = am_cm05h[l] &&
                       ((b4_cm05h && (s_cm05h[1:0] != 2'b00)) || (b2_cm05h && s_cm05h[0]));
    end
  end

  // ---- Flops: A2's lanes -------------------------------------------------
  // A guarded payload: read only through its memop, so it is written
  // whenever its group is clocked and holds nothing of its own.
  wire va_en_cm05h = v_q_cm05h;
  logic [NL*VW-1:0] va_q_cm06h;
  logic [NL-1:0]    fal_q_cm06h;
  always_ff @(posedge miu_core_clk) begin
    if (va_en_cm05h) begin
      va_q_cm06h  <= va_d_cm05h;
      fal_q_cm06h <= fal_d_cm05h;
    end
  end
  assign va_cm06h  = va_q_cm06h;
  assign fal_cm06h = fal_q_cm06h;

endmodule
`undef CCV_CLK
`undef CCV_RST
