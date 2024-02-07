.macro ON_KEY_JUMP &KEY_CODE, &LOCATION
    cp &KEY_CODE
    jp z, &LOCATION
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
