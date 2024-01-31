.local

hard_screen_data:
hard_screen_background:
.asciz "┌──────────────────┐"
.asciz "│    α             │"
.asciz "│           ∩      │"
.asciz "│                  │"
.asciz "│                  │"
.asciz "│         ∩        │"
.asciz "│∩∩          α     │"
.asciz "└──────────────────┘"
hard_title: .asciz "Test Room"
.db 0
.db 0
.db 0
.db 0
.db 0
.db 0
.db 0
.db 0
.db 0
.db 0
.db 0
hard_start_x: .db 2 ; 1-indexed since it's screen coordinates!
hard_start_y: .db 2

screen_data: .dw 0

background_index: .dw 0

avatar_data:
avatar_x: .db 0
avatar_y: .db 0

party_location: .dw 0
party_size: .db 0

; Displays the exploration screen until exited
; HL should contain a pointer to the party array, and A should contain party size.
; TODO: Pass a pointer to a block of screen data
exploration_ui::
    ld (party_location), hl
    ld (party_size), a

    ld hl, hard_screen_data
    ld (screen_data), hl
    call init_screen

read_loop:
    call rom_kyread
    jp z, read_loop

    ON_KEY_JUMP ch_down_arrow, on_down_arrow
    ON_KEY_JUMP ch_s, on_down_arrow
    ON_KEY_JUMP ch_S, on_down_arrow

    ON_KEY_JUMP ch_up_arrow, on_up_arrow
    ON_KEY_JUMP ch_w, on_up_arrow
    ON_KEY_JUMP ch_W, on_up_arrow

    ON_KEY_JUMP ch_left_arrow, on_left_arrow
    ON_KEY_JUMP ch_a, on_left_arrow
    ON_KEY_JUMP ch_A, on_left_arrow

    ON_KEY_JUMP ch_right_arrow, on_right_arrow
    ON_KEY_JUMP ch_d, on_right_arrow
    ON_KEY_JUMP ch_D, on_right_arrow

on_down_arrow:
    call handle_down_arrow
    jp read_loop
on_up_arrow:
    call handle_up_arrow
    jp read_loop
on_left_arrow:
    call handle_left_arrow
    jp read_loop
on_right_arrow:
    call handle_right_arrow
    jp read_loop

    ret

init_screen:
    ld hl, (screen_data)
    ld b, 0
    ld c, sc_offs_start_x
    add hl, bc

    ld a, (hl)
    ld (avatar_x), a

    ld hl, (screen_data)
    ld b, 0
    ld c, sc_offs_start_y
    add hl, bc

    ld a, (hl)
    ld (avatar_y), a

    call rom_clear_screen
    call draw_background
    call draw_avatar
    call draw_status_window_base

    ret

draw_avatar:
    ld a, (avatar_x)
    ld h, a
    ld a, (avatar_y)
    ld l, a
    call rom_set_cursor

    ld a, ch_stick_person_1
    call rom_print_a
    ret

clear_avatar:
    ld a, (avatar_x)
    ld h, a
    ld a, (avatar_y)
    ld l, a
    call rom_set_cursor

    ld a, " "
    call rom_print_a
    ret

exploration_ui_movement_count = 0
.macro EXPLORATION_UI_MOVEMENT &INC_OR_DEC, &CHANGE_REG, &CHANGE_ADDR
    ld a, (avatar_x)
    ld h, a
    ld a, (avatar_y)
    ld l, a

    &INC_OR_DEC &CHANGE_REG

    call can_player_enter_hl
    cp a, 0
    jp nz, exit_exploration_ui_movement_{exploration_ui_movement_count}

    call clear_avatar

    ld a, (&CHANGE_ADDR)
    &INC_OR_DEC a
    ld (&CHANGE_ADDR), a

    call draw_avatar
exit_exploration_ui_movement_{exploration_ui_movement_count}:
    ret
exploration_ui_movement_count = exploration_ui_movement_count + 1
.endm

handle_down_arrow:
    EXPLORATION_UI_MOVEMENT inc, l, avatar_y

handle_up_arrow:
    EXPLORATION_UI_MOVEMENT dec, l, avatar_y

handle_left_arrow:
    EXPLORATION_UI_MOVEMENT dec, h, avatar_x

handle_right_arrow:
    EXPLORATION_UI_MOVEMENT inc, h, avatar_x

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

; returns the address into screen data at column H, row L into HL
; Destroys A, BC
get_background_address:
    ; coordinates are 1-based, so drop down to 0-based
    dec h
    dec l
    ; data is stored in row strings of 20 chars (21 bytes)
    ld a, 21
    ld b, l
    call mul_a_b

    add a, h

    ld b, 0
    ld c, a
    ld hl, (screen_data)
    add hl, bc

    ret

; If the player may walk to column H, row L, A is zero. Otherwise, A is non-zero
; Destroys HL
can_player_enter_hl:
    ld a, h
    cp a, 1
    jp z, col_good
    jp c, cannot_enter

    cp a, 20
    jp z, col_good
    jp nc, cannot_enter

col_good:
    ld a, l
    cp a, 1
    jp z, position_good
    jp c, cannot_enter

    cp a, 8
    jp z, position_good
    jp nc, cannot_enter

position_good:
    call get_background_address
    ld a, (hl)
    sub a, " "
    ret

cannot_enter:
    ld a, 1
    ret

draw_status_window_base:
    ld h, 21
    ld l, 1
    call rom_set_cursor

    ld hl, (screen_data)
    ld bc, sc_offs_title
    add hl, bc
    call print_string
    ret
.endlocal
