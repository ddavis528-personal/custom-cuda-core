# gather: lane addresses in no simple order.
#
#   R3 = 33 * tid   one line per lane: 32 line requests for one load, more
#                   than MIU has request ids to DCU, so ids are reused
#   R6 = 31 - tid   one line, lanes in reverse address order
#   zero index      every lane the same word (broadcast)
# The scattered store then writes one word into each of 32 lines, a 4-byte
# byte mask in each.
        POR        P0, 4, 0             # P0 = all ones
        MOVI48     R0, 3                # a: window 0x30000
        MOVI48     R5, 5                # c: window 0x50000
        SRD        R1, 0                # tid
        MOVI       R2, 33
        MADLO      R3, R1, R2, R4       # R3 = 33 * tid (R4 unwritten: zero)
        MOVI       R2, 31
        MOVI48     R7, 0xffffffff       # -1
        MADLO      R6, R1, R7, R2       # R6 = 31 - tid
        LD_GLOBAL_IDX R8, R0, R3, 1, 0    # a[33 * tid]
        LD_GLOBAL_IDX R9, R0, R6, 1, 0    # a[31 - tid]
        LD_GLOBAL_IDX R10, R0, R4, 1, 8   # a[2], every lane
        C_ADD      R8, R9
        C_ADD      R8, R10
        ST_GLOBAL_IDX R8, R5, R3, 1, 0    # c[33 * tid]
        C_EXIT     0
