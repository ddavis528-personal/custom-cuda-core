//===-- miu_pair.sv - MIU address pairing: each address with its memop ----===//
//
// Spec: docs/design-snapshots/miu-spec.md (live: CCV per-block architecture
//       specs, MIU tab, "MA's Phase 2", slice 1 (rev 150): H's definition,
//       the stage table's H row, the module partition's miu_pair row; the
//       credits paragraph's lead-pipe pairing, OA-412).
//
// A memop arrives on ccv_ooe_miu_memop on the lowest credited slot of its
// footprint, and its one address message arrives on ccv_rcu_miu_addr on its
// lead pipe's slot, ctz(pipes), CCV_LAT_MIU_PAIR_LAG cycles after it (the
// address path minus the memop path, LAG here). Co-issued footprints are
// disjoint (V-60), so two memops that arrive in one cycle never share a lead
// pipe, and the address that lands on slot k at cycle V is the one of the
// memop that arrived at V - LAG with lead pipe k: MIU pairs by arrival cycle
// and lead pipe, never by rob_tag. A bulk discard (mem_op 0xF) has pipes 0
// and sends no address (A-41), so it pairs with nothing. A fence's pipes are
// its data register's, like any memop's, and it pairs the same way.
//
// Stages (tags _cmNNh), the memop's arrival M = 00:
//   00 M      the memop's valid on slot j (mv), a cycle ahead of its payload
//   01        the payload's pipes and the MQ entry miu_mq allocates it (me),
//             written into row wp of a ring of LAG rows, one cell a slot
//   03 V      M + LAG: the address's valid lands (miu_cap's av); row rp, the
//             one written at M + 1, names each lead pipe's entry
//   04 H-1    the entry read: a 40:1 read of miu_mq's held A1 view (a1_cm02h,
//             its flops) by the entry, into this module's A1 flops
//   05 H, A1  the slot's A1 fields, its entry and its valid, from flops
// The tags take LAG (CCV_LAT_MIU_PAIR_LAG, TI-514) at its value, 3; a ring row dwells LAG - 1 cycles between
// its write (02) and its read (03), as any queue's entries do. miu_cap's
// tags count from the same M (its V is 03, H 05).
//
// The ring is a queue indexed by two free-running counters a fixed distance
// apart (wp writes, rp reads, rp = wp + 1 mod LAG), not a shift array: no
// cell feeds another (CCV-L23). A cell is clocked only when its row is
// written and it gains or loses a memop (CG-3), and every enable starts at
// this module's flops (CG-5).
//
// Inputs from the memop channel are capture flops' (arrival 0), and miu_mq's
// view is its flops (arrival 0): the read mux is this module's, ahead of its
// own flops, so nothing runs through miu_mq input to output. Every output
// comes straight from a flop.
//
// The reference is the MIU model's pairing (sim/miu/miu_block.cpp pairs by
// rob_tag; the two agree wherever the contract holds), and
// test/miu/pair_tb.cpp holds this module to a value model of it.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK miu_core_clk
`define CCV_RST rst_r01h
module miu_pair #(
  parameter  int NS  = ccv_params_pkg::CCV_MIU_PIPES,          // slots, 4
  parameter  int LAG = ccv_prov_pkg::CCV_LAT_MIU_PAIR_LAG,     // 3 (MI-18, TI-514)
  parameter  int NE  = ccv_params_pkg::CCV_MIU_PIPES * ccv_prov_pkg::CCV_MEMOP_CREDITS,   // MQ entries, 40
  // An entry's A1 view, miu_mq's AW: warp_id, cta_slot, mem_op, chwidth,
  // pipes, disp, scale_en, space, ordering, slot_form, arg_slot (4),
  // local_form, xfer_size (2), xfer_signed. 63.
  parameter  int FW  = ccv_params_pkg::CCV_W_WARP_ID + ccv_prov_pkg::CCV_P_W_CTA_SLOT +
                       ccv_prelim_pkg::CCV_L_W_MEM_OP + ccv_params_pkg::CCV_W_CHWIDTH +
                       ccv_params_pkg::CCV_MIU_PIPES + ccv_params_pkg::CCV_W_DISP + 1 +
                       ccv_params_pkg::CCV_L_W_SPACE + ccv_params_pkg::CCV_L_W_ORDERING + 1 + 4 + 1 + 2 + 1,
  localparam int NQ  = ccv_params_pkg::CCV_W_LANE_MASK / 8,    // lane quarters (miu_lead's copies), 4
  localparam int EW  = $clog2(NE),
  localparam int PW  = (LAG > 1) ? $clog2(LAG) : 1
) (
  input  logic             miu_core_clk,
  input  logic             rst_n,
  // ccv_ooe_miu_memop, slot j: its valid at M, the payload's pipes at M + 1,
  // and the MQ entry miu_mq allocates the memop on slot j that cycle.
  input  logic [NS-1:0]    mv_cm00h,
  input  logic [NS*NS-1:0] mp_cm01h,     // slot j's pipes at [j*NS +: NS]
  input  logic [NS*EW-1:0] me_cm01h,     // slot j's entry at [j*EW +: EW]
  // miu_mq's held A1 view, entry e's at [e*FW +: FW].
  input  logic [NE*FW-1:0] mqa_cm02h,
  // A1: address slot k's memop, held from H until the next pairing.
  output logic [NS-1:0]    a1v_cm05h,
  output logic [NS*FW-1:0] a1f_cm05h,
  output logic [NS*EW-1:0] a1e_cm05h,
  // A1: slot k's transfer, decoded here for miu_agu8 and miu_lead (whose
  // adders take the whole stage): {b2, b4, sh2, sh1} at [k*4 +: 4]. b4/b2 a
  // 4- or 2-byte transfer (else 1): xfer_size's (1 or 2 bytes, O-80), or
  // else chwidth's span; sh2/sh1 the index's scale, when scale_en.
  output logic [NS*4-1:0]  a1x_cm05h,
  // A1: slot k's {sh2, sh1, disp[15:0]} once per lane quarter q, at
  // [(k*NQ + q)*18 +: 18], each its own (* keep *) flops: miu_lead's
  // fixed-leader adder for quarter q reads its copy (MI-27 (3), MA rev
  // 196; one per quarter since the fixed leader, MA rev 203).
  output logic [NS*NQ*18-1:0] a1q_cm05h
);

  if (LAG < 2) begin : g_lag
    // LAG 1 lands the address with the payload, before the ring holds it;
    // the spec allows it (rev 150, at least 1), and a bypass around the ring
    // would serve it. No configuration has it yet.
    $error("miu_pair: LAG %0d needs a bypass around the ring", LAG);
  end

  // rst_n flopped before any use (RST-1), inverted after the flop.
  logic rst_cr01h_n;
  always_ff @(posedge miu_core_clk) begin
    rst_cr01h_n <= rst_n;
  end
  wire rst_r01h = !rst_cr01h_n;

  // ---- The memop's valid, a cycle on (CG-5) -------------------------------
  logic [NS-1:0] mv_q_cm01h;
  always_ff @(posedge miu_core_clk) begin
    if (rst_r01h) mv_q_cm01h <= '0;
    else          mv_q_cm01h <= mv_cm00h;
  end

  // ---- The ring: LAG rows, a cell an arrival slot -------------------------
  // wp names the row written this cycle, rp the row written LAG - 1 cycles
  // ago, whose memops' addresses land now. Each counter is its own
  // register, at the stage that uses it.
  logic [PW-1:0] wp_cm02h;
  logic [PW-1:0] rp_cm03h;
  always_ff @(posedge miu_core_clk) begin
    if (rst_r01h) begin
      wp_cm02h <= '0;
      rp_cm03h <= PW'(1 % LAG);
    end else begin
      wp_cm02h <= (wp_cm02h == PW'(LAG - 1)) ? '0 : wp_cm02h + PW'(1);
      rp_cm03h <= (rp_cm03h == PW'(LAG - 1)) ? '0 : rp_cm03h + PW'(1);
    end
  end

  logic          cv_cm02h [LAG][NS];     // the cell holds a memop
  logic [NS-1:0] cp_cm02h [LAG][NS];     // its pipes
  logic [EW-1:0] ce_cm02h [LAG][NS];     // its MQ entry
  for (genvar r = 0; r < LAG; r++) begin : g_row
    for (genvar j = 0; j < NS; j++) begin : g_cell
      // Clocked when its row is written and it gains a memop or loses the
      // one it held, so every clocked cycle changes it.
      wire cell_en_cm02h = (wp_cm02h == PW'(r)) & (mv_q_cm01h[j] | cv_cm02h[r][j]);
      always_ff @(posedge miu_core_clk) begin
        if (rst_r01h)           cv_cm02h[r][j] <= 1'b0;
        else if (cell_en_cm02h) cv_cm02h[r][j] <= mv_q_cm01h[j];
      end
      always_ff @(posedge miu_core_clk) begin
        if (cell_en_cm02h) begin
          cp_cm02h[r][j] <= mp_cm01h[j*NS +: NS];
          ce_cm02h[r][j] <= me_cm01h[j*EW +: EW];
        end
      end
    end
  end

  // ---- V: each lead pipe's memop from row rp ------------------------------
  // hit[k*NS + j]: slot j's memop leads on pipe k, its lowest pipe.
  // Disjoint footprints make each k's hits one-hot.
  logic [NS*NS-1:0] hit_cm03h;
  logic [NS-1:0]    pv_d_cm03h;
  logic [NS*EW-1:0] pe_d_cm03h;
  always_comb begin
    pe_d_cm03h = '0;
    for (int k = 0; k < NS; k++) begin
      for (int j = 0; j < NS; j++) begin
        hit_cm03h[k*NS + j] = cv_cm02h[rp_cm03h][j] & cp_cm02h[rp_cm03h][j][k] &
                              ~|(cp_cm02h[rp_cm03h][j] & ((NS'(1) << k) - NS'(1)));
        pe_d_cm03h[k*EW +: EW] = pe_d_cm03h[k*EW +: EW] |
                                 ({EW{hit_cm03h[k*NS + j]}} & ce_cm02h[rp_cm03h][j]);
      end
      pv_d_cm03h[k] = |hit_cm03h[k*NS +: NS];
    end
  end

  // ---- H-1: the entry to read --------------------------------------------
  // Clocked when row rp holds a memop (a bulk discard's cell too, rare): the
  // row's valid bits alone, so the enable stays within 8 NGD (CG-2). The
  // held pairing is current only in the cycle after: pnew says so, one
  // ungated flop where four would be.
  logic pe_en_cm03h;
  always_comb begin
    pe_en_cm03h = 1'b0;
    for (int j = 0; j < NS; j++) pe_en_cm03h = pe_en_cm03h | cv_cm02h[rp_cm03h][j];
  end
  logic             pnew_q_cm04h;
  logic [NS-1:0]    pvh_q_cm04h;
  logic [NS*EW-1:0] pe_q_cm04h;
  always_ff @(posedge miu_core_clk) begin
    if (rst_r01h) pnew_q_cm04h <= 1'b0;
    else          pnew_q_cm04h <= pe_en_cm03h;
  end
  always_ff @(posedge miu_core_clk) begin
    if (pe_en_cm03h) begin
      pvh_q_cm04h <= pv_d_cm03h;
      pe_q_cm04h  <= pe_d_cm03h;
    end
  end
  wire [NS-1:0] pv_q_cm04h = pvh_q_cm04h & {NS{pnew_q_cm04h}};

  // Each slot's read of miu_mq's view: the entry's one-hot, AND-OR over 40.
  logic [NS*FW-1:0] fld_cm04h;
  always_comb begin
    fld_cm04h = '0;
    for (int k = 0; k < NS; k++)
      for (int e = 0; e < NE; e++)
        fld_cm04h[k*FW +: FW] = fld_cm04h[k*FW +: FW] |
            ({FW{pe_q_cm04h[k*EW +: EW] == EW'(e)}} & mqa_cm02h[e*FW +: FW]);
  end

  // The transfer's decode, from the A1 view's fields (the memop payload's
  // low FW bits, LSB first: xfer_signed, xfer_size, local_form, arg_slot,
  // slot_form, ordering, space, scale_en, disp, pipes, chwidth, ...).
  localparam int XS_L = 1;
  localparam int SE_L = 9 + ccv_params_pkg::CCV_L_W_ORDERING + ccv_params_pkg::CCV_L_W_SPACE;
  localparam int CW_L = SE_L + 1 + ccv_params_pkg::CCV_W_DISP + ccv_params_pkg::CCV_MIU_PIPES;
  localparam int CW   = ccv_params_pkg::CCV_W_CHWIDTH;
  logic [NS*4-1:0] xd_cm04h;
  always_comb begin
    for (int k = 0; k < NS; k++) begin
      logic [1:0]    xs;
      logic [CW-1:0] cw;
      logic          se, rd, b4, b2;
      xs = fld_cm04h[k*FW + XS_L +: 2];
      cw = fld_cm04h[k*FW + CW_L +: CW];
      se = fld_cm04h[k*FW + SE_L];
      // rd: rdata's width sets the transfer, xfer_size 0 (and the reserved
      // 3, as the model reads it).
      rd = (xs == 2'd0) || (xs == 2'd3);
      b4 = rd && (cw == CW'(0));
      b2 = (xs == 2'd2) || (rd && (cw == CW'(1)));
      xd_cm04h[k*4 +: 4] = {b2, b4, se & b4, se & b2};
    end
  end

  // ---- H: slot k's A1 fields, from the entry miu_mq read ------------------
  // Each slot one clock gate: clocked when it pairs, and the cycle after its
  // last pairing, to clear its valid (CG-4: no valid flop clocked idle).
  logic [NS-1:0] a1v_q_cm05h;
  for (genvar k = 0; k < NS; k++) begin : g_a1
    // The fields are a guarded payload: read only under a1v, so a clearing
    // cycle may load whatever miu_mq answers.
    wire a1_en_cm04h = pv_q_cm04h[k] | a1v_q_cm05h[k];
    // a1f and a1x keep too: else synthesis merges a copy of disp or the
    // scale into them, and the merged flop drives both.
    (* keep *) logic [FW-1:0] a1f_q_cm05h;
    logic [EW-1:0] a1e_q_cm05h;
    (* keep *) logic [3:0]    a1x_q_cm05h;
    (* keep *) logic [NQ*18-1:0] a1q_q_cm05h;
    always_ff @(posedge miu_core_clk) begin
      if (rst_r01h)         a1v_q_cm05h[k] <= 1'b0;
      else if (a1_en_cm04h) a1v_q_cm05h[k] <= pv_q_cm04h[k];
    end
    always_ff @(posedge miu_core_clk) begin
      if (a1_en_cm04h) begin
        a1f_q_cm05h <= fld_cm04h[k*FW +: FW];
        a1e_q_cm05h <= pe_q_cm04h[k*EW +: EW];
        a1x_q_cm05h <= xd_cm04h[k*4 +: 4];
        for (int q = 0; q < NQ; q++)
          a1q_q_cm05h[q*18 +: 18] <= {xd_cm04h[k*4 +: 2], fld_cm04h[k*FW + SE_L + 1 +: 16]};
      end
    end
    assign a1f_cm05h[k*FW +: FW] = a1f_q_cm05h;
    assign a1e_cm05h[k*EW +: EW] = a1e_q_cm05h;
    assign a1x_cm05h[k*4 +: 4]   = a1x_q_cm05h;
    assign a1q_cm05h[k*NQ*18 +: NQ*18] = a1q_q_cm05h;
  end
  assign a1v_cm05h = a1v_q_cm05h;

endmodule
`undef CCV_CLK
`undef CCV_RST
