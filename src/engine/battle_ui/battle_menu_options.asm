#define bm_option_attack_value $01
#define bm_option_cast_value $02
#define bm_option_move_value $03
#define bm_option_inspect_value $FD
#define bm_option_end_turn_value $FE

opt_bm_root:
.db bm_option_attack_value
bm_root_attack_flags: .db default_options_flags
.dw opt_bm_option_attack_label

.db bm_option_cast_value
bm_root_cast_flags: .db default_options_flags
.dw opt_bm_option_cast_label

.db bm_option_move_value
bm_root_move_flags: .db default_options_flags
.dw opt_bm_option_move_label

.db bm_option_inspect_value
.db default_options_flags
.dw opt_bm_option_inspect_label

.db bm_option_end_turn_value
.db default_options_flags
.dw opt_bm_option_end_turn_label

#define opt_bm_root_option_count 5

consolidated_battle_menu: ; Can only show 7 options at the moment
.block mi_data_size * 7, 0
