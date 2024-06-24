.macro ON_KEY_JUMP &KEY_CODE, &LOCATION
    cp &KEY_CODE
    jp z, &LOCATION
.endm

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

.macro ALLOCATE_PLAYER &NAME
&NAME:
&NAME_str: .db 0
&NAME_dex: .db 0
&NAME_con: .db 0
&NAME_int: .db 0
&NAME_wis: .db 0
&NAME_chr: .db 0
&NAME_race: .db 0
&NAME_class: .db 0
&NAME_level: .db 1
&NAME_name: .asciz "          "
.endm

.macro DEFINE_PLAYER &LABEL_NAME, &STR, &DEX, &CON, &INT, &WIS, &CHR, &RACE, &CLASS, &LEVEL, &NAME
&LABEL_NAME:
&LABEL_NAME_str: .db &STR
&LABEL_NAME_dex: .db &DEX
&LABEL_NAME_con: .db &CON
&LABEL_NAME_int: .db &INT
&LABEL_NAME_wis: .db &WIS
&LABEL_NAME_chr: .db &CHR
&LABEL_NAME_race: .db &RACE
&LABEL_NAME_class: .db &CLASS
&LABEL_NAME_level: .db &LEVEL
&LABEL_NAME_name: .asciz &NAME
.endm

.macro DEFINE_INTERACTABLE &LABEL, &TYPE, &FLAGS, &ROW, &COL
&LABEL:
&LABEL_type: .db &TYPE
&LABEL_flags: .db &FLAGS
&LABEL_row: .db &ROW
&LABEL_col: .db &COL
.endm

; Z80 doesn't have indirect call, but if we "call" down to this label, it will set up the stack with the right
; return value, and then jumping indirect to our address calls into the function, which will ret like normal.
call_hl:
    jp hl
    ret

.local
await_any_keypress::
loop:
    call keyread_a
    jp z, loop
    ret
.endlocal

.local
; given a count in A and a callback in HL, call the callback A times.
; A will be set to the current index before HL is called
; for (i = 0; i < A; i++) { HL(i (passed through A) ); }
iterate_a::
    push hl
    ld b, a
    ld c, 0
    push bc

iterate_a_loop:
    ld hl, 0
    add hl, sp
    ld a, (hl)
    ld b, a
    inc hl
    ld a, (hl)
    cp a, b
    jp z, iterate_a_done

    ld hl, 2
    add hl, sp
    ld a, (hl)
    ld c, a
    inc hl
    ld a, (hl)
    ld b, a
    ld hl, 0
    add hl, sp
    ld a, (hl)
    ld hl, bc
    call call_hl

    pop bc
    inc c
    push bc
    jp iterate_a_loop

iterate_a_done:
    pop hl
    pop hl
    ret
.endlocal
