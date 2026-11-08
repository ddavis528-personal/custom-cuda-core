# CAS, executed (O-72, IS-21; OI-127): Format M's 48-bit compare-and-swap on
# .global and .shared, the form test/kernels/atom leaves out. rd takes the
# old word; where it equals rs_cmp the word becomes rs_swap, and pd is set;
# otherwise pd is clear. Every pd is read back by a guarded add, so a wrong
# one is a stored word that differs from ccv-sim's. 32 lanes; R1 is the
# lane's index. Results:
#   window 8  (0x80000): +0 the chain's word (32), +4 the one-winner's (1)
#   window 9  (0x90000): lane l's old value: the chain at +4l (l), the
#                        one-winner at +128+4l (lane 0's 0, then 1)
#   window 10 (0xA0000): lane l's own word, at +4l
#   window 11 (0xB0000): lane l's pd as 0/1, at +128k+4l for CAS k (0-5)
#   window 12 (0xC0000): lane l's old value, at +128k+4l for CAS k (2-5),
#                        and at +0x300 and +0x304 the two .shared words
        POR        P0, 4, 0            # P0 = all ones, the unguarded CASes' guard
        SRD        R1, 0               # lane index
        MOVI       R0, 0
        MOVI       R8, 8
        MOVI       R9, 9
        MOVI       R10, 10
        MOVI       R11, 11
        MOVI       R12, 12
        ADDI       R4, R1, 1
        # 0. .global, contended, a chain: lane l compares l and swaps l + 1.
        # In ascending lane order every lane succeeds, and the word ends 32.
        CAS_G      R6, P1, 0, R8, R0, 0, 0, R1, R4
        ST_GLOBAL_IDX R6, R9, R1, 1, 0
        MOVI       R5, 0
        ADDI_P     R5, 1, R5, 1        # @P1 R5 = 1
        ST_GLOBAL_IDX R5, R11, R1, 1, 0
        # 1. .global, contended, one winner: every lane compares 0 and swaps
        # l + 1 at +4. Lane 0 alone succeeds; every other lane reads 1.
        CAS_G      R6, P1, 0, R8, R0, 0, 4, R0, R4
        ADDI       R7, R1, 32
        ST_GLOBAL_IDX R6, R9, R7, 1, 0
        MOVI       R5, 0
        ADDI_P     R5, 1, R5, 1
        ST_GLOBAL_IDX R5, R11, R7, 1, 0
        # 2. .global, uncontended: lane l's own word (0), scaled index l. The
        # odd lanes compare 0 and succeed, the even ones compare 1 and fail;
        # each swaps 100 + l.
        MOVI       R2, 1
        ANDI       R5, R1, 1
        SUB        R5, R2, R5, R5      # 1 - (l & 1) (rs2 unread)
        ADDI       R4, R1, 100
        CAS_G      R6, P2, 0, R10, R1, 1, 0, R5, R4
        ADDI       R7, R1, 64
        ST_GLOBAL_IDX R6, R12, R7, 1, 0
        MOVI       R5, 0
        ADDI_P     R5, 2, R5, 1        # @P2 R5 = 1
        ST_GLOBAL_IDX R5, R11, R7, 1, 0
        # 3. .global, guarded @P1 on lanes 0-15, so OOE merges rd and pd from
        # their old names (A-43): every guarded lane compares 0, so its even
        # lanes succeed, its odd ones (100 + l) fail; each swaps 200 + l.
        # Lanes 16-31 keep R6 and P2 from CAS 2, the odd ones set.
        SETP_LT_NPI P1, R14, R1, 16    # lanes 0-15
        ADDI       R4, R1, 200
        CAS_G      R6, P2, 1, R10, R1, 1, 0, R0, R4
        ADDI       R7, R1, 96
        ST_GLOBAL_IDX R6, R12, R7, 1, 0
        MOVI       R5, 0
        ADDI_P     R5, 2, R5, 1
        ST_GLOBAL_IDX R5, R11, R7, 1, 0
        # 4. .shared word 0, contended, one winner: 0 -> l + 1, lane 0 alone.
        ADDI       R4, R1, 1
        CAS_S      R6, P1, 0, R0, R0, 0, 0, R0, R4
        ADDI       R7, R1, 128
        ST_GLOBAL_IDX R6, R12, R7, 1, 0
        MOVI       R5, 0
        ADDI_P     R5, 1, R5, 1
        ST_GLOBAL_IDX R5, R11, R7, 1, 0
        # 5. .shared word 1, contended, the chain: every lane succeeds.
        CAS_S      R6, P2, 0, R0, R0, 0, 4, R1, R4
        ADDI       R7, R1, 160
        ST_GLOBAL_IDX R6, R12, R7, 1, 0
        MOVI       R5, 0
        ADDI_P     R5, 2, R5, 1
        ST_GLOBAL_IDX R5, R11, R7, 1, 0
        LD_SHARED  R5, R0, 0
        ST_GLOBAL  R5, R12, 768
        LD_SHARED  R5, R0, 4
        ST_GLOBAL  R5, R12, 772
        C_EXIT     0
