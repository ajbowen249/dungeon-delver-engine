; ZX Spectrum Adaptor Layer

; Note that the full Z80 syntax should be available within this file.

#include "./zx_spectrum/character_map.asm"
#include "./zx_spectrum/api_impl.asm"

#define seconds_10s $F934
#define seconds_1s $F933

; TODO: find something for a seed
#define random_seed_0 0
#define random_seed_1 1

#define ex_view_col 6
#define ex_view_row 3

#define ex_message_col 6
#define ex_message_row 11

#define ex_title_col 1
#define ex_title_row 1

#define ra_ability_label_col 7
#define ra_ability_label_row 5
#define ra_instructions_col 8
#define ra_instructions_row 14

#define ba_action_menu_column 1
#define ba_action_menu_row 9
#define ba_message_row 6
#define ba_cast_damage_colum 22
#define ba_victory_col 12
#define ba_game_over_col 11
#define ba_end_msg_row 12

#define ch_pause_escape_key ch_delete

#define ex_avatar_char ch_stick_person_1
