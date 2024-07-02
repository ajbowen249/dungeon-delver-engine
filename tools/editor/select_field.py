from tkinter import *
from tkinter import ttk
from typing import Callable

# For convenience in passing to TextField
def to_int(value: str):
    if value == '':
        value = '0'
    return int(value)

class SelectField(Frame):
    def __init__(
            self,
            root: Misc,
            label: str,
            options: list[str],
            source_object: object | None,
            source_attr: str,
            converter: Callable[[str], any] = lambda v: v,
            **kwargs
        ):
        super().__init__(root)
        self.options = options
        self.source_object = source_object
        self.source_attr = source_attr
        self.converter = converter

        self.var = StringVar(self, self.get_source_str())
        self.observers: list[Callable[[str], None]] = []

        self.var.trace_add('write', lambda v, i, m: self.set_prop())

        Label(self, text=label).grid(row=0, column=0, sticky=W)
        self.combobox = ttk.Combobox(
            self,
            textvariable=self.var,
            values=self.options,
            width=kwargs.get('width', None)
        )
        self.combobox.grid(row=1, column=0)
        self.update_enablement()

    def get_source_str(self):
        # None source_object is "unbound" state
        if self.source_object is None:
            return ''

        return str(getattr(self.source_object, self.source_attr))

    def set_prop(self):
        # We also disengage from the source object so we can update the visual binding with our new value
        if self.source_object is None:
            return

        setattr(self.source_object, self.source_attr, self.converter(self.var.get()))
        for observer in self.observers:
            observer(self.var.get())

    def add_observer(self, observer: Callable[[str], None]):
        self.observers.append(observer)

    def rebind(self, new_source: object):
        self.source_object = None
        self.var.set(str(getattr(new_source, self.source_attr)))
        self.source_object = new_source
        self.update_enablement()

    def update_enablement(self):
        self.combobox.configure(state='readonly' if self.source_object is not None else 'disabled')
