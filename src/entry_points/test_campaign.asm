; Dungeon Delver Engine Test Campaign
; This is a CRPG built on the Dungeon Delver Engine

.org $C000

; Keep this at the top; this is the entry point
    call main
    ret

#include "../dde.asm"
#include "./test_campaign/global_data.asm"
#include "./test_campaign/screen_1.asm"
#include "./test_campaign/screen_2.asm"

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

screen_loop:
    call screen_1
    call screen_2
    jp screen_loop

    ret
