# retmiss (RI-18): tgt[lane] at 0x30000, each lane's return address, comes
# from a load that misses, and the ret reads it directly: OOE issues the
# ret on the load's speculated hit, on stale lanes, and replays it when the
# hit does not come. Every third lane returns to plus7, the rest to
# triple1: two passes. Results land at 0x70000, one word per lane.
        POR        P0, 4, 0             # P0 = all ones
        SRD        R2, 0                # lane
        MOVI48     R0, 3                # tgt: window 0x30000
        LD_GLOBAL_IDX R5, R0, R2, 1, 0  # tgt[lane]: a miss
        C_MOV      R1, R2
        CALL       R14, stub            # link in R14, then ret R5
        MOVI48     R3, 7
        ST_GLOBAL_IDX R1, R3, R2, 1, 0
        C_EXIT     0
stub:   C_RET      80                   # ret R5, the loaded word
triple1: MULI      R1, R1, 3
        ADDI       R1, R1, 1
        C_RET      224                  # ret R14
plus7:  ADDI       R1, R1, 7
        C_RET      224
