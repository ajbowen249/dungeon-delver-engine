import sys
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
        type=str,
        help='JSON Input file'
    )

    result = parser.parse_args()

    return result

def main():
    args = process_args()
    editor = Editor(args.input)
    editor.main_loop()

if __name__ == '__main__':
    main()
