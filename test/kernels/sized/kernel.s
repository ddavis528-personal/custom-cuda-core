# sized: O-80's sized loads and stores (DA tab rev 90), from the compiler's
# test/sized.s, .global only. Window 8 holds bytes FF F0 81 80 at 0x80000;
# results are words in window 9 (0x90000), +16 and +20 poked 0xAAAAAAAA so
# a store wider than its transfer shows.
#   +0   ld.global.u8   byte 0                      255
#   +4   ld.global.s8   byte 0                      0xFFFFFFFF
#   +8   ld.global.u16  bytes 2-3                   0x8081
#   +12  ld.global.s16  bytes 2-3                   0xFFFF8081
#   +16  st.global.8    0x12345678 over 0xAAAAAAAA  0xAAAAAA78
#   +20  st.global.16   the same                    0xAAAA5678
#   +24  ld.global.u16, index 1 scaled by 2         0x8081
#   +28  ld.global.s8 into a 16-bit rdata, widened  0xFFFF
        MOVI48     R9, 9               # result window
        MOVI48     R2, 8               # table window
        MOVI       R4, 0
        MOVI       R6, 2
        SZ_GLOBAL_LD_U8  R1, R2, R4, 0, 0
        ST_GLOBAL  R1, R9, 0
        SZ_GLOBAL_LD_S8  R1, R2, R4, 0, 0
        ST_GLOBAL  R1, R9, 4
        SZ_GLOBAL_LD_U16 R1, R2, R6, 0, 0
        ST_GLOBAL  R1, R9, 8
        SZ_GLOBAL_LD_S16 R1, R2, R6, 0, 0
        ST_GLOBAL  R1, R9, 12
        MOVI48     R5, 305419896       # 0x12345678
        MOVI       R3, 16
        SZ_GLOBAL_ST_8   R5, R9, R3, 0, 0
        MOVI       R3, 20
        SZ_GLOBAL_ST_16  R5, R9, R3, 0, 0
        MOVI       R3, 1
        SZ_GLOBAL_LD_U16 R1, R2, R3, 1, 0
        ST_GLOBAL  R1, R9, 24
        C_CHWIDTH  R7, 1
        SZ_GLOBAL_LD_S8  R7, R2, R4, 0, 0
        C_CHWIDTH  R7, 0
        ST_GLOBAL  R7, R9, 28
        C_EXIT     0
