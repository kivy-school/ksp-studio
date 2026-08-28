from .EntrypointScreen.entrypoint_screen import EntrypointScreenView

from ksproject_studio.Model.entrypoint_screen import EntrypointScreenModel

screens = {
    'entrypoint screen': {
        'object': EntrypointScreenView,
        'module': 'View.EntrypointScreen',
        'model': EntrypointScreenModel,
    },
}
