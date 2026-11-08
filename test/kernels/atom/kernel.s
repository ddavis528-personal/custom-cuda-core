# Format M atomics, executed (O-72): the base + index address and the RMW
# forms on .global and .shared, from the compiler's test/atomics.s with CAS
# left out (OOE's A2 writes no predicate yet; TI's row to OI). 32 lanes; R1
# is the lane's index. Results:
#   window 9  (0x90000): +0 the add counter, +4 max.s, +8 min.u, +12 xor
#   window 8  (0x80000): lane l's old value from the add, at +4l
#   window 10 (0xA0000): lane l's word, exchanged for 3l, at +4l
#   window 12 (0xC0000): lane l's old value from the exchange, at +4l
#   window 11 (0xB0000): lane l's old value from the .shared add, at +4l;
#                        at +0x100, the shared word after the or
        PMOV_IMM   P3, 1
        SRD        R1, 0               # lane index
        MOVI       R0, 0
        MOVI       R9, 9
        MOVI       R8, 8
        MOVI       R10, 10
        MOVI       R11, 11
        MOVI       R12, 12
        MOVI       R2, 1
        # add: every lane adds 1 to one word; lane l sees l (ascending order)
        ATOM_ADD_G R3, R9, R0, 0, 0, R2
        ST_GLOBAL_IDX R3, R8, R1, 1, 0
        # max.s of l - 16 over -100 is 15, at +4 (displacement)
        ADDI       R4, R1, -16
        ATOM_MAX_S_G R5, R9, R0, 0, 4, R4
        # min.u of l + 5 over 1000 is 5, at +8 (index 2, scaled)
        MOVI       R7, 2
        ADDI       R4, R1, 5
        ATOM_MIN_U_G R5, R9, R7, 1, 0, R4
        # xor of l mod 8 at +12 (index 9, displacement 3): each value is
        # xored in four times, so the word comes back as it was
        MOVI       R7, 9
        ANDI       R5, R1, 7
        ATOM_XOR_G R6, R9, R7, 0, 3, R5
        # exch at a computed element: lane l's word for 3l, scaled index
        MULI       R4, R1, 3
        ATOM_EXCH_G R6, R10, R1, 1, 0, R4
        ST_GLOBAL_IDX R6, R12, R1, 1, 0
        # add on .shared word 1: every lane adds l + 1; lane l sees l(l+1)/2
        ADDI       R4, R1, 1
        ATOM_ADD_S R6, R0, R0, 0, 4, R4
        ST_GLOBAL_IDX R6, R11, R1, 1, 0
        # or of l into .shared word 0: 31
        ATOM_OR_S  R6, R0, R0, 0, 0, R1
        LD_SHARED  R5, R0, 0
        ST_GLOBAL  R5, R11, 256
        C_EXIT     0
