#include "./class_mechanics_common.asm"
#include "./monsters.asm"

; each get_character_x function takes a pointer to a player data structure in HL and returns in A the total value for that
; item, including any and all bonuses atop the core stat. All destroy HL

.local
; but just return their base attrs, for now. This will be filled in later with leveling mechanics.
get_character_strength::
    LOAD_BASE_ATTR_FROM_HL pl_offs_str
    ret

get_character_dexterity::
    LOAD_BASE_ATTR_FROM_HL pl_offs_dex
    ret

get_character_constitution::
    LOAD_BASE_ATTR_FROM_HL pl_offs_con
    ret

get_character_intelligence::
    LOAD_BASE_ATTR_FROM_HL pl_offs_int
    ret

get_character_wisdom::
    LOAD_BASE_ATTR_FROM_HL pl_offs_wis
    ret

get_character_charisma::
    LOAD_BASE_ATTR_FROM_HL pl_offs_chr
    ret
.endlocal

; Each perform_x_check makes a D20 roll and adds the subsequent total modifier for that skill for the player in HL
; Returns the result in A

.local
bonus_backup: .db 0
.macro ABILITY_CHECK_SUBROUTINE &ABILITY
roll_&ABILITY_check::
    call get_character_&ABILITY
    ld (bonus_backup), a
    call roll_d20

    ld a, (bonus_backup)
    ld b, 0
    ld c, a
    add hl, bc

    ld a, l
    ret
.endm

    ABILITY_CHECK_SUBROUTINE strength
    ABILITY_CHECK_SUBROUTINE dexterity
    ABILITY_CHECK_SUBROUTINE constitution
    ABILITY_CHECK_SUBROUTINE intelligence
    ABILITY_CHECK_SUBROUTINE wisdom
    ABILITY_CHECK_SUBROUTINE charisma

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
campaign_class_0_hit_die. db 0
campaign_class_1_hit_die. db 0
campaign_class_2_hit_die. db 0
campaign_class_3_hit_die. db 0

.local
class_functions:
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
campaign_class_0_ac. dw 0
campaign_class_1_ac. dw 0
campaign_class_2_ac. dw 0
campaign_class_3_ac. dw 0

get_character_armor_class::
    ld (resolving_character), hl
    LOAD_BASE_ATTR_FROM_HL pl_offs_class
    ld b, a
    ld c, class_cutoff
    and a, c
    cp a, 0
    jp nz, monster_ac

    ld a, b
    ld b, 2
    ld hl, class_functions
    call get_array_item
    ld bc, (hl)
    ld hl, bc

    call call_hl
    ret

monster_ac:
    call get_monster_ac
    ret

get_fighter_ac:
    ld a, 15; Ring Mail + Fighting Style: Defense
    ret

get_wizard_ac:
    ld hl, (resolving_character)
    call get_character_dexterity
    add a, 10
    ret

get_cleric_ac:
    ld hl, (resolving_character)
    call get_character_dexterity
    cp a, 2 ; Medium armor, max 2 bonus
    jp z, cleric_apply_medium_armor
    jp m, cleric_apply_medium_armor
    ld a, 2

cleric_apply_medium_armor:
    ld b, a
    ld a, 14; Scale Mail
    add a, b
    ret

get_barbarian_ac:
    ld hl, (resolving_character)
    call get_character_dexterity
    add a, 11 ; Leather Armor
    ret

; TODO: This can overflow at the moment on high enough levels! Needs 16-bit math!!!
resolving_contitution: .db 0
get_hit_points::
    ld (resolving_character), hl
    LOAD_BASE_ATTR_FROM_HL pl_offs_class
    ld b, a ; b has original class
    ld c, class_cutoff
    and a, c
    cp a, 0
    jp nz, monster_hp

    ld hl, hit_die_array
    ld c, b
    ld b, 0
    add hl, bc
    ld a, (hl)
    ld d, a ; d has hit dice

    ld hl, (resolving_character)
    LOAD_BASE_ATTR_FROM_HL pl_offs_con
    ld (resolving_contitution), a

    ld hl, (resolving_character)
    LOAD_BASE_ATTR_FROM_HL pl_offs_level
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
; loads A with the hit die, and B with the number of die to roll
get_hit_dice::
    ld de, hl
    LOAD_BASE_ATTR_FROM_HL pl_offs_level
    ld b, a

    ld hl, de
    LOAD_BASE_ATTR_FROM_HL pl_offs_class
    ld c, class_cutoff
    and a, c
    cp a, 0
    jp nz, get_monster_die

    ld hl, hit_die_array
    ld d, 0
    ld e, a
    add hl, de
    ld a, (hl)
    ret

get_monster_die:
    call get_monster_hit_die
    ret
.endlocal

.local
roll_hit_dice::
    call get_hit_dice
    call roll_b_a
    ret
.endlocal
