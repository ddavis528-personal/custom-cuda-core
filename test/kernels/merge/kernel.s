# merge: partial writes under rename, and the zero registers.
#
# P1 = tid < 16 switches lanes 16-31 off for the guarded writes. A guarded
# write keeps its inactive lanes' old value (ISA invariant 10); under rename
# that old value is a fourth source, carried to the lane as merge_data (A-33,
# A-44), and for predicates RCU merges itself (A-43). A launched warp's
# registers all start as the hardwired zero registers (A-64), so the first
# guarded write of R6 and of P2 merges from them, and C_ADD reads one.
        POR        P0, 4, 0             # P0 = all ones
        SRD        R1, 0                # tid
        MOVI       R2, 16
        SETP_LT    P1, R15, 0, R1, R2   # @P0 P1 = tid < 16
        ADD_P      R6, 1, R1, R2, R2    # @P1 R6 = tid + 16: first write, merges from the zero register
        ADD_P      R6, 5, R6, R1, R1    # @!P1 R6 += tid: merges from R6's old value
        C_ADD      R7, R1               # R7 += tid: R7 is still the zero register
        SETP_LT    P2, R15, 1, R1, R2   # @P1 P2 = tid < 16: first write, merges from the zero predicate
        C_EXIT     0
