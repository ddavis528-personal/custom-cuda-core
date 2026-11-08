# coll: the warp collectives (O-85; ISA v1.9 section 3, "What the collectives
# compute"). Participating lanes are the issue mask AND the guard, and only
# they are written. A shuffle reads lane l - c (up), l + c (down), l ^ c
# (bfly) or c (idx), a source outside 0..31 keeping the lane's own value, and
# reads it whether or not that lane participates; the _R forms take c per
# lane from the low 5 bits of the index register. vote and ballot read one
# predicate over the participating lanes; unballot is diagonal, lane l's
# bit l of its own rs.
#
# P1 = tid < 16 guards half the ops, so the lanes 16-31 keep their old
# values, and a guarded shfl.down reads lanes 16-20, which do not
# participate. shfl.down.r by tid sends lanes 16-31 out of range.
        POR        P0, 4, 0             # P0 = all ones
        SRD        R1, 0                # tid
        MOVI       R2, 16
        MOVI       R3, 3
        MOVI       R5, 100
        C_ADD      R5, R1               # R5 = tid + 100, the data
        MOVI       R6, 7
        MOVI       R7, 7
        MOVI       R9, 7
        SETP_LT    P1, R15, 0, R1, R2   # @P0 P1 = tid < 16
        SHFL_UP    R6, 0, R5, 3         # R6 = R5[l - 3], lanes 0-2 their own
        SHFL_DOWN  R7, 1, R5, 5         # @P1 R7 = R5[l + 5]; lanes 16-31 keep 7
        SHFL_BFLY  R8, 0, R5, 7         # R8 = R5[l ^ 7]
        SHFL_IDX   R10, 0, R5, 9        # R10 = R5[9]
        SHFL_UP_R  R11, 0, R5, R3       # R11 = R5[l - 3], by register
        SHFL_DOWN_R R12, 0, R5, R1      # R12 = R5[2l]; lanes 16-31 their own
        SHFL_BFLY_R R13, 0, R5, R3      # R13 = R5[l ^ 3]
        SHFL_IDX_R R14, 0, R5, R1       # R14 = R5[l]
        VOTE_ANY   P2, 0, 1             # P2 = any(P1): all ones
        VOTE_ALL   P3, 0, 1             # P3 = all(P1): zero
        BALLOT     R9, 1, 1             # @P1 R9 = ballot(P1) = 0000ffff; 16-31 keep 7
        VOTE_ALL   P3, 1, 1             # @P1 P3 = all(P1) over lanes 0-15: ones there
        UNBALLOT   P2, 0, R12           # P2 lane l = bit l of lane l's R12 (100 + 2l under 16), not lane 0's
        C_EXIT     0
