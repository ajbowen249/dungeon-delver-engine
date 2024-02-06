

size_hit_die_table:
hit_die_tiny: .db 4
hit_die_small: .db 6
hit_die_medium: .db 8
hit_die_large: .db 10
hit_die_huge: .db 12
hit_die_gargantuan: .db 20

moster_size_table:
monster_size_badger: .db monster_size_tiny

monster_ac_table:
monster_ac_badger: .db 10

.macro MONSTER_MODIFIERS &NAME, &STR, &DEX, &CON, &INT, &WIS, &CHA
modifier_&NAME_str: .db &STR
modifier_&NAME_dex: .db &DEX
modifier_&NAME_con: .db &CON
modifier_&NAME_int: .db &INT
modifier_&NAME_wis: .db &WIS
modifier_&NAME_cha: .db &CHA
.endm

monster_modifiers_table:
    MONSTER_MODIFIERS badger, -3, 0, 1, -4, 1, -3

    DEFINE_PLAYER monster_badger, 4, 11, 12, 2, 12, 5, race_monster, class_m_badger, 1, "Badger"
.db 0
.db 0
.db 0
.db 0

.local
; assumes class is in a
get_monster_hit_die::
    ld a, 4
    ret

    ld b, class_cutoff
    sub a, b
    ld hl, moster_size_table
    ld b, 0
    ld c, a
    add hl, bc
    ld a, (hl)
    ld c, a
    ld hl, size_hit_die_table
    add hl, bc
    ld a, (hl)
    ret
.endlocal

.local
; assumes class is in a
get_monster_ac::
    ld a, 4
    ret

    ld b, class_cutoff
    sub a, b
    ld hl, monster_ac_table
    ld b, 0
    ld c, a
    add hl, bc
    ld a, (hl)
    ret
.endlocal

.local
; needs monster in HL and class in a
get_monster_hp::
    ; half hit die value times level plus 1 (aka hit dice count)
    call get_monster_hit_die
    rra
    and a, $7F
    inc a
    ld d, a

    ld hl, (resolving_character)
    LOAD_A_WITH_ATTR_THROUGH_HL pl_offs_level
    ld b, d
    call mul_a_b
    ld d, a

    ; plus constitution modifier (not overall value)
    ld hl, (resolving_character)
    LOAD_A_WITH_ATTR_THROUGH_HL pl_offs_class
    ld b, class_cutoff
    sub a, b
    ld b, 6 ;bytes per set of modifiers
    ld hl, monster_modifiers_table
    call get_array_item
    ld bc, 2
    add hl, bc ; get up to constitution
    ld a, (hl)
    add d

    ret
.endlocal
