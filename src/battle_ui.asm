.local

blank_message_string: .asciz "                               "
test_string: .asciz "Battle"

screen_data: .dw 0

party_location: .dw 0
party_size: .db 0

should_exit: .db 0

#define message_column 8

; Displays the combat screen until the encounter is resolved
; TODO: Pass pointer(s) to a block(s) of character data
battle_ui::
    ld a, 0
    ld (should_exit), a

    call init_screen

read_loop:
    ld a, (should_exit)
    cp a, 0
    jp z, keep_reading

    ret

keep_reading:
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

    ON_KEY_JUMP ch_enter, on_press_enter

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

on_press_enter:
    call handle_press_enter

    jp read_loop_continue

read_loop_continue:
    jp read_loop

    ret

init_screen:
    call rom_clear_screen
    PRINT_AT_LOCATION 2, message_column, test_string
    ret

handle_down_arrow:
    ret

handle_up_arrow:
    ret

handle_left_arrow:
    ret

handle_right_arrow:
    ret

handle_press_enter:
    ld a, 1
    ld (should_exit), a
    ret

clear_message_area:
    PRINT_AT_LOCATION 2, message_column, blank_message_string
    PRINT_AT_LOCATION 3, message_column, blank_message_string
    PRINT_AT_LOCATION 4, message_column, blank_message_string
    PRINT_AT_LOCATION 5, message_column, blank_message_string
    PRINT_AT_LOCATION 6, message_column, blank_message_string
    PRINT_AT_LOCATION 7, message_column, blank_message_string
    PRINT_AT_LOCATION 8, message_column, blank_message_string
    ret
.endlocal
