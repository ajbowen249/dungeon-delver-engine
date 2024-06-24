
; yoinked from
; https://wikiti.brandonw.net/index.php?title=Z80_Routines:Math:Random
;Inputs:
;   (seed1) contains a 16-bit seed value
;   (seed2) contains a NON-ZERO 16-bit seed value
;Outputs:
;   HL is the result
;   BC is the result of the LCG, so not that great of quality
;   DE is preserved
;Destroys:
;   AF
;cycle: 4,294,901,760 (almost 4.3 billion)
;160cc
;26 bytes

seed1: .dw 0
seed2: .dw 0

.local
random_16::
    ld hl,(seed1)
    ld b,h
    ld c,l
    add hl,hl
    add hl,hl
    inc l
    add hl,bc
    ld (seed1),hl
    ld hl,(seed2)
    add hl,hl
    sbc a,a
    and %00101101
    xor l
    ld l,a
    ld (seed2),hl
    add hl,bc
    ret
.endlocal

; seeds the RNG based on the ASCII date characters for current seconds
.local
seed_random::
    ld a,(random_seed_0)
    ld (seed1), a
    inc a
    ld (seed1 + 1), a
    ld a,(random_seed_1)
    ld (seed2), a
    inc a
    ld (seed2 + 1), a
    ret
.endlocal
