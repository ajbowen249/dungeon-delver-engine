; Unit tests

.org $C000

#include "../dde.asm"

rom_file_end:

#target ram
#test TESTS, rom_file_end

.local
    jp test_entry

math_tests:
    call test_multiplication
    ret

test_multiplication:
    ld a, 10
    ld b, 3
    call mul_a_b
.expect a = 30
    ld a, 14
    ld b, 12
    call mul_a_b
.expect a = 168
    ld a, 12
    ld b, 14
    call mul_a_b
.expect a = 168
    ld a, 255
    ld b, 0
    call mul_a_b
.expect a = 0
    ld a, 24
    ld b, 1
    call mul_a_b
.expect a = 24
    ld a, 1
    ld b, 24
    call mul_a_b
.expect a = 24
    ret

.macro DECIMAL_TEST &D, &E, &D1, &D2, &D3
    ld d, &D
    ld e, &E
    call de_to_decimal_string
    ld hl, bc

    ld a, (hl)
.expect a = &D1
    inc hl
    ld a, (hl)
.expect a = &D2
    inc hl
    ld a, (hl)
.expect a = &D3
    inc hl
    ld a, (hl)
.expect a = 0
.endm

test_decimal:
    DECIMAL_TEST 0, 123, "1", "2", "3"
    DECIMAL_TEST 0, 0, "0", "0", "0"
    DECIMAL_TEST $03, $E7, "9", "9", "9"
    ret

test_start:
    call math_tests
    ret

test_entry:
    call test_start
    call test_decimal
.endlocal
