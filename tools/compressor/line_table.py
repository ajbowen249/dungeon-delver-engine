from functools import reduce

class Reference:
    def __init__(self, id):
        self.id = id

def map_chunk(chunk, text, id):
    if isinstance(chunk, Reference) or not text in chunk:
        return [chunk]

    sub_chunks = []
    remaining_text = chunk

    while text in remaining_text:
        start = remaining_text.find(text)
        before = remaining_text[0:start]

        if before != '':
            sub_chunks.append(before)

        sub_chunks.append(Reference(id))

        remaining_text = remaining_text[start + len(text):]

    if remaining_text != '':
        sub_chunks.append(remaining_text)

    return sub_chunks

class Line:
    def __init__(self, line):
        self.chunks = [line]

    def remaining_strings(self):
        return list(filter(lambda x: isinstance(x, str), self.chunks))

    def replace_string(self, text, id):
        new_chunks = []
        for chunk in self.chunks:
            result = map_chunk(chunk, text, id)
            new_chunks.extend(result)

        self.chunks = new_chunks

class Block:
    def __init__(self, key, lines):
        self.key = key
        self.lines = list(map(lambda x: Line(x), lines))

    def remaining_strings(self):
        line_strs = []
        for line in self.lines:
            line_strs.extend(line.remaining_strings())

        return line_strs

    def replace_string(self, text, id):
        for line in self.lines:
            line.replace_string(text, id)


def build_sequence_table(all_strings, target_length):
    sequence_dict = {}
    for str in all_strings:
        if len(str) < target_length:
            continue

        start_index = 0
        while start_index + target_length <= len(str):
            window = str[start_index:start_index + target_length]
            if window in sequence_dict:
                sequence_dict[window] += 1
            else:
                sequence_dict[window] = 1

            start_index += 1

    return sequence_dict

class Sequence:
    string = ''
    count = 0
    size = 0
    saved_bytes = 0
    score = 0

class LineTable:
    """Tracks the state text that needs to be put into the table."""

    def __init__(self, from_json):
        self.blocks = {}

        for key in from_json:
            self.blocks[key] = Block(key, from_json[key])

    def replace_string(self, text, id):
        """Within all lines of all blocks, replace instances of text with a reference to id"""
        for block in self.blocks.values():
            block.replace_string(text, id)

    def get_sequence_tables(self):
            """
            Gets a list of all sequences of at least size 1, sorted by best choice. 'Best choice' is currently the
            most bytes saved.
            """
            sequence_tables = {}
            all_sequences = []
            all_strings = self.remaining_strings()
            max_length = max(list(map(lambda x: len(x), all_strings)))

            for i in range(1, max_length + 1):
                table = build_sequence_table(all_strings, i)
                sequence_tables[i] = table

                for sequence_str in table:
                    sequence = Sequence()
                    sequence.string = sequence_str
                    sequence.count = table[sequence_str]
                    sequence.size = i
                    # This is the number of bytes saved by extracting one instance of that string to a table and
                    # replacing all instances of it with a two-byte reference ID. -1 more for the additional null
                    # terminator.
                    sequence.saved_bytes = (i * table[sequence_str]) - (table[sequence_str] * 2) - i - 1
                    sequence.score = (i * table[sequence_str]) - (table[sequence_str] * 2) - i - 1
                    all_sequences.append(sequence)

            all_sequences = sorted(all_sequences, key=lambda sequence: sequence.score)
            all_sequences.reverse()

            return all_sequences

    def remaining_strings(self):
        """Gets all strings in the table not currently replaced with a reference."""
        all_lines = []

        for block in self.blocks.values():
            remaining_strings = block.remaining_strings()
            if len(remaining_strings) > 0:
                all_lines.extend(remaining_strings)

        return all_lines
