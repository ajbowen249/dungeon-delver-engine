from tkinter import *
from tkinter import ttk

class Editor:
    def __init__(self, dde_project):
        self.dde_project = dde_project

        self.root = Tk()
        self.frame = ttk.Frame(self.root, padding=10)
        self.frame.grid()
        ttk.Label(self.frame, text="DDE Editor!").grid(column=0, row=0)
        ttk.Button(self.frame, text="Quit", command=self.root.destroy).grid(column=1, row=0)

    def main_loop(self):
        self.root.mainloop()
