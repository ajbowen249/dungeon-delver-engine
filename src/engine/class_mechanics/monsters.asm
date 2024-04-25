

size_hit_die_table:
hit_die_tiny: .db 4
hit_die_small: .db 6
hit_die_medium: .db 8
hit_die_large: .db 10
hit_die_huge: .db 12
hit_die_gargantuan: .db 20

monster_size_table:
monster_size_badger: .db monster_size_tiny
monster_size_hobgoblin: .db monster_size_medium
monster_size_goblin: .db monster_size_small
monster_size_drow_elf: .db monster_size_medium
monster_size_duergar: .db monster_size_medium
.block remaining_builtin_monsters ; leave space for built-in creatures, and another then campaign monsters
campaign_monster_size_table::
.block max_campaign_monsters

monster_ac_table:
monster_ac_badger: .db 4
monster_ac_hobgoblin: .db 18
monster_ac_goblin: .db 15
monster_ac_drow_elf: .db 15
monster_ac_duergar: .db 16
.block remaining_builtin_monsters ; leave space for built-in creatures, and another then campaign monsters
campaign_monster_ac_table::
.block max_campaign_monsters

    DEFINE_PLAYER monster_badger, 4, 11, 12, 2, 12, 5, race_monster, class_m_badger, 1, "Badger"
.db 0
.db 0
.db 0
.db 0

    DEFINE_PLAYER monster_hobgoblin, 13, 12, 12, 10, 10, 9, race_monster, class_m_hobgoblin, 1, "Hobgoblin"
.db 0

    DEFINE_PLAYER monster_goblin, 8, 14, 10, 10, 8, 8, race_monster, class_m_goblin, 1, "Goblin"
.db 0
.db 0
.db 0
.db 0

    DEFINE_PLAYER monster_drow_elf, 10, 14, 10, 11, 11, 12, race_monster, class_m_drow_elf, 1, "Drow Elf"
.db 0
.db 0

    DEFINE_PLAYER monster_duergar, 14, 11, 14, 11, 10, 9, race_monster, class_m_duergar, 1, "Duergar"
.db 0
.db 0
.db 0

.local
; assumes class is in a
get_monster_hit_die::
    ld b, class_cutoff
    sub a, b
    ld hl, monster_size_table
    ld b, 0
    ld c, a
    add hl, bc
    ld a, (hl)
    ld b, 0
    ld c, a
    ld hl, size_hit_die_table
    add hl, bc
    ld a, (hl)
    ret
.endlocal

.local
; assumes class is in a
get_monster_ac::
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
    ; half hit die value plus 1 times level (aka hit dice count)
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
    LOAD_A_WITH_ATTR_THROUGH_HL pl_offs_con
    call ability_score_to_modifier
    add d

    ret
.endlocal

.local
; registers a monster through the argument array starging at HL
; The required arguments are:
; 0: class enum value (must be at least 32. 0-15 are classes, 16-31 are built-in monsters)
; 1: size
; 2: armor class
; 3-4: pointer to a subroutine to determine damage dealt on successful default attack. A will be loaded with the class
; value when called.
adding_monster_class_value: .db 0
adding_monster_class_offset_value: .db 0
reading_address: .dw 0
register_campaign_monster::
    ld (reading_address), hl
    ld a, (hl)
    ld (adding_monster_class_value), a
    ld b, campaign_monster_cutoff
    sub a, b
    ld (adding_monster_class_offset_value), a
    inc hl
    ld (reading_address), hl
    ld a, (hl)
    ld d, a ; d has size

    ld a, (adding_monster_class_offset_value)
    ld b, 0
    ld c, a
    ld hl, campaign_monster_size_table
    add hl, bc
    ld a, d
    ld (hl), a

    ld hl, (reading_address)
    inc hl
    ld (reading_address), hl
    ld a, (hl)
    ld d, a ; d has ac

    ld a, (adding_monster_class_offset_value)
    ld b, 0
    ld c, a
    ld hl, campaign_monster_ac_table
    add hl, bc
    ld a, d
    ld (hl), a

    ld hl, (reading_address)
    inc hl
    ld (reading_address), hl

    ld de, (hl) ; de has damage function pointer
    ld a, (adding_monster_class_offset_value)
    ld b, 2
    ld hl, campaign_monster_damage_table
    call get_array_item
    ld (hl), de

    ret
.endlocal

.macro CAMPAIGN_MONSTER_DESCRIPTOR &LABEL, &CLASS, &SIZE, &AC, &DAMAGE
&LABEL:
cmd_&LABEL_class: .db &CLASS
cmd_&LABEL_size: .db &SIZE
cmd_&LABEL_ac: .db &AC
cmd_&LABEL_damage_sub: .dw &DAMAGE
.endm
