#define encounter_id_badger 1

.local
encounter_badger::
    ld hl, (screen_controller_party)
    ld a, (screen_controller_party_size)
    ld bc, monster_badger
    ld d, 1
    call battle_ui
    ret
.endlocal
