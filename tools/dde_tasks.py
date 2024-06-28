from waflib import TaskGen
from waflib.Task import Task

import os

GENERATED_DISCLAIMER = '; File is auto-generated. Changes will not be saved.\n'

PLATFORM_TRS80_M100 = 'trs80_m100'

ALL_PLATFORMS = [ PLATFORM_TRS80_M100 ]

DEFAULT_ENTRY_POINTS = {
    PLATFORM_TRS80_M100: 0xAB00,
}

PLATFORM_IDS = {
    PLATFORM_TRS80_M100: 1,
}

def dde_options(ctx):
    all_platforms_str = ','.join(ALL_PLATFORMS)
    ctx.add_option(
        '--platforms',
        action='store',
        default=all_platforms_str,
        help=f'List of platforms ({all_platforms_str})'
    )

def configure_dde(ctx, dde_root):
    platforms = ctx.options.platforms.split(',')

    for platform in platforms:
        if platform not in ALL_PLATFORMS:
            raise Exception(f'Unknown platform: {platform}')

    ctx.env.PLATFORMS = ctx.options.platforms
    ctx.find_program('zasm', var='ZASM')
    ctx.find_program('python3', var='PYTHON')
    ctx.env.TEXT_COMPRESSOR = dde_root.find_node('tools/compressor').abspath()
    ctx.env.ENGINE_TEXT = dde_root.find_node('tools/compressor/engine_text.json').abspath()

class GenerateMain(Task):
    ext_out = ['.asm']
    before = [ 'CompressText' ]
    def run(self):
        with open(self.outputs[0].abspath(), 'w') as file:
            file.write(GENERATED_DISCLAIMER)
            file.write(f'.org {self.entry_point}\n')
            relative_path = self.inputs[0].path_from(self.outputs[0].parent).replace('\\', '/')
            file.write(f'#define dde_platform {PLATFORM_IDS[self.platform]}\n')
            file.write(f'#include "{relative_path}"\n')

class CompressText(Task):
    run_str = '${PYTHON} ${TEXT_COMPRESSOR} -i ${ENGINE_TEXT} ${SRC} -o ${TGT}'
    ext_out = ['.asm']
    after = [ 'GenerateMain' ]
    before = [ 'Assemble' ]

class Assemble(Task):
    after = [ 'GenerateMain', 'CompressText' ]
    before = [ 'LinkCO', 'CreateTAP' ]
    ext_out = ['.hex', '.obj']
    def run(self):
        return self.exec_command([
            self.env.ZASM[0],
            '--8080' if self.is_8080 else '--z80',
            '-x' if self.is_hex else '-b',
            self.inputs[0].abspath(),
            '-o',
            self.outputs[0].abspath(),
        ])

class LinkCO(Task):
    ext_out = ['.co']
    after = [ 'Assemble' ]
    def run(self):
        with open(self.outputs[0].abspath(), 'wb') as co_file:
            write = lambda value: co_file.write(value.to_bytes(2, 'little'))

            write(self.entry_point)
            write(os.stat(self.inputs[0].abspath()).st_size)
            write(self.entry_point)

            with open(self.inputs[0].abspath(), 'rb') as obj_file:
                co_file.write(obj_file.read())

@TaskGen.feature('dde_game')
@TaskGen.before('dde_game')
def generate_platform_include_file(self):
    with open(self.get_cwd().make_node('platform_api.asm').abspath(), 'w') as platform_api:
        platform_api.write(GENERATED_DISCLAIMER)

        engine_path = '../src/engine' if self.is_dde_inner else '../dde/src/engine'

        for platform in ALL_PLATFORMS:
            platform_api.write(f'#define platform_{platform} {PLATFORM_IDS[platform]}\n')
            platform_api.write(f'#if dde_platform == platform_{platform}\n')
            platform_api.write(f'#include "{engine_path}/platform/{platform}.asm"\n')
            platform_api.write('#endif\n\n')

@TaskGen.feature('dde_game')
@TaskGen.after('compress_text')
def dde_game(self):
    cwd = self.get_cwd()

    generated_folder = cwd.make_node(f'generated/{self.name}')
    platform_generated = generated_folder.make_node(self.platform)
    platform_generated.mkdir()

    outer_main_asm = platform_generated.make_node('outer_main.asm')

    self.create_task(
        'GenerateMain',
        self.main_asm,
        outer_main_asm,
        entry_point = self.entry_point,
        platform = self.platform,
    )

    compressed_text = generated_folder.make_node('compressed_text.asm')

    json_files = self.text_json
    self.create_task(
        'CompressText',
        json_files,
        compressed_text,
    )

    asm_inputs = [outer_main_asm, compressed_text]
    asm_inputs.extend(self.all_asm)

    self.create_task(
        'Assemble',
        asm_inputs,
        self.out_obj,
        is_hex = False,
        is_8080 = self.is_8080,
    )

    if self.build_hex:
        self.create_task(
            'Assemble',
            asm_inputs,
            self.out_hex,
            is_hex = True,
            is_8080 = self.is_8080,
        )

    if self.platform == PLATFORM_TRS80_M100 and self.build_m100_co:
        link_inputs = [self.out_obj]
        link_inputs.extend(asm_inputs)

        self.create_task(
            'LinkCO',
            link_inputs,
            self.out_co,
            entry_point = self.entry_point,
        )

def build_dde_game(bld, path, **kwargs):
    platform_filter = bld.env.PLATFORMS.split(',')
    name = path.name
    platforms = kwargs.get('platforms', ALL_PLATFORMS)

    for platform in platforms:
        if platform not in platform_filter:
            continue

        platform_node = bld.path.make_node(f'build/{platform}')
        platform_node.mkdir()

        bld(
            features = 'dde_game',
            name = name,
            platform = platform,
            main_asm = path.find_node('main.asm'),
            text_json = kwargs.get('text_json', []),
            all_asm = bld.path.ant_glob('**/*.asm', excl=['build']),
            out_hex = platform_node.make_node(f'{name}.hex'),
            out_obj = platform_node.make_node(f'{name}.obj'),
            out_co = platform_node.make_node(f'{name}.co'),
            out_tap = platform_node.make_node(f'{name}.tap'),
            build_hex = kwargs.get('build_hex', True),
            build_m100_co = kwargs.get('build_m100_co', True),
            entry_point = kwargs.get(f'entry_point_{platform}', DEFAULT_ENTRY_POINTS[platform]),
            is_dde_inner = kwargs.get('is_dde_inner', False),
            is_8080 = platform == PLATFORM_TRS80_M100,
        )
