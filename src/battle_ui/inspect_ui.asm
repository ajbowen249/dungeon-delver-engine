; Takes over both sides of the battle UI to show arrow selection over combatants and shows their current status in the
; action window.
; Exits when confirm is pressed, and saves last_inspected_index, so it can be combined with menu actions

last_inspected_index: .db 0
test_str: .asciz "Inspect menu FTW!"
inspect_ui:
    call clear_action_window
    PRINT_AT_LOCATION 8, 20, test_str
    ret
