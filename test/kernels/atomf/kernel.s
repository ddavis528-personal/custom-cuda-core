# O-76: atom.add.f32. 32 lanes add to one word, on .global and on .shared;
# lane l's addend is window 12's word l (2^24 for lane 0, 1.0 for the rest).
# In ascending lane order, every 2^24 + 1 is a tie and rounds to even, so
# the sum stays 2^24 (0x4B800000), and every lane but 0 sees 2^24 as the old
# value. Any other order differs: lanes 31..1 first sum to 31, and 2^24 + 31
# rounds to 0x4B800010. Results:
#   window 13 (0xD0000): +0 the .global sum, +4 the .shared one
#   window 14 (0xE0000): lane l's old value from the .global add, at +4l
        SRD           R1, 0
        MOVI          R0, 0
        MOVI          R12, 12
        MOVI          R13, 13
        MOVI          R14, 14
        LD_GLOBAL_IDX R2, R12, R1, 1, 0
        ATOM_ADD_F_G  R3, R13, R0, 0, 0, R2
        ST_GLOBAL_IDX R3, R14, R1, 1, 0
        ATOM_ADD_F_S  R4, R0, R0, 0, 0, R2
        LD_SHARED     R5, R0, 0
        ST_GLOBAL     R5, R13, 4
        C_EXIT        0
