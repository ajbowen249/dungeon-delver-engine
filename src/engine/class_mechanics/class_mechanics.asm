#include "./class_mechanics_common.asm"
#include "./monsters.asm"
#include "./spells.asm"

.local
.macro MODIFIER_TABLE_ENTRY &ABILITY_SCORE, &MODIFIER_VALUE
.db &ABILITY_SCORE
.db &MODIFIER_VALUE
.endm

modifier_table:
    MODIFIER_TABLE_ENTRY 0, -5
    MODIFIER_TABLE_ENTRY 2, -4
    MODIFIER_TABLE_ENTRY 4, -3
    MODIFIER_TABLE_ENTRY 6, -2
    MODIFIER_TABLE_ENTRY 8, -1
    MODIFIER_TABLE_ENTRY 10, 0
    MODIFIER_TABLE_ENTRY 12, 1
    MODIFIER_TABLE_ENTRY 14, 2
    MODIFIER_TABLE_ENTRY 16, 3
    MODIFIER_TABLE_ENTRY 18, 4
    MODIFIER_TABLE_ENTRY 20, 5
    MODIFIER_TABLE_ENTRY 22, 6
    MODIFIER_TABLE_ENTRY 24, 7
    MODIFIER_TABLE_ENTRY 26, 8
    MODIFIER_TABLE_ENTRY 28, 9

#define modifier_table_max_score 30
#define modifier_table_max_value 10

; given an ability score in A, set A to the modifier value.
ability_score_to_modifier::
    ld b, a
    cp a, modifier_table_max_score
    jp p, ret_max_modifier
    jp z, ret_max_modifier

    ld hl, modifier_table
find_range_loop:
    ld a, (hl)
    inc hl
    ld c, a
    ld a, b
    cp a, c
    jp p, next_entry

    dec hl
    dec hl
    ld a, (hl)
    ret

next_entry:
    inc hl
    jp find_range_loop

ret_max_modifier:
    ld a, modifier_table_max_value
    ret
.endlocal

.local
; Performs a check against skill A with player HL
roll_ability_check::
    POINT_HL_TO_ATTR pl_offs_attrs_array
    ld b, 0
    ld c, a
    add hl, bc
    ld a, (hl)
    ld b, a
    push bc
    call roll_d20
    pop bc
    ld a, b
    add a, l
    ret
.endlocal

hit_die_array:
hit_die_fighter: .db 10
hit_die_wizard: .db 6
hit_die_cleric: .db 8
hit_die_barbarian: .db 12
hit_die_placeholder: ; 8 bytes to fill out SRD classes, plus 4 for campaign-defined
.db 0
.db 0
.db 0
.db 0
.db 0
.db 0
.db 0
.db 0
campaign_class_0_hit_die:: .db 0
campaign_class_1_hit_die:: .db 0
campaign_class_2_hit_die:: .db 0
campaign_class_3_hit_die:: .db 0

.local
ac_table:
.dw get_fighter_ac
.dw get_wizard_ac
.dw get_cleric_ac
.dw get_barbarian_ac
class_functions_placeholder: ; 8 + 4 like before, but each are dw
.dw 0
.dw 0
.dw 0
.dw 0
.dw 0
.dw 0
.dw 0
.dw 0
campaign_class_0_ac_subroutine_pointer:: .dw 0
campaign_class_1_ac_subroutine_pointer:: .dw 0
campaign_class_2_ac_subroutine_pointer:: .dw 0
campaign_class_3_ac_subroutine_pointer:: .dw 0

get_character_armor_class::
    ld (resolving_character), hl
    LOAD_A_WITH_ATTR_THROUGH_HL pl_offs_class
    ld b, a
    ld c, monster_mask
    and a, c
    cp a, 0
    jp nz, monster_ac

    ld a, b
    ld b, 2
    ld hl, ac_table
    call get_array_item
    ld bc, (hl)
    ld hl, bc

    call call_hl
    ret

monster_ac:
    ld hl, (resolving_character)
    LOAD_A_WITH_ATTR_THROUGH_HL pl_offs_class
    call get_monster_ac
    ret

get_fighter_ac:
    ld a, 15; Ring Mail + Fighting Style: Defense
    ret

get_wizard_ac:
    ld hl, (resolving_character)
    LOAD_A_WITH_ATTR_THROUGH_HL pl_offs_dex
    call ability_score_to_modifier
    add a, 10
    ret

