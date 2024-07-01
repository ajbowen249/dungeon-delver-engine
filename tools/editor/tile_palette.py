from tkinter import *

from tools.constants import TILE_CHARACTERS
from tools.editor.common import get_app_icon

ROWS = 8

class TilePalette:
    def __init__(self, root, click_callback):
        self.click_callback = click_callback
        self.window = Toplevel(root)
        self.window.title('Tile Palette')
        self.window.wm_iconphoto(False, get_app_icon())
        self.window.protocol("WM_DELETE_WINDOW", lambda: None)
        self.window.resizable(width=False, height=False)

        for i in range(0, len(TILE_CHARACTERS)):
            character = TILE_CHARACTERS[i]
            Button(
                self.window,
                text=character,
                font=('Arial', 12),
                command=lambda ch=character: click_callback(ch)
            ).grid(column=int(i / ROWS), row=i % ROWS)

    def close(self):
        self.window.destroy()
