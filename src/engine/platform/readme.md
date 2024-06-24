# Platform API

Each supported platform has a an `asm` file here that implements the required interface methods, as well as any character mapping for the platform.

## Required Subroutines
|Name|Description|
|-|-|
|`print_a`|Takes a character in `a`, and prints it to the current cursor location, and advances the cursor location forward. Must also preserve HL and DE!|
|`set_cursor_hl`|Sets the cursor location to column `h`, row `l`. Coordinates should be 1-indexed, not 0!|
|`clear_screen`|clears the screen and homes the cursor|
|`keyread_a`|Reads keyboard input and returns into `a`. If no character is available, `a` is `0`|
|`inlin_hl`|Wait for the user to enter some characters, followed by enter. Returns the location of the read string in `hl`|

## Required Subroutines
|Name|Description|
|-|-|
|`random_seed_0`|One of two memory locations used by `seed_random`. Should point to something unpredictable.|
|`random_seed_1`|The other of two memory locations used by `seed_random`. Should point to something unpredictable.|
