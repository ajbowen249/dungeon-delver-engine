; Unit tests

.org $C000

#include "../dde.asm"

test_associative_array:
test_assoc_0:
.db 2
.db 2

test_assoc_1:
.db 3
.db 1

test_assoc_2:
.db 4
.db 0


test_assoc_3:
.db 0
.db 4

test_assoc_4:
.db 1
.db 3

test_sort_swap_space:
.db 55
.db 55

copy_test_src:
.db "a"
.db "b"
.db "c"
.db "d"
.db "e"
.db "f"
.db "g"

copy_test_dst:
.db 0
.db 0
.db 0
.db 0
.db 0
.db 0
.db 0

    DEFINE_PLAYER test_character1, 15, 8, 5, 5, 4, 8, race_human, class_barbarian, 1, "Fronk"
.db 0
.db 0
.db 0
.db 0
.db 0

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

test_copy:
    ld a, (copy_test_dst)
.expect a = 0

    ld a, 7
    ld hl, copy_test_src
    ld bc, copy_test_dst
    call copy_hl_bc

    ld a, (copy_test_dst)
.expect a = "a"
    ld a, (copy_test_dst + 1)
.expect a = "b"
    ld a, (copy_test_dst + 2)
.expect a = "c"
    ld a, (copy_test_dst + 3)
.expect a = "d"
    ld a, (copy_test_dst + 4)
.expect a = "e"
    ld a, (copy_test_dst + 5)
.expect a = "f"
    ld a, (copy_test_dst + 6)
.expect a = "g"
    ret

test_sort:
    ld d, 2
    ld a, 5
    ld hl, test_associative_array
    ld bc, test_sort_swap_space
    call sort_associative_array

    ld a, (test_assoc_0)
.expect a = 0
    ld a, (test_assoc_0 + 1)
.expect a = 4

    ld a, (test_assoc_1)
.expect a = 1
    ld a, (test_assoc_1 + 1)
.expect a = 3

    ld a, (test_assoc_2)
.expect a = 2
    ld a, (test_assoc_2 + 1)
.expect a = 2

    ld a, (test_assoc_3)
.expect a = 3
    ld a, (test_assoc_3 + 1)
.expect a = 1

    ld a, (test_assoc_4)
.expect a = 4
    ld a, (test_assoc_4 + 1)
.expect a = 0

    ret

array_tests:
    call test_copy
    call test_sort
    ret

test_class_mechanics:
    ld hl, test_character1
    call get_hit_points
.expect a = 17
    ld a, 2
    ld (test_character1 + pl_offs_level), a
    ld hl, test_character1
    call get_hit_points
.expect a = 29
    ld a, 3
    ld (test_character1 + pl_offs_level), a
    ld hl, test_character1
    call get_hit_points
.expect a = 41
    ld a, 4
    ld (test_character1 + pl_offs_level), a
    ld hl, test_character1
    call get_hit_points
.expect a = 53
    ld a, 5
    ld (test_character1 + pl_offs_level), a
    ld hl, test_character1
    call get_hit_points
.expect a = 65
    ld a, class_wizard
    ld (test_character1 + pl_offs_class), a
    ld hl, test_character1
    call get_hit_points
.expect a = 47
    ld a, class_cleric
    ld (test_character1 + pl_offs_class), a
    ld hl, test_character1
    call get_hit_points
.expect a = 53
    ld a, class_fighter
    ld (test_character1 + pl_offs_class), a
    ld hl, test_character1
    call get_hit_points
.expect a = 59
    ret

test_start:
    call math_tests
    call test_decimal
    call array_tests
    call test_class_mechanics
    ret

test_entry:
    call test_start
.endlocal
