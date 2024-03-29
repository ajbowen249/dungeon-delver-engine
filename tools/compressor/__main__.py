import sys
import json
import argparse
import os

from compressor import Compressor

engine_text_path = './engine_text.json'

def process_args():
    parser = argparse.ArgumentParser(
        prog='DDE Text Compressor',
        description='Compresses text for the Dungeon Delver Engine')

    parser.add_argument('-i', '--input', dest='input', type=argparse.FileType('r'), help='JSON Input file', nargs='+')
    parser.add_argument('-o', '--output', dest='output', type=argparse.FileType('w'), help='Output assembly file',
                        default=sys.stdout)

    result = parser.parse_args()

    return result

def main():
    args = process_args()

    engine_json = json.load(open(os.path.join(os.path.dirname(__file__), engine_text_path)))

    if args.input is not None:
        for input_file in args.input:
            input_json = json.load(input_file)
            engine_json.update(input_json)

    compressor = Compressor(engine_json)
    sequence_table = compressor.compress()
    output_string = compressor.create_assembly_file(sequence_table)

    args.output.write(output_string)

if __name__ == '__main__':
    main()
