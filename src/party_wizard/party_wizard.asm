#include "default_party_ui.asm"
#include "party_size_ui.asm"

.local
party_location: .dw 0
party_size: .db 0
member_index: .db 0

; Sets up a party of 1-4 players and inserts them into the array starting at HL
; A contains the selected party size, and 0 if the default party was selected.
; Leaves the party array untouched if the default party is selected.
party_wizard::
    ld  (party_location), hl

    call default_party_ui
    cp a, 0
    jp nz, default_party

    call party_size_ui
    ld (party_size), a
    ld a, 0
    ld (member_index), a

add_players_loop:
    ld a, (member_index)
    ld hl, (party_location)
    call get_party_member
    call character_wizard

    ld a, (member_index)
    inc a
    ld (member_index), a
    ld b, a
    ld a, (party_size)
    cp a, b
    jp nz, add_players_loop

    ld a, (party_size)
    ret

default_party:
    ld a, 0
    ret
.endlocal
