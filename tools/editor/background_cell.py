from tkinter import *

CELL_WIDTH = 35
CELL_HEIGHT = 44
SELECTED_COLOR = 'white'
DESELECTED_COLOR = 'gray'
DESELECTED_CH_COLOR = 'black'
SELECTED_CH_COLOR = 'gray25'
HALF_CELL_WIDTH = int(CELL_WIDTH / 2)
HALF_CELL_HEIGHT = int(CELL_HEIGHT / 2)

class BackgroundCell:
    def __init__(self, background_grid, row, col, screen, click_callback):
        self.row = row
        self.col = col
        self.screen = screen
        self.is_selected = False
        self.click_callback = click_callback

        frame = Frame(background_grid, width=CELL_WIDTH, height=CELL_HEIGHT)
        self.frame = frame
        frame.grid(row=row, column=col, sticky='snew')

        canvas = Canvas(frame, bg=DESELECTED_COLOR, width=CELL_WIDTH, height=CELL_HEIGHT, bd=0, highlightthickness=0)
        self.canvas = canvas

        self.draw()

        canvas.pack()
        canvas.bind('<Button-1>', lambda e: self.on_click())

    def get_character(self):
        return self.screen['background'][self.row][self.col]

    def draw_character(self, color):
        # IMPROVE: This is only a slight improvement over vscode, but it at least doesn't suffer from inconsistent
        # character width.
        self.canvas.create_text(
            HALF_CELL_WIDTH,
            HALF_CELL_HEIGHT,
            text=self.get_character(),
            font=("Purisa", CELL_WIDTH),
            fill=color
        )

    def on_click(self):
        if self.is_selected:
            self.is_selected = False
            self.on_deselected()
        else:
            self.is_selected = True
            self.on_selected()

        self.click_callback(self, self.is_selected)

    def deselect(self):
        self.is_selected = False
        self.on_deselected()

    def on_selected(self):
        self.draw()
        self.canvas.focus_set()
        pass

    def on_deselected(self):
        self.draw()
        self.canvas.focus_set()
        pass

    def draw(self):
        self.canvas.delete(ALL)
        self.canvas.configure(bg=SELECTED_COLOR if self.is_selected else DESELECTED_COLOR)
        self.draw_character(SELECTED_CH_COLOR if self.is_selected else DESELECTED_CH_COLOR)

    def set_character_value(self, character):
        line = self.screen['background'][self.row]
        left = line[:self.col]
        right = line[self.col + 1:]
        self.screen['background'][self.row] = f'{left}{character}{right}'
        self.draw()
        pass
