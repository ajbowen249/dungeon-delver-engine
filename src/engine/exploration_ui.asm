.local

blank_19_char_string: .asciz "                   "
blank_20_char_string: .asciz "                    "

screen_data: .dw 0

background_index: .dw 0

avatar_data:
avatar_x: .db 0
avatar_y: .db 0

party_location: .dw 0
party_size: .db 0

position_changed: .db 0
near_interactable: .db 0
auto_interact: .db 0
should_exit: .db 0

.macro EX_UI_LOAD_AVATAR_LOCATION_INTO_HL
    ld a, (avatar_x)
    ld h, a
    ld a, (avatar_y)
    ld l, a
.endm

; Displays the exploration screen until exited
; HL should contain a pointer to the party array, and A should contain party size.
; BC should contain a pointer to the screen data
exploration_ui::
    ld (party_location), hl
    ld (party_size), a

    ld hl, bc
    ld (screen_data), hl

    ld a, 255
    ld (near_interactable), a

    ld a, 0
    ld (should_exit), a

    call init_screen
    call configure_inputs

read_loop:
    ld a, (dde_should_exit)
    cp a, 0
    jp nz, exit_exploration

    ld a, 0
    ld (position_changed), a
    ld (auto_interact), a

    ld a, (should_exit)
    cp a, 0
    jp nz, exit_exploration

    ; IMPROVE: stack-based input table instead of static
    call configure_inputs
    call iterate_input_table

    ld a, (position_changed)
    cp a, 0
    call nz, on_position_changed

    ld a, (auto_interact)
    cp a, 0
    call nz, on_interact

    jp read_loop

exit_exploration:
    ret

init_screen:
    ld hl, (screen_data)
    LOAD_A_WITH_ATTR_THROUGH_HL sc_offs_start_x
    ld (avatar_x), a

    ld hl, (screen_data)
    LOAD_A_WITH_ATTR_THROUGH_HL sc_offs_start_y
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

on_down_arrow:
    EXPLORATION_UI_MOVEMENT inc, l, avatar_y

on_up_arrow:
    EXPLORATION_UI_MOVEMENT dec, l, avatar_y

on_left_arrow:
    EXPLORATION_UI_MOVEMENT dec, h, avatar_x

on_right_arrow:
    EXPLORATION_UI_MOVEMENT inc, h, avatar_x

on_confirm:
    ld a, (near_interactable)
    cp a, 255
    call nz, on_interact
    ret

on_escape:
    ld hl, (screen_data)
    ld bc, sc_offs_menu_callback
    add hl, bc
    ld bc, (hl)
    ld hl, bc
    call call_hl

    ld a, (dde_should_exit)
    cp a, 0
    jp nz, on_escape_done

    call rom_clear_screen
    call draw_background
    call draw_avatar
    call draw_status_window_base

on_escape_done:
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
    call print_compressed_string
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
    call clear_exploration_message_area
    ; first check to see if we've stepped on something
    EX_UI_LOAD_AVATAR_LOCATION_INTO_HL
    ld b, $01
    ld c, $01
    call search_interactables_at_hl
    cp a, 255
    jp nz, on_position_changed_stepped_on_interactable

    ; then look "around" the player for something we can button interact with
    call find_interactable_around_avatar

    cp a, 255
    jp z, on_position_changed_no_interactable

    jp on_position_changed_found_interactable

on_position_changed_stepped_on_interactable:
    ld e, a
    ld a, 1
    ld (auto_interact), a
    ld a, e
on_position_changed_found_interactable:
    ld (near_interactable), a

    ld hl, (screen_data)
    ld bc, sc_offs_get_interaction_prompt
    add hl, bc
    ld bc, (hl)
    ld hl, bc
    call call_hl

    ld bc, hl

    PRINT_AT_LOCATION 2, 21, bc

    ret

on_position_changed_no_interactable:
    ld a, 255
    ld (near_interactable), a
    ret

on_interact:
    ; make sure it's still active (last interaction could have disabled it)
    ld hl, (screen_data)
    ld bc, sc_offs_interactables_start
    add hl, bc
    ld a, (near_interactable)
    ld b, in_data_length
    call get_array_item
    ld b, 0
    ld c, in_row_offset
    add hl, bc
    ld a, (hl)
    cp a, 0
    jp z, interact_bail
    inc hl
    ld a, (hl)
    cp a, 0
    jp z, interact_bail

    ld hl, (screen_data)
    ld bc, sc_offs_interact_callback
    add hl, bc
    ld bc, (hl)
    ld hl, bc

    ld a, (near_interactable)
    call call_hl

    ; a has our exit flag now
    ld (should_exit), a

interact_bail:
    ret

clear_exploration_message_area::
    ld a, 6
    ld hl, clear_exploration_message_area_callback
    call iterate_a

    PRINT_AT_LOCATION 8, 21, blank_19_char_string
    ret

clear_exploration_message_area_callback:
    add a, 2
    PRINT_AT_LOCATION a, 21, blank_20_char_string
    ret

configure_inputs:
    REGISTER_INPUTS on_up_arrow, on_down_arrow, on_left_arrow, on_right_arrow, on_confirm, on_escape, 0, 0
    ret
.endlocal

.local

; if the flag at BC is set, clear the interactable at HL. Needs screen graphic data at DE
; Uses A
clear_interactable_if_flag::
    push hl

    ld hl, bc
    ld a, (hl)
    cp a, 0
    jp z, flag_not_set

    pop hl
    push hl
    LOAD_A_WITH_ATTR_THROUGH_HL in_row_offset
    dec a ; 1-based
    ld b, 21
    call mul_a_b
    ld b, a

    pop hl
    push hl
    push bc
    LOAD_A_WITH_ATTR_THROUGH_HL in_col_offset
    dec a ; 1-based
    pop bc
    add a, b

    ld c, a
    ld b, 0
    ld hl, de
    add hl, bc
    ld a, " "
    ld (hl), a

    pop hl
    POINT_HL_TO_ATTR in_row_offset
    ld a, 0
    ld (hl), a
    inc hl
    ld (hl), a
    ret

flag_not_set:
    pop hl
    ret
.endlocal

.macro CLEAR_INTERACTABLE_IF_FLAG &FLAG_LABEL, &INTERACTABLE_LABEL, &BACKGROUND_GRAPHIC_LABEL
    ld bc, &FLAG_LABEL
    ld hl, &INTERACTABLE_LABEL
    ld de, &BACKGROUND_GRAPHIC_LABEL
    call clear_interactable_if_flag
.endm

.local
; if the flag in BC is set, clear the graphic at column H, row L, starting from DE
; uses A
clear_graphic_if_flag::
    push hl

    ld hl, bc
    ld a, (hl)
    cp a, 0
    jp z, flag_not_set

    pop hl
    dec h
    dec l
    ld a, l
    ld b, 21
    call mul_a_b

    add a, h
    ld c, a
    ld b, 0
    ld hl, bc
    add hl, de
    ld a, " "
    ld (hl), a

    ret

flag_not_set:
    pop hl
    ret
.endlocal

.macro CLEAR_GRAPHIC_IF_FLAG &FLAG_LABEL, &ROW, &COL, &BACKGROUND_GRAPHIC_LABEL
    ld bc, &FLAG_LABEL
    ld h, &COL
    ld l, &ROW
    ld de, &BACKGROUND_GRAPHIC_LABEL
    call clear_graphic_if_flag
.endm
