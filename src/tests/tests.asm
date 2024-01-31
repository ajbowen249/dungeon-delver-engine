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

test_start:
    call math_tests
    ret

test_entry:
    call test_start
.endlocal
