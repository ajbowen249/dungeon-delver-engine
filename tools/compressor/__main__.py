import sys
import json
import argparse
import os

sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..'))

from tools.compressor.compressor import Compressor

from tools.constants import PLATFORM_TRS80_M100, PLATFORM_ZX_SPECTRUM

def process_args():
    parser = argparse.ArgumentParser(
        prog='DDE Text Compressor',
        description='Compresses text for the Dungeon Delver Engine')

    parser.add_argument('-i', '--input', dest='input', type=argparse.FileType('r'), help='JSON Input file', nargs='+')
    parser.add_argument('-o', '--output', dest='output', type=argparse.FileType('w'), help='Output assembly file',
                        default=sys.stdout)

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

def main():
    args = process_args()

    engine_json = json.loads("{}")

    if args.input is not None:
        for input_file in args.input:
            input_json = json.load(input_file)
            engine_json.update(input_json)

    compressor = Compressor(engine_json, args.platform)
    sequence_table = compressor.compress()
    output_string = compressor.create_assembly_file(sequence_table)

    args.output.write(output_string)

if __name__ == '__main__':
    main()
