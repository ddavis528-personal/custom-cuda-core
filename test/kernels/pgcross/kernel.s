# pgcross: a .global load whose lanes span two 64 KiB pages (MI-7 (c)).
# Two loads first touch page 2 and page 3 alone (each walks under
# CCV_MIU_TLB=cold); the third, at 0x30000 - 64 + 4 tid, finds both pages
# held: lanes 0-15 read page 2, lanes 16-31 page 3. Under the MIU model it
# reaches the two-page branch (tlb_two_page) already ineligible: MA-6's
# eligibility keeps a contracted load inside one 64 KiB page.
        POR        P0, 4, 0               # P0 = all ones
        MOVI48     R0, 3                  # window 0x30000
        SRD        R1, 0                  # tid
        LD_GLOBAL_IDX R4, R0, R1, 1, -128 # page 2 only: [0x2ff80 + 4 tid] = tid
        LD_GLOBAL_IDX R5, R0, R4, 1, 0    # page 3 only: [0x30000 + 4 tid] = tid
        LD_GLOBAL_IDX R2, R0, R5, 1, -64  # both pages: [0x2ffc0 + 4 tid]
        C_ADD      R2, R1
        C_EXIT     0
