#define bm_option_end_turn_value $FE
opt_bm_option_end_turn_label: .asciz "End Turn"

opt_bm_root:
.db bm_option_end_turn_value
.db default_options_flags
.dw opt_bm_option_end_turn_label
