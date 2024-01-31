# Dungeon Delver Engine

![demo](/gh_media/roll_abilities_demo.gif)

This is an implementation of a limited subset of [OGL-SRD 5.1](https://dnd.wizards.com/resources/systems-reference-document) for the [Tandy TRS-80 Model 100](https://en.wikipedia.org/wiki/TRS-80_Model_100).

## Building

This project uses [zasm](https://k1.spdns.de/Develop/Projects/zasm/Documentation/index.html) and [make](https://www.gnu.org/software/make/manual/make.html). To build it, just run `make` from the project root. This should create a `build/dde.hex` file.

## Running

For now, only the raw binary is created. A build step that adds a `CO` file header is coming _Eventually™_. It is meant to be loaded a `$E290` (`58000`). This process will eventually be less painful.

Before either method, get into the BASIC prompt and run `clear 256, 58000`.

### Physical Model 100

If you have a serial connection established with a PC running an application that can send binary files, you can use the `loadhx.ba` BASIC program under `utils`. It will wait for an intel hex format file to be sent over `COM:88N1E` and `POKE` each byte into memory beginning at `$E290`. You'll want to run the `clear` command above before loading `loadhx` into BASIC. It will immediately start waiting for the first byte of the hex file when run, so start it before triggering file send.

> **Note:** This has only been tested with [`Tera Term`](https://tera-term.en.softonic.com/) and a 50ms delay between characters.

### Virtual-T

Using the [Virtual-T](https://sourceforge.net/projects/virtualt/) emulator, first run `clear 256, 58000`. Then, using the `Memory Editor` tool, load the output hex file starting and address `0xE290`.

Once the binary is loaded into memory, you can also save it with `savem "dde", 58000,<end address>,58000`. `<end address>` will vary by build, and is `58000` + file size (of the binary, not the hex file!)
