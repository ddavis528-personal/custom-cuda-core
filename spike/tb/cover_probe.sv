// Cover cases need a different question asked of them: not "did it fire" but
// "was it reached". Neither simulator reports cover hits on stdout by default,
// so the runner asks each tool for its own coverage output and this file just
// documents where that lives:
//
//   With Verilator: --coverage-user, then a nonzero count in logs/coverage.dat
//   Icarus    : no cover-property support expected; see the matrix
//
// Kept as a file rather than a comment in the runner so the asymmetry is
// visible next to the cases it applies to.
