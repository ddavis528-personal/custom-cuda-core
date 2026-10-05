# unal: warp accesses that are not line-aligned (128-byte lines).
#
# A warp's 32 consecutive words are one line only when they start on a line
# boundary. Each access here starts mid-line, so one instruction touches two
# lines, split at a different lane each time: MIU asks DCU for both, and puts
# each lane's word together from the line it falls in. The store writes a
# partial byte mask on each of its two lines.
        POR        P0, 4, 0             # P0 = all ones
        MOVI48     R0, 3                # a: window 0x30000
        MOVI48     R5, 5                # c: window 0x50000
        SRD        R1, 0                # tid
        LD_GLOBAL_IDX R8, R0, R1, 1, 20   # a[tid + 5]: lanes 0-26 in line 0, 27-31 in line 1
        LD_GLOBAL_IDX R9, R0, R1, 1, 124  # a[tid + 31]: lane 0 in line 0, lanes 1-31 in line 1
        C_ADD      R8, R9
        ST_GLOBAL_IDX R8, R5, R1, 1, 68   # c[tid + 17]: lanes 0-14 in line 0, 15-31 in line 1
        C_EXIT     0
