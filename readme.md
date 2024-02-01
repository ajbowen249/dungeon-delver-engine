# Dungeon Delver Engine

![demo](/gh_media/roll_abilities_demo.gif)

This is an implementation of a limited subset of [OGL-SRD 5.1](https://dnd.wizards.com/resources/systems-reference-document) for the [Tandy TRS-80 Model 100](https://en.wikipedia.org/wiki/TRS-80_Model_100).

## Building

This project uses [zasm](https://k1.spdns.de/Develop/Projects/zasm/Documentation/index.html) and [make](https://www.gnu.org/software/make/manual/make.html). To build all campaigns and run the unit tests, just run `make` from the project root. This should create one or more `.hex` files under `build`. The engine currently powers one "test" campaign, though more may come eventually. If you only care to build a specific campaign, use `make <campaign name>`.

## System Requirements

DDE is designed for systems with at least 24k of RAM (i.e, `21446` Bytes Free upon cold boot).

## Running

Select a campaign, and find its hex file. For now, only the raw binary is created. A build step that adds a `CO` file header is coming _Eventually™_. All campaigns are meant to be loaded at `$C000` (`49152`). This process will eventually be less painful.

Before either method, get into the BASIC prompt and run `clear 256, 49152`.

### Physical Model 100

If you have a serial connection established with a PC running an application that can send ascii files, you can use the `loadhx.ba` BASIC program under `utils`. It will wait for an intel hex format file to be sent over `COM:88N1E` and `POKE` each byte into memory beginning at `$C000`. You'll want to run the `clear` command above before loading `loadhx` into BASIC. It will immediately start waiting for the first byte of the hex file when run, so start it before triggering file send.

> **Note:** This has only been tested with [`Tera Term`](https://tera-term.en.softonic.com/) and a 50ms delay between characters.

### Virtual-T

Using the [Virtual-T](https://sourceforge.net/projects/virtualt/) emulator, first run `clear 256, 49152`. Then, using the `Memory Editor` tool, load the output hex file starting and address `$C000`.

#### Once Loaded

Once the binary is loaded into memory through any method, you can also save it with `savem "<name>", 49152,<end address>,49152`. `<end address>` will vary by build, and is `49152` + file size (of the binary, not the hex file). `<name>` is capped at 6 chars on the Model 100, so pick anything you'll remember for the given campaign name.

## Architecture

The `E` in `DDE` stands for `Engine` because it is structured as a set of modules designed to present gameplay components to progress through campaigns designed for SRD 5.1 (though many features will be left unimplemented). The top-level entry points are under `src/entry_points`, and they include `src/dde.asm`. This means everything within `DDE` itself could end up located anywhere once assembled, depending on the campaign. `src/entry_points` also contains the unit tests entry point.

### Syntax

Even though this is for an 8085 CPU, It's using Z80 Assembler syntax. This is a feature of `zasm`, and additional Z80 instructions not available in i8080 are disabled via the `--8080` flag. This is encouraged by `zasm` as i8080 mnemonics are harder to read, and this author already has some familiarity with Z80 syntax as well.

### User Interface

The user interface is divided into three levels:

- **Components** - Re-usable data entry screens
- **UIs** - Specific, modal screens that get data and may or may not extend a component
- **Wizards** - Multi-step processes that show multiple modal UIs in sequence

Note that a "Component" in this context is a configurable singular UI (for example, `enum_menu` allows selection from a list of options all shown on one screen), rather than a sub-screen element that would share the screen with other components.

All three levels are implemented as subroutines with the same calling convention as the Model 100 ROM routines, where arguments and return values (or pointers thereto) are passed in registers. For example, the Character Wizard accepts a pointer to character data that will be filled in completely by the time it exits. The individual screens' function interfaces each set up their data by exit, too, which is wrangled into place by the Wizard between steps. Further down, each screen of that UI may or may not defer some of its work to a common Component.

Since each screen does so much, you may generally expect all registers to be destroyed or set to an exit condition with each call. Also of note is that _all screens are currently static_, rather than using stack space for their local data. This may change eventually, but, for now, as a general rule, UI pages _should not nest calls to one another_. It should technically be fine for unrelated screens to nest calls, but a screen can't, for example, use an `enum_menu` and nest a call to another screen that uses an `enum_menu`, since the second would overwrite the first's workspace.

### Unit Tests
Tests are located in `entry_points/tests.asm`, and are compiled and run automatically by `zasm`. They can be run individually with `make test`.
