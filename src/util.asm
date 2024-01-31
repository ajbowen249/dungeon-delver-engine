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
