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
