# sel: a predicate read as DATA by a lane (the S1 second kernel).
#
# rd = P ? rs0 : rs1 on every issue-mask lane. pred_bit is the lane's
# ENABLE (issue mask AND guard), so sel's predicate travels separately as
# rcu_lane_ops.pred_data -- and half the lanes must choose rs1, which is what
# makes the bit observable. Output: c[tid] = tid < 16 ? tid : 16, at 0x50000.
        POR        P0, 4, 0          # P0 = all ones (Format K, unpredicated)
        MOVI48     R0, 5             # window 5 -> byte address 0x50000
        SRD        R1, 0             # tid
        MOVI       R2, 16
        SETP_LT    P0, R15, 0, R1, R2   # @P0 P0 = tid < 16
        SEL        R3, 0, R1, R2, R2    # @P0 sel R3, R1, R2 (rs2 unread)
        ST_GLOBAL_IDX R3, R0, R1, 1, 0  # c[tid]
        C_EXIT     0
