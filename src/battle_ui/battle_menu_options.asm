#define bm_option_move_value $01
opt_bm_option_move_label: .asciz "Move"

#define bm_option_attack_value $02
opt_bm_option_attack_label: .asciz "Attack"

#define bm_option_end_turn_value $FE
opt_bm_option_end_turn_label: .asciz "End Turn"

opt_bm_root:
.db bm_option_move_value
bm_root_move_flags: .db default_options_flags
.dw opt_bm_option_move_label

.db bm_option_attack_value
bm_root_attack_flags: .db default_options_flags
.dw opt_bm_option_attack_label

.db bm_option_end_turn_value
.db default_options_flags
.dw opt_bm_option_end_turn_label

#define opt_bm_root_option_count 3
