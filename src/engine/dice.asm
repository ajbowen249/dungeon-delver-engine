; Dice routines

.macro ROLL_MASK &MASK
    call random_16
    ; mask down to the bits that cap to 0-(N-1)
    ld h, 0
    ld a, l
    and &MASK
    inc a ; this is 0-(N-1) now, so get up to 1-N
    ld l, a
    ret
.endm

.macro ADD_MASK &MASK_1, &MASK_2
    call random_16
    ; mask down to the bits that cap to 0-(N-1)
    ld a, h
    and &MASK_1
    ld h, a

    ; mask down to the bits that cap to 0-(N-1)
    ld a, l
    and &MASK_2
    ld l, a

    ld a, h
    add a, l
    inc a ; this is 0-(N-1) now, so get up to 1-N

    ld h, 0
    ld l, a
    ret
.endm

.local
; loads HL with a random number 1-2
; Uses A
roll_d2::
    ROLL_MASK $01
.endlocal

.local
; loads HL with a random number 1-4
; Uses A
roll_d4::
    ROLL_MASK $03
.endlocal

.local
; loads HL with a random number 1-8
; Uses a, b
roll_d6::
    ADD_MASK $01, $03
.endlocal

.local
; loads HL with a random number 1-8
; Uses A
roll_d8::
    ROLL_MASK $07
.endlocal

.local
; loads HL with a random number 1-10
; Uses bc
roll_d10::
    ADD_MASK $01, $07
.endlocal

.local
; loads HL with a random number 1-12
; Uses bc
roll_d12::
    ADD_MASK $03, $04
.endlocal

.local
; loads HL with a random number 1-16
; Uses A
roll_d16::
    ROLL_MASK $0F
.endlocal

.local
; loads HL with a random number 1-20
; Uses bc
roll_d20::
    ADD_MASK $03, $0F
.endlocal

.local
dice_table:
.dw roll_d2
.dw roll_d2
.dw roll_d2
.dw roll_d4
.dw roll_d4
.dw roll_d4
.dw roll_d6
.dw roll_d6
.dw roll_d8
.dw roll_d8
.dw roll_d10
.dw roll_d10
.dw roll_d12
.dw roll_d12
.dw roll_d12
.dw roll_d12
.dw roll_d16
.dw roll_d16
.dw roll_d16
.dw roll_d16
.dw roll_d20

; Loads HL with a value from 1-a
; a may only be 2, 4, 6, 8, 10, 12, 16, or 20.
; uses a, bc
roll_a::
    rla
    and a, $FE

    ld hl, dice_table
    ld b, 0
    ld c, a
    add hl, bc
    ld bc, (hl)
    ld hl, bc

    call call_hl
    ret
.endlocal

.local
roll_total: .db 0
roll_die: .db 0

; rolls an A die B times, and returns the total in A
roll_b_a::
    ld (roll_die), a
    ld a, 0
    ld (roll_total), a

    ld a, b
    ld hl, roll_b_a_callback
    call iterate_a

    ld a, (roll_total)
    ret

roll_b_a_callback:
    ld a, (roll_die)
    call roll_a
    ld b, a
    ld a, (roll_total)
    add a, b
    ld (roll_total), a

    ret
.endlocal
