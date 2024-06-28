# Platform API

Each supported platform has a an `asm` file here that implements the required interface methods, as well as any character mapping for the platform.

## Required Subroutines
|Name|Description|
|-|-|
|`print_a`|Takes a character in `a`, and prints it to the current cursor location, and advances the cursor location forward. Must also preserve HL and DE!|
|`set_cursor_hl`|Sets the cursor location to column `h`, row `l`. Coordinates should be 1-indexed, not 0! Must also preserve HL's original value.|
|`clear_screen`|clears the screen and homes the cursor|
|`keyread_a`|Reads keyboard input and returns into `a`. If no character is available, `a` is `0`|
|`inlin_hl`|Wait for the user to enter some characters, followed by enter. Returns the location of the read string in `hl`|

## Required Symbols
|Name|Description|
|-|-|
|`random_seed_0`|One of two memory locations used by `seed_random`. Should point to something unpredictable.|
|`random_seed_1`|The other of two memory locations used by `seed_random`. Should point to something unpredictable.|
|`ex_view_col`|The 1-indexed row number of the main view of the exploration UI.|
|`ex_view_row`|The 1-indexed column number of the main view of the exploration UI.|
|`ex_message_col`|The 1-indexed column number of the "message" area of the exploration UI.|
|`ex_message_row`|The 1-indexed row number of the "message" area of the exploration UI.|
|`ex_title_col`|The 1-indexed column number to place the room title in the exploration UI.|
|`ex_title_row`|The 1-indexed row number to place the room title in the exploration UI.|
|`ex_avatar_char`|The character to use as the player avatar.|
|`ch_pause_escape_key`|The character to use for "pause/escape" functionality. Usually `ch_escape`, but not every platform has an escape key.|

## Character Mappings

This project originated on the TRS-80 Model 100. Currently, the engine assumes a certain subset of its custom character set exists. This will eventually be less coupled to some degree, but, for now, check the character mapping files of the implemented platforms to see what is currently needed.
