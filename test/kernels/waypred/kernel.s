# waypred: two lines in one L1 set under two tags, re-read alternately
# (MI-9 (3); MA-26's way prediction, AR 390, OA-442).
#
# a[tid] = tid at 0x30000 and b[tid] = 100 + tid at 0x300000: a multiple of
# 64 KiB apart, the size of one way (512 sets of 128-byte lines), so both
# lines are set 0 under two tags, 3 and 48, and take two of its ways. The
# tags' XOR folds agree at 4 bits (3 = 0 ^ 3; MA-30) and at 1 (both even
# parity), so the predictor cannot tell the ways apart: it names the lowest
# matching way (index, AR 405), a's, so each re-read of b mispredicts. Each load's index is the load
# before it's result, less 100 after a b read, so each issues only once the
# one before it has answered and the reads run strictly in turn. After both fills, a and b are
# read in turn: a predictor that names the lowest matching way predicts a's
# way at each re-read of b.
        POR        P0, 4, 0             # P0 = all ones
        MOVI48     R0, 3                # a: window 0x30000
        MOVI48     R10, 48              # b: window 0x300000, the same set
        SRD        R1, 0                # tid
        LD_GLOBAL_IDX R2, R0, R1, 1, 0  # a[tid] = tid: misses, fills a way of set 0
        LD_GLOBAL_IDX R3, R10, R2, 1, 0 # b[tid] = 100 + tid: misses, fills another
        ADDI       R9, R3, -100         # tid again, after b
        LD_GLOBAL_IDX R4, R0, R9, 1, 0  # a: the set last used b's way
        LD_GLOBAL_IDX R5, R10, R4, 1, 0 # b: last used a's
        ADDI       R11, R5, -100
        LD_GLOBAL_IDX R6, R0, R11, 1, 0 # a
        LD_GLOBAL_IDX R8, R10, R6, 1, 0 # b
        C_ADD      R7, R3
        C_ADD      R7, R4
        C_ADD      R7, R5
        C_ADD      R7, R6
        C_ADD      R7, R8               # acc = 3 * (100 + tid) + 2 * tid
        C_EXIT     0
