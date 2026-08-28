from kivy.properties import ObjectProperty, StringProperty
from kivy.clock import Clock

from carbonkivy.uix.tab import CTab
from carbonkivy.uix.boxlayout import CBoxLayout
from carbonkivy.uix.stacklayout import CStackLayout

from ksproject_studio.libs.datamodel import PyProjectData

from ..PermissionsModal import PermissionsModal


class Permission(CBoxLayout):
    name = StringProperty()


class Permissions(CTab):
    data = ObjectProperty() # type: ObjectProperty[PyProjectData]
    android_data = ObjectProperty() # type: ObjectProperty[PyProjectData.Android]

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.modal = PermissionsModal()
        #self.bind(data=self.on_data)
        #self.bind(android_data=self._setup_bindings)
        #Clock.schedule_once(self._setup_bindings)

    def on_data(self, _, data: PyProjectData) -> None:
        # if data:
        #     self.android_data = data.android
        # else:
        #     self.android_data = None
        pass

    def on_android_data(self, _, android_data: PyProjectData.Android) -> None:
        if android_data:
            self._setup_bindings(None, self.data)
        else:
            # Clear the UI if there's no android data
            layout = self.ids.PermLayout
            layout.clear_widgets()

    def _setup_bindings(self, _, data: PyProjectData) -> None:
        """
        Binds the UI to the datamodel so it automatically refreshes 
        if permissions are added or removed dynamically.
        """
        self.data.bind(android_permissions=self.update_permissions_ui)

        self.update_permissions_ui(self.data, self.data.android_permissions)

    def update_permissions_ui(self, instance, permissions_list):
        """
        Clears the layout and repopulates it based on the datamodel list.
        """
        layout = self.ids.PermLayout

        for perm in (permissions_list or []):
            layout.add_widget(Permission(name=perm))

    def launch_modal(self, *args) -> None:
        self.modal.open()
