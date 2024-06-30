import json

from tkinter import *
from tkinter import ttk, filedialog

class Editor:
    def __init__(self, path):
        self.path = path
        if self.path is not None:
            with open(self.path, 'r', encoding='utf-8') as in_file:
                self.dde_project = json.load(in_file)

        self.root = Tk()
        menu_bar = Menu(self.root)
        file_menu = Menu(menu_bar, tearoff=0)
        self.file_menu = file_menu
        file_menu.add_command(label='Open', command=lambda: self.open_file())
        file_menu.add_command(label='Save', command=lambda: self.save_file())
        menu_bar.add_cascade(label='File', menu=file_menu)
        self.root.config(menu=menu_bar)

        self.set_file_menu_state()

    def main_loop(self):
        self.root.mainloop()

    def set_file_menu_state(self):
        self.file_menu.entryconfig('Save', state='normal' if self.path is not None else 'disabled')

    def open_file(self):
        new_path = filedialog.askopenfilename(filetypes=[('JSON Files', '.json')])
        with open(new_path, 'r', encoding='utf-8') as new_file:
            new_dde_project = json.load(new_file)
            self.dde_project = new_dde_project
            self.path = new_path
            self.set_file_menu_state()

    def save_file(self):
        if self.path is None:
            return

        with open(self.path, 'w', encoding='utf-8') as out_file:
            json.dump(self.dde_project, out_file, indent=4)
