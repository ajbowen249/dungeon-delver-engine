import os
from tkinter import PhotoImage

ICON_PATH = os.path.join(os.path.dirname(__file__), 'icon.png')

def get_app_icon():
    return PhotoImage(file=ICON_PATH)
