; The screen controllers handles automatic transition between "screens," aka exploration, battle, etc.
; It requires two tables: a "room" table, and an "encounter" table. They should be separate lists of pointers to
; subroutines that run an instance of the exploration_ui or battle_ui, respectively. The indices should match the value
; placed in last_screen_exit_argument before exiting either UI, and the tables are selected via ec_door or ec_encounter
; in last_screen_exit_code.
; Note: For now, encounters always automatically return the player to the previous room.

last_screen_exit_code: .db 0
last_screen_exit_argument: .db 0

room_table_location: .dw 0
encounter_table_location: .dw 0

screen_controller_party: .dw 0
screen_controller_party_size: .db 0

last_room_id: .db 0

.local
; Points the screen controller to the room table at HL, the encounter table at BC, and the party at DE of size A
configure_screen_controller::
    ld (room_table_location), hl
    ld hl, bc
    ld (encounter_table_location), hl
    ld hl, de
    ld (screen_controller_party), hl
    ld (screen_controller_party_size), a
    ret
.endlocal

.local
run_screen_controller::
screen_loop:
    ld a, (last_screen_exit_code)

    cp a, ec_door
    jp z, run_room

    cp a, ec_encounter
    jp z, run_encounter

    ; exit if we don't know this exit code
    ret

run_room:
    ld a, (last_screen_exit_argument)
    ld (last_room_id), a
    ld b, 2
    ld hl, (room_table_location)
    call get_array_item
    ld bc, (hl)
    ld hl, bc
    call call_hl

    jp screen_loop

run_encounter:
    ld a, (last_screen_exit_argument)
    ld b, 2
    ld hl, (encounter_table_location)
    call get_array_item
    ld bc, (hl)
    ld hl, bc
    call call_hl

    ld a, ec_door
    ld (last_screen_exit_code), a
    ld a, (last_room_id)
    ld (last_screen_exit_argument), a

    jp screen_loop

.endlocal

.local
; Stores exit code A with argument B
; Destroys A
set_screen_exit_conditions::
    ld (last_screen_exit_code), a
    ld a, b
    ld (last_screen_exit_argument), a
    ret
.endlocal

.local
; Stores exit code A with argument B and sets A to 1 to flag exit from exploration_ui
flag_exploration_exit_with_conditions::
    call set_screen_exit_conditions
    ld a, 1
    ret
.endlocal

.macro EXIT_EXPLORATION &EXIT_CODE, &EXIT_ARG
    ld a, &EXIT_CODE
    ld b, &EXIT_ARG
    call flag_exploration_exit_with_conditions
.endm
