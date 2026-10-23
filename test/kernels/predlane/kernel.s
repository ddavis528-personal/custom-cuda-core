# predlane: a predicate transfer's address is lane 0's rbase, whether or not
# lane 0 is in the issue mask (O-62; TI-36). rbase is 9 + lane, non-uniform,
# whose result invariant 3 makes lane 0's: lanes 16-31 store P1 to window 9,
# not to window 25, the lowest of their own.
        SRD          R1, 0              # lane index
        MOVI48       R3, 9              # window 9 ...
        C_ADD        R3, R1             # ... + lane: rbase differs per lane
        SETP_LT_NPI  P0, R14, R1, 16    # lanes 0-15
        POR          P1, 5, 1           # P1 = all ones
        BRA_PRED     0, join            # lanes 0-15 skip the store
        ST_PRED_G    2, R3, 12          # P1 to lane 0's window 9, +16: lanes 16-31's bits
        POR          P1, 0, 0           # P1 = P0, in lanes 16-31 alone: they clear
join:   ST_PRED_G    2, R3, 44          # all lanes: P1 over +48's poked ones, every
                                        # bit written, the clear ones too, since P1 is
                                        # data, not a guard
        C_EXIT       0
