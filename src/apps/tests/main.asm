; Unit tests

#include "../../../build/generated/tests/generated_header.asm"

#include "../../../build/generated/tests/compressed_text.asm"
#include "../../engine/dde.asm"

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

reverse_test_array:
.ascii "ab"
.ascii "cd"
.ascii "ef"
.ascii "gh"
.ascii "ij"

test_reverse_swap_space:
.ascii "  "

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

#define class_mc_test_monster 16
    DEFINE_PLAYER test_campaign_monster_class, 10, 9, 8, 7, 6, 5, race_monster, class_mc_test_monster, 1, "TEST"
.db 0
.db 0
.db 0
.db 0
.db 0
.db 0

    CAMPAIGN_MONSTER_DESCRIPTOR test_campaign_monster_descriptor, class_mc_test_monster, monster_size_large, 5, test_damage_s

test_damage_s:
    ld a, 12
    ret

rom_file_end:

#target ram
#test TESTS, rom_file_end

.local
    jp test_entry

math_tests:
    call test_multiplication
    call test_parse_hex
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

test_parse_hex:
    ld a, "0"
    call parse_a_as_hex_digit
.expect a = 0
    ld a, "9"
    call parse_a_as_hex_digit
.expect a = 9
    ld a, "A"
    call parse_a_as_hex_digit
.expect a = 10
    ld a, "F"
    call parse_a_as_hex_digit
.expect a = 15
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
    DECIMAL_TEST 0, 23, " ", "2", "3"
    DECIMAL_TEST 0, 3, " ", " ", "3"
    DECIMAL_TEST 0, 0, " ", " ", "0"
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

test_reverse:
    ld hl, reverse_test_array
    ld a, 5
    ld d, 2
    ld bc, test_reverse_swap_space
    call reverse_array

    ld a, (reverse_test_array)
.expect a = "i"
    ld a, (reverse_test_array + 1)
.expect a = "j"

    ld a, (reverse_test_array + 2)
.expect a = "g"
    ld a, (reverse_test_array + 3)
.expect a = "h"

    ld a, (reverse_test_array + 4)
.expect a = "e"
    ld a, (reverse_test_array + 5)
.expect a = "f"

    ld a, (reverse_test_array + 6)
.expect a = "c"
    ld a, (reverse_test_array + 7)
.expect a = "d"

    ld a, (reverse_test_array + 8)
.expect a = "a"
    ld a, (reverse_test_array + 9)
.expect a = "b"
    ret

array_tests:
    call test_copy
    call test_sort
    call test_reverse
    ret

test_class_mechanics:
    ld hl, test_character1
    call get_character_armor_class
.expect a = 10
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
    ld a, 10
    ld (test_character1 + pl_offs_level), a
    ld hl, test_character1
    call get_hit_points
.expect a = 125
    ld a, 5
    ld (test_character1 + pl_offs_level), a
    ld hl, test_character1
    call get_hit_points
.expect a = 65
    ld a, class_wizard
    ld (test_character1_class), a
    ld hl, test_character1
    call get_hit_points
.expect a = 47
    ld a, class_cleric
    ld (test_character1_class), a
    ld hl, test_character1
    call get_hit_points
.expect a = 53
    ld a, class_fighter
    ld (test_character1_class), a
    ld hl, test_character1
    call get_hit_points
.expect a = 59
    ld hl, monster_badger
    call get_hit_points
.expect a = 4
    ld hl, monster_badger
    call get_character_armor_class
.expect a = 4
    ld a, 2
    ld (monster_badger_level), a
    ld hl, monster_badger
    call get_hit_points
.expect a = 7
    ld hl, test_campaign_monster_descriptor
    call register_campaign_monster

    ld hl, test_campaign_monster_class
    call get_hit_points
.expect a = 5
    ld hl, test_campaign_monster_class
    call get_damage_value
