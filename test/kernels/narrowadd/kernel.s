# narrowadd: narrow registers on full rows (AR-24's interim; AR's rev 178,
# OA's rev 230), from the compiler's test/chwidth.s, .global only. R2 holds
# 0xEFBEADC9 while 32-bit and is narrowed, so ccv-sim keeps those bits above
# its element; R2 and R3 load two bytes each, 0xfff0 and 0x0123, and their
# 16-bit add carries out of bit 15 and wraps to 0x0113. The two-byte store
# must write only its halfword, and the widen must read 0x00000113: the bits
# above a narrow element are zero in the row (O-38). R4, an 8-bit immediate
# stored as one byte, and a 16-bit subtract that borrows, 0x0001 - 0x0002,
# close the set. Data window 3 at 0x30000; results at +16 and up.
        MOVI48     R0, 3               # .global window 3: byte address 0x30000
        MOVI48     R2, 4023233417      # 0xEFBEADC9 while R2 is 32-bit
        C_CHWIDTH  R2, 1               # R2 is 16-bit
        C_CHWIDTH  R3, 1
        LD_GLOBAL  R2, R0, 0           # two bytes: 0xfff0
        LD_GLOBAL  R3, R0, 2           # two bytes: 0x0123
        ADD        R2, R2, R3, R2      # wraps at 16 bits: 0x0113 (rs2 unread)
        ST_GLOBAL  R2, R0, 16          # two bytes: the halfword at +18 untouched
        C_CHWIDTH  R2, 0               # widen: 0x00000113, nothing above
        ST_GLOBAL  R2, R0, 20          # four bytes
        C_CHWIDTH  R4, 2               # R4 is 8-bit
        MOVI       R4, 171             # 0xAB
        ST_GLOBAL  R4, R0, 24          # one byte: +25 to +27 untouched
        C_CHWIDTH  R5, 1
        C_CHWIDTH  R6, 1
        LD_GLOBAL  R5, R0, 4           # two bytes: 0x0001
        LD_GLOBAL  R6, R0, 6           # two bytes: 0x0002
        SUB        R5, R5, R6, R5      # borrows: 0xffff at 16 bits (rs2 unread)
        C_CHWIDTH  R5, 0               # widen: 0x0000ffff
        ST_GLOBAL  R5, R0, 28
        C_EXIT     0
