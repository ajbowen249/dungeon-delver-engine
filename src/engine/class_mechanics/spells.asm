; complete menu of all spells.
; flags here should be configured via configure_spell_menu for the selected class+level before display

#define spell_firebolt $01
spell_option_firebolt_label: .asciz "Fire Bolt"

#define spell_acid_splash $02
spell_option_acid_splash_label: .asciz "Acid Splash"

#define spell_ray_of_frost $03
spell_option_ray_of_frost_label: .asciz "Ray of Frost"

#define spell_sacred_flame $04
spell_option_sacred_flame_label: .asciz "Sacred Flame"

spell_menu_root:
.db spell_firebolt
spell_menu_firebolt_flags: .db default_options_flags
.dw spell_option_firebolt_label

.db spell_acid_splash
spell_menu_acid_splash_flags: .db default_options_flags
.dw spell_option_acid_splash_label

.db spell_ray_of_frost
spell_menu_ray_of_frost_flags: .db default_options_flags
.dw spell_option_ray_of_frost_label

.db spell_sacred_flame
spell_menu_sacred_flame_flags: .db default_options_flags
.dw spell_option_sacred_flame_label

#define spell_menu_total_options 4

.local

; Enables spells for the player at HL
configure_spell_menu::
    ld a, 0
    ld (spell_menu_firebolt_flags), a
    ld (spell_menu_acid_splash_flags), a
    ld (spell_menu_ray_of_frost_flags), a
    ld (spell_menu_sacred_flame_flags), a

    LOAD_A_WITH_ATTR_THROUGH_HL pl_offs_class

    cp a, class_wizard
    jp z, wizard_menu

    cp a, class_cleric
    jp z, cleric_menu

no_cast:
    ld a, 0
    ret

wizard_menu:
    ld a, default_options_flags
    ld (spell_menu_firebolt_flags), a
    jp ret_cast

cleric_menu:
    ld a, default_options_flags
    ld (spell_menu_sacred_flame_flags), a
    jp ret_cast

ret_cast:
    ld a, 1
    ret

.endlocal

#define spell_type_ranged 6

.local
spell_check_type_table:
.db 0
firebolt_type: .db spell_type_ranged
acid_splash_type: .db spell_type_ranged
ray_of_frost_type: .db spell_type_ranged
sacred_flame_type: .db ability_dex

; If the spell in A requires a saving throw, A will be 0-5, matching the indices for roll_ability_check for the enemy
; to roll against, needing to exceed the value of get_spell_save_bonus for the player character to dodge.
; If A is 6, the spell is ranged and the player should roll a D20 plus the bonus in get_ranged_spell_attack_bonus,
; exceeding the enemy's AC to hit.
get_spell_check_type::
    ld b, 1
    ld hl, spell_check_type_table
    call get_array_item
    ld a, (hl)
    ret
.endlocal

.local
; for the player in BC, returns their spell attack bonus
get_ranged_spell_attack_bonus::
    ld hl, bc
    ld (resolving_character), hl
    LOAD_A_WITH_ATTR_THROUGH_HL pl_offs_class

    cp a, class_wizard
    jp z, wizard_spell_bonus

    cp a, class_cleric
    jp z, cleric_spell_bonus

    ld a, 0
    ret

wizard_spell_bonus:
    ; TODO: proficiency bonus
    ld hl, (resolving_character)
    LOAD_A_WITH_ATTR_THROUGH_HL pl_offs_int
    ret

cleric_spell_bonus:
    ; TODO: proficiency bonus
    ld hl, (resolving_character)
    LOAD_A_WITH_ATTR_THROUGH_HL pl_offs_wis
    ret
.endlocal

.local
; for the player in HL, returns their spell save bonus
get_spell_save_bonus::
    ld (resolving_character), hl
    LOAD_A_WITH_ATTR_THROUGH_HL pl_offs_class

    cp a, class_wizard
    jp z, wizard_spell_save

    cp a, class_cleric
    jp z, cleric_spell_save

    ld a, 0
    ret

wizard_spell_save:
    ; TODO: proficiency bonus
    ld hl, (resolving_character)
    LOAD_A_WITH_ATTR_THROUGH_HL pl_offs_int
    ld b, a
    ld a, 8
    add a, b
    ret

cleric_spell_save:
    ; TODO: proficiency bonus
    ld hl, (resolving_character)
    LOAD_A_WITH_ATTR_THROUGH_HL pl_offs_wis
    ld b, a
    ld a, 8
    add a, b
    ret
.endlocal