.expect a = 12
    ld a, monster_size_gargantuan
    ld (cmd_test_campaign_monster_descriptor_size), a

    ld hl, test_campaign_monster_descriptor
    call register_campaign_monster

    ld hl, test_campaign_monster_class
    call get_hit_points
.expect a = 10
    ld hl, monster_hobgoblin
    call get_hit_points
.expect a = 6
    ld a, 5
    ld (monster_hobgoblin_level), a
    ld hl, monster_hobgoblin
    call get_hit_points
.expect a = 26
    ld hl, monster_goblin
    call get_hit_points
.expect a = 4
    ld a, 3
    ld (monster_goblin_level), a
    ld hl, monster_goblin
    call get_hit_points
.expect a = 12
    ld hl, monster_drow_elf
    call get_hit_points
.expect a = 5
    ld a, 6
    ld (monster_drow_elf_level), a
    ld hl, monster_drow_elf
    call get_hit_points
.expect a = 30
    ld hl, monster_duergar
    call get_hit_points
.expect a = 7
    ld a, 10
    ld (monster_duergar_level), a
    ld hl, monster_duergar
    call get_hit_points
.expect a = 52

    ld a, 1
    call ability_score_to_modifier
.expect a = 251

.macro MODIFIER_TABLE_TEST_PAIR &B1, &B2, &VAL
    ld a, &B1
    call ability_score_to_modifier
.expect a = &VAL
    ld a, &B2
    call ability_score_to_modifier
.expect a = &VAL
.endm

    MODIFIER_TABLE_TEST_PAIR 2, 3, 252
    MODIFIER_TABLE_TEST_PAIR 4, 5, 253
    MODIFIER_TABLE_TEST_PAIR 6, 7, 254
    MODIFIER_TABLE_TEST_PAIR 8, 9, 255
    MODIFIER_TABLE_TEST_PAIR 10, 11, 0
    MODIFIER_TABLE_TEST_PAIR 12, 13, 1
    MODIFIER_TABLE_TEST_PAIR 14, 15, 2
    MODIFIER_TABLE_TEST_PAIR 16, 17, 3
    MODIFIER_TABLE_TEST_PAIR 18, 19, 4
    MODIFIER_TABLE_TEST_PAIR 20, 21, 5
    MODIFIER_TABLE_TEST_PAIR 22, 23, 6
    MODIFIER_TABLE_TEST_PAIR 24, 25, 7
    MODIFIER_TABLE_TEST_PAIR 26, 27, 8
    MODIFIER_TABLE_TEST_PAIR 28, 29, 9
    MODIFIER_TABLE_TEST_PAIR 30, 40, 10

    ret

iterate_a_total: .db 0
iterate_a_test_body_1:
    ld b, a
    ld a, (iterate_a_total)
    add a, b
    ld (iterate_a_total), a
    ret

iterate_a_inner_total: .db 0
iterate_a_nested_body_inner:
    ld b, a
    ld a, (iterate_a_inner_total)
    add a, b
    ld (iterate_a_inner_total), a
    ret

iterate_a_outer_total: .db 0
iterate_a_nested_body_outer:
    ld b, a
    ld a, (iterate_a_outer_total)
    add a, b
    ld (iterate_a_outer_total), a

    ld a, 6
    ld hl, iterate_a_nested_body_inner
    call iterate_a
    ret

iterate_a_tests:
    ld a, 0
    ld (iterate_a_total), a

    ld a, 10
    ld hl, iterate_a_test_body_1
    call iterate_a

    ld a, (iterate_a_total)
.expect a = 45

    ld a, 0
    ld (iterate_a_inner_total), a
    ld (iterate_a_outer_total), a

    ld a, 5
    ld hl, iterate_a_nested_body_outer
    call iterate_a

    ld a, (iterate_a_outer_total)
.expect a = 10
    ld a, (iterate_a_inner_total)
.expect a = 75

    ret

test_start:
    call math_tests
    call test_decimal
    call array_tests
    call test_class_mechanics
    call iterate_a_tests
    ret

test_entry:
    call test_start
.endlocal
