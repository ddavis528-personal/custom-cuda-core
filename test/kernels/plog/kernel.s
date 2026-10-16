# plog: predicate logic on real values (TI-1). pand, por and pxor read two
# predicates, and OOE renames them like any source: RCU gets their physical
# names in imm, each with its negate, not DEC's qualifiers. Every other
# kernel's only predicate logic is POR P0, 4, 0, which is all ones whatever
# it reads, so this one gives the path values that a wrong name or a lost
# negate would change.
#
# P1 = tid < 16, P2 = tid < 8, so P3 = !P1 | P2 holds for lanes 0-7 and
# 16-31. P3 then guards an add, so a wrong P3 shows in R6's lanes as well
# as in the final P3.
        POR        P0, 4, 0             # P0 = all ones
        SRD        R1, 0                # tid
        MOVI       R2, 16
        MOVI       R3, 8
        MOVI       R6, 7
        SETP_LT    P1, R15, 0, R1, R2   # @P0 P1 = tid < 16
        SETP_LT    P2, R15, 0, R1, R3   # @P0 P2 = tid < 8
        POR        P3, 5, 2             # P3 = !P1 | P2
        ADD_P      R6, 3, R1, R2, R2    # @P3 R6 = tid + 16; lanes 8-15 keep 7
        C_EXIT     0
