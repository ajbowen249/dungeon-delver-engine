from waflib import TaskGen
from waflib.Task import Task

import os

DEFAULT_ENTRY_POINT = 0xB200

def configure_dde(ctx, dde_root):
    ctx.find_program('zasm', var='ZASM')
    ctx.find_program('python3', var='PYTHON')
    generated_path = ctx.path.make_node('build/generated')
    generated_path.mkdir()
    ctx.env.TEXT_COMPRESSOR = dde_root.find_node('tools/compressor').abspath()
    ctx.env.ENGINE_TEXT = dde_root.find_node('tools/compressor/engine_text.json').abspath()

class GenerateHeader(Task):
    ext_out = ['.asm']
    before = [ 'CompressText' ]
    def run(self):
        with open(self.outputs[0].abspath(), 'w') as file:
            file.write(f'.org {self.entry_point}\n')

class CompressText(Task):
    run_str = '${PYTHON} ${TEXT_COMPRESSOR} -i ${ENGINE_TEXT} ${SRC} -o ${TGT}'
    ext_out = ['.asm']
    after = [ 'GenerateHeader' ]
    before = [ 'Assemble' ]

class Assemble(Task):
    after = [ 'GenerateHeader', 'CompressText' ]
    before = [ 'LinkCO' ]
    def run(self):
        self.exec_command([
            self.env.ZASM[0],
            '--8080',
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
@TaskGen.after('compress_text')
def dde_game(self):
    cwd = self.get_cwd()

    self.create_task(
        'GenerateHeader',
        None,
        cwd.make_node(f'generated/{self.name}/generated_header.asm'),
        entry_point = self.entry_point,
    )

    compressed_path = 'generated/' + self.name
    cwd.make_node(compressed_path).mkdir()
    compressed_path = compressed_path + '/compressed_text.asm'

    json_files = self.text_json
    self.create_task(
        'CompressText',
        json_files,
        cwd.make_node(compressed_path)
    )

    asm_inputs = [self.main_asm, cwd.make_node(compressed_path)]
    asm_inputs.extend(self.all_asm)

    if self.build_hex:
        self.create_task(
            'Assemble',
            asm_inputs,
            getattr(self, 'out_hex'),
            is_hex = True,
        )

    if self.build_co:
        self.create_task(
            'Assemble',
            asm_inputs,
            self.out_obj,
            is_hex = False,
        )

        link_inputs = [self.out_obj]
        link_inputs.extend(asm_inputs)

        self.create_task(
            'LinkCO',
            link_inputs,
            getattr(self, 'out_co'),
            entry_point = self.entry_point,
        )

def build_dde_game(bld, path, **kwargs):
    name = path.name

    bld(
        features = 'dde_game',
        name = name,
        main_asm = path.find_node('main.asm'),
        text_json = kwargs.get('text_json', []),
        all_asm = bld.path.ant_glob('**/*.asm', excl=['build']),
        out_hex = bld.path.make_node('build/' + name + '.hex'),
        out_obj = bld.path.make_node('build/' + name + '.obj'),
        out_co = bld.path.make_node('build/' + name + '.co'),
        build_hex = kwargs.get('build_hex', True),
        build_co = kwargs.get('build_co', True),
        entry_point = kwargs.get('entry_point', DEFAULT_ENTRY_POINT),
    )
