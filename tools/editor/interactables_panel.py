from tkinter import *
from typing import Callable

from tools.dde_project import DDEScreen, DDEInteractable, DDELocation

from tools.editor.common import FONT
from tools.editor.text_field import TextField, to_int
from tools.editor.bool_field import BoolField
from tools.editor.select_field import SelectField
from tools.constants import MAX_INTERACTABLES, EXIT_CODE_OPTIONS

ACTION_CHOICE_CUSTOM = 'custom'
SELECTION_ACTION_TYPES = (ACTION_CHOICE_CUSTOM, 'exit', 'call')

class StoreLocationPanel(Frame):
    def __init__(self, root: Misc, interactable: DDEInteractable):
        super().__init__(root, pady=5)
        self.interactable = interactable
        self.should_store_location = False

        self.store_checkbox = BoolField(self, 'Store Location', self, 'should_store_location')
        self.store_checkbox.grid(row=0, column=0, columnspan=2)
        self.store_checkbox.add_observer(lambda v: self.on_store_changed(v))

        self.x_field = TextField(self, 'X', None, 'col', to_int, width=9)
        self.x_field.grid(row=1, column=0)

        self.y_field = TextField(self, 'Y', None, 'row', to_int, width=9)
        self.y_field.grid(row=1, column=1)

        self.setup_data()

    def setup_data(self):
        self.should_store_location = self.interactable.action is not None and self.interactable.action.store_location is not None
        self.store_checkbox.rebind(self)

        if self.should_store_location:
            self.x_field.rebind(self.interactable.action.store_location)
            self.y_field.rebind(self.interactable.action.store_location)
        else:
            self.x_field.rebind(None)
            self.y_field.rebind(None)

    def rebind(self, interactable: DDEInteractable):
        self.interactable = interactable
        self.setup_data()

    def on_store_changed(self, value: bool):
        if value and self.interactable.action is not None and self.interactable.action.store_location is None:
            self.interactable.action.store_location = DDELocation(0, 0)
        elif not value and self.interactable.action is not None and self.interactable.action.store_location is not None:
            self.interactable.action.store_location = None

        self.setup_data()

class CustomActionPanel(Frame):
    def __init__(self, root: Misc, interactable: DDEInteractable):
        super().__init__(root)
        self.type = None
        self.interactable = interactable
        Label(self, text='Compiler will expect label:').pack(side='top')
        self.required_label_label = Label(self)
        self.required_label_label.pack(side='top')
        self.set_label()

    def set_label(self):
        self.required_label_label.configure(text=f'on_{self.interactable.label}')

    def rebind(self, interactable: DDEInteractable):
        self.interactable = interactable
        self.set_label()

class CallActionPanel(Frame):
    def __init__(self, root: Misc, interactable: DDEInteractable):
        super().__init__(root)
        self.type = interactable.type
        self.label_field = TextField(self, 'Call Label', interactable.action, 'call_label')
        self.label_field.pack(side='top')

        self.store_location_panel = StoreLocationPanel(self, interactable)
        self.store_location_panel.pack(side='top')

    def rebind(self, interactable: DDEInteractable):
        self.label_field.rebind(interactable.action)
        self.store_location_panel.rebind(self, interactable)

class ExitActionPanel(Frame):
    def __init__(self, root: Misc, interactable: DDEInteractable):
        super().__init__(root)
        self.type = interactable.type

        self.code_field = SelectField(self, 'Exit Code', EXIT_CODE_OPTIONS, interactable.action, 'exit_code')
        self.code_field.pack(side='top')

        self.id_field = TextField(self, 'Exit ID', interactable.action, 'exit_id')
        self.id_field.pack(side='top')

        self.hook_before_field = BoolField(self, 'Hook Before', interactable.action, 'hook_before')
        self.hook_before_field.pack(side='top')

        self.store_location_panel = StoreLocationPanel(self, interactable)
        self.store_location_panel.pack(side='top')

    def rebind(self, interactable: DDEInteractable):
        self.id_field.rebind(interactable.action)
        self.code_field.rebind(interactable.action)
        self.hook_before_field.rebind(interactable.action)
        self.store_location_panel.rebind(self, interactable)

class BaseInteractableProps(Frame):
    class PanelData:
        def __init__(self):
            self.selected_action: str | None = None

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

        self.columnconfigure(1, minsize=250)
        self.rowconfigure(1, minsize=75)
        self.rowconfigure(2, minsize=75)
        self.action_panel = None
        self.set_selected_action_type(interactable)
        self.action_selector = SelectField(self, 'Action', SELECTION_ACTION_TYPES, self.data, 'selected_action')
        self.action_selector.grid(row=0, column=1)

        location_frame = Frame(self)
        location_frame.grid(row=4, column=0)
        location = interactable.location if interactable is not None else None

        self.x_field = TextField(location_frame, 'X', location, 'col', to_int, width=9)
        self.x_field.pack(side='left')
        self.y_field = TextField(location_frame, 'Y', location, 'row', to_int, width=9)
        self.y_field.pack(side='left')

    def set_selected_action_type(self, interactable: DDEInteractable | None):
        if interactable is None:
            self.data = None
            if self.action_panel is not None:
                self.action_panel.destroy()
                self.action_panel = None
        else:
            self.data = BaseInteractableProps.PanelData()
            action_type = None if interactable.action is None else interactable.action.type
            self.data.selected_action = ACTION_CHOICE_CUSTOM if action_type is None else action_type
            if self.action_panel is None or self.action_panel.type != action_type:
                self.create_action_panel(interactable)
            else:
                self.action_panel.rebind(interactable)

    def set_interactable(self, interactable: DDEInteractable):
        self.set_selected_action_type(interactable)
        self.action_selector.rebind(self.data)

        self.label_field.rebind(interactable)
        self.type_field.rebind(interactable)
        self.flags_field.rebind(interactable)
        self.prompt_field.rebind(interactable)

        location = interactable.location if interactable is not None else None
        self.x_field.rebind(location)
        self.y_field.rebind(location)

    def focus_label(self):
        self.label_field.focus_entry()

    def create_action_panel(self, interactable: DDEInteractable):
        if self.action_panel is not None:
            self.action_panel.destroy()
            self.action_panel = None

        if interactable.action is not None:
            match interactable.action.type:
                case 'call':
                    self.action_panel = CallActionPanel(self, interactable)
                case 'exit':
                    self.action_panel = ExitActionPanel(self, interactable)
        else:
            self.action_panel = CustomActionPanel(self, interactable)

        if self.action_panel is not None:
            self.action_panel.grid(row=1, column = 1, rowspan=3)

class InteractablesPanel(Frame):
    def __init__(self, root: Misc, screen: DDEScreen):
        super().__init__(root, padx=10)
        self.screen = screen

        self.selected_interactable: DDEInteractable | None = None

        buttons_frame = Frame(self)
        buttons_frame.grid(row=0, column=0)

        self.add_button = Button(buttons_frame, text='+')
        self.add_button.pack(side='left', anchor='n')
        self.remove_button = Button(buttons_frame, text='-', command=lambda: self.delete_selected_interactable())
        self.remove_button.pack(side='right', anchor='n')

        Label(self, text='Interactables', font=FONT).grid(row=0, column=1, sticky=W)

        self.listbox = Listbox(self)
        self.build_list()
        self.listbox.grid(row=1, column=1, sticky=W)
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
        self.base_props_panel.set_interactable(None)
        self.on_selected_interactable_changed()

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
        if self.base_props_panel.action_panel.type is None:
            self.base_props_panel.action_panel.set_label()
