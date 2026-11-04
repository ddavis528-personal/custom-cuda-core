//===-- rcu_bank_slice.sv - RCU GPR bank slice: one byte of four lanes ---===//
//
// Spec: docs/design-snapshots/rcu-arch-register-file.md (live: CCV RCU
//       Architecture, Register file tab: Slices, Organisation, Row
//       predecode, Read ports, Write ports, the full-row interim);
//       docs/design-snapshots/rcu-arch-partition.md (the slice's row, M3).
//
// Slice (K, J): byte section K of lanes 4J to 4J+3, ROWS rows of 32 bits
// (lane l's byte at [8l+7:8l]). A complete bank for its 32 bits: every read
// and write port, each with its own predecoded row select, its own row
// enables, its own flopped reset. No logic crosses slices; J only names
// which lanes the parent wires here.
//
// Row predecode. A row index r is held as two one-hots in flops, sel_hi
// (r[7:4], NH bits, none for r >= ROWS) and sel_lo (r[3:0], 16 bits); row r
// is selected by sel_hi[r>>4] & sel_lo[r&15]. The zero register (255) and
// any row past ROWS decode to no select: it reads 0 and a write to it
// writes nothing. Each port keeps its own copy (the fanout copies, RA-33).
//
// Port timing, every port alike (CG-5: an enable comes only from the
// slice's own flops, so a port's valid leads its row by a cycle):
//   cycle t-1  *_v_cr00h    the port's valid, flopped every cycle
//   cycle t    *_row_cr01h  its row (and a write's sections or lead),
//                           taken into the select flops under that flop
//   cycle t+1  a read's data on rd_cr03h, from the selects and the rows;
//              a write's data on *_dat_cr02h, written at the edge ending t+1
// A read in t+1 of a row written in t+1 sees the old value.
//
// Read ports (NR, 10): L0-L2 and L3 (merge data), M0-M2, R0-R2, in the
// order the parent wires them. Each is a 16:1 AND-OR on sel_lo per group of
// 16 rows, gated by its sel_hi bit, then an NH:1 OR: the spec's read mux.
//
// Write ports. Generic ports (NW, 3: LW, SW, RW, at indices 0, 1, 2) take a
// row, the sections the write covers and, in the write cycle, 4 lanes'
// byte K and a lane mask:
//   - LW writes bank K when K is an owned section (the op's footprint);
//   - SW and RW write bank K when K is in the destination's secmask, or,
//     under FULL_ROW, always, the byte forced to zero when K is outside it
//     (AR-24's interim: the row zero above the register).
// The load port MW takes, per MIU slot j, its lead (row, width, position,
// the 4 lanes' active bits) and in the write cycle the slot's 4 lane words.
// Bank K takes the one slot whose secmask covers K (under FULL_ROW, any
// slot landing), and its byte K - pos of the word, zero past the
// register's width (the MW position shift; a 4-bit load keeps its low
// nibble, as the model's elemMask does). Two slots on one bank in a
// cycle break MIU's contract (RA-28; asserted).
//
// Rows. One clock gate a row (32 flops), its enable the OR of the ports'
// hits, all from the slice's flops (CG-2, CG-5). Lanes a write leaves alone
// keep their value through the D input (AND-OR on D), so the gate stays
// whole. At most one port hits a row in a cycle (asserted). No reset: no row
// is read before it is written (A-29).
//
// The reference is the RCU model's register file rules (sim/rcu/rcu_core.cpp,
// commit()): test/rcu/bank_slice_tb.cpp holds this module to a value model
// of them, port by port and cycle by cycle.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK rcu_core_clk
`define CCV_RST rst_r01h
module rcu_bank_slice #(
  parameter int ROWS = ccv_prov_pkg::CCV_P_PHYS_REGS,   // rows of the bank (32 for loops)
  parameter int K = 0,          // the byte section this slice holds
  parameter int J = 0,          // its lanes are 4J to 4J+3 (wiring only)
  parameter int FULL_ROW = 1,   // AR-24's interim: SW, MW, RW write the whole row
  parameter int NR = 10,        // read ports
  parameter int NW = 3,         // generic write ports: LW, SW, RW
  parameter int NM = 4,         // MIU slots on the load port
  localparam int L = 4,         // lanes
  localparam int WR = 8,        // a row index (CCV_P_W_PHYS_REG)
  localparam int NH = (ROWS + 15) / 16   // sel_hi bits
) (
  input  logic              rcu_core_clk,
  input  logic              rcu_rst_r00h,
  // Read ports.
  input  logic [NR-1:0]     rd_v_cr00h,     // port p reads next cycle
  input  logic [NR*WR-1:0]  rd_row_cr01h,   //   this row
  output logic [NR*32-1:0]  rd_cr03h,       // port p's 4 lanes' byte K (lane l at p*32 + 8l)
  // Generic write ports: 0 LW, 1 SW, 2 RW.
  input  logic [NW-1:0]     wr_v_cr00h,     // port p writes in two cycles
  input  logic [NW*WR-1:0]  wr_row_cr01h,   //   this row
  input  logic [NW*4-1:0]   wr_sec_cr01h,   //   covering these sections (LW: owned; SW, RW: secmask)
  input  logic [NW*32-1:0]  wr_dat_cr02h,   //   with this data, lane l's byte K at p*32 + 8l
  input  logic [NW*L-1:0]   wr_lm_cr02h,    //   in these lanes
  // The load port: each MIU slot's lead and, a cycle on, its data.
  input  logic [NM-1:0]     mw_v_cr00h,     // slot j lands in two cycles
  input  logic [NM*WR-1:0]  mw_row_cr01h,   //   its destination row
  input  logic [NM*2-1:0]   mw_wid_cr01h,   //   width code (0 32, 1 16, 2 8, 3 4 bits)
  input  logic [NM*2-1:0]   mw_pos_cr01h,   //   position
  input  logic [NM*L-1:0]   mw_lm_cr01h,    //   the 4 lanes' active bits
  input  logic [NM*L*32-1:0] mw_dat_cr02h   //   lane l's word at (j*L + l)*32, right-aligned
);

  logic rst_r01h;
  always_ff @(posedge rcu_core_clk) begin
    rst_r01h <= rcu_rst_r00h;
  end

  // One-hot predecode of a row index.
  function automatic logic [NH-1:0] dec_hi(input logic [WR-1:0] r);
    for (int h = 0; h < NH; h++) dec_hi[h] = r[WR-1:4] == h[WR-5:0];
  endfunction
  function automatic logic [15:0] dec_lo(input logic [WR-1:0] r);
    for (int i = 0; i < 16; i++) dec_lo[i] = r[3:0] == i[3:0];
  endfunction
  // Does a register of width code w at position pos cover section K, and
  // which of its bytes sits there.
  function automatic logic covers(input logic [1:0] w, input logic [1:0] pos);
    int span;
    span = (w == 2'd0) ? 4 : (w == 2'd1) ? 2 : 1;
    covers = (K >= pos) && (K < pos + span);
  endfunction

  // ---- Valids: each port's lead, flopped every cycle -------------------
  logic [NR-1:0] rd_v_cr01h;
  logic [NW-1:0] wr_v_cr01h;
  logic [NM-1:0] mw_v_cr01h;
  always_ff @(posedge rcu_core_clk) begin
    if (rst_r01h) begin
      rd_v_cr01h <= '0;
      wr_v_cr01h <= '0;
      mw_v_cr01h <= '0;
    end else begin
      rd_v_cr01h <= rd_v_cr00h;
      wr_v_cr01h <= wr_v_cr00h;
      mw_v_cr01h <= mw_v_cr00h;
    end
  end
  wire [NR-1:0] rd_en_cr01h = rd_v_cr01h;
  wire [NW-1:0] wr_en_cr01h = wr_v_cr01h;
  wire          mw_en_cr01h = |mw_v_cr01h;

  // ---- Read selects and the read mux -----------------------------------
  (* keep *) logic [NR*NH-1:0] rd_hi_cr02h;
  (* keep *) logic [NR*16-1:0] rd_lo_cr02h;
  for (genvar p = 0; p < NR; p++) begin : g_rsel
    always_ff @(posedge rcu_core_clk) begin
      if (rd_en_cr01h[p]) begin
        rd_hi_cr02h[p*NH +: NH] <= dec_hi(rd_row_cr01h[p*WR +: WR]);
        rd_lo_cr02h[p*16 +: 16] <= dec_lo(rd_row_cr01h[p*WR +: WR]);
      end
    end
  end

  logic [ROWS*32-1:0] row_cr03h;   // row r, lane l's byte at r*32 + 8l

  always_comb begin
    for (int p = 0; p < NR; p++) begin
      logic [31:0] acc;
      acc = '0;
      for (int h = 0; h < NH; h++) begin
        logic [31:0] grp;
        grp = '0;
        for (int i = 0; i < 16; i++)
          if (h * 16 + i < ROWS)
            grp = grp | ({32{rd_lo_cr02h[p*16 + i]}} & row_cr03h[(h*16 + i)*32 +: 32]);
        acc = acc | ({32{rd_hi_cr02h[p*NH + h]}} & grp);
      end
      rd_cr03h[p*32 +: 32] = acc;
    end
  end

  // ---- Write selects ---------------------------------------------------
  // A generic port acts on bank K when it covers it, or (SW, RW under
  // FULL_ROW) whenever it writes; it keeps byte K's data only when K is
  // covered, zero otherwise (the row zero above the register).
  (* keep *) logic [NW*NH-1:0] wr_hi_cr02h;
  (* keep *) logic [NW*16-1:0] wr_lo_cr02h;
  logic [NW-1:0] wr_act_cr02h, wr_keep_cr02h;
  for (genvar p = 0; p < NW; p++) begin : g_wsel
    always_ff @(posedge rcu_core_clk) begin
      if (wr_en_cr01h[p]) begin
        wr_hi_cr02h[p*NH +: NH] <= dec_hi(wr_row_cr01h[p*WR +: WR]);
        wr_lo_cr02h[p*16 +: 16] <= dec_lo(wr_row_cr01h[p*WR +: WR]);
        wr_keep_cr02h[p]        <= wr_sec_cr01h[p*4 + K];
      end
    end
  end
  always_ff @(posedge rcu_core_clk) begin
    if (rst_r01h) wr_act_cr02h <= '0;
    else
      for (int p = 0; p < NW; p++)
        wr_act_cr02h[p] <= wr_v_cr01h[p] & (wr_sec_cr01h[p*4 + K] | (FULL_ROW != 0 && p != 0));
  end

  // The load port: the slot covering bank K, its row, its byte select
  // (slot j, byte b: one-hot at j*4 + b) and its lanes.
  logic [NM-1:0] mw_cov_cr01h;
  logic [NH-1:0] mw_hi_d_cr01h;
  logic [15:0]   mw_lo_d_cr01h;
  logic [NM*4-1:0] mw_byte_d_cr01h;
  logic [L-1:0]  mw_lm_d_cr01h;
  logic          mw_nib_d_cr01h;   // the covering slot is a 4-bit load: its byte's low nibble only
  always_comb begin
    mw_nib_d_cr01h = 1'b0;
    mw_hi_d_cr01h = '0;
    mw_lo_d_cr01h = '0;
    mw_byte_d_cr01h = '0;
    mw_lm_d_cr01h = '0;
    for (int j = 0; j < NM; j++) begin
      logic [1:0] w, pos;
      w = mw_wid_cr01h[j*2 +: 2];
      pos = mw_pos_cr01h[j*2 +: 2];
      mw_cov_cr01h[j] = mw_v_cr01h[j] & (covers(w, pos) | (FULL_ROW != 0));
      mw_hi_d_cr01h = mw_hi_d_cr01h | ({NH{mw_cov_cr01h[j]}} & dec_hi(mw_row_cr01h[j*WR +: WR]));
      mw_lo_d_cr01h = mw_lo_d_cr01h | ({16{mw_cov_cr01h[j]}} & dec_lo(mw_row_cr01h[j*WR +: WR]));
      mw_lm_d_cr01h = mw_lm_d_cr01h | ({L{mw_cov_cr01h[j]}} & mw_lm_cr01h[j*L +: L]);
      mw_nib_d_cr01h = mw_nib_d_cr01h | (mw_cov_cr01h[j] & (w == 2'd3));
      for (int b = 0; b < 4; b++)
        mw_byte_d_cr01h[j*4 + b] = mw_cov_cr01h[j] & covers(w, pos) && (K - b == 32'(pos));
    end
  end
  (* keep *) logic [NH-1:0] mw_hi_cr02h;
  (* keep *) logic [15:0]   mw_lo_cr02h;
  logic [NM*4-1:0] mw_byte_cr02h;
  logic [L-1:0]    mw_lm_cr02h;
  logic            mw_nib_cr02h;
  always_ff @(posedge rcu_core_clk) begin
    if (mw_en_cr01h) begin
      mw_nib_cr02h  <= mw_nib_d_cr01h;
      mw_hi_cr02h   <= mw_hi_d_cr01h;
      mw_lo_cr02h   <= mw_lo_d_cr01h;
      mw_byte_cr02h <= mw_byte_d_cr01h;
      mw_lm_cr02h   <= mw_lm_d_cr01h;
    end
  end
  logic mw_act_cr02h;
  always_ff @(posedge rcu_core_clk) begin
    if (rst_r01h) mw_act_cr02h <= 1'b0;
    else          mw_act_cr02h <= |mw_cov_cr01h & |mw_lm_d_cr01h;   // no active lane here: no clock
  end

  // ---- The write cycle: each port's data and lanes ---------------------
  localparam int NP = NW + 1;   // ports into the rows: the generic ones, then MW
  logic [NP*32-1:0] pdat_cr02h;   // port p's 4 lanes' byte K
  logic [NP*L-1:0]  plm_cr02h;    // port p's lanes
  logic [NP*NH-1:0] phi_cr02h;
  logic [NP*16-1:0] plo_cr02h;
  logic [NP-1:0]    pact_cr02h;
  always_comb begin
    for (int p = 0; p < NW; p++) begin
      pdat_cr02h[p*32 +: 32] = {32{wr_keep_cr02h[p]}} & wr_dat_cr02h[p*32 +: 32];
      plm_cr02h[p*L +: L]    = wr_lm_cr02h[p*L +: L];
      phi_cr02h[p*NH +: NH]  = wr_hi_cr02h[p*NH +: NH];
      plo_cr02h[p*16 +: 16]  = wr_lo_cr02h[p*16 +: 16];
      pact_cr02h[p]          = wr_act_cr02h[p];
    end
    // MW: lane l's byte K is byte b of slot j's word, by the one-hot select.
    for (int l = 0; l < L; l++) begin
      logic [7:0] by;
      by = '0;
      for (int j = 0; j < NM; j++)
        for (int b = 0; b < 4; b++)
          by = by | ({8{mw_byte_cr02h[j*4 + b]}} & mw_dat_cr02h[(j*L + l)*32 + 8*b +: 8]);
      pdat_cr02h[NW*32 + 8*l +: 8] = by & {{4{~mw_nib_cr02h}}, 4'hf};
    end
    plm_cr02h[NW*L +: L]   = mw_lm_cr02h;
    phi_cr02h[NW*NH +: NH] = mw_hi_cr02h;
    plo_cr02h[NW*16 +: 16] = mw_lo_cr02h;
    pact_cr02h[NW]         = mw_act_cr02h;
  end

  // ---- Rows: hits, enables and D ---------------------------------------
  logic [ROWS*NP-1:0] hit_cr02h;   // row r, port p at r*NP + p
  logic [ROWS-1:0]    row_en_cr02h;
  logic [ROWS*32-1:0] row_d_cr02h;
  always_comb begin
    for (int r = 0; r < ROWS; r++) begin
      logic [31:0] d, keep;
      d = '0;
      keep = '1;
      row_en_cr02h[r] = 1'b0;
      for (int p = 0; p < NP; p++) begin
        logic h;
        h = pact_cr02h[p] & phi_cr02h[p*NH + r/16] & plo_cr02h[p*16 + r%16];
        hit_cr02h[r*NP + p] = h;
        row_en_cr02h[r] = row_en_cr02h[r] | h;
        for (int l = 0; l < L; l++) begin
          d[8*l +: 8]    = d[8*l +: 8] | ({8{h & plm_cr02h[p*L + l]}} & pdat_cr02h[p*32 + 8*l +: 8]);
          keep[8*l +: 8] = keep[8*l +: 8] & ~{8{h & plm_cr02h[p*L + l]}};
        end
      end
      row_d_cr02h[r*32 +: 32] = d | (keep & row_cr03h[r*32 +: 32]);
    end
  end
  for (genvar r = 0; r < ROWS; r++) begin : g_row
    always_ff @(posedge rcu_core_clk) begin
      if (row_en_cr02h[r]) row_cr03h[r*32 +: 32] <= row_d_cr02h[r*32 +: 32];
    end
  end

  // ---- Contracts -------------------------------------------------------
  // Each a reduction over its rows or ports, so each is one named assertion.
  logic two_hits_cr02h, bad_rd_cr01h, bad_wr_cr01h, bad_mw_cr01h;
  always_comb begin
    two_hits_cr02h = 1'b0;
    for (int r = 0; r < ROWS; r++)
      two_hits_cr02h = two_hits_cr02h | !$onehot0(hit_cr02h[r*NP +: NP]);
    bad_rd_cr01h = 1'b0;
    for (int p = 0; p < NR; p++)
      bad_rd_cr01h = bad_rd_cr01h | (rd_v_cr01h[p] && 32'(rd_row_cr01h[p*WR +: WR]) >= ROWS &&
                                     32'(rd_row_cr01h[p*WR +: WR]) != ccv_prov_pkg::CCV_P_PHYS_ZERO);
    bad_wr_cr01h = 1'b0;
    for (int p = 0; p < NW; p++)
      bad_wr_cr01h = bad_wr_cr01h | (wr_v_cr01h[p] && 32'(wr_row_cr01h[p*WR +: WR]) >= ROWS);
    bad_mw_cr01h = 1'b0;
    for (int j = 0; j < NM; j++)
      bad_mw_cr01h = bad_mw_cr01h | (mw_v_cr01h[j] && 32'(mw_row_cr01h[j*WR +: WR]) >= ROWS &&
                                     32'(mw_row_cr01h[j*WR +: WR]) != ccv_prov_pkg::CCV_P_PHYS_ZERO);
  end
  // At most one port hits a row in a cycle (renaming and section ownership).
  `CCV_ASSERT(one_write_a_row, !two_hits_cr02h)
  // One load slot a bank a cycle (RA-28).
  `CCV_ASSERT(one_load_a_bank, $onehot0(mw_cov_cr01h))
  // Rows past the pool are never named; a read may name the zero register.
  `CCV_ASSERT(read_row_named, !bad_rd_cr01h)
  // A write never names the zero register (A-64) or a row past the pool.
  `CCV_ASSERT(write_row_named, !bad_wr_cr01h)
  // A load may name the zero register: a predicate-only load writes no row.
  `CCV_ASSERT(load_row_named, !bad_mw_cr01h)

endmodule
`undef CCV_CLK
`undef CCV_RST
