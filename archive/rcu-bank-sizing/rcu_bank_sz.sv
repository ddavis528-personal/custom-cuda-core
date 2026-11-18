// Sizing stand-in for ccv_rcu_bank (RCU spec, Register file tab). Not the
// implementation (RI's): it has the bank's storage, ports and select flops,
// so Yosys and ABC see its size and depth, nothing else.
//
// ROWS x (8*LANES) bits. RP read ports, WP write ports. Every select is a
// predecoded one-hot pair (sel_hi of r[7:4], sel_lo of r[3:0]) in flops,
// one (* keep *) copy per 64-bit section (8 lanes) per port (RA-33 (a)).
// Read: combinational AND-OR from the select flops. Write: hit = v & hi & lo,
// row_en = OR of hits, D = OR of hit & lmask & data, else hold.
module rcu_bank_sz #(
  parameter int ROWS  = 16,
  parameter int LANES = 1,
  parameter int RP    = 10,
  parameter int WP    = 4,
  parameter int SECW  = 64,    // bits under one select copy
  parameter int ONEHOT = 0     // read selects held as a ROWS-bit one-hot
) (
  input  logic                         clk,
  input  logic                         rst_n,
  input  logic [RP-1:0]                rd_lead_v,
  input  logic [RP*8-1:0]              rd_row,
  output logic [RP*8*LANES-1:0]        rd_data,
  input  logic [WP-1:0]                wr_v,
  input  logic [WP*8-1:0]              wr_row,
  input  logic [WP*LANES-1:0]          wr_lmask,
  input  logic [WP*8*LANES-1:0]        wr_data
);
  localparam int BITS = 8 * LANES;
  localparam int NHI  = (ROWS + 15) / 16;
  localparam int NSEC = (BITS + SECW - 1) / SECW;

  logic rst_q;
  always_ff @(posedge clk) rst_q <= ~rst_n;

  logic [ROWS*BITS-1:0] row_q;
  logic [BITS*ROWS-1:0] col;                 // row_q transposed: col[b*ROWS + r]
  for (genvar r = 0; r < ROWS; r++) begin : g_t
    for (genvar b = 0; b < BITS; b++) begin : g_b
      assign col[b*ROWS + r] = row_q[r*BITS + b];
    end
  end

  // ---- read ports ---------------------------------------------------------
  logic [RP-1:0] rv_q;
  always_ff @(posedge clk) rv_q <= rd_lead_v & {RP{~rst_q}};

  for (genvar p = 0; p < RP; p++) begin : g_rp
    for (genvar s = 0; s < NSEC; s++) begin : g_s
      (* keep *) logic [NHI-1:0] hi_q;
      (* keep *) logic [15:0]    lo_q;
      always_ff @(posedge clk)
        if (rv_q[p]) begin
          hi_q <= NHI'(1) << rd_row[p*8+4 +: 4];
          lo_q <= 16'(1)  << rd_row[p*8   +: 4];
        end
      logic [ROWS-1:0] rsel;
      if (ONEHOT) begin : g_oh
        (* keep *) logic [ROWS-1:0] oh_q;
        always_ff @(posedge clk)
          if (rv_q[p]) oh_q <= ROWS'(1) << rd_row[p*8 +: 8];
        assign rsel = oh_q;
      end else begin : g_pd
        for (genvar r = 0; r < ROWS; r++) begin : g_r
          assign rsel[r] = hi_q[r/16] & lo_q[r%16];
        end
      end
      for (genvar b = SECW*s; b < BITS && b < SECW*s + SECW; b++) begin : g_b
        assign rd_data[p*BITS + b] = |(rsel & col[b*ROWS +: ROWS]);
      end
    end
  end

  // ---- write ports --------------------------------------------------------
  logic [WP-1:0] wv_q;
  always_ff @(posedge clk) wv_q <= wr_v & {WP{~rst_q}};

  // hl[(p*LANES + l)*ROWS + r]: port p writes lane l of row r
  logic [WP*LANES*ROWS-1:0] hl;
  logic [WP*ROWS-1:0]       hit;             // section 0's copy: the row enable
  for (genvar p = 0; p < WP; p++) begin : g_wp
    for (genvar s = 0; s < NSEC; s++) begin : g_s
      (* keep *) logic [NHI-1:0] hi_q;
      (* keep *) logic [15:0]    lo_q;
      always_ff @(posedge clk)
        if (wr_v[p]) begin
          hi_q <= NHI'(1) << wr_row[p*8+4 +: 4];
          lo_q <= 16'(1)  << wr_row[p*8   +: 4];
        end
      for (genvar r = 0; r < ROWS; r++) begin : g_r
        logic h;
        assign h = wv_q[p] & hi_q[r/16] & lo_q[r%16];
        if (s == 0) begin : g_en
          assign hit[p*ROWS + r] = h;
        end
        for (genvar l = (SECW/8)*s; l < LANES && l < (SECW/8)*(s+1); l++) begin : g_l
          assign hl[(p*LANES + l)*ROWS + r] = h & wr_lmask[p*LANES + l];
        end
      end
    end
  end

  // ---- rows: one gate group per row ---------------------------------------
  for (genvar r = 0; r < ROWS; r++) begin : g_row
    logic row_en;
    logic [BITS-1:0] d;
    logic [WP-1:0] h;
    for (genvar p = 0; p < WP; p++) begin : g_h
      assign h[p] = hit[p*ROWS + r];
    end
    assign row_en = |h;
    for (genvar l = 0; l < LANES; l++) begin : g_l
      logic [WP-1:0] w;
      for (genvar p = 0; p < WP; p++) begin : g_p
        assign w[p] = hl[(p*LANES + l)*ROWS + r];
      end
      for (genvar b = 8*l; b < 8*l + 8; b++) begin : g_b
        logic [WP-1:0] v;
        for (genvar p = 0; p < WP; p++) begin : g_p
          assign v[p] = w[p] & wr_data[p*BITS + b];
        end
        assign d[b] = (|v) | (~(|w) & row_q[r*BITS + b]);
      end
    end
    always_ff @(posedge clk)
      if (row_en) row_q[r*BITS +: BITS] <= d;
  end
endmodule
