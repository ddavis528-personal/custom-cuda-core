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
// Port timing (CG-5: an enable comes only from the slice's own flops).
// A port whose valid leads its row by a cycle (L0-L3, M0-M2, R2, LW, SW, RW):
//   cycle t-1  *_v_cr00h    the port's valid, flopped every cycle
//   cycle t    *_row_cr01h  its row (and a write's sections or lead),
//                           taken into the select flops under that flop
//   cycle t+1  a read's data on rd_cr03h, from the selects and the rows;
//              a write's data on *_dat_cr02h, written at the edge ending t+1
// MW, whose valid comes with MIU's lead (RA's re:RI-9 (b)): the valid and
// lead in T-1, the slot covering K loaded every cycle, ungated (its row
// binary, decoded in T, and its fields); the data in T as above.
// R0 and R1 (RA-39, OA rev 336): no select flops. The R issue valid lead in
// A-1 (rv_cr02h, flopped); the payload's phys_src rows on the wire in A
// (rr_row_cr03h), decoded and read in A, with the MIU write-through (the MW
// write landing in A, on its lanes, substituted for the read), into the
// slice's rsrc at A's edge (rs_cr04h, raw: rcu_r aligns it in A+1).
// A read of a row written in the same cycle sees the old value, but for
// R0/R1's write-through of MW.
//
// Read ports: NR (8) whose valid leads, L0-L2 and L3 (merge data), M0-M2,
// R2, in the order the parent wires them, on rd_*; R0 and R1 on rr_*. Each
// is a 16:1 AND-OR on sel_lo per group of 16 rows, gated by its sel_hi
// bit, then an NH:1 OR: the spec's read mux.
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
  parameter int NR = 8,         // read ports whose valid leads: L0-L3, M0-M2, R2
  parameter int NW = 3,         // generic write ports: LW, SW, RW
  parameter int NM = 4,         // MIU slots on the load port
  localparam int L = 4,         // lanes
  localparam int WR = 8,        // a row index (CCV_P_W_PHYS_REG)
  localparam int NRR = 2,       // read ports whose valid comes with the row: R0, R1
  localparam int NH = (ROWS + 15) / 16   // sel_hi bits
) (
  input  logic              rcu_core_clk,
  input  logic              rcu_rst_r00h,
  // Read ports.
  input  logic [NR-1:0]     rd_v_cr00h,     // port p reads next cycle
  input  logic [NR*WR-1:0]  rd_row_cr01h,   //   this row
  output logic [NR*32-1:0]  rd_cr03h,       // port p's 4 lanes' byte K (lane l at p*32 + 8l)
  // R0 and R1: the R issue valid lead, then the payload's rows.
  input  logic              rv_cr02h,       // R issues next cycle (the lead's valid)
  input  logic [NRR*WR-1:0] rr_row_cr03h,   //   phys_src: R0 at [7:0], R1 at [15:8], on the wire
  output logic [NRR*32-1:0] rs_cr04h,       // rsrc: their 4 lanes' byte K, raw, a cycle on
  // Generic write ports: 0 LW, 1 SW, 2 RW.
  input  logic [NW-1:0]     wr_v_cr00h,     // port p writes in two cycles
  input  logic [NW*WR-1:0]  wr_row_cr01h,   //   this row
  input  logic [NW*4-1:0]   wr_sec_cr01h,   //   covering these sections (LW: owned; SW, RW: secmask)
  input  logic [NW*32-1:0]  wr_dat_cr02h,   //   with this data, lane l's byte K at p*32 + 8l
  input  logic [NW*L-1:0]   wr_lm_cr02h,    //   in these lanes
  // The load port: each MIU slot's lead and, a cycle on, its data.
  input  logic [NM-1:0]     mw_v_cr01h,     // slot j lands next cycle, its lead now
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
  always_ff @(posedge rcu_core_clk) begin
    if (rst_r01h) begin
      rd_v_cr01h <= '0;
      wr_v_cr01h <= '0;
    end else begin
      rd_v_cr01h <= rd_v_cr00h;
      wr_v_cr01h <= wr_v_cr00h;
    end
  end
  wire [NR-1:0] rd_en_cr01h = rd_v_cr01h;
  wire [NW-1:0] wr_en_cr01h = wr_v_cr01h;

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

  // R0 and R1: decoded on the wire.
  localparam logic [WR-1:0] ZROW = WR'(ccv_prov_pkg::CCV_P_PHYS_ZERO);
  logic [NRR*NH-1:0] rr_hi_cr02h;
  logic [NRR*16-1:0] rr_lo_cr02h;
  always_comb begin
    for (int q = 0; q < NRR; q++) begin
      rr_hi_cr02h[q*NH +: NH] = dec_hi(rr_row_cr03h[q*WR +: WR]);
      rr_lo_cr02h[q*16 +: 16] = dec_lo(rr_row_cr03h[q*WR +: WR]);
    end
  end

  logic [ROWS*32-1:0] row_cr03h;   // row r, lane l's byte at r*32 + 8l

  localparam int NA = NR + NRR;    // every read port: NR's, then R0 and R1
  wire [NA*NH-1:0] sel_hi_cr02h = {rr_hi_cr02h, rd_hi_cr02h};
  wire [NA*16-1:0] sel_lo_cr02h = {rr_lo_cr02h, rd_lo_cr02h};
  logic [NA*32-1:0] rdx_cr03h;
  always_comb begin
    for (int p = 0; p < NA; p++) begin
      logic [31:0] acc_cr03h;
      acc_cr03h = '0;
      for (int h = 0; h < NH; h++) begin
        logic [31:0] grp_cr03h;
        grp_cr03h = '0;
        for (int i = 0; i < 16; i++)
          if (h * 16 + i < ROWS)
            grp_cr03h = grp_cr03h | ({32{sel_lo_cr02h[p*16 + i]}} & row_cr03h[(h*16 + i)*32 +: 32]);
        acc_cr03h = acc_cr03h | ({32{sel_hi_cr02h[p*NH + h]}} & grp_cr03h);
      end
      rdx_cr03h[p*32 +: 32] = acc_cr03h;
    end
  end
  assign rd_cr03h = rdx_cr03h[NR*32-1:0];

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

  // The load port: in T-1, from MIU's lead, the one slot covering bank K
  // (under FULL_ROW, any slot landing); loaded every cycle, ungated: its row
  // (binary; the zero register when none), slot, byte, lanes, whether it
  // covers K at all (else, under FULL_ROW, it writes zero here), and a
  // 4-bit load's nibble mask (RA's re:RI-9 (b), (d)).
  logic [NM-1:0]   mw_cov_cr01h;
  logic [WR-1:0]   mw_row_d_cr01h;
  logic [1:0]      mw_slot_d_cr01h, mw_b_d_cr01h;
  logic [L-1:0]    mw_lm_d_cr01h;
  logic            mw_kp_d_cr01h, mw_nib_d_cr01h;
  always_comb begin
    mw_row_d_cr01h = '0;
    mw_slot_d_cr01h = '0;
    mw_b_d_cr01h = '0;
    mw_lm_d_cr01h = '0;
    mw_kp_d_cr01h = 1'b0;
    mw_nib_d_cr01h = 1'b0;
    for (int j = 0; j < NM; j++) begin
      logic [1:0] w_cr01h, pos_cr01h;
      logic       c_cr01h;
      w_cr01h = mw_wid_cr01h[j*2 +: 2];
      pos_cr01h = mw_pos_cr01h[j*2 +: 2];
      c_cr01h = covers(w_cr01h, pos_cr01h);
      mw_cov_cr01h[j] = mw_v_cr01h[j] & (c_cr01h | (FULL_ROW != 0));
      mw_row_d_cr01h  = mw_row_d_cr01h | ({WR{mw_cov_cr01h[j]}} & mw_row_cr01h[j*WR +: WR]);
      mw_slot_d_cr01h = mw_slot_d_cr01h | ({2{mw_cov_cr01h[j]}} & 2'(j));
      mw_b_d_cr01h    = mw_b_d_cr01h | ({2{mw_cov_cr01h[j]}} & 2'(K - 32'(pos_cr01h)));
      mw_lm_d_cr01h   = mw_lm_d_cr01h | ({L{mw_cov_cr01h[j]}} & mw_lm_cr01h[j*L +: L]);
      mw_kp_d_cr01h   = mw_kp_d_cr01h | (mw_cov_cr01h[j] & c_cr01h);
      mw_nib_d_cr01h  = mw_nib_d_cr01h | (mw_cov_cr01h[j] & (w_cr01h == 2'd3));
    end
  end
  (* keep *) logic [WR-1:0] mw_row_cr02h;
  logic [1:0]      mw_slot_cr02h, mw_b_cr02h;
  logic [L-1:0]    mw_lm_cr02h;
  logic            mw_kp_cr02h, mw_nib_cr02h, mw_act_cr02h;
  always_ff @(posedge rcu_core_clk) begin
    if (rst_r01h) begin
      mw_act_cr02h <= 1'b0;
      mw_row_cr02h <= ZROW;
    end else begin
      mw_act_cr02h <= |mw_cov_cr01h & |mw_lm_d_cr01h;   // no active lane here: no clock
      mw_row_cr02h <= |mw_cov_cr01h ? mw_row_d_cr01h : ZROW;
    end
  end
  always_ff @(posedge rcu_core_clk) begin
    mw_slot_cr02h <= mw_slot_d_cr01h;
    mw_b_cr02h    <= mw_b_d_cr01h;
    mw_lm_cr02h   <= mw_lm_d_cr01h;
    mw_kp_cr02h   <= mw_kp_d_cr01h;
    mw_nib_cr02h  <= mw_nib_d_cr01h;
  end
  wire [NH-1:0] mw_hi_cr02h = dec_hi(mw_row_cr02h);
  wire [15:0]   mw_lo_cr02h = dec_lo(mw_row_cr02h);

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
      logic [31:0] wd_cr02h;
      logic [7:0]  by_cr02h;
      wd_cr02h = mw_dat_cr02h[(32'(mw_slot_cr02h)*L + l)*32 +: 32];
      by_cr02h = wd_cr02h[8*mw_b_cr02h +: 8];
      pdat_cr02h[NW*32 + 8*l +: 8] = {8{mw_kp_cr02h}} & by_cr02h & {{4{~mw_nib_cr02h}}, 4'hf};
    end
    plm_cr02h[NW*L +: L]   = mw_lm_cr02h;
    phi_cr02h[NW*NH +: NH] = mw_hi_cr02h;
    plo_cr02h[NW*16 +: 16] = mw_lo_cr02h;
    pact_cr02h[NW]         = mw_act_cr02h;
  end
  // R0 and R1 into rsrc: the read, or on the lanes of an MW write landing
  // now in the same row (never the zero register), the byte it writes.
  logic rv_cr03h;
  always_ff @(posedge rcu_core_clk) begin
    if (rst_r01h) rv_cr03h <= 1'b0;
    else          rv_cr03h <= rv_cr02h;
  end
  logic [NRR*32-1:0] rs_d_cr03h;
  always_comb begin
    for (int q = 0; q < NRR; q++) begin
      logic wt_cr03h;
      wt_cr03h = mw_act_cr02h & (rr_row_cr03h[q*WR +: WR] == mw_row_cr02h) &
                 (rr_row_cr03h[q*WR +: WR] != ZROW);
      for (int l = 0; l < L; l++)
        rs_d_cr03h[q*32 + 8*l +: 8] = (wt_cr03h & mw_lm_cr02h[l]) ? pdat_cr02h[NW*32 + 8*l +: 8]
                                                                 : rdx_cr03h[(NR + q)*32 + 8*l +: 8];
    end
  end
  wire rs_en_cr03h = rv_cr03h;
  always_ff @(posedge rcu_core_clk) begin
    if (rs_en_cr03h) rs_cr04h <= rs_d_cr03h;
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
    for (int q = 0; q < NRR; q++)
      bad_rd_cr01h = bad_rd_cr01h | (rv_cr03h && 32'(rr_row_cr03h[q*WR +: WR]) >= ROWS &&
                                     32'(rr_row_cr03h[q*WR +: WR]) != ccv_prov_pkg::CCV_P_PHYS_ZERO);
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
