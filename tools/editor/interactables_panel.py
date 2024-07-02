from tkinter import *

from tools.editor.common import FONT
from tools.constants import MAX_INTERACTABLES
from tools.dde_project import DDEScreen

class InteractablesPanel(Frame):
    def __init__(self, root, screen: DDEScreen):
        super().__init__(root, padx=10)
        self.screen = screen

        self.add_button = Button(self, text='+')
        self.add_button.grid(row=0, column=0)
        self.remove_button = Button(self, text='-', command=lambda: self.delete_selected_interactable())
        self.remove_button.grid(row=0, column=1)

        Label(self, text='Interactables', font=FONT).grid(row=0, column=2)

        self.listbox = Listbox(self)
        self.build_list()
        self.listbox.grid(row=1, column=2)
        self.listbox.bind('<<ListboxSelect>>', lambda e: self.on_selected_interactable_changed())

    def on_selected_interactable_changed(self):
        selection = self.listbox.curselection()
        self.remove_button.configure(state='disabled' if selection == () else 'normal')
        self.add_button.configure(state='normal' if len(self.screen.interactables) < MAX_INTERACTABLES else 'disabled')

    def delete_selected_interactable(self):
        selection = self.listbox.curselection()
        if selection == ():
            return

        del self.screen.interactables[selection[0]]
        self.build_list()

    def build_list(self):
        end = self.listbox.index('end')
        if end is not None:
            self.listbox.delete(0, end)

        for i in range(0, len(self.screen.interactables)):
            interactable = self.screen.interactables[i]
            self.listbox.insert(i, interactable.label)

        self.on_selected_interactable_changed()
