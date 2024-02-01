#include "./roll_abilities_ui.asm"
#include "./select_race_ui.asm"
#include "./select_class_ui.asm"
#include "./enter_name_ui.asm"

.local

copy_source: .dw 0
copy_destination: .dw 0

; Runs through all steps necessary to create a new character
; Copies character data to HL
; Note: This DOES NOT touch the Level field. It is up to the campaign to initialize the character level, as some may
; wish to start the party above level one.
character_wizard::
    ld (copy_destination), hl

    call roll_abilities_ui

    ld b, 6
    ld (copy_source), hl
    call copy_character_info

    call select_race_ui
    call write_a_to_character_info

    call select_class_ui
    call write_a_to_character_info

    ld hl, (copy_destination)
    inc hl ; skip level
    ld bc, hl
    call enter_name_ui

    ld hl, (copy_destination)
    ld b, 0
    ld c, pl_name_data_len
    add hl, bc
    ld (copy_destination), hl

    ret

; copies b bytes from source to dest, advancing both as it goes.
copy_character_info:
    ld hl, (copy_source)
    ld a, (hl)
    inc hl
    ld (copy_source), hl

    ld hl, (copy_destination)
    ld (hl), a
    inc hl
    ld (copy_destination), hl

    dec b
    jp nz, copy_character_info

    ret

write_a_to_character_info:
    ld hl, (copy_destination)
    ld (hl), a
    inc hl
    ld (copy_destination), hl
    ret
.endlocal
