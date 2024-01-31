.macro ON_KEY_JUMP &KEY_CODE, &LOCATION
    cp &KEY_CODE
    jp z, &LOCATION
.endm
