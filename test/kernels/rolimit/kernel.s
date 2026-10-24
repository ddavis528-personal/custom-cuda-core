# rolimit: the .const range's limit is exclusive. With [0x50000, 0x50004),
# lane 0's word at 0x50000, the limit less 4, faults, and lane 1's at
# 0x50004, the limit, does not (AR's rev 124 controls).
        POR        P0, 4, 0             # P0 = all ones
        MOVI48     R3, 5                # window 0x50000
        SRD        R1, 0                # lane
        MOVI       R4, 77
        ST_GLOBAL_IDX R4, R3, R1, 1, 0  # [0x50000 + 4 lane] = 77: lane 0 faults
        C_EXIT     0
