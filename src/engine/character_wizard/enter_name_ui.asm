.local
destination_og: .dw 0
destination: .dw 0
inlin_result: .dw 0

; Presents the name entry screen
; The name (max 10 chars) will be written to the buffer beginning at BC
enter_name_ui::
    ld hl, bc
    ld (destination_og), hl
    ld (destination), hl

    call init_screen

    ld l, 2
    ld h, 3
    call set_cursor_hl

    call inlin_hl
    ld (inlin_result), hl

    ld c, 0
copy_loop:
    ld hl, (inlin_result)
    ld b, 0
    add hl, bc

    ld a, (hl)
    ld hl, (destination)
    ld (hl), a

    inc hl
    ld (destination), hl

    cp a, 0
    jp z, copy_done

    inc c
    ld a, c
    cp a, 10
    jp nz, copy_loop

    ; c hit 10, so we need to terminate here
    ld a, 0
    ld (hl), a

copy_done:

    ret

init_screen:
    call clear_screen
    PRINT_COMPRESSED_AT_LOCATION 1, 1, enter_name_header

    ret
.endlocal
