resolving_character: .dw 0

.macro LOAD_BASE_ATTR_FROM_HL &OFFSET
    ld b, 0
    ld c, &OFFSET
    add hl, bc
    ld a, (hl)
.endm
