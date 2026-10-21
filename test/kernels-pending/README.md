# Kernels waiting on a decision

A kernel here is complete and matches ccv-sim, but the gate cannot hold it
clean until the decision it names is made; tools/gen-oracle.sh and every
check read test/kernels/ only. Move it back when the decision lands.

- `vadd4`: vadd over four CTAs, one warp each, side by side. Every register
  and memory word matches ccv-sim in every OOE mode, but with four warps
  decoding six uops a cycle against rename's four, the decode queue fills and
  a uop waits on ccv_dec_ooe_uop up to about 48 cycles: legal backpressure
  ("DEC sees a full queue as ordinary credit backpressure", OOE doc, Decode
  queue), over the bank's response bound, CCV_P_TIMEOUT_N = 32, which is
  provisional until contention data exists. TI-22 asks AR for the bound on a
  channel a downstream stall can backpressure.