get_cleric_ac:
    ld hl, (resolving_character)
    ; temporary; replacing soon with modifier getter
    LOAD_A_WITH_ATTR_THROUGH_HL pl_offs_dex
    call ability_score_to_modifier
    cp a, 2 ; Medium armor, max 2 modifier
    jp z, cleric_apply_medium_armor
    jp m, cleric_apply_medium_armor
    ld a, 2

cleric_apply_medium_armor:
    ld b, a
    ld a, 14; Scale Mail
    add a, b
    ld b, 2 ; shield
    add a, b
    ret

get_barbarian_ac:
    ld hl, (resolving_character)
    LOAD_A_WITH_ATTR_THROUGH_HL pl_offs_dex
    call ability_score_to_modifier
    add a, 11 ; Leather Armor
    ret

; TODO: This can overflow at the moment on high enough levels! Needs 16-bit math!!!
resolving_contitution: .db 0
get_hit_points::
    ld (resolving_character), hl
    LOAD_A_WITH_ATTR_THROUGH_HL pl_offs_class
    ld b, a ; b has original class
    ld c, monster_mask
    and a, c
    cp a, 0
    ld a, b
    jp nz, monster_hp

    ld hl, hit_die_array
    ld c, b
    ld b, 0
    add hl, bc
    ld a, (hl)
    ld d, a ; d has hit dice

    ld hl, (resolving_character)
    LOAD_A_WITH_ATTR_THROUGH_HL pl_offs_con
    ld (resolving_contitution), a

    ld hl, (resolving_character)
    LOAD_A_WITH_ATTR_THROUGH_HL pl_offs_level
    ld e, a ; e has level
    cp a, 1
    jp nz, higher_level_hit_points

    ld a, (resolving_contitution)
    add a, d
    ret

higher_level_hit_points:
    ld a, d
    ; cut it in half and add 1
    rra
    and a, $7F
    add a, 1

    ; b = half_hit + con
    ld b, a
    ld a, (resolving_contitution)
    add a, b
    ld b, a

    ; multiply by level-1
    ld a, e
    dec a
    call mul_a_b

    ; add original base
    add a, d
    ld b, a
    ld a, (resolving_contitution)
    add a, b

    ret

monster_hp:
    ld hl, (resolving_character)
    call get_monster_hp
    ret
.endlocal

.local
damage_table:
.dw get_fighter_damage
.dw get_wizard_damage
.dw get_cleric_damage
.dw get_barbarian_damage
.dw get_placeholder_damage
.dw get_placeholder_damage
.dw get_placeholder_damage
.dw get_placeholder_damage
.dw get_m_badger_damage
.dw get_m_hobgoblin_damage
.dw get_m_goblin_damage
.dw get_m_drow_elf_damage
.dw get_m_duergar_damage
.block 2 * remaining_builtin_monsters ; leave space for built-in creatures, and another then campaign monsters
campaign_monster_damage_table::
.block 2 * max_campaign_monsters

; returns pre-rolled or looked-up damage value in A
get_damage_value::
    ld (resolving_character), hl
    LOAD_A_WITH_ATTR_THROUGH_HL pl_offs_class
    ld b, 2
    ld hl, damage_table
    call get_array_item
    ld bc, (hl)
    ld de, bc

    ld (resolving_character), hl
    LOAD_A_WITH_ATTR_THROUGH_HL pl_offs_class

    ld hl, de
    call call_hl
    ret

get_fighter_damage:
    ; whip
    ld a, 4
    call roll_a
    ld a, l
    ret

get_wizard_damage:
    ; quarterstaff
    ld a, 6
    call roll_a
    ld a, l
    ret

get_cleric_damage:
    ; mace
    ld a, 6
    call roll_a
    ld a, l
    ret

get_barbarian_damage:
    ; battleaxe
    ld a, 8
    call roll_a
    ld a, l
    ret

get_placeholder_damage:
    ld a, 0
    ret

get_m_badger_damage:
    ld a, 1
    ret

get_m_hobgoblin_damage:
    ; longsword
    call roll_d8
    inc a
    ret

get_m_goblin_damage:
    ; scimitar
    call roll_d6
    inc a
    inc a
    ret

get_m_drow_elf_damage:
    ; shortsword
    call roll_d6
    inc a
    inc a
    ret

get_m_duergar_damage:
    ; war pick
    ; 1d8+2
    call roll_d8
    add a, 2
    ret
.endlocal
