import copy

from tkinter import *

from tools.constants import BACKGROUND_COLS, BACKGROUND_ROWS, TILE_CHARACTERS
from tools.editor.background_cell import CELL_HEIGHT, BackgroundCell
from tools.editor.common import get_app_icon

FONT = ('Arial', 15)

class ScreenEditor(Toplevel):
    def __init__(self, dde_project, screen_index, tk_root, save_callback, focus_callback):
        super().__init__(tk_root)
        self.dde_project = copy.deepcopy(dde_project)
        self.screen_index = screen_index
        self.tk_root = tk_root
        self.save_callback = save_callback
        self.focus_callback = focus_callback

        self.was_destroyed = False
        self.protocol("WM_DELETE_WINDOW", lambda: self.close())

        self.background_cells = []
        self.selected_cell = None
        self.react_to_cell_entry = True

        self.wm_iconphoto(False, get_app_icon())
        screen = self.dde_project['screens'][self.screen_index]
        self.title(screen['name'])

        self.bind("<FocusIn>", lambda e: self.on_focus())

        if screen.get('is_custom', False):
            custom_label = Label(self, text=f'{screen["name"]} is a custom screen')
            custom_label.pack(side='top')
        else:
            top_bar = Frame(self)
            top_bar.pack(side='top', fill='x')
            props_frame = Frame(top_bar)

            def add_props_box(label, var, row):
                label = Label(props_frame, text=label, font=FONT)
                label.grid(column=0, row=row)

                text = Entry(props_frame, font=FONT, textvariable=var)
                text.grid(column=1, row=row)

                return text

            label = Label(props_frame, text='Name', font=FONT)
            label.grid(column=0, row=0)

            text = Label(props_frame, text=screen['name'], font=FONT)
            text.grid(column=1, row=0)

            def bind_prop(prop, source, name):
                def set_prop():
                    source[name] = prop.get()
                prop.trace_add('write', lambda v, i, m: set_prop())

            self.title_var = StringVar(props_frame, screen['title'])
            bind_prop(self.title_var, screen, 'title')
            add_props_box('Title', self.title_var, 1)

            start_location = screen['start_location']
            self.start_x_var = StringVar(props_frame, str(start_location['col']))
            bind_prop(self.start_x_var, start_location, 'col')
            add_props_box('Start X', self.start_x_var, 2)

            self.start_y_var = StringVar(props_frame, str(start_location['row']))
            bind_prop(self.start_y_var, start_location, 'row')
            add_props_box('Start Y', self.start_y_var, 3)

            props_frame.pack(side='left', anchor='n')

            middle_bar = Frame(self)
            middle_bar.pack(side='top', fill='x')

            background_grid = Frame(middle_bar)
            self.background_cells = []

            screen = self.dde_project['screens'][self.screen_index]

            for row in range(0, BACKGROUND_ROWS):
                row_cells = []
                background_grid.rowconfigure(row, minsize=CELL_HEIGHT)
                for col in range(0, BACKGROUND_COLS):
                    row_cells.append(BackgroundCell(
                        background_grid,
                        row,
                        col,
                        screen,
                        lambda c, s: self.on_cell_clicked(c, s)
                    ))

                self.background_cells.append(row_cells)

            background_grid.pack(side='left')

            cell_props_frame = Frame(top_bar)

            Label(cell_props_frame, text='Location ', font=FONT).grid(row=0, column=0)
            self.cell_location_label = Label(cell_props_frame, font=FONT, width=10)
            self.cell_location_label.grid(row=0, column=1)

            Label(cell_props_frame, text='Value ', font=FONT).grid(row=1, column=0)

            self.selected_cell_value = StringVar(cell_props_frame)
            self.selected_cell_value.trace_add('write', lambda v, i, m: self.on_cell_value_changed())
            Entry(cell_props_frame, font=FONT, textvariable=self.selected_cell_value).grid(row=1, column=1)

            self.on_selected_cell_changed()

            cell_props_frame.pack(side='right', anchor='n')

        bottom_frame = Frame(self)
        bottom_frame.pack(side='bottom', fill='x')

        apply_button = Button(bottom_frame, text='Apply', font=FONT, command=lambda: self.save())
        apply_button.pack(side='right')

    def close(self):
        if not self.was_destroyed:
            self.was_destroyed = True
            self.destroy()

    def save(self):
        self.save_callback(self.dde_project['screens'][self.screen_index], self.screen_index)

    def on_cell_clicked(self, cell, is_selected):
        if not is_selected:
            self.set_selected_cell(None)
        else:
            self.set_selected_cell(cell)

    def set_selected_cell(self, new_cell):
        if new_cell is not None and self.selected_cell != new_cell:
            for row in self.background_cells:
                for cell in row:
                    if cell != new_cell:
                        cell.deselect()

        if self.selected_cell != new_cell:
            self.selected_cell = new_cell
            self.on_selected_cell_changed()

    def on_selected_cell_changed(self):
        if self.selected_cell is None:
            self.cell_location_label.configure(text='<none>')
            self.set_selected_cell_value_text('')
        else:
            cell = self.selected_cell
            self.cell_location_label.configure(text=f'{cell.col + 1}, {cell.row + 1}')

            cell_character = self.dde_project['screens'][self.screen_index]['background'][cell.row][cell.col]
            self.set_selected_cell_value_text(cell_character)

    def set_selected_cell_value_text(self, text, react = False):
        self.react_to_cell_entry = react
        self.selected_cell_value.set(text)

    def on_cell_value_changed(self):
        if not self.react_to_cell_entry:
            self.react_to_cell_entry = True
            return

        if self.selected_cell is not None:
            value = self.selected_cell_value.get()
            if len(value) == 0:
                value = ' '
            else:
                value = value[0]

            if value not in TILE_CHARACTERS:
                value = '?'

            self.selected_cell.set_character_value(value)

    def use_character_from_palette(self, character):
        if self.selected_cell is None:
            return

        self.selected_cell.set_character_value(character)

    def on_focus(self):
        self.focus_callback(self)
