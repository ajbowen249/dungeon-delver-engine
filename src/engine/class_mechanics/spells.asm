; complete menu of all spells.
; flags here should be configured via configure_spell_menu for the selected class+level before display

#define spell_option_firebolt_value $01
spell_option_firebolt_label: .asciz "Fire Bolt"

#define spell_option_acid_splash_value $02
spell_option_acid_splash_label: .asciz "Acid Splash"

#define spell_option_ray_of_frost_value $03
spell_option_ray_of_frost_label: .asciz "Ray of Frost"

#define spell_option_sacred_flame_value $04
spell_option_sacred_flame_label: .asciz "Sacred Flame"

spell_menu_root:
.db spell_option_firebolt_value
spell_menu_firebolt_flags: .db default_options_flags
.dw spell_option_firebolt_label

.db spell_option_acid_splash_value
spell_menu_acid_splash_flags: .db default_options_flags
.dw spell_option_acid_splash_label

.db spell_option_ray_of_frost_value
spell_menu_ray_of_frost_flags: .db default_options_flags
.dw spell_option_ray_of_frost_label

.db spell_option_sacred_flame_value
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
