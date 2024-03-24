from line_table import LineTable, Reference

def sequence_label(id):
    return 'cs_' + str(id)

class Compressor:
    """Compresses blocks of text"""
    def __init__(self, input_dict):
        self.line_table = LineTable(input_dict)

    def compress(self):
        final_sequence_table = {}
        sequence_id = 0
        saved = 0

        while len(self.line_table.remaining_strings()) != 0:
            all_sequences = self.line_table.get_sequence_tables()
            top_sequence = all_sequences[0]
            if top_sequence['score'] < 0:
                break

            remove_string = top_sequence['string']
            final_sequence_table[remove_string] = sequence_id
            print('Removing', '"' + remove_string + '"', top_sequence['score'])

            saved += top_sequence['score']

            self.line_table.replace_string(remove_string, sequence_id)

            sequence_id += 1

        print('saved approximately', saved, 'bytes of text')
        return final_sequence_table

    def create_assembly_file(self, sequence_table):
        output_str = 'compressed_sequences:\n'
        for sequence in sequence_table:
            output_str += sequence_label(sequence_table[sequence]) + ': .asciz "' + sequence + '"\n'

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
                        # need to make this explicitly big-endian so the flag can be in the correct byte in the string
                        # the first bit is a "flag" because we load at $b200, past $8000, so it'll always be set
                        # all ascii characters printable in this form are below $80
                        output_str += '.db hi(' + sequence_label(chunk.id) + ')\n'
                        output_str += '.db lo(' + sequence_label(chunk.id) + ')\n'

                output_str += '.db 0\n\n'


        return output_str
