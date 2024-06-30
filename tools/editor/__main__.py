import sys
import json
import argparse
import os

sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..'))

from tools.editor.editor import Editor

def process_args():
    parser = argparse.ArgumentParser(
        prog='DDE Editor',
        description='Graphical editor for DDE Games')

    parser.add_argument(
        '-i',
        '--input',
        dest='input',
        type=argparse.FileType('r', encoding='utf-8'),
        help='JSON Input file',
        required=True
    )

    result = parser.parse_args()

    return result

def main():
    args = process_args()
    dde_project = json.load(args.input)

    editor = Editor(dde_project)
    editor.main_loop()

if __name__ == '__main__':
    main()
