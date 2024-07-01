import json
import os

from tkinter import *
from tkinter import filedialog, messagebox, simpledialog

from tools.editor.screen_editor import ScreenEditor
from tools.editor.common import get_app_icon
from tools.editor.tile_palette import TilePalette

VALID_LABEL_CHARS = 'abcdefghijklmnopqrstuvwxyz_0123456789'

class Editor:
    def __init__(self, path):
        self.path = path
        self.dde_project = None
        self.open_screen_editors = []

        self.tile_palette = None
        self.focused_screen_editor = None

        self.root = Tk()
        self.root.wm_iconphoto(False, get_app_icon())
        self.root.iconbitmap()
        self.root.title('DDE Editor')
        self.root.geometry('500x40')
        menu_bar = Menu(self.root)
        self.menu_bar = menu_bar

        file_menu = Menu(menu_bar, tearoff=0)
        self.file_menu = file_menu
        file_menu.add_command(label='Open', command=lambda: self.open_file())
        file_menu.add_command(label='Save', command=lambda: self.save_file())
        menu_bar.add_cascade(label='File', menu=file_menu)

        screen_menu = Menu(menu_bar, tearoff=0)
        self.screen_menu = screen_menu

        menu_bar.add_cascade(label='Screen', menu=screen_menu)
        self.screen_menu.add_command(label='New Screen...', command=lambda: self.new_screen())

        edit_screen_menu = Menu(screen_menu, tearoff=0)
        self.edit_screen_menu = edit_screen_menu
        screen_menu.add_cascade(label='Edit Screen', menu=edit_screen_menu)

        self.root.config(menu=menu_bar)

        editing_label = Label(self.root, text='Editing: ')
        editing_label.pack(side='left')
        self.path_label = Label(self.root)
        self.path_label.pack(side='left')

        if self.path is not None:
            self.try_open(self.path)
        else:
            self.set_menu_state()

    def main_loop(self):
        self.root.mainloop()

    def set_menu_state(self):
        self.file_menu.entryconfig('Save', state='normal' if self.path is not None else 'disabled')

        project_dep_state='normal' if self.dde_project is not None else 'disabled'
        self.menu_bar.entryconfig('Screen', state=project_dep_state)

        self.path_label.configure(text=self.path if self.path is not None else '<none>')

        if self.dde_project is not None:
            index = self.edit_screen_menu.index('end')
            if index is not None:
                self.edit_screen_menu.delete(0, index)

            for i in range(0, len(self.dde_project['screens'])):
                screen = self.dde_project['screens'][i]
                name = screen['name']
                self.edit_screen_menu.add_command(label=name, command=lambda si=i: self.edit_screen(si))

    def open_file(self):
        new_path = filedialog.askopenfilename(filetypes=[('JSON Files', '.json')])
        self.try_open(new_path)

    def save_file(self):
        if self.path is None:
            return

        with open(self.path, 'w', encoding='utf-8') as out_file:
            json.dump(self.dde_project, out_file, indent=4)

    def try_open(self, path):
        self.close_all_open_windows()
        try:
            with open(path, 'r', encoding='utf-8') as in_file:
                new_dde_project = json.load(in_file)
                self.path = path
                self.dde_project = new_dde_project
                self.set_menu_state()
        except Exception as e:
            messagebox.showerror('Error', str(e))

    def edit_screen(self, index):
        if self.tile_palette is None:
            self.tile_palette = TilePalette(self.root, lambda c: self.on_tile_palette_click(c))
        else:
            self.tile_palette.focus_set()

        def set_screen(s, i):
            self.dde_project['screens'][i] = s

        self.open_screen_editors = [ed for ed in self.open_screen_editors if not ed.was_destroyed]

        for existing_editor in self.open_screen_editors:
            if existing_editor.screen_index == index:
                existing_editor.focus_set()
                return

        self.open_screen_editors.append(ScreenEditor(
            self.dde_project,
            index,
            self.root,
            set_screen,
            lambda e: self.set_focused_screen_editor(e)
        ))

    def close_all_open_windows(self):
        if self.tile_palette is not None:
            self.tile_palette.close()
            self.tile_palette = None

        for editor in self.open_screen_editors:
            editor.destroy()

        self.open_screen_editors = []

    def new_screen(self):
        screen_name = simpledialog.askstring('New screen', prompt='Screen Name (lower-case letters, numbers, and underscores only)')
        if screen_name is None:
            return

        if len(screen_name) == 0:
            messagebox.showerror('Invalid Name', f'Name cannot be empty.')
            return

        for char in screen_name:
            if char not in VALID_LABEL_CHARS:
                messagebox.showerror('Invalid Name', f'Name may only contain "{VALID_LABEL_CHARS}"')
                return

        screens = self.dde_project['screens']
        screens.append({
            "name": screen_name,
            "title": screen_name,
            "background": [
                "┌──────────────────┐",
                "│                  │",
                "│                  │",
                "│                  │",
                "│                  │",
                "│                  │",
                "│                  │",
                "└──────────────────┘"
            ],
            "start_location": {
                "col": 2,
                "row": 2
            },
            "interactables": []
        })

        self.set_menu_state()
        self.edit_screen(len(screens) - 1)

    def set_focused_screen_editor(self, editor):
        self.focused_screen_editor = editor

    def on_tile_palette_click(self, character):
        if self.focused_screen_editor is None:
            return

        self.focused_screen_editor.use_character_from_palette(character)
