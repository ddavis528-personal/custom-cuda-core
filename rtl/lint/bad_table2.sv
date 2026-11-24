//===-- bad_table2.sv - lint fixture for two-writer tables ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 (declared table, two writers;
//       OA-479 (b), Daniel 2026-11-24)
//
// Every violation is intentional. tools/check-1d.sh fails if any stops
// firing here. DO NOT FIX THE VIOLATIONS IN THIS FILE.
//
// Each module is reference_table2.sv's shape with one term of OA-479 (b)
// broken, declared in its own <module>.feedback.json, its nets prefixed by a
// letter of its own: reference_twnoassert has no assertion of the fill's
// enable against the read (iii); reference_twundecl has a third writer, at
// stage 05, that the declaration does not list (i); reference_twnoconf has
// no assertion of the fill's enable against the lookup's, no write conflict
// at the port (DI-42).
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_twnoassert (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic       nle_in_cy01h,
  input  logic [2:0] nli_in_cy01h,
  input  logic       nfe_in_cy03h,
  input  logic [2:0] nfi_in_cy03h,
  input  logic [5:0] nfd_in_cy03h,
  output logic [5:0] nrd_out_cy03h
);
  // The loop writer: a lookup at stage 02 reads the word and writes it back,
  // plus one, at the same port (its back edge is the table's own read).
  logic       nle_cy02h;
  logic [2:0] nli_cy02h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) nle_cy02h <= 1'b0;
    else              nle_cy02h <= nle_in_cy01h;
    nli_cy02h <= nli_in_cy01h;
  end
  // A later writer from another pipeline: a fill at stage 04, its data,
  // index and enable its own registers, muxed into the same port.
  logic       nfe_cy04h;
  logic [2:0] nfi_cy04h;
  logic [5:0] nfd_cy04h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) nfe_cy04h <= 1'b0;
    else              nfe_cy04h <= nfe_in_cy03h;
    nfi_cy04h <= nfi_in_cy03h;
    nfd_cy04h <= nfd_in_cy03h;
  end

  logic [5:0] ntab_cy03h [8];
  logic [5:0] nrd_cy02h;
  assign nrd_cy02h = ntab_cy03h[nli_cy02h];

  // The write port.
  logic       npe_cy02h;
  logic [2:0] npi_cy02h;
  logic [5:0] npd_cy02h;
  assign npe_cy02h = nle_cy02h | nfe_cy04h;
  assign npi_cy02h = nfe_cy04h ? nfi_cy04h : nli_cy02h;
  assign npd_cy02h = nfe_cy04h ? nfd_cy04h : nrd_cy02h + 6'd1;
  always_ff @(posedge reference_core_clk) begin
    if (npe_cy02h) ntab_cy03h[npi_cy02h] <= npd_cy02h;
  end
  always_ff @(posedge reference_core_clk) nrd_out_cy03h <= nrd_cy02h;

  // No write conflict at the port; no lookup reads a word the fill wrote in
  // that cycle or the next.
  logic       nfe_cy05h;
  logic [2:0] nfi_cy05h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) nfe_cy05h <= 1'b0;
    else              nfe_cy05h <= nfe_cy04h;
    nfi_cy05h <= nfi_cy04h;
  end
  `CCV_ASSERT(ntab_one_writer, !(nle_cy02h && nfe_cy04h))
endmodule

module reference_twundecl (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic       ule_in_cy01h,
  input  logic [2:0] uli_in_cy01h,
  input  logic       ufe_in_cy03h,
  input  logic [2:0] ufi_in_cy03h,
  input  logic [5:0] ufd_in_cy03h,
  input  logic       uge_in_cy04h,
  input  logic [2:0] ugi_in_cy04h,
  input  logic [5:0] ugd_in_cy04h,
  output logic [5:0] urd_out_cy03h
);
  // The loop writer: a lookup at stage 02 reads the word and writes it back,
  // plus one, at the same port (its back edge is the table's own read).
  logic       ule_cy02h;
  logic [2:0] uli_cy02h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) ule_cy02h <= 1'b0;
    else              ule_cy02h <= ule_in_cy01h;
    uli_cy02h <= uli_in_cy01h;
  end
  // A later writer from another pipeline: a fill at stage 04, its data,
  // index and enable its own registers, muxed into the same port.
  logic       ufe_cy04h;
  logic [2:0] ufi_cy04h;
  logic [5:0] ufd_cy04h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) ufe_cy04h <= 1'b0;
    else              ufe_cy04h <= ufe_in_cy03h;
    ufi_cy04h <= ufi_in_cy03h;
    ufd_cy04h <= ufd_in_cy03h;
  end
  logic       uge_cy05h;
  logic [2:0] ugi_cy05h;
  logic [5:0] ugd_cy05h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) uge_cy05h <= 1'b0;
    else              uge_cy05h <= uge_in_cy04h;
    ugi_cy05h <= ugi_in_cy04h;
    ugd_cy05h <= ugd_in_cy04h;
  end

  logic [5:0] utab_cy03h [8];
  logic [5:0] urd_cy02h;
  assign urd_cy02h = utab_cy03h[uli_cy02h];

  // The write port.
  logic       upe_cy02h;
  logic [2:0] upi_cy02h;
  logic [5:0] upd_cy02h;
  assign upe_cy02h = ule_cy02h | ufe_cy04h | uge_cy05h;
  assign upi_cy02h = uge_cy05h ? ugi_cy05h : ufe_cy04h ? ufi_cy04h : uli_cy02h;
  assign upd_cy02h = uge_cy05h ? ugd_cy05h : ufe_cy04h ? ufd_cy04h : urd_cy02h + 6'd1;
  always_ff @(posedge reference_core_clk) begin
    if (upe_cy02h) utab_cy03h[upi_cy02h] <= upd_cy02h;
  end
  always_ff @(posedge reference_core_clk) urd_out_cy03h <= urd_cy02h;

  // No write conflict at the port; no lookup reads a word the fill wrote in
  // that cycle or the next.
  logic       ufe_cy05h;
  logic [2:0] ufi_cy05h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) ufe_cy05h <= 1'b0;
    else              ufe_cy05h <= ufe_cy04h;
    ufi_cy05h <= ufi_cy04h;
  end
  `CCV_ASSERT(utab_one_writer, !(ule_cy02h && ufe_cy04h))
  `CCV_ASSERT(utab_margin, !((ufe_cy04h && ufi_cy04h == uli_cy02h) || (ufe_cy05h && ufi_cy05h == uli_cy02h)))
endmodule

module reference_twnoconf (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic       cle_in_cy01h,
  input  logic [2:0] cli_in_cy01h,
  input  logic       cfe_in_cy03h,
  input  logic [2:0] cfi_in_cy03h,
  input  logic [5:0] cfd_in_cy03h,
  output logic [5:0] crd_out_cy03h
);
  // The loop writer: a lookup at stage 02 reads the word and writes it back,
  // plus one, at the same port (its back edge is the table's own read).
  logic       cle_cy02h;
  logic [2:0] cli_cy02h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) cle_cy02h <= 1'b0;
    else              cle_cy02h <= cle_in_cy01h;
    cli_cy02h <= cli_in_cy01h;
  end
  // A later writer from another pipeline: a fill at stage 04, its data,
  // index and enable its own registers, muxed into the same port.
  logic       cfe_cy04h;
  logic [2:0] cfi_cy04h;
  logic [5:0] cfd_cy04h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) cfe_cy04h <= 1'b0;
    else              cfe_cy04h <= cfe_in_cy03h;
    cfi_cy04h <= cfi_in_cy03h;
    cfd_cy04h <= cfd_in_cy03h;
  end

  logic [5:0] ctab_cy03h [8];
  logic [5:0] crd_cy02h;
  assign crd_cy02h = ctab_cy03h[cli_cy02h];

  // The write port.
  logic       cpe_cy02h;
  logic [2:0] cpi_cy02h;
  logic [5:0] cpd_cy02h;
  assign cpe_cy02h = cle_cy02h | cfe_cy04h;
  assign cpi_cy02h = cfe_cy04h ? cfi_cy04h : cli_cy02h;
  assign cpd_cy02h = cfe_cy04h ? cfd_cy04h : crd_cy02h + 6'd1;
  always_ff @(posedge reference_core_clk) begin
    if (cpe_cy02h) ctab_cy03h[cpi_cy02h] <= cpd_cy02h;
  end
  always_ff @(posedge reference_core_clk) crd_out_cy03h <= crd_cy02h;

  // No write conflict at the port; no lookup reads a word the fill wrote in
  // that cycle or the next.
  logic       cfe_cy05h;
  logic [2:0] cfi_cy05h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) cfe_cy05h <= 1'b0;
    else              cfe_cy05h <= cfe_cy04h;
    cfi_cy05h <= cfi_cy04h;
  end
  `CCV_ASSERT(ctab_margin, !((cfe_cy04h && cfi_cy04h == cli_cy02h) || (cfe_cy05h && cfi_cy05h == cli_cy02h)))
endmodule

`undef CCV_CLK
`undef CCV_RST
