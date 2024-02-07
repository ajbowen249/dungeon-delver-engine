resolving_character: .dw 0

.macro POINT_HL_TO_ATTR &OFFSET
    ld bc, &OFFSET
    add hl, bc
.endm

.macro LOAD_A_WITH_ATTR_THROUGH_HL &OFFSET
    POINT_HL_TO_ATTR &OFFSET
    ld a, (hl)
.endm

.macro WRITE_A_TO_ATTR_THROUGH_HL &OFFSET
    POINT_HL_TO_ATTR &OFFSET
    ld (hl), a
.endm
