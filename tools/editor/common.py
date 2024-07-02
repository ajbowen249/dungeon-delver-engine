import os
from tkinter import PhotoImage

ICON_PATH = os.path.join(os.path.dirname(__file__), 'icon.png')
FONT = ('Arial', 15)

def get_app_icon():
    return PhotoImage(file=ICON_PATH)
