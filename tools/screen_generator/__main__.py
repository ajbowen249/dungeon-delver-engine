import json
import argparse
import os
import pathlib

# IMPROVE: Ugh. de-duplicate
PLATFORM_TRS80_M100 = 'trs80_m100'
PLATFORM_ZX_SPECTRUM = 'zx_spectrum'

SCREEN_TITLE_MAX_LENGTH = 20
SCREEN_TITLE_BYTES = SCREEN_TITLE_MAX_LENGTH + 1
MAX_INTERACTABLES = 10
BACKGROUND_ROWS = 8

def foreach(list, func):
    for item in list:
        func(item)

def process_args():
    parser = argparse.ArgumentParser(
        prog='DDE Screen Generator',
        description='Create .asm files from json rooms.')

    parser.add_argument('-i', '--input', dest='input', type=str, help='DDE Project file', required=True)
    parser.add_argument('-o', '--output', dest='output', type=str,
                        help='Generated output path (e.g, /build/generated)', required=True)

    parser.add_argument(
        '-p',
        '--platform',
        dest = 'platform',
        help = 'Platform to select. Precede a key with `<platform>:` to limit it to a certain platform.',
        required = True,
        choices = [ PLATFORM_TRS80_M100, PLATFORM_ZX_SPECTRUM ]
    )

    result = parser.parse_args()

    return result

def validate_screen(screen):
    if screen.get('is_custom', False):
        return

    background = screen['background']
    if len(background) != BACKGROUND_ROWS:
        raise Exception(f'{screen["name"]} number of background lines ({len(background)})')
    for i in range(0, len(background)):
        line = background[i]
        length = len(line)
        if length != 20:
            raise Exception(f'Background line {i} is wrong length. len("{line}") == {length}')

