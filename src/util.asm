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
&NAME_name: .asciz "          "
.endm

.macro DEFINE_PLAYER &LABEL_NAME, &STR, &DEX, &CON, &INT, &WIS, &CHR, &RACE, &CLASS, &NAME
&LABEL_NAME:
&LABEL_NAME_str: .db &STR
&LABEL_NAME_dex: .db &DEX
&LABEL_NAME_con: .db &CON
&LABEL_NAME_int: .db &INT
&LABEL_NAME_wis: .db &WIS
&LABEL_NAME_chr: .db &CHR
&LABEL_NAME_race: .db &RACE
&LABEL_NAME_class: .db &CLASS
&LABEL_NAME_name: .asciz &NAME
.endm
