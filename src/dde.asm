; Dungeon Delver Engine
; This is a CRPG engine that implements a subset of OGL SRD 5.1

; Test assembly program for Model 100
.org $C000

; Keep this at the top; this is the entry point
    call main
    ret

#include "util.asm"
#include "constants.asm"
#include "rom_api.asm"
#include "random.asm"
#include "dice.asm"
#include "string.asm"
#include "simple_menu.asm"

#include "character_builder/character_builder.asm"
#include "character_sheet_ui.asm"

    ALLOCATE_PLAYER test_character

main:
    call seed_random

    ld hl, test_character
    call create_character_ui

    ld hl, test_character
    call character_sheet_ui

    ret
