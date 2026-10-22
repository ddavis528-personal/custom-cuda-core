# slotform: Format D's launch-slot form (O-45; TI-31) and a per-lane base
# (TI-32). Slots 0 and 13 sit in the two lines of the launch block's slot
# area, so MIU fills its window table twice; slot 1's window is stored to.
# R6 is a window per lane, an O-30 frame pointer's shape: its store and
# load touch 32 lines in 32 windows.
        SRD        R1, 0                # lane
        LD_GLOBAL_SLOT R4, 0, R1, 1, 0  # [win(slot 0) + 4 lane]
        LD_GLOBAL_SLOT R5, 13, R1, 1, 4 # [win(slot 13) + 4 lane + 4]
        C_ADD      R4, R5
        ST_GLOBAL_SLOT R4, 1, R1, 1, 0  # [win(slot 1) + 4 lane]
        MOVI       R6, 96               # window 0x60 ...
        C_ADD      R6, R1               # ... + lane
        ST_GLOBAL  R4, R6, -4           # [((0x60 + lane) << 16) - 4]
        LD_GLOBAL  R7, R6, -4
        C_ADD      R7, R4
        ST_GLOBAL_SLOT R7, 1, R1, 1, 128  # [win(slot 1) + 4 lane + 128]
        C_EXIT     0
