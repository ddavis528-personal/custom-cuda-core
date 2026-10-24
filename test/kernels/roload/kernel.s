# roload: loads are never F-RO (O-51): every lane reads the .const range
# and the launch window, and the kernel runs to its exit.
        POR        P0, 4, 0             # P0 = all ones
        MOVI48     R3, 5                # window 0x50000: .const
        MOVI48     R5, 2                # window 0x20000: the launch window
        SRD        R1, 0                # lane
        LD_GLOBAL_IDX R4, R3, R1, 1, 0  # [0x50000 + 4 lane]
        LD_GLOBAL  R6, R5, 0            # [0x20000]
        C_ADD      R4, R6
        C_EXIT     0
