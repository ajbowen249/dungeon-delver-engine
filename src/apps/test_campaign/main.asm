; Dungeon Delver Engine Test Campaign
; This is a CRPG built on the Dungeon Delver Engine

.org $B200

; Keep this at the top; this is the entry point
    call main
    ret

#include "../../../build/generated/compressed_text.asm"
#include "../../engine/dde.asm"
#include "./global_data.asm"
#include "./main_menu.asm"
#include "./dialog/dialog.asm"
#include "./screens/screen_table.asm"
#include "./encounters/encounter_table.asm"
#include "party_wizard/party_wizard.asm"

main:
    call seed_random

    ld hl, player_party
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
    ld hl, screen_table
    ld bc, encounter_table
    ld de, player_party
    ld a, (party_size)
    call configure_screen_controller

    ld a, ec_door
    ld b, screen_id_screen_1
    call set_screen_exit_conditions

    call run_screen_controller
    ret
