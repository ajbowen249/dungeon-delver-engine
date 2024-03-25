# Dungeon Delver Engine

_All screens extremely WIP_
![demo](/gh_media/battle_demo.gif)
![demo](/gh_media/cantrips_demo.gif)
![demo](/gh_media/exploration_demo.gif)
![demo](/gh_media/skill_check_demo.gif)
![demo](/gh_media/roll_abilities_demo.gif)

This is an implementation of a limited subset of [OGL-SRD 5.1](https://dnd.wizards.com/resources/systems-reference-document) for the [Tandy TRS-80 Model 100](https://en.wikipedia.org/wiki/TRS-80_Model_100).

## Building

This project uses [zasm](https://k1.spdns.de/Develop/Projects/zasm/Documentation/index.html), [make](https://www.gnu.org/software/make/manual/make.html), and [python 3](https://www.python.org/). To build the unit tests and the test campaign, run `make` from the project root. To only build and run the tests, use `make test`.

## System Requirements

DDE is designed for systems with at least 24k of RAM (i.e, `21446` Bytes Free upon cold boot).

## Running

Built into this project is a test campaign that flexes features of the engine. Other projects that wish to use this engine should be able to simply use `zasm` with the `--8080` argument and include `src/engine/dde.asm`.

Only the raw binary is created for the test campaign, at `build/test_campaign.hex`. It is meant to be loaded at `$B200` (`45568`).

Before either method, get into the BASIC prompt and run `clear 256, 45568`.

### Physical Model 100

If you have a serial connection established with a PC running an application that can send ascii files, this repository includes a two-step process to transfer the campaign binary to it. For the first step, run `clear 256, 45056`, as we'll be using some higher memory than the campaign itself. Transfer the `loadhx.ba` BASIC program under `utils` to your machine and start it up. It will await an intel hex format file and begin poking it into `$B000` (`45056`). Send over `build/ldhx.hex`. Note that this first loader script is slow, and has only been proven to work consistently through [`Tera Term`](https://tera-term.en.softonic.com/) with a 50ms delay between characters. It will only be used to load the faster loader. When it is complete, an assembly-language version of essentially this same application will be loaded, and you can save it for easier re-use now with `savem "ldhx",45056,45560,45056`. Once this is complete, you'll want to delete the original `loadhx.do` file to make some room.

Once the fast loader is loaded, running it will once again wait for an intel hex format file, only now it will begin inserting at `$B200` (`45568`). This loader is much faster, and has proven stable with only a 5ms delay between characters.

### Virtual-T

Using the [Virtual-T](https://sourceforge.net/projects/virtualt/) emulator, first run `clear` command above. Then, using the `Memory Editor` tool, load the output hex file starting at address `$B200`.

#### Once Loaded

Once the binary is loaded into memory through any method, you can run it with `call 45568`. Note that the binary size is currently unoptimized, and the test campaign appears to already exceed the size that a 24k machine can save for later via the `savem` command.

## Gameplay

DDE follows a typical RPG setup with screens for exploration, combat, and dialog interactions. It has a handful of simplifications from the full OGL 5.1 experience. These may eventually be expanded on, but not with any current concrete plans:
1. **Automatic Leveling**: Choices normally offered to players when advancing their level are not implemented. Instead, things like spells or specializations are hardcoded for each level of each class.
    - This also means that spell preparation is automatic, and a caster will never learn more spells than they can have prepared.
    - This may also end up applying to equipment. Shops and inventory management are currently a stretch goal.
2. **Automatic Resting**: It is simply implied, for now, that the party takes a long rest after each combat encounter. HP, Spell Slots, and other resources that regenerate with rest automatically reset after each encounter.
3. **Combat Positioning**: Combat takes a simplified, JRPG-inspired approach of having "battle rows," where each player may be at the "front" or "back" of their respective line. This is swizzled with SRD rules as follows:
    - Each side has its own two lines, for a total of 4.
    - Players are limited to their side's lines.
    - Players may move between lines at least once each turn.
        - Stretch goal: Allow players with a high enough movement speed to make multiple moves in one turn.
    - Normal melee rules apply when attacker and defender are 1 line apart (both in the "front"). If both players are in the back line, they are out of melee range. If one player is in the back and the other the front, the attacker has disadvantage. (If there was a hard range cutoff, then ranged characters could always beat melee-only combatants by never going up front in this system.)
    - Ranged attacks more-or-less follow SRD rules, but the range is determined by battle line distance, and ranges of weapons and spells are defined in terms of that distance. For example, a short bow may work normally with the attacker in the back and the defender in the front, and have disadvantage if the defender is also in the back. A long bow, then, would not have disadvantage at long distance. Both bows would have disadvantage if both attacker and defender are in the front.
    - Stretch goal: Opportunity attacks still fit in with this system, if you consider 1 line of distance normal melee range.

## Architecture

The `E` in `DDE` stands for `Engine` because it is structured as a set of modules designed to present gameplay components to progress through campaigns designed for SRD 5.1 (though many features will be left unimplemented). This project's top-level entry points are under `src/apps`, and they include `src/engine/dde.asm`. This means everything within `DDE` itself could end up located anywhere once assembled, depending on the campaign. Currently, the two apps are the unit tests and a test campaign. This may expand to include a faster version of the hex loader in assembly, or a more-substantial example campaign.

As mentioned, other projects that wish to use this engine should be able to simply include this project (submodule, etc.), then `#include "(dde root)/src/engine/dde.asm"` in their source, and compile their root file with `zasm` and the `--8080` flag.

### Syntax

Even though this is for an 8085 CPU, It's using Z80 Assembler syntax. This is a feature of `zasm`, and additional Z80 instructions not available in i8080 are disabled via the `--8080` flag. This is encouraged by `zasm` as i8080 mnemonics are harder to read, and this author already has some familiarity with Z80 syntax as well.

### User Interface

The user interface is divided into three levels:

- **Components** - Re-usable data entry screens
- **UIs** - Specific, modal screens that get data and may or may not extend a component
- **Wizards** - Multi-step processes that show multiple modal UIs in sequence

Note that a "Component" in this context is a configurable singular UI (for example, `menu` allows selection from a list of options all shown on one screen), rather than a sub-screen element that would share the screen with other components.

All three levels are implemented as subroutines with the same calling convention as the Model 100 ROM routines, where arguments and return values (or pointers thereto) are passed in registers. For example, the Character Wizard accepts a pointer to character data that will be filled in completely by the time it exits. The individual screens' function interfaces each set up their data by exit, too, which is wrangled into place by the Wizard between steps. Further down, each screen of that UI may or may not defer some of its work to a common Component.

Since each screen does so much, you may generally expect all registers to be destroyed or set to an exit condition with each call. Also of note is that _all screens are currently static_, rather than using stack space for their local data. This may change eventually, but, for now, as a general rule, UI pages _should not nest calls to one another_. It should technically be fine for unrelated screens to nest calls, but a screen can't, for example, use a `menu` and nest a call to another screen that uses a `menu`, since the second would overwrite the first's workspace.

### Screen Controller
The subroutines in `screen_controller` allow for simple setup of the exploration/combat loop. By registering "room" and "encounter" tables and the player party, one can create subroutines that wrap the `exploration_ui` and `combat_ui`. The combat UI will always exit to the last room, and the exploration UI can exit to either another exploration wrapper or combat wrapper by setting `last_screen_exit_code` and `last_screen_exit_argument` before exiting. See `apps/test_campaign/screens` for examples.

### Text Compression
A simple string compression algorithm allows for apps to store their strings in a JSON file and run it through `tools/compressor` to generate an assembly file where all strings are declared, but up to 126 of the most-common sequences of characters will be extracted to the top, and a single-byte reference to each sequence in the lookup table is used as a byte in each original string with its MSB flagged. To print them, use `print_compressed_string`, `PRINT_COMPRESSED_AT_LOCATION`, or `BLOCK_PRINT`. Note that compressible text may not contain characters above value `126` (`~`), though that range does include most typeable, non-graphical characters. Make sure to include the generated output file somewhere in your source code.

If your app doesn't need to compress its text, it should still run `tools/compressor` without the `-i` argument to get the compressed core engine text and include the generated file.

### Unit Tests
Tests are located in `src/apps/tests/main.asm`, and are compiled and run automatically by `zasm`. They can be run individually with `make test`.
