# rolaunch: the whole launch window, window 2, is read-only (ISA section 5.2,
# O-61), with no .const range set: a store to 0x20040, past every word a
# kernel pokes, faults F-RO on every lane.
        POR        P0, 4, 0             # P0 = all ones
        MOVI48     R3, 2                # window 0x20000: the launch window
        MOVI       R7, 0
        MOVI       R4, 77
        ST_GLOBAL_IDX R4, R3, R7, 1, 64 # [0x20040] = 77: faults
        C_EXIT     0
