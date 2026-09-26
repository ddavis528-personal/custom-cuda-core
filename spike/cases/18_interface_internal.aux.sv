interface ccv_rv_if (input logic clk, input logic rst);
  logic valid;
  logic ready;
  modport producer (output valid, input ready, input clk, input rst);
  modport consumer (input valid, output ready, input clk, input rst);
endinterface
