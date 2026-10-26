# borrow: an instruction of more slots than a warp's share (TI-46 (b), OA's
# rev 263). The chwidth holds rename until it retires, so the moves behind it
# wait in the decode queue; the chwidth.multi of eight registers is eight
# slots, over the share of six, and FET may pick it only once its credits
# are full again, borrowing the rest.
        SRD        R1, 0                # tid
        C_CHWIDTH  R3, 0                # holds rename until it retires
        C_MOV      R2, R1
        C_MOV      R4, R1
        CHWIDTH_MULTI 255, 0            # R0-R7 to 32 bits: eight slots
        C_ADD      R2, R4
        C_EXIT     0
