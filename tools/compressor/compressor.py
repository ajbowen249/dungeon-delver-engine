from tools.compressor.line_table import LineTable, Reference

MAX_SEQUENCE_ID = 126 # Saving ID 127 for possible flag to second-byte ID.

def sequence_label(id):
    return 'cs_' + str(id)

class Compressor:
    """Compresses blocks of text"""
    def __init__(self, input_dict, platform):
        self.platform = platform
        self.line_table = LineTable(input_dict, platform)

    def compress(self):
        final_sequence_table = {}
        sequence_id = 0
        saved = 0

        while len(self.line_table.remaining_strings()) != 0:
            all_sequences = self.line_table.get_sequence_tables()
            top_sequence = all_sequences[0]
            if top_sequence.saved_bytes < 0:
                break

            if sequence_id > MAX_SEQUENCE_ID:
                print('WARNING: Stopped at cap of ' + str(MAX_SEQUENCE_ID) + ' string fragments')
                break

            remove_string = top_sequence.string
            final_sequence_table[remove_string] = sequence_id
            print('Removing', '"' + remove_string + '"', top_sequence.saved_bytes)

            saved += top_sequence.saved_bytes

            self.line_table.replace_string(remove_string, sequence_id)

            sequence_id += 1

        print('saved approximately', saved, 'bytes of text')
        return final_sequence_table

    def create_assembly_file(self, sequence_table):
        output_str = '; Note: this file is auto-generated. Change the JSON file instead!\n\n'
        output_str += 'compressed_sequences:\n'
        for sequence in sequence_table:
            output_str += sequence_label(sequence_table[sequence]) + ': .asciz "' + sequence + '"\n'

        output_str += '\ncompressed_string_fragment_table:\n'

        for sequence in sequence_table:
            output_str += '.dw ' + sequence_label(sequence_table[sequence]) + '\n'

        output_str += '\n'

        for block in self.line_table.blocks.values():
            output_str += '#define ' + block.key + '_lines ' + str(len(block.lines)) + '\n'
            output_str += block.key + ':\n'

            line_index = 0

            for line in block.lines:
                output_str += "; " + block.key + "_line_" + str(line_index) + "\n"
                line_index += 1

                for chunk in line.chunks:
                    if isinstance(chunk, str):
                        output_str += '.ascii "' + chunk + '"\n'
                    elif isinstance(chunk, Reference):
                        # flag the first bit to show it's a reference
                        output_str += '.db ' + str(chunk.id) + ' | $80\n'
                        pass

                output_str += '.db 0\n\n'


        return output_str
