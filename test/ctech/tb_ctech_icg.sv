//===-- tb_ctech_icg.sv - the ctech ICG, in event simulation --------------===//
//
// Spec: docs/clock-gate.md, "The ctech layer"
//
// Whichever view of ccv_ctech_icg the build compiles, driven with en and te
// that move at random -- in the low phase, in the high phase, anywhere but
// on an edge -- for 2000 cycles:
//
//   every gclk rise is at a clk rise and every gclk fall at a clk fall, so
//   no runt pulse, however the enable moved;
//   each clk rise passes exactly when en | te was high just before it --
//   the enable a latch transparent in the low phase would hold.
//
// With +define+VENDOR_REF the SkyWater sky130_fd_sc_hd__sdlclkp_1 model
// (test/ctech/vendor/, UDP latch and all) runs beside the DUT on the same
// inputs and every sample must agree: the simulation view is the cell.
// tools/check-ctech.sh runs it on Icarus and Verilator, and runs mutants of
// the simulation view that must fail it.
//
// Timing: clk edges at multiples of 5 ns; stimulus at k + 0.5 ns; samples at
// k + 0.25 and k + 0.75. Nothing coincides, so no check races an edge.
//===----------------------------------------------------------------------===//
`timescale 1ns/10ps
module tb;
  logic clk = 1'b0, en = 1'b0, te = 1'b0;
  wire  gclk;
  ccv_ctech_icg u_dut (.clk(clk), .en(en), .te(te), .gclk(gclk));
`ifdef VENDOR_REF
  wire  gclk_ref;
  sky130_fd_sc_hd__sdlclkp_1 u_ref (.CLK(clk), .GATE(en), .SCE(te), .GCLK(gclk_ref));
`endif

  localparam int CYCLES = 2000;
  int errors = 0, rises = 0, want_rises = 0, mid_high = 0, ref_cmp = 0;

  always #5 clk = ~clk;

  // No runt: gclk moves only where clk does, and is never high while clk is low.
  // Times are integers in 10 ps units, so the tests are exact.
  always @(posedge gclk) begin
    rises++;
    if ((longint'($realtime * 100) % 1000) != 500) begin
      errors++;
      if (errors < 5) $display("ICG_ERR gclk rose at %0.2f ns, not at a clk rise", $realtime);
    end
  end
  always @(negedge gclk) begin
    if ((longint'($realtime * 100) % 1000) != 0) begin
      errors++;
      if (errors < 5) $display("ICG_ERR gclk fell at %0.2f ns, not at a clk fall", $realtime);
    end
  end

  initial begin
    int unsigned seed;
    logic en_before;
    if (!$value$plusargs("seed=%d", seed)) seed = 1;
    void'($urandom(seed));
    // A clk rise at 10c + 5: en | te as it stood a quarter-ns before decides
    // it; a quarter-ns after, gclk must say so.
    fork
      for (int c = 0; c < CYCLES; c++) begin
        #4.75;
        en_before = en | te;
        #0.5;
        if (gclk !== en_before) begin
          errors++;
          if (errors < 5)
            $display("ICG_ERR cycle %0d: en|te=%b before the edge, gclk=%b after", c, en_before, gclk);
        end
        want_rises += en_before;
        #4.75;
      end
      // Stimulus at k + 0.5 ns, any phase. te is mostly low, as in function.
      for (int k = 0; k < CYCLES * 10; k++) begin
        #0.5;
        if ($urandom_range(3) == 0) begin
          en = $urandom_range(1);
          if ((k % 10) >= 5) mid_high++;
        end
        te = ($urandom_range(15) == 0);
        #0.5;
      end
`ifdef VENDOR_REF
      for (int k = 0; k < CYCLES * 20; k++) begin
        #0.25;
        ref_cmp++;
        if (gclk !== gclk_ref) begin
          errors++;
          if (errors < 5) $display("ICG_ERR %0.2f ns: view gclk=%b, sky130 cell gclk=%b",
                                   $realtime, gclk, gclk_ref);
        end
        #0.25;
      end
`endif
    join
    if (rises != want_rises) begin
      errors++;
      $display("ICG_ERR %0d gated edges, want %0d", rises, want_rises);
    end
    if (errors == 0) $display("ICG_OK cycles=%0d edges=%0d mid_high_changes=%0d ref_samples=%0d",
                              CYCLES, rises, mid_high, ref_cmp);
    else             $display("ICG_FAIL errors=%0d", errors);
    $finish;
  end
endmodule
