// ccv_secded.svh - the SECDED code's parity-check matrix, as a constant
// function, included inside ccv_common_secded_enc, _syn and _fix (one
// code for all three; sim/skel/secded.h is the same in C++).
//
// Data bit i's column is the i-th R-bit vector of odd weight 3 or more,
// taken by weight (3, 5, ...) and then by value; check bit j's is the unit
// vector j.

function automatic integer ccv_secded_pop(input integer v, input integer r);
  integer b;
  begin
    ccv_secded_pop = 0;
    for (b = 0; b < r; b = b + 1) ccv_secded_pop = ccv_secded_pop + ((v >> b) & 1);
  end
endfunction

// Row j of the data part: bit i set when data bit i's column has bit j.
function automatic [1023:0] ccv_secded_row(input integer k, input integer r, input integer j);
  integer n, w, v;
  begin
    ccv_secded_row = '0;
    n = 0;
    for (w = 3; w <= r; w = w + 2)
      for (v = 0; v < (1 << r); v = v + 1)
        if (n < k && ccv_secded_pop(v, r) == w) begin
          ccv_secded_row[n] = ((v >> j) & 1) != 0;
          n = n + 1;
        end
  end
endfunction
