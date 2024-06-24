; Dungeon Delver Engine
; This is a CRPG engine that implements a subset of OGL SRD 5.1

dde_version:
dde_version_major: .db 0
dde_version_minor: .db 0
dde_version_build: .db 1

dde_should_exit: .db 0

#include "math.asm"
#include "util.asm"
#include "array_util.asm"
#include "constants.asm"
#include "common_options.asm"
#include "io_interface.asm"
#include "compressed_string.asm"
#include "random.asm"
#include "dice.asm"
#include "decimal_string.asm"
#include "hex_string.asm"
#include "class_mechanics/class_mechanics.asm"
#include "enemy_logic/enemy_logic.asm"

#include "./ui_components/ui_components.asm"

#include "character_wizard/character_wizard.asm"

#include "character_sheet_ui.asm"
#include "exploration_ui.asm"
#include "skill_check_ui.asm"
#include "battle_ui/battle_ui.asm"
#include "screen_controller.asm"
