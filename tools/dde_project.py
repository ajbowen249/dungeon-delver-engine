# Core DDE Project Definition

from tools.constants import MAX_INTERACTABLES, SCREEN_TITLE_MAX_LENGTH, BACKGROUND_COLS, BACKGROUND_ROWS, TILE_CHARACTERS

def require(dict, dict_name, attr):
    value = dict.get(attr)
    if value is None:
        raise TypeError(f'{dict_name} is missing key {attr}')

    return value

class DDELocation:
    def __init__(self, col: int, row: int):
        self.col = col
        self.row = row

    def from_dict(dict) -> 'DDELocation':
        dict_name = 'DDELocation'
        return DDELocation(
            require(dict, dict_name, 'col'),
            require(dict, dict_name, 'row')
        )

    def to_dict(self) -> dict:
        return {
            "col": self.col,
            "row": self.row,
        }

class DDEExitActionArgs:
    def __init__(self, exit_code: str, exit_id: str):
        self.exit_code = exit_code
        self.exit_id = exit_id

    def from_dict(dict):
        get = lambda key: require(dict, 'DDEExitActionArgs', key)
        return DDEExitActionArgs(get('exit_code'), get('exit_id'))

class DDECallActionArgs:
    def __init__(self, call_label: str):
        self.call_label = call_label

    def from_dict(dict):
        return DDECallActionArgs(require(dict, 'DDECallActionArgs', 'call_label'))

class DDEAction:
    def __init__(
        self,
        hook_before: bool,
        store_location: DDELocation | None,
        exit: DDEExitActionArgs | None,
        call: DDECallActionArgs | None
    ):
        self.hook_before = hook_before
        self.store_location = store_location
        if exit is not None and call is not None:
            raise TypeError('DDEAction got multiple sets of type argument')

        if exit is not None:
            self.type = 'exit'
            self.exit_code = exit.exit_code
            self.exit_id = exit.exit_id
        elif call is not None:
            self.type = 'call'
            self.call_label = call.call_label

    def from_dict(dict):
        get = lambda key: require(dict, 'DDEAction', key)

        exit = None
        call = None

        action_type = get('type')

        match action_type:
            case 'exit':
                exit = DDEExitActionArgs.from_dict(dict)
            case 'call':
                call = DDECallActionArgs.from_dict(dict)
            case _:
                raise TypeError(f'Unknown action type: {action_type}')

        store_location = dict.get('store_location', None)
        if store_location is not None:
            store_location = DDELocation.from_dict(store_location)

        return DDEAction(
            dict.get('hook_before', False),
            store_location,
            exit,
            call
        )

    def to_dict(self) -> dict:
        dict = {
            "type": self.type,
            "hook_before": self.hook_before,
            "store_location": self.store_location.to_dict() if self.store_location is not None else None,
        }

        match self.type:
            case 'exit':
                dict['exit_code'] = self.exit_code
                dict['exit_id'] = self.exit_id
            case 'call':
                dict['call_label'] = self.call_label
            case _:
                raise TypeError(f'Unknown action type: {self.type}')

        return dict

class DDEInteractable:
    def __init__(
            self,
            label: str,
            type: str,
            flags: str,
            location: DDELocation,
            prompt_label: str | None,
            action: DDEAction | None,
        ):
        self.label = label
        self.type = type
        self.flags = flags
        self.location = location
        self.prompt_label = prompt_label
        self.action = action

    def from_dict(dict) -> 'DDEInteractable':
        def get(key):
            return require(dict, 'DDEInteractable', key)

        action = dict.get('action', None)
        if action is not None:
            action = DDEAction.from_dict(action)

        return DDEInteractable(
            get('label'),
            get('type'),
            get('flags'),
            DDELocation.from_dict(get('location')),
            dict.get('prompt_label', None),
            action,
        )

    def to_dict(self) -> dict:
        return {
            "label": self.label,
            "type": self.type,
            "flags": self.flags,
            "location": self.location.to_dict(),
            "prompt_label": self.prompt_label,
            "action": self.action.to_dict() if self.action is not None else None,
        }

# These flatten into DDEScreen, but I'm packing them together to show they're all or nothing together
class DDEScreenProps:
    def __init__(
            self,
            title: str,
            init: bool,
            background: list[list[str]],
            start_location: DDELocation,
            interactables: list[DDEInteractable]
        ):

        if len(title) > SCREEN_TITLE_MAX_LENGTH:
            raise TypeError(
                f'Screen {title}\'s title is too long ({len(title)} > {SCREEN_TITLE_MAX_LENGTH})'
            )

        if len(background) != BACKGROUND_ROWS:
            raise TypeError(
                f'Screen {title} has wrong number of background rows ({len(background)} != {BACKGROUND_ROWS})'
            )

        for i in range(0, len(background)):
            row = background[i]
            if len(row) != BACKGROUND_COLS:
                raise TypeError(
                    f'Screen {title} background row {i} has wrong number of columns ({len(row)} != {BACKGROUND_COLS})'
                )
            for char in row:
                if char not in TILE_CHARACTERS:
                    raise TypeError(
                        f'Screen {title} has unmapped character in background ({char})'
                    )


        if len(interactables) > MAX_INTERACTABLES:
            raise TypeError(
                f'Screen {title} has too many interactables ({len(interactables)} > {MAX_INTERACTABLES})'
            )

        self.title = title
        self.init = init
        self.background = background
        self.start_location = start_location
        self.interactables = interactables

class DDEScreen:
    def __init__(self, name: str, props: DDEScreenProps | None = None):
        self.name = name

        if props is None:
            self.is_custom = True
        else:
            self.is_custom = False
            self.title = props.title
            self.init = props.init
            self.background = props.background
            self.start_location = props.start_location
            self.interactables = props.interactables

    def from_dict(dict) -> 'DDEScreen':
        def get(key):
            return require(dict, 'DDEScreen', key)

        name = get('name')
        is_custom = dict.get('is_custom', False)
        if is_custom:
            return DDEScreen(name)

        return DDEScreen(
            name,
            DDEScreenProps(
                get('title'),
                dict.get('init', False),
                get('background'),
                DDELocation.from_dict(get('start_location')),
                [DDEInteractable.from_dict(i) for i in get('interactables')]
            )
        )

    def to_dict(self) -> dict:
        if self.is_custom:
            return {
                "name": self.name,
                "is_custom": self.is_custom,
            }

        return {
            "name": self.name,
            "is_custom": self.is_custom,
            "title": self.title,
            "init": self.init,
            "background": self.background,
            "start_location": self.start_location.to_dict(),
            "interactables": [i.to_dict() for i in self.interactables]
        }

class DDEProject:
    def __init__(
            self,
            name: str,
            menu_label: str,
            player_party_label: str,
            party_size_label: str,
            screens: list[DDEScreen]
        ):
        self.name = name
        self.menu_label = menu_label
        self.player_party_label = player_party_label
        self.party_size_label = party_size_label
        self.screens = screens

    def from_dict(dict) -> 'DDEProject':
        def get(key):
            return require(dict, 'DDEProject', key)

        return DDEProject(
            get('name'),
            get('menu_label'),
            get('player_party_label'),
            get('party_size_label'),
            [DDEScreen.from_dict(s) for s in get('screens')]
        )

    def to_dict(self) -> dict:
        return {
            "name": self.name,
            "menu_label": self.menu_label,
            "player_party_label": self.player_party_label,
            "party_size_label": self.party_size_label,
            "screens": [s.to_dict() for s in self.screens],
        }
