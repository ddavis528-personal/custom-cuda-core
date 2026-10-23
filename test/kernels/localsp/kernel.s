# localsp: O-69's interleaved spill space (IS-19), two warps in contexts 0
# and 1. local_base is window 256 (launch-block word 24), so the space starts
# at window 256 + CCV_LANE_CONTEXTS, and context c's frame 4c MiB above it.
# Each lane spills two words, word 2 (b = 8) and word 1025 (b = 4100), reloads
# them and stores their sum to window 9 at 4 * %lanectx: lane + 2 * ctaid.
# A context's frame is its own: dropped ctx, both warps spill to one frame.
# P1 (lanes 0-15) goes to the frame's predicate words at b = 16 through
# st.pred.local, is cleared, and comes back through ld.pred.local; @P1 then
# writes 7 to window 10 at 4 * %lanectx, the other lanes 0.
        SRD          R1, 0              # lane index
        SRD          R8, 1              # %ctaid: the warp's CTA, 0 or 1
        SRD          R7, 2              # %lanectx: (ctx << 5) | lane
        MOVI48       R9, 9              # result window
        MOVI48       R11, 10            # predicate result window
        ADD          R2, R1, R8, R8     # lane + ctaid (rs2 unread)
        ST_LOCAL     R2, 8              # word 2: the frame's line 2
        ST_LOCAL     R8, 4100           # word 1025: its line 1025
        LD_LOCAL     R3, 8
        LD_LOCAL     R4, 4100
        ADD          R5, R3, R4, R4     # lane + 2 * ctaid (rs2 unread)
        ST_GLOBAL_IDX R5, R9, R7, 1, 0  # [0x90000 + 4 lanectx]
        SETP_LT_NPI  P1, R14, R1, 16    # lanes 0-15
        ST_PRED_LOCAL 2, 16             # P1 alone: its word, b = 20
        SETP_LT_NPI  P1, R14, R1, 0     # cleared
        LD_PRED_LOCAL 2, 16             # and back
        MOVI         R12, 7
        ADD_P        R6, 1, R12, R14, R14   # @P1 R6 = 7; lanes 16-31 keep 0
        ST_GLOBAL_IDX R6, R11, R7, 1, 0 # [0xa0000 + 4 lanectx]
        C_EXIT       0
