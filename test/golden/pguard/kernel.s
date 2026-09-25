# pguard: a guarded compare that writes a different predicate (Q-21).
#
# @P0 setp P1 reads its guard in P0 and writes P1, which the ISA encodes in
# separate fields (Format C: qualifier [29:27], destination [31:30]). The uop
# carries them separately too, as pred_guard and pred_dst. Lanes the guard
# disables keep P1's old value (a partial write preserves, ISA invariant 10),
# so P1 ends as tid < 8 on lanes 0-15 and tid < 24 on lanes 16-31, and the
# store makes it visible: c[tid] = P1 ? tid : 8, at 0x50000.
        POR        P0, 4, 0             # P0 = all ones (Format K, unpredicated)
        MOVI48     R0, 5                # window 5 -> byte address 0x50000
        SRD        R1, 0                # tid
        MOVI       R2, 24
        MOVI       R4, 16
        MOVI       R5, 8
        SETP_LT    P1, R15, 0, R1, R2   # @P0 P1 = tid < 24 (every lane)
        SETP_LT    P0, R15, 0, R1, R4   # @P0 P0 = tid < 16
        SETP_LT    P1, R15, 0, R1, R5   # @P0 P1 = tid < 8: guard P0, writes P1
        SEL        R3, 1, R1, R5, R5    # @P1 sel R3, R1, R5 (rs2 unread)
        ST_GLOBAL_IDX R3, R0, R1, 1, 0  # c[tid]
        C_EXIT     0
