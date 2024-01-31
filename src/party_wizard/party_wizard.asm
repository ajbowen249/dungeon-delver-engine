#include "default_party_ui.asm"
#include "party_size_ui.asm"

.local
; Sets up a party of 1-4 players and inserts them into the array starting at HL
party_wizard::
    call default_party_ui
    cp a, 0
    jp nz, exit


    call party_size_ui

exit:
    ret
.endlocal
