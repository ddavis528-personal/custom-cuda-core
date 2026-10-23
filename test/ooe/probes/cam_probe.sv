// Depth probe (ooe_rename slice 1): the producer lookup as a compare over
// the RS entries' names (each entry's GPR and predicate destination,
// written with its allocation) instead of a map indexed by name. A source
// name's producers are the entries valid, not allocated at the last edge
// (their names not yet written), whose name matches: the dependency row's
// bits directly, one-hot, no map and no decode. L lookups of LG-bit names.
module cam_probe #(parameter int N = 45, parameter int L = 16, parameter int LG = 10) (
  input  logic [N-1:0]    valid,     // ooe_rs's valid bits
  input  logic [N-1:0]    fresh,     // allocated at the last edge (the registered grant)
  input  logic [N-1:0]    ew,        // entry e's occupant writes a name
  input  logic [N*LG-1:0] en,        // and the name
  input  logic [L-1:0]    lv,        // lookup l is used
  input  logic [L*LG-1:0] ln,        // its name
  output logic [L*N-1:0]  row        // lookup l's producers
);
  always_comb
    for (int l = 0; l < L; l++)
      for (int e = 0; e < N; e++)
        row[l * N + e] = lv[l] && valid[e] && !fresh[e] && ew[e] && en[e * LG +: LG] == ln[l * LG +: LG];
endmodule
