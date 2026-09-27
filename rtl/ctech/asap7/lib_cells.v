// Port declarations of the ASAP7 cells this view instantiates, so the view
// elaborates in this repository's checks without the PDK. Never part of a
// synthesis file list: there the library supplies the cells. Taken from the
// Liberty cell ICGx1_ASAP7_75t_R (asap7sc7p5t_SEQ_RVT); no Verilog model of it
// is vendored here, so the view is checked structurally, not in simulation.
(* blackbox *)
module ICGx1_ASAP7_75t_R (GCLK, CLK, ENA, SE);
  output GCLK;
  input  CLK;
  input  ENA;
  input  SE;
endmodule
