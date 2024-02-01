.local

hard_screen_data:
hard_screen_background:
.asciz "┌──────────────────┐"
.asciz "│    α              "
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
interactables:
    DEFINE_INTERACTABLE chest_1, in_chest, 0, 3, 13
    DEFINE_INTERACTABLE door_1, in_door, $01, 2, 20
    DEFINE_INTERACTABLE blank_3, 0, 0, 0, 0
    DEFINE_INTERACTABLE blank_4, 0, 0, 0, 0
    DEFINE_INTERACTABLE blank_5, 0, 0, 0, 0
    DEFINE_INTERACTABLE blank_6, 0, 0, 0, 0
    DEFINE_INTERACTABLE blank_7, 0, 0, 0, 0
    DEFINE_INTERACTABLE blank_8, 0, 0, 0, 0
    DEFINE_INTERACTABLE blank_9, 0, 0, 0, 0
    DEFINE_INTERACTABLE blank_0, 0, 0, 0, 0
screen_data: .dw 0

background_index: .dw 0

avatar_data:
avatar_x: .db 0
avatar_y: .db 0

party_location: .dw 0
party_size: .db 0

position_changed: .db 0

.macro EX_UI_LOAD_AVATAR_LOCATION_INTO_HL
    ld a, (avatar_x)
    ld h, a
    ld a, (avatar_y)
    ld l, a
.endm

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

    ld b, a
    ld a, 0
    ld (position_changed), a
    ld a, b

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
    jp read_loop_continue
on_up_arrow:
    call handle_up_arrow
    jp read_loop_continue
on_left_arrow:
    call handle_left_arrow
    jp read_loop_continue
on_right_arrow:
    call handle_right_arrow
    jp read_loop_continue

read_loop_continue:
    ld a, (position_changed)
    call nz, on_position_changed

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
    EX_UI_LOAD_AVATAR_LOCATION_INTO_HL
    call rom_set_cursor

    ld a, ch_stick_person_1
    call rom_print_a
    ret

clear_avatar:
    EX_UI_LOAD_AVATAR_LOCATION_INTO_HL
    call rom_set_cursor

    ld a, " "
    call rom_print_a
    ret

exploration_ui_movement_count = 0
.macro EXPLORATION_UI_MOVEMENT &INC_OR_DEC, &CHANGE_REG, &CHANGE_ADDR
    EX_UI_LOAD_AVATAR_LOCATION_INTO_HL

    &INC_OR_DEC &CHANGE_REG

    call can_player_enter_hl
    cp a, 0
    jp nz, exit_exploration_ui_movement_{exploration_ui_movement_count}

    ld a, 1
    ld (position_changed), a

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


interactable_search_row: .db 0
interactable_search_col: .db 0
interactable_search_index: .db 0
interactable_search_flags .db 0
interactable_search_flags_mask .db 0

; Sets A to index of the first interactable found at col H row L
; B should contain desired flags, and C should contain the mask flag
; A is 255 if none are found
search_interactables_at_hl:
    ld a, l
    ld (interactable_search_row), a
    ld a, h
    ld (interactable_search_col), a

    ld a, b
    and a, c
    ld (interactable_search_flags), a

    ld a, c
    ld (interactable_search_flags_mask), a

    ld de, hl

    ld a, 0
    ld (interactable_search_index), a

search_interactables_at_hl_loop:
    ld hl, (screen_data)
    ld bc, sc_offs_interactables_start
    add hl, bc

    ld a, (interactable_search_index)
    ld b, in_data_length
    call mul_a_b

    ld b, 0
    ld c, a
    add hl, bc

    ld bc, in_flags_offset
    add hl, bc

    ld a, (interactable_search_flags)
    ld b, a
    ld a, (interactable_search_flags_mask)
    ld c, a
    ld a, (hl)
    and a, c
    cp a, b
    jp nz, search_interactables_at_hl_continue

    inc hl
    ld a, (hl)
    cp a, e
    jp nz, search_interactables_at_hl_continue

    inc hl
    ld a, (hl)
    cp a, d
    jp nz, search_interactables_at_hl_continue

    ld a, (interactable_search_index)
    ret

search_interactables_at_hl_continue:
    ld a, (interactable_search_index)
    inc a
    ld (interactable_search_index), a
    cp sc_interactable_array_elements
    jp nz, search_interactables_at_hl_loop

    ld a, 255
    ret

; searches above, below, left, and right of the party avatar for interactables
; A is set to the index of the first found interactable. Otherwise, 0
; Excludes "trigger" items from the search, since you need to stand on them to activate
find_interactable_around_avatar:
.macro EX_UI_FIND_INTERACTABLE_CHECK_LOCATION
    ld b, 0
    ld c, $01
    call search_interactables_at_hl
    cp a, 255
    jp nz, find_interactable_around_avatar_found
.endm

    EX_UI_LOAD_AVATAR_LOCATION_INTO_HL
    dec l
    EX_UI_FIND_INTERACTABLE_CHECK_LOCATION

    EX_UI_LOAD_AVATAR_LOCATION_INTO_HL
    inc l
    EX_UI_FIND_INTERACTABLE_CHECK_LOCATION

    EX_UI_LOAD_AVATAR_LOCATION_INTO_HL
    dec h
    EX_UI_FIND_INTERACTABLE_CHECK_LOCATION

    EX_UI_LOAD_AVATAR_LOCATION_INTO_HL
    inc h
    EX_UI_FIND_INTERACTABLE_CHECK_LOCATION

find_interactable_around_avatar_found:
    ret

on_position_changed:
    ; first check to see if we've stepped on something (this will auto-interact eventually)
    EX_UI_LOAD_AVATAR_LOCATION_INTO_HL
    ld b, $01
    ld c, $01
    call search_interactables_at_hl
    cp a, 255
    jp nz, on_position_changed_found_interactable

    ; then look "around" the player for something we can button interact with
    call find_interactable_around_avatar

    cp a, 255
    jp z, on_position_changed_end

on_position_changed_found_interactable:
    ld e, a
    ld h, 21
    ld l, 2
    call rom_set_cursor

    ld d, 0
    ld bc, glob_de_to_hex_str_buffer
    call de_to_hex_str

    ld hl, bc
    call print_string

on_position_changed_end:
    ret
.endlocal
