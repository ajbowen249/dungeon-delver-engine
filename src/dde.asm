; Dungeon Delver Engine
; This is a CRPG engine that implements a subset of OGL SRD 5.1

; Test assembly program for Model 100
.org $C000

; Keep this at the top; this is the entry point
    call main
    ret

#include "math.asm"
#include "util.asm"
#include "party_util.asm"
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
    DEFINE_PLAYER test_character1, 1, 2, 3, 4, 5, 6, race_human, class_barbarian, "Fronk"
.db 0
.db 0
.db 0
.db 0
.db 0
    DEFINE_PLAYER test_character2, 7, 8, 9, 10, 11, 12, race_elf, class_cleric, "Elfy"
.db 0
.db 0
.db 0
.db 0
.db 0
.db 0
    DEFINE_PLAYER test_character3, 13, 14, 15, 16, 17, 18, race_dwarf, class_fighter, "Grumble"
.db 0
.db 0
.db 0
    DEFINE_PLAYER test_character4, 19, 20, 1, 2, 3, 4, race_half_elf, class_wizard, "Sparkle"
.db 0
.db 0
.db 0

party_size: .db 0

main:
    call seed_random

    ld hl, test_characters
    call party_wizard
    cp a, 0
    jp nz, show_sheets
    ld a, 4

show_sheets:
    ld (party_size), a

    ld hl, test_character1
    call character_sheet_ui

    ld a, (party_size)
    cp a, 2
    jp m, sheets_done

    ld hl, test_character2
    call character_sheet_ui

    ld a, (party_size)
    cp a, 3
    jp m, sheets_done

    ld hl, test_character3
    call character_sheet_ui

    ld a, (party_size)
    cp a, 4
    jp m, sheets_done

    ld hl, test_character4
    call character_sheet_ui

sheets_done:

    ld hl, test_characters
    ld a, (party_size)
    call exploration_ui
    ret

rom_file_end:

#target ram
#test TESTS, rom_file_end
#include "./tests/tests.asm" ; Nothing in here should make it into the final binary. Including it at this point so that
                             ; tests are automatically loaded up at the end of the binary when run.
