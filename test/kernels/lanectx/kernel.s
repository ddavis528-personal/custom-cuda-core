# lanectx: srd #2, %lanectx (ISA v1.9 O-64): (hardware warp context << 5) |
# lane, which OOE substitutes from the warp's context and the lane ORs in.
# Two warps of one CTA, so warp 1's context is 1 both on the core and in
# ccv-sim (-warp 1): its lanes read 32-63, where %ctatid would read the same
# and srd #0 cannot tell them apart from a CTA's second warp's.
        SRD        R1, 2                # %lanectx
        MOVI48     R3, 3                # window 0x30000
        C_MOV      R2, R1               # a separate data register
        ST_GLOBAL_IDX R2, R3, R1, 1, 0  # [0x30000 + 4 lanectx] = lanectx
        C_EXIT     0
