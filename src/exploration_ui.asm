.local

hard_screen_data:
hard_screen_background:
.asciz "┌Test Screen───────┐"
.asciz "│                  │"
.asciz "│                  │"
.asciz "│                  │"
.asciz "│                  │"
.asciz "│                  │"
.asciz "│                  │"
.asciz "└──────────────────┘"

screen_data: .dw 0

background_index: .dw 0

; Displays the exploration screen until exited
; TODO: Pass a pointer to a block of screen data
exploration_ui::
    ld hl, hard_screen_data
    ld (screen_data), hl
    call init_screen

read_loop:
    call rom_kyread
    jp z, read_loop

    ret

init_screen:
    call rom_clear_screen
    call draw_background

    ret

draw_background:
    ld hl, (screen_data)
    ld (background_index), hl

    ld d, 1

draw_bg_loop:
    ld h, 1
    ld l, d
    call rom_set_cursor

    ld hl, (background_index)
    call print_string

    ld hl, (background_index)
    ld bc, 21 ; 20 char string plus terminator
    add hl, bc
    ld (background_index), hl

    inc d
    ld a, d
    cp a, 9 ; rows 1-8
    jp nz, draw_bg_loop

    ret
.endlocal
