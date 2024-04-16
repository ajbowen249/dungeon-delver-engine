from math import ceil

class Line:
    def __init__(self, text):
        self.text = text

class Block:
    def __init__(self, key, lines):
        self.key = key
        if isinstance(lines, str):
            lines = [lines]

        self.lines = list(map(lambda x: Line(x), lines))


class LineTable:
    def __init__(self, from_json):
        self.blocks = {}

        for key in from_json:
            self.blocks[key] = Block(key, from_json[key])

    def for_all_text(self, callback):
        for key in self.blocks:
            block = self.blocks[key]
            for line in block.lines:
                callback(line.text)

    def total_original_text_size(self):
        total = 0
        for key in self.blocks:
            block = self.blocks[key]
            for line in block.lines:
                total += len(line.text)

        return total

class HuffmanNode:
    def __init__(self):
        return

    def traverse(self, callback, depth):
        if not self.is_internal:
            callback(self, depth)
        else:
            self.left.traverse(callback, depth + 1)
            callback(self, depth)
            self.right.traverse(callback, depth + 1)

    def internal(left, right):
        node = HuffmanNode()
        node.is_internal = True
        node.left = left
        node.right = right
        node.count = left.count + right.count
        return node

    def leaf(value, count):
        node = HuffmanNode()
        node.is_internal = False
        node.value = value
        node.count = count
        return node

class HuffmanQueue:
    def __init__(self, raw_frequencies):
        self.nodes = [ HuffmanNode.leaf(ch, raw_frequencies[ch]) for ch in raw_frequencies ]

    def pop_lowest(self):
        lowest_two = []

        while len(lowest_two) < 2 and len(self.nodes) > 0:
            lowest = min(self.nodes, key=lambda x: x.count)
            lowest_two.append(lowest)
            self.nodes = [ node for node in self.nodes if node != lowest ]

        return lowest_two

    def add(self, node):
        self.nodes.append(node)

class HuffmanGenerator:
    def __init__(self, from_json):
        self.line_table = LineTable(from_json)
        self.frequencies = {}

    def generate_tree(self):
        self.line_table.for_all_text(lambda text: self.process_line(text))
        queue = HuffmanQueue(self.frequencies)

        lowest = queue.pop_lowest()
        while len(lowest) == 2:
            queue.add(HuffmanNode.internal(lowest[0], lowest[1]))
            lowest = queue.pop_lowest()

        return lowest[0]

    def process_line(self, line):
        for char in line:
            if char in self.frequencies:
                self.frequencies[char] += 1
            else:
                self.frequencies[char] = 1

def huffman_test(json):
    g = HuffmanGenerator(json)
    tree = g.generate_tree()

    leaves = []

    def add_leaf(node, depth):
        if node.is_internal:
            return

        leaves.append([node, depth])

    tree.traverse(add_leaf, 0)

    total_bits = 0
    for leaf in leaves:
        print(leaf[0].value, leaf[0].count, leaf[1], leaf[0].count * leaf[1], ceil((leaf[0].count * leaf[1]) / 8))
        total_bits += leaf[0].count * leaf[1]

    # approx_bytes here is the ideal total if the whole game's text was one contiguous string
    approx_bytes = ceil(total_bits / 8)
    original_total = g.line_table.total_original_text_size()
    print("total ideal bytes", approx_bytes, "down from", original_total, "saved", original_total - approx_bytes)

    # To get a little more realistic, we know we'll need at least one semaphore byte per string (haven't made any
    # encoding choices at the time of writing, but it'd probably be a leading length byte). We also can't realistically
    # pack the entire thing without trailing bits at the end of each string's last byte.

    char_map = {}
    for leaf in leaves:
        char_map[leaf[0].value] = leaf

    unpacked_total = 0

    def total_line(line):
        # start at one for the length byte (or whatever)
        line_total = 1

        bit_total = 0
        for ch in line:
            bit_total = bit_total + char_map[ch][1]

        # ceil because the last byte will have trailing bits if not filled
        line_total = line_total + ceil(bit_total / 8)

        return line_total

    for key in g.line_table.blocks:
        block = g.line_table.blocks[key]
        for line in block.lines:
            unpacked_total += total_line(line.text)

    print("total unpacked bytes", unpacked_total, "down from", original_total, "saved", original_total - unpacked_total)

    unpacked_total_with_impl = unpacked_total

    # Now approximate the minimal bytes needed in an implementation of the table. Not sure how to do it yet, but I can't
    # imagine something taking less than two bytes per character in the table; at least one byte for the constant
    # itself, and some kind of offset pointer.

    unpacked_total_with_impl += len(leaves) * 2

    print("total unpacked bytes with approximate minimal table impl", unpacked_total_with_impl, "down from", original_total, "saved", original_total - unpacked_total_with_impl)

    return
