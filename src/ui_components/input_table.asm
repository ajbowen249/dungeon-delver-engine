; The input table disconnects the idea of a specific keyboard button from a conceptual control.
; For example, registering for arrow inputs includes both arrow keys and WASD.
; To use it, call the REGISTER_INPUTS macro, which takes a subroutine address for each input. Pass 0 to disable that
; input.

input_table_array:
input_table_arrow_up: .dw 0
input_table_arrow_down: .dw 0
input_table_arrow_left: .dw 0
input_table_arrow_right: .dw 0
input_table_confirm: .dw 0

.macro REGISTER_INPUT &OFFSET, &TABLE_ADDRESS
    ld hl, &OFFSET
    ld (&TABLE_ADDRESS), hl
.endm

; uses HL
.macro REGISTER_INPUTS &UP, &DOWN, &LEFT, &RIGHT, &CONFIRM
   REGISTER_INPUT &UP, input_table_arrow_up
   REGISTER_INPUT &DOWN, input_table_arrow_down
   REGISTER_INPUT &LEFT, input_table_arrow_left
   REGISTER_INPUT &RIGHT, input_table_arrow_right
   REGISTER_INPUT &CONFIRM, input_table_confirm
.endm


.local
; non-blocking call to check input and dispatch any appropriate callback. Returns immediately if there is no input
; Be sure to REGISTER_INPUTS before calling this.
iterate_input_table::
    call rom_kyread
    jp z, exit_input_table

    ON_KEY_JUMP ch_up_arrow, on_arrow_up
    ON_KEY_JUMP ch_w, on_arrow_up
    ON_KEY_JUMP ch_W, on_arrow_up

    ON_KEY_JUMP ch_down_arrow, on_arrow_down
    ON_KEY_JUMP ch_s, on_arrow_down
    ON_KEY_JUMP ch_S, on_arrow_down

    ON_KEY_JUMP ch_left_arrow, on_arrow_left
    ON_KEY_JUMP ch_a, on_arrow_left
    ON_KEY_JUMP ch_A, on_arrow_left

    ON_KEY_JUMP ch_right_arrow, on_arrow_right
    ON_KEY_JUMP ch_d, on_arrow_right
    ON_KEY_JUMP ch_D, on_arrow_right

    ON_KEY_JUMP ch_enter, on_confirm

    jp exit_input_table

.macro ON_INPUT &NAME
on_&NAME:
    ld hl, (input_table_&NAME)
    jp check_callback
.endm

    ON_INPUT arrow_up
    ON_INPUT arrow_down
    ON_INPUT arrow_left
    ON_INPUT arrow_right
    ON_INPUT confirm

check_callback:
    ld a, h
    cp a, 0
    jp nz, call_callback
    ld a, l
    cp a, 0
    jp nz, call_callback
    jp exit_input_table

call_callback:
    call call_hl

exit_input_table:
    ret

.endlocal
