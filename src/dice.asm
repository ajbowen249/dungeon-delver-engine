; Dice routines

.macro ROLL_N &MASK
    call random_16
    ; mask down to the bits that cap to 0-(N-1)
    ld h, 0
    ld a, l
    and &MASK
    inc a ; this is 0-(N-1) now, so get up to 1-N
    ld l, a
    ret
.endm

.macro ADD_ROLLS &FIRST_ROLL, &SECOND_ROLL
    call &FIRST_ROLL
    ld b, l
    call &SECOND_ROLL
    ld a, l
    add b
    ret
.endm

.local
; loads HL with a random number 1-2
; Uses A
roll_d2::
    ROLL_N $01
.endlocal

.local
; loads HL with a random number 1-4
; Uses A
roll_d4::
    ROLL_N $03
.endlocal

.local
; loads HL with a random number 1-8
; Uses a, b
roll_d6::
    ADD_ROLLS roll_d2, roll_d4
.endlocal

.local
; loads HL with a random number 1-8
; Uses A
roll_d8::
    ROLL_N $07
.endlocal

.local
; loads HL with a random number 1-10
; Uses bc
roll_d10::
    ADD_ROLLS roll_d2, roll_d8
.endlocal

.local
; loads HL with a random number 1-16
; Uses A
roll_d16::
    ROLL_N $0F
.endlocal

.local
; loads HL with a random number 1-10
; Uses bc
roll_d20::
    ADD_ROLLS roll_d4, roll_d16
.endlocal

.macro CALL_ROLL_WRAP &N
    cp &N
    jp z, _roll_d&N
.endm

.macro ROLL_WRAP &N
_roll_d&N:
    call roll_d&N
    ret
.endm

.local
; Loads HL with a value from 1-n
; n may only be 2, 4, 6, 8, 10, 16, or 20.
; uses a, bc
roll_n::
    ; IMPROVE: I tried a function table approach, but it didn't really work
    CALL_ROLL_WRAP 2
    CALL_ROLL_WRAP 4
    CALL_ROLL_WRAP 6
    CALL_ROLL_WRAP 8
    CALL_ROLL_WRAP 10
    CALL_ROLL_WRAP 16
    CALL_ROLL_WRAP 20

    ROLL_WRAP 2
    ROLL_WRAP 4
    ROLL_WRAP 6
    ROLL_WRAP 8
    ROLL_WRAP 10
    ROLL_WRAP 16
    ROLL_WRAP 20

    ret
.endlocal
