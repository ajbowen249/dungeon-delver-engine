from tkinter import *
from typing import Callable

from tools.editor.common import FONT
from tools.editor.text_field import TextField
from tools.constants import MAX_INTERACTABLES
from tools.dde_project import DDEScreen, DDEInteractable

class BaseInteractableProps(Frame):
    def __init__(self, root: Misc, interactable: DDEInteractable, update_label: Callable[[str], None]):
        super().__init__(root)
        self.label_field = TextField(self, 'Label', interactable, 'label')
        self.label_field.grid(row=0, column=0)
        self.label_field.add_observer(lambda s: update_label(s))

        self.type_field = TextField(self, 'Type', interactable, 'type')
        self.type_field.grid(row=1, column=0)

        self.flags_field = TextField(self, 'Flags', interactable, 'flags')
        self.flags_field.grid(row=2, column=0)

        self.prompt_field = TextField(self, 'Prompt Label', interactable, 'prompt_label')
        self.prompt_field.grid(row=3, column=0)

        location_frame = Frame(self)
        location_frame.grid(row=4, column=0)
        location = interactable.location if interactable is not None else None

        self.x_field = TextField(location_frame, 'X', location, 'col', width=9)
        self.x_field.pack(side='left')
        self.y_field = TextField(location_frame, 'Y', location, 'row', width=9)
        self.y_field.pack(side='left')

    def set_interactable(self, interactable: DDEInteractable):
        self.label_field.rebind(interactable)
        self.type_field.rebind(interactable)
        self.flags_field.rebind(interactable)
        self.prompt_field.rebind(interactable)

        location = interactable.location if interactable is not None else None
        self.x_field.rebind(location)
        self.y_field.rebind(location)

    def focus_label(self):
        self.label_field.focus_entry()

class InteractablesPanel(Frame):
    def __init__(self, root: Misc, screen: DDEScreen):
        super().__init__(root, padx=10)
        self.screen = screen

        self.selected_interactable: DDEInteractable | None = None

        self.add_button = Button(self, text='+')
        self.add_button.grid(row=0, column=0)
        self.remove_button = Button(self, text='-', command=lambda: self.delete_selected_interactable())
        self.remove_button.grid(row=0, column=1)

        Label(self, text='Interactables', font=FONT).grid(row=0, column=2)

        self.listbox = Listbox(self)
        self.build_list()
        self.listbox.grid(row=1, column=2)
        self.listbox.bind('<<ListboxSelect>>', lambda e: self.on_selected_interactable_changed())

        self.edit_panel = Frame(self)
        self.edit_panel.grid(row = 2, column=0, columnspan=3)

        self.base_props_panel = BaseInteractableProps(self.edit_panel, None, lambda v: self.update_selected_label())
        self.base_props_panel.pack()

    def on_selected_interactable_changed(self):
        selection = self.listbox.curselection()
        self.remove_button.configure(state='disabled' if selection == () else 'normal')
        self.add_button.configure(state='normal' if len(self.screen.interactables) < MAX_INTERACTABLES else 'disabled')

        if selection == ():
            return

        self.selected_interactable = self.screen.interactables[selection[0]]
        self.base_props_panel.set_interactable(self.selected_interactable)

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

    def update_selected_label(self):
        selection = self.listbox.curselection()
        if selection == ():
            return

        self.build_list()
        self.listbox.selection_set(selection[0])
        self.base_props_panel.focus_label()
