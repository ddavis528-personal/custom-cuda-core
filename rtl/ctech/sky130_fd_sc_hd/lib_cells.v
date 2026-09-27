// Port declarations of the sky130_fd_sc_hd cells this view instantiates, so
// the view elaborates in this repository's checks without the PDK. Never part
// of a synthesis file list: there the library supplies the cells.
// tools/check-ctech.sh checks these ports against the vendored cell model.
(* blackbox *)
module sky130_fd_sc_hd__sdlclkp_1 (GCLK, SCE, GATE, CLK);
  output GCLK;
  input  SCE;
  input  GATE;
  input  CLK;
endmodule
