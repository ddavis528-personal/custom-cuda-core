// case: packed struct on a block's port list
// expect_sim: SKIP
// expect_formal: SKIP
// runners: none
// aux: 36_packed_struct_port.aux.sv
//
// Probed out of band by the runner, because the question is not "does this
// simulate" but "what does the C++ model's boundary look like" -- which no
// testbench can answer.
//
// The interface convention §2 chooses packed structs over SystemVerilog
// `interface` constructs, on the argument that a packed struct keeps the
// define-once benefit and is a plain bit vector at the module boundary, so
// the tool presents it as one wide signal the C++ harness decomposes. §1's
// block-swap mechanism depends on that being true, so it is measured.
module blk (
  input  logic   clk,
  input  logic   rst,
  output issue_t iss,
  input  logic   iss_ready
);
  always_ff @(posedge clk) begin
    if (rst) iss <= '0;
    else begin
      iss.valid   <= iss_ready;
      iss.payload <= iss.payload + 1;
      iss.tag     <= iss.tag + 1;
    end
  end
endmodule
