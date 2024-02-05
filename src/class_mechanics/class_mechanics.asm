; each get_character_x function takes a pointer to a player data structure in HL and returns in A the total value for that
; item, including any and all bonuses atop the core stat. All destroy HL

.local
.macro LOAD_BASE_ATTR_FROM_HL &OFFSET
    ld b, 0
    ld c, &OFFSET
    add hl, bc
    ld a, (hl)
.endm

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

.local
class_functions:
.dw get_fighter_ac
.dw get_wizard_ac
.dw get_cleric_ac
.dw get_barbarian_ac

resolving_character: .dw 0
get_character_armor_class::
    ld (resolving_character), hl
    LOAD_BASE_ATTR_FROM_HL pl_offs_class

    ld b, 2
    ld hl, class_functions
    call get_array_item
    ld bc, (hl)
    ld hl, bc

    call call_hl

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
.endlocal
