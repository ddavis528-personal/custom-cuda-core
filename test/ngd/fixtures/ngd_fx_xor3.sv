// check-ngd fixture: a carry-save tree, nine 8-bit operands to a sum and a
// carry, which ABC maps onto the genlib's XOR3, each level's late operand on
// its fast pin C. The selftest times it again with every gate at its slowest
// pin, which must disagree with ABC: the timing pass is per pin.
// tools/check-ngd.py --selftest.
module ngd_fx_xor3 (
  input  logic       clk,
  input  logic [71:0] x,
  output logic [7:0] s,
  output logic [7:0] c
);
  logic [71:0] x_q;
  logic [7:0]  s_q, c_q;
  logic [7:0]  o [0:8];
  logic [7:0]  l1s [0:2], l1c [0:2], l2s, l2c, l3s, l3c, l4s, l4c;
  always_comb begin
    for (int i = 0; i < 9; i++) o[i] = x_q[i*8 +: 8];
    for (int i = 0; i < 3; i++) begin
      l1s[i] = o[3*i] ^ o[3*i+1] ^ o[3*i+2];
      l1c[i] = ((o[3*i] & o[3*i+1]) | (o[3*i] & o[3*i+2]) | (o[3*i+1] & o[3*i+2])) << 1;
    end
    l2s = l1s[0] ^ l1s[1] ^ l1s[2];
    l2c = ((l1s[0] & l1s[1]) | (l1s[0] & l1s[2]) | (l1s[1] & l1s[2])) << 1;
    l3s = l1c[0] ^ l1c[1] ^ l1c[2];
    l3c = ((l1c[0] & l1c[1]) | (l1c[0] & l1c[2]) | (l1c[1] & l1c[2])) << 1;
    l4s = l2s ^ l2c ^ l3s;
    l4c = ((l2s & l2c) | (l2s & l3s) | (l2c & l3s)) << 1;
  end
  always_ff @(posedge clk) begin
    x_q <= x;
    s_q <= l4s ^ l4c ^ l3c;
    c_q <= ((l4s & l4c) | (l4s & l3c) | (l4c & l3c)) << 1;
  end
  assign s = s_q;
  assign c = c_q;
endmodule
