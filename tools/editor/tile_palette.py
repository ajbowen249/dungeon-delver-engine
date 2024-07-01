import copy

from tkinter import *

from tools.constants import TILE_CHARACTERS
from tools.editor.background_cell import CELL_HEIGHT, BackgroundCell

ROWS = 8

class TilePalette:
    def __init__(self, root, click_callback):
        self.click_callback = click_callback
        self.frame = Frame(root)

        for i in range(0, len(TILE_CHARACTERS)):
            character = TILE_CHARACTERS[i]
            Button(
                self.frame,
                text=character,
                font=('Arial', 12),
                command=lambda ch=character: click_callback(ch)
            ).grid(column=int(i / ROWS), row=i % ROWS)

        self.frame.pack(side='right')
