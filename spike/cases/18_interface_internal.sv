// case: SystemVerilog interface + modport, internal to a block
// expect_sim: CHECK
// expect_formal: CHECK
// aux: 18_interface_internal.aux.sv
//
// §9's interface-style question, inner half. The top-level port list stays
// plain, so this measures only whether interfaces elaborate and carry
// assertions. The block-SWAP half -- an interface on the top-level boundary,
// which is the one §1's swap mechanism actually cares about -- is measured
// out of band by the runner, because a tool that cannot do it also cannot be
// given this testbench.
module dut (input logic clk, input logic rst, input logic a, input logic b, output logic o);
  ccv_rv_if ifc (.clk(clk), .rst(rst));
  assign ifc.valid = a;
  assign ifc.ready = b;
  assign o         = ifc.valid & ifc.ready;
  a_if: assert property (@(posedge clk) disable iff (rst) ifc.valid |-> ifc.ready)
    else $error("18: interface-borne property fired");
endmodule
