# rogated: F-RO is per lane and gated by the issue mask (ISA section 12.2):
# lanes 0-15 branch past the store, so only lanes 16-31 execute it, each to
# a word of its own inside the .const range. The fault names lanes 16-31 at
# lane 16's address, the lowest executing lane's.
        POR        P0, 4, 0             # P0 = all ones
        MOVI48     R3, 5                # window 0x50000
        SRD        R1, 0                # lane
        MOVI       R2, 16
        MOVI       R4, 77
        SETP_LT    P1, R15, 0, R1, R2   # @P0 P1 = lane < 16
        BRA_PRED   1, Ldone             # @P1: lanes 0-15 skip the store
        ST_GLOBAL_IDX R4, R3, R1, 1, 0  # lanes 16-31: faults
Ldone:
        C_EXIT     0
