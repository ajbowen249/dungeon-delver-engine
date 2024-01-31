; Dungeon Delver Engine
; This is a CRPG engine that implements a subset of OGL SRD 5.1

; Test assembly program for Model 100
.org $C000

; Keep this at the top; this is the entry point
    call main
    ret

#include "util.asm"
#include "constants.asm"
#include "enums.asm"
#include "rom_api.asm"
#include "random.asm"
#include "dice.asm"
#include "string.asm"

#include "./ui_components/ui_components.asm"

#include "character_wizard/character_wizard.asm"
#include "character_sheet_ui.asm"
#include "exploration_ui.asm"

    ALLOCATE_PLAYER test_character

main:
    call seed_random

    ; ld hl, test_character
    ; call character_wizard

    ; ld hl, test_character
    ; call character_sheet_ui

    call exploration_ui

    ret
