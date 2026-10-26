# spmbank: .shared through SPM's banks (TI's rev 230). Lane l's word at
# 128 l lies in bank 0 for every lane, so its store and its load each take
# 32 passes; a word every lane names is one pass, its load a broadcast; a
# store every lane makes to one word keeps lane 31's; and 4 l is one pass.
        SRD        R1, 0                # tid
        C_MOV      R2, R1
        C_SHLI     R2, 7                # 128 tid: bank 0, word tid
        ST_SHARED  R1, R2, 0            # 32 passes
        LD_SHARED  R3, R2, 0            # 32 passes: R3 = tid
        MOVI       R4, 64
        ST_SHARED  R1, R4, 0            # one word, every lane: lane 31's wins
        LD_SHARED  R5, R4, 0            # one pass: R5 = 31 on every lane
        C_MOV      R6, R1
        C_SHLI     R6, 2                # 4 tid: one pass
        ST_SHARED  R3, R6, 8192
        LD_SHARED  R7, R6, 8192         # R7 = tid
        C_EXIT     0
