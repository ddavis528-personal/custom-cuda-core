# roconst: a store into the module's .const range faults F-RO (O-51, O-61;
# AR's response TI-26). With the range [0x50000, 0x50006), lane i stores to
# 0x50000 + 4i: lane 0's word lies inside, lane 1's starts inside and ends
# past the limit (any byte counts), and lane 2's starts past it. So the
# fault names lanes 0 and 1 at 0x50000, and the instruction has no effect
# on any lane: lane 2's and above's words keep their poked values.
        POR        P0, 4, 0             # P0 = all ones
        MOVI48     R3, 5                # window 0x50000
        SRD        R1, 0                # lane
        MOVI       R4, 77
        ST_GLOBAL_IDX R4, R3, R1, 1, 0  # [0x50000 + 4 lane] = 77: faults
        C_EXIT     0
