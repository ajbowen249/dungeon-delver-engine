# Dungeon Delver Engine

This is an implementation of a limited subset of [OGL-SRD 5.1](https://dnd.wizards.com/resources/systems-reference-document) for the [Tandy TRS-80 Model 100](https://en.wikipedia.org/wiki/TRS-80_Model_100) and [ZX Spectrum](https://en.wikipedia.org/wiki/ZX_Spectrum).

![demo](/gh_media/battle_demo.gif)
![demo](/gh_media/exploration_demo.gif)
![demo](/gh_media/skill_check_demo.gif)
![demo](/gh_media/roll_abilities_demo.gif)

![demo](/gh_media/zx_spectrum_demo.gif)


## Building

### Basics
This project requires [`zasm`](https://k1.spdns.de/Develop/Projects/zasm/Documentation/index.html) and [`python 3`](https://www.python.org/). The build system is [`waf`](https://waf.io/), which itself is built on Python, and the `waf` "executable" is versioned alongside this project. To use `waf`, you can invoke it with `./waf` on *nix platforms, or use `./waf.bat` on Windows. It's recommended, especially if you use other `waf` projects, to set up an alias to make invocation simpler (such as `alias waf=./waf`).

When you first check the project out (or after pulling down updates), you'll first want to run `waf configure`, which will set up some paths and ensure it can find `zasm`. This step will fail if `zasm` is not in your `PATH`, or if your python version is below 3.

After that, simply run `waf` to build all outputs and run unit tests. You'll usually only need to run `waf configure` after changes to the build script, or to make changes to your selected options.

### ZX Spectrum (Experimental)

The ZX Spectrum build is currently disabled by default until stabilized. To enable it, pass `zx_spectrum` to `waf configure`'s `--platform` option. You can supply it on its own, or with both platforms:

```shell
# Spectrum on its own
waf configure --platforms=zx_spectrum
# Spectrum and Model 100
waf configure --platforms=trs80_m100,zx_spectrum
```

When you select the `zx_spectrum` platform, `waf configure` will also ensure you have [`bin2tap`](https://sourceforge.net/p/zxspectrumutils/wiki/bin2tap/) (from [`zxspectrum-utils`](https://sourceforge.net/projects/zxspectrumutils/)) available in your path. This is required to package the raw binary output from `zasm` into a tape format with a `BASIC` bootloader.

> **Note:** The reason this is disabled by default is that the build will currently fail on the first pass when calling `bin2tap`. Simply invoking `waf` multiple times _does_ eventually produce a working `tap` file.


## System Requirements

### TRS80-Model 100
DDE is designed for systems with at least 24k of RAM (i.e, `21446` Bytes Free upon cold boot).

### ZX Spectrum
DDE is designed for systems with at least 48k of RAM.

## Running

Built into this project is a test campaign that flexes features of the engine. Other projects that wish to use this engine should be able to utilize this engine to create bigger experiences.

### TRS-80 Model 100
The build process creates raw binaries in two formats for the "Test Campaign," which should be output at `build/trs80_m100/test_campaign.co` and `build/trs80_m100/test_campaign.hex`. The former is a Model 100 `.co`-format machine language program file, and the `.hex` file is an Intel Hex format encoding of the raw campaign binary.

> Note: So far, both the large flagship project and even the small test campaign are already too large for the `.co` file to be saved to the Model 100's internal storage.

#### From Cassette

With help from [majick](https://github.com/majick), the build script produces a `.co`-formatted file binary file. This file is too large to work in the Model 100's built-in storage, but can be loaded up through the cassette interface. This is currently only confirmed working on [CloudT](https://bitchin100.com/CloudT/#!/M100Display), but should, theoretically, work on a stock Model 100 when loaded through the cassette interface as well. To run it on CloudT:

1. Enter BASIC, and run `clear 256,43776`
2. Click "Choose File," and select `test_campaign.co`
3. Run `cloadm`
4. When it's done loading, run `call 43776`

#### Physical Model 100 With Just a Serial Cable

If you have a serial connection established with a PC running an application that can send ascii files, this repository includes a two-step process to transfer the campaign binary to it. For the first step, run `clear 256, 43264`, as we'll be using some higher memory than the campaign itself. Transfer the `loadhx.ba` BASIC program under `utils` to your machine and start it up. It will await an intel hex format file and begin poking it into `$A900` (`43264`). Send over `build/trs80_m100/ldhx.hex`. Note that this first loader script is slow, and has only been proven to work consistently through [`Tera Term`](https://tera-term.en.softonic.com/) with a 50ms delay between characters. It will only be used to load the faster loader. When it is complete, an assembly-language version of essentially this same application will be loaded, and you can save it for easier re-use now with `savem "ldhx",43264,43674,43264`. Before saving, you'll want to delete the original `loadhx.do` file to make some room.

Once the fast loader is loaded, running it will once again wait for an intel hex format file, only now it will begin inserting at `$AB00` (`43776`). This loader is much faster, and has proven stable with only a 5ms delay between characters. Once it's done loading, start it up with `call 43776`.

> **Note:**: Both loaders hardcode the serial port `STAT` value to `88N1E`. Ensure your serial terminal is configured appropriately.

#### Virtual-T

Using the [Virtual-T](https://sourceforge.net/projects/virtualt/) emulator, first run `clear 256,43776`. Then, using the `Memory Editor` tool, load the output `.hex` file starting at address `$AB00`. Once that is done, you can run it with `call 43776`.

### ZX Spectrum

If configured to build for the Spectrum, a `tap` file will be available at `build/zx_spectrum/test_campaign.tap`. You can load it like any other tape with `LOAD ""`. This has so far only been verified via the [`Fuze`](https://fuse-emulator.sourceforge.net/) emulator set to the `Spectrum 48k` ROM, and has not been verified on physical hardware.

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
    - Normal melee rules apply when attacker and defender are 1 line apart (both in the "front"). If both players are in the back line, they are out of melee range. If one player is in the back and the other the front, the attacker has disadvantage. (If there was a hard range cutoff, then ranged characters could always beat melee-only combatants by never going up front in this system.)
    - Ranged combat currently just assumes players are in the spell's normal range.

## Controls

On all platforms, both arrow keys and `WASD` are supported for movement and navigating menus. `ENTER` is used to select menu options and interact with interactables. On the Model 100, the `ESC` key can be used to bring up the menu and cancel combat attacks and casting. That key is `DELETE` (backspace) for the ZX Spectrum.

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
Tests are located in `src/apps/tests/main.asm`, and are compiled and run automatically by `zasm` when the file is assembled.
