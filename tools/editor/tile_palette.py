from tkinter import *

from tools.constants import TILE_CHARACTERS
from tools.editor.common import get_app_icon

ROWS = 8

class TilePalette(Toplevel):
    def __init__(self, root: Misc, click_callback):
        super().__init__(root)
        self.click_callback = click_callback
        self.title('Tile Palette')
        self.wm_iconphoto(False, get_app_icon())
        self.protocol("WM_DELETE_WINDOW", lambda: None)
        self.resizable(width=False, height=False)

        for i in range(0, len(TILE_CHARACTERS)):
            character = TILE_CHARACTERS[i]
            Button(
                self,
                text=character,
                font=('Arial', 12),
                command=lambda ch=character: click_callback(ch)
            ).grid(column=int(i / ROWS), row=i % ROWS)

    def close(self):
        self.destroy()