def main():
    args = process_args()
    all_generated_files = []

    with open(args.input, 'r', encoding='utf-8') as input_file:
        project = json.loads(input_file.read())
        project_folder = pathlib.Path(args.input).parent

        out_root = pathlib.Path(args.output)
        out_root.mkdir(parents=True, exist_ok=True)
        generated_folder = out_root.joinpath(project['name'], args.platform)
        screens_path = generated_folder.joinpath('screens')
        screens_path.mkdir(parents=True, exist_ok=True)

        for i in range(0, len(project['screens'])):
            screen_id = i + 1
            screen = project['screens'][i]
            validate_screen(screen)
            name = screen["name"]

            screen_file = screens_path.joinpath(screen['name'] + '.asm')
            all_generated_files.append(screen_file)


            with open(screen_file, 'w', encoding='utf-8') as outfile:
                write = lambda lines: foreach(
                    lines if type(lines) is list else [lines], lambda line: outfile.write(line)
                )

                write([
                    f'; Auto-generated screen file.\n',
                    f'#define screen_id_{name} {screen_id}\n',
                    f'.local\n',
                ])

                if not screen.get('is_custom', False):
                    title = screen["title"]
                    write([
                        f'screen_data:\n',
                        f'screen_background:\n'
                    ])

                    write([f'.asciz "{line}"\n' for line in screen['background']])

                    write([
                        f'screen_title: .asciz "{title}"\n',
                        f'.block {SCREEN_TITLE_BYTES - (len(title) + 1)}, 0\n',

                        f'screen_start_x: .db {screen["start_location"]["col"]}\n',
                        f'screen_start_y: .db {screen["start_location"]["row"]}\n',

                        f'{name}_interactables:\n'
                    ])

                    interactables = screen['interactables']

                    for i in range(0, MAX_INTERACTABLES):
                        if i < len(interactables):
                            inter = interactables[i]
                            loc = inter['location']
                            write(f'    DEFINE_INTERACTABLE {inter["label"]}, {inter["type"]}, {inter["flags"]}, {loc["row"]}, {loc["col"]}\n')
                        else:
                            write(f'    DEFINE_INTERACTABLE blank_{i}, 0, iflags_normal, 0, 0\n')

                    write([
                        f'screen_interaction_prompt_callback_ptr: .dw get_interaction_prompt\n',
                        f'screen_interaction_callback_ptr: .dw on_interact\n',
                        f'screen_menu_callback: .dw {project["menu_label"]}\n'
                    ])

                    write([
                        f'{name}::\n',
                        f'    call init_screen\n' if screen.get('init', False) else '',
                        f'    ld hl, {project["player_party_label"]}\n',
                        f'    ld a, ({project["party_size_label"]})\n',
                        f'    ld bc, screen_data\n',
                        f'    call exploration_ui\n',
                        f'    ret\n'
                        f'\n',
                    ])

                    write('get_interaction_prompt:\n')
                    for i in range(0, len(interactables)):
                        interactable = interactables[i]
                        if interactable.get('prompt_label', '') == '':
                            continue

                        write([
                            f'    cp a, {i}\n',
                            f'    jp z, ret_label_{interactable["label"]}\n'
                        ])

                    write([
                        '    ld hl, empty_str\n'
                        '    ret\n',
                        '\n'
                    ])

                    for i in range(0, len(interactables)):
                        interactable = interactables[i]
                        prompt_label = interactable.get('prompt_label', '')
                        if prompt_label == '':
                            continue

                        write([
                            f'ret_label_{interactable["label"]}:\n',
                            f'    ld hl, {prompt_label}\n',
                            f'    ret\n'
                        ])

                    write('on_interact:\n')
                    for i in range(0, len(interactables)):
                        interactable = interactables[i]
                        write([
                            f'    cp a, {i}\n',
                            f'    jp z, on_{interactable["label"]}\n'
                        ])
                    write([
                        '    ret\n',
                        '\n'
                    ])

                    for interactable in interactables:
                        label = interactable["label"]
                        action = interactable.get('action', None)
                        if action is None:
                            continue

                        write(f'on_{label}:\n')
                        store_location = action.get('store_location', None)
                        if store_location is not None:
                            write([
                                f'    ld a, {store_location["col"]}\n',
                                f'    ld (screen_start_x), a\n',
                                f'    ld a, {store_location["row"]}\n',
                                f'    ld (screen_start_y), a\n',
                            ])

                        match action['type']:
                            case 'exit':
                                if action.get('hook_before', False):
                                    write(f'    call before_{label}\n')

                                write([
                                    f'    EXIT_EXPLORATION {action["exit_code"]}, {action["exit_id"]}\n',
                                    f'    ret\n'
                                ])
                            case 'call':
                                write([
                                    f'    call {action["call_label"]}\n',
                                    f'    ret\n'
                                ])

                screen_asm_file = project_folder.joinpath('screens', name + '.asm')
                if (screen_asm_file.exists()):
                    with open(screen_asm_file, 'r', encoding='utf-8') as asm_file:
                        write(asm_file.read())

                write('.endlocal\n')

        relpath = lambda from_path, to_path: os.path.relpath(
            str(to_path.absolute()),
            str(from_path.absolute())
        ).replace('\\', '/')

        screens_table_file = generated_folder.joinpath('screens/screen_table.asm')
        with open(screens_table_file, 'w') as screens_table:
            for generated_file in all_generated_files:
                path = relpath(screens_table_file.parent, generated_file)
                screens_table.write(f'#include "./{path}"\n')

            screens_table.write('\nscreen_table:\n')
            screens_table.write('.dw 0 ; reserve 0\n')

            for screen in project['screens']:
                screens_table.write(f'.dw {screen["name"]}\n')

        screens_root_file = generated_folder.joinpath('screens.asm')
        with open(screens_root_file, 'w') as screens_root:
            screens_root.write('.macro INCLUDE_SCREEN_TABLE\n')
            path = relpath(project_folder, screens_table_file)
            screens_root.write(f'#include "./{path}"\n')

            screens_root.write('.endm\n')

if __name__ == '__main__':
    main()
