// Hard-macro fixture (AR register rev 344; docs/rtl-coding-style.md, "Hard
// macros"): one module that instantiates each SRAM macro at a realistic
// size, for tools/check-ngd.py's and tools/check-cg.py's selftests, whose
// controls are this same module at other parameters.
//
// A command arrives as the bench's in_v, and its word in_d the cycle after
// (tb_sram_fx.sv), so the flopped valid v_q is the enable that captures it
// (CG-5), and c_q, a cycle later, is the command's valid beside the captured
// op_q. Each command is one access to each macro:
//   1rw  (W x D, 64 Kibit by default): op_q[15] writes, else reads, at
//        op_q[6:0] + ptr_q -- the index through an adder -- with a byte
//        mask from op_q[14:8].
//   1r1w (W2 x D2): writes op_q[14] at waddr op_q's low bits ^ ptr_q, and
//        reads at op_q's low bits every command, so a read can meet the
//        write to its own word (read before write).
// Read data comes back the cycle after (rv_q, rv2_q) and folds into acc_q
// and acc2_q through an XOR tree of the whole word; out_q, its own register
// (NGD-7), carries the two out.
//
// The parameters that make the controls, each 0 in the compliant fixture:
//   MACRO = 0     every macro replaced by the same array inferred here, as
//                 flops: check-ngd's flop-array control
//   EN_IN bit 0   the 1rw's ce from input in_v, not a flop; bit 1, the
//                 1r1w's re; bit 2, the 1rw's we: check-cg's CG-5 controls
//   DEEP_IDX = 1  the 1rw's index through a 16 x 16 multiply: an input
//                 pin is an endpoint, so check-ngd counts the logic to it
//   DEEP_RD = 1   the 1rw's read data through a multiply into acc_q:
//                 rdata launches at 0 and what follows it counts
//   RST_CE = 1    the 1rw's ce gated by the flopped reset: check-cg's RST-2
//                 then sees the reset reach the macro's pin, as it would a
//                 flop's D (a macro has no reset, so it is otherwise none)
module sram_fx #(
  parameter int MACRO = 1,
  parameter int EN_IN = 0,
  parameter int DEEP_IDX = 0,
  parameter int DEEP_RD = 0,
  parameter int RST_CE = 0,
  parameter int W = 512,
  parameter int D = 128,
  parameter int W2 = 64,
  parameter int D2 = 128
) (
  input  logic        clk,
  input  logic        rst,
  input  logic        in_v,
  input  logic [15:0] in_d,
  output logic        out_v,
  output logic [15:0] out_d
);
  localparam int AW = $clog2(D);
  localparam int AW2 = $clog2(D2);

  logic        rst_q, v_q, c_q, rv_q, rv2_q, o_v_q;
  logic [15:0] op_q;
  logic [AW-1:0] ptr_q;
  logic [15:0] acc_q, acc2_q, out_q;
  wire         ld_en = v_q;

  always_ff @(posedge clk) begin
    rst_q <= rst;
    v_q   <= in_v;
    c_q   <= v_q;
    rv_q  <= c_q & ~op_q[15];
    rv2_q <= c_q;
    o_v_q <= rv_q | rv2_q;
  end

  always_ff @(posedge clk) begin
    if (ld_en) op_q <= in_d;
  end

  always_ff @(posedge clk) begin
    if (rst_q)      ptr_q <= '0;
    else if (ld_en) ptr_q <= ptr_q + 1'b1;
  end

  // -- the 1rw: index, controls and write data ---------------------------
  logic [AW-1:0]  addr;
  logic [31:0]    prod;
  assign prod = {op_q, ptr_q[AW-1:0], op_q[AW-1:0], 2'b01} * {op_q[7:0], op_q[15:8], ~op_q};
  assign addr = DEEP_IDX != 0 ? prod[16 +: AW] : op_q[AW-1:0] + ptr_q;
  wire            ce = EN_IN[0] ? in_v : RST_CE != 0 ? c_q & ~rst_q : c_q;
  wire            we = EN_IN[2] ? in_v : op_q[15];
  logic [W-1:0]   wdata;
  wire [W/8-1:0]  wmask = {(W / 64){op_q[14:8], 1'b1}};
  logic [W-1:0]   rdata;

  // -- the 1r1w ------------------------------------------------------------
  wire            re2 = EN_IN[1] ? in_v : c_q;
  wire            we2 = c_q & op_q[14];
  wire [AW2-1:0]  raddr2 = op_q[AW2-1:0];
  wire [AW2-1:0]  waddr2 = op_q[AW2-1:0] ^ ptr_q[AW2-1:0];
  logic [W2-1:0]  wdata2;
  wire [W2/8-1:0] wmask2 = {(W2 / 8){1'b1}} ^ {{(W2 / 8 - 1){1'b0}}, op_q[13]};
  logic [W2-1:0]  rdata2;

  // Write data: every bit its own parity of the command and the pointer,
  // by a fixed hash of its position, so no two columns of a flop array
  // hold the same function and synthesis merges none of them (an array of
  // repeated slices would shrink to a few columns and prove nothing).
  function automatic logic [22:0] mix(input int i);
    logic [31:0] h;
    h = 32'(i) * 32'h9e3779b1;
    h = h ^ (h >> 15);
    h = h * 32'h85ebca6b;
    h = h ^ (h >> 13);
    mix = h[22:0] | 23'h1;
  endfunction
  wire [22:0] din = 23'({ptr_q, op_q});
  for (genvar i = 0; i < W; i++) begin : g_wd
    assign wdata[i] = ^(din & mix(i));
  end
  for (genvar i = 0; i < W2; i++) begin : g_wd2
    assign wdata2[i] = ^(din & mix(W + i));
  end

  if (MACRO != 0) begin : g_macro
    ccv_common_sram_1rw #(.W(W), .D(D)) u_sram (
      .clk, .ce, .we, .addr, .wdata, .wmask, .rdata);
    ccv_common_sram_1r1w #(.W(W2), .D(D2)) u_sram2 (
      .clk, .re(re2), .raddr(raddr2), .rdata(rdata2),
      .we(we2), .waddr(waddr2), .wdata(wdata2), .wmask(wmask2));
  end else begin : g_flops
    // The same arrays as flops: ccv_common_sram_1rw's and _1r1w's bodies.
    logic [W-1:0]  mem_q [D];
    logic [W-1:0]  rdata_q;
    logic [W2-1:0] mem2_q [D2];
    logic [W2-1:0] rdata2_q;
    wire           wr_en = ce & we, rd_en = ce & ~we;
    wire           wr2_en = we2, rd2_en = re2;
    always_ff @(posedge clk) begin
      if (wr_en) begin
        for (int b = 0; b < W / 8; b++) begin
          if (wmask[b]) mem_q[addr][b*8 +: 8] <= wdata[b*8 +: 8];
        end
      end
    end
    always_ff @(posedge clk) begin
      if (rd_en) rdata_q <= mem_q[addr];
    end
    always_ff @(posedge clk) begin
      if (wr2_en) begin
        for (int b = 0; b < W2 / 8; b++) begin
          if (wmask2[b]) mem2_q[waddr2][b*8 +: 8] <= wdata2[b*8 +: 8];
        end
      end
    end
    always_ff @(posedge clk) begin
      if (rd2_en) rdata2_q <= mem2_q[raddr2];
    end
    assign rdata = rdata_q;
    assign rdata2 = rdata2_q;
  end

  // -- read data into logic, into a flop -----------------------------------
  // Each bit j of a fold is the XOR of bit j of every 16-bit slice, a
  // reduction (a balanced tree), not a chain.
  logic [15:0] rd, rd2, rmul;
  for (genvar j = 0; j < 16; j++) begin : g_fold
    logic [W/16-1:0]  col;
    logic [W2/16-1:0] col2;
    for (genvar k = 0; k < W / 16; k++) begin : g_k
      assign col[k] = rdata[k*16 + j];
    end
    for (genvar k = 0; k < W2 / 16; k++) begin : g_k2
      assign col2[k] = rdata2[k*16 + j];
    end
    assign rd[j]  = ^col;
    assign rd2[j] = ^col2;
  end
  assign rmul = rd * rdata[W-1 -: 16];
  wire  [15:0] rd_use = DEEP_RD != 0 ? rmul : rd;
  wire         acc_en = rv_q, acc2_en = rv2_q, out_en = o_v_q;

  always_ff @(posedge clk) begin
    if (acc_en) acc_q <= {acc_q[14:0], ~acc_q[15]} ^ rd_use;
  end
  always_ff @(posedge clk) begin
    if (acc2_en) acc2_q <= {acc2_q[14:0], ~acc2_q[15]} ^ rd2;
  end
  always_ff @(posedge clk) begin
    if (out_en) out_q <= acc_q ^ acc2_q;
  end

  assign out_v = o_v_q;
  assign out_d = out_q;
endmodule
