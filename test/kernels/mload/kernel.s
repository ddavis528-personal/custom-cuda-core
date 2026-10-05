# mload: masked loads, whose inactive lanes keep their old value through a
# copy-only op (A-33, A-38).
#
# A load's data reaches the register file from MIU, active lanes only, and
# rcu_miu_data carries no merge fields. Under rename the destination is a
# fresh register, so the inactive lanes' old values are copied into it by a
# second op OOE issues with the load: CCV_OP_PRF_COPY, through a lane, the
# old destination as merge_data, written on the inactive lanes only.
#
# P1 = tid < 16. R5 holds 100 + tid before the first load, so each inactive
# lane keeps a different value; R8 is unwritten, so the second load's copy
# is from the zero register. C_ADD then reads every lane of R5, copied lanes
# included.
        POR        P0, 4, 0             # P0 = all ones
        MOVI48     R0, 5                # window 0x50000
        SRD        R1, 0                # tid
        MOVI       R2, 16
        MOVI       R5, 100
        C_ADD      R5, R1               # R5 = 100 + tid
        SETP_LT    P1, R15, 0, R1, R2   # @P0 P1 = tid < 16
        LD_GLOBAL_P R5, 1, R0, 0        # @P1 R5 = [0x50000]: lanes 16-31 keep 100 + tid
        LD_GLOBAL_P R8, 5, R0, 4        # @!P1 R8 = [0x50004]: lanes 0-15 keep zero
        C_ADD      R5, R1               # reads the copied lanes
        C_EXIT     0
