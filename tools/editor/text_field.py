from tkinter import *
from typing import Callable

# For convenience in passing to TextField
def to_int(value: str):
    if value == '':
        value = '0'
    return int(value)

class TextField(Frame):
    def __init__(
            self,
            root: Misc,
            label: str,
            source_object: object,
            source_attr: str,
            converter: Callable[[str], any] = lambda v: v
        ):
        super().__init__(root)
        var = StringVar(self, str(getattr(source_object, source_attr)))

        def set_prop():
            setattr(source_object, source_attr, converter(var.get()))

        var.trace_add('write', lambda v, i, m: set_prop())

        Label(self, text=label).grid(row=0, column=0, sticky=W)
        Entry(self, textvariable=var).grid(row=1, column=0)
