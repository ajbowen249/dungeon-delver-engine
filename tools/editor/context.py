import json
import os

from tools.dde_project import DDEProject, load_strings

class Context:
    def __init__(self, path: str):
        self.path = path
        with open(path, 'r', encoding='utf-8') as in_file:
            self.dde_project = DDEProject.from_dict(json.load(in_file))
            self.project_strings = load_strings(self.dde_project, os.path.dirname(path))

        Context.CONTEXT_INSTANCE = self

    def get_all_string_labels(self):
        if self.project_strings is None:
            return []

        keys = []

        def handle_dict(dict):
            for str_label in dict.keys():
                if ':' in str_label:
                    parts = str_label.split(':')
                    keys.append(parts[1])
                else:
                    keys.append(str_label)

        for str_file in self.project_strings.items():
            handle_dict(str_file[1])

        engine_json_path = os.path.join(os.path.dirname(__file__), '..', 'compressor', 'engine_text.json')
        with open(engine_json_path, 'r', encoding='utf-8') as engine_json_file:
            engine_json = json.load(engine_json_file)
            handle_dict(engine_json)

        return list(set(keys))


def ctx() -> Context:
    if Context.CONTEXT_INSTANCE is None:
        raise Exception('Tried to get context instance before initialization.')

    return Context.CONTEXT_INSTANCE

def has_ctx() -> bool:
    return Context.CONTEXT_INSTANCE is not None
