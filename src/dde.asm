; Dungeon Delver Engine
; This is a CRPG engine that implements a subset of OGL SRD 5.1

; Test assembly program for Model 100
.org $C000

; Keep this at the top; this is the entry point
    call main
    ret

#include "math.asm"
#include "util.asm"
#include "constants.asm"
#include "enums.asm"
#include "rom_api.asm"
#include "random.asm"
#include "dice.asm"
#include "string.asm"

#include "./ui_components/ui_components.asm"

#include "character_wizard/character_wizard.asm"
#include "party_wizard/party_wizard.asm"

#include "character_sheet_ui.asm"
#include "exploration_ui.asm"

test_characters:
    ALLOCATE_PLAYER test_character1
    ALLOCATE_PLAYER test_character2
    ALLOCATE_PLAYER test_character3
    ALLOCATE_PLAYER test_character4

main:
    call seed_random

    ; ld hl, test_character
    ; call character_wizard

    ; ld hl, test_character
    ; call character_sheet_ui

    ld hl, test_characters
    call party_wizard

    ret

rom_end:

#target ram
#test TESTS, rom_end
#include "./tests/tests.asm" ; Nothing in here should make it into the final binary. Including it at this point so that
                             ; tests are automatically loaded up at the end of the binary when run.
