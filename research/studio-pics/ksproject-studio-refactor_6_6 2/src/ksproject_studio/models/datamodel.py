import os
import toml
import time

from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

from kivy.app import App
from kivy.clock import mainthread
from kivy.properties import AliasProperty, ObjectProperty, StringProperty
from kivy.event import EventDispatcher

#from ksproject_utils.pyproject_toml import KivySchoolData
from ._datamodel import PyProjectData as _PyProjectData # generated from models.yaml

class PyProjectData(_PyProjectData):
    """
    wrapper for PyProjectData.
    """

    # [project]
    project = ObjectProperty(None, allownone=True) # type: ObjectProperty[dict] # raw project section for any future use

    # [build-system]
    build_system = StringProperty(None, allownone=True) # type: StringProperty | None

    # [tool.kivy-school]
    android = ObjectProperty(None, allownone=True) # type: ObjectProperty[PyProjectData.Android | None]
    ios = ObjectProperty(None, allownone=True) # type: ObjectProperty[PyProjectData.IOS | None]
    macos = ObjectProperty(None, allownone=True) # type: ObjectProperty[PyProjectData.MacOS | None]

    pyproject_toml = StringProperty(None, allownone=True) # type: StringProperty | None

    

    def __init__(self, *args, **kwargs) -> None:
        self.observer = Observer()     
        super().__init__(*args, **kwargs)
        self.bind(pyproject_toml=self.reload_toml_path)

    def on_modified(self, event):
        if os.path.abspath(event.src_path) == self.pyproject_toml:
            print(f"[Watchdog] Detected change in {self.pyproject_toml}. Reloading...")
            self.reload_toml_data(self.pyproject_toml)

    def reload_toml_path(self, _, path: str | None):
        if path:
            self.remove_observer()
            self.add_observer(path)
            self.reload_toml_data(path)
        else:
            self.remove_observer()
            self.reload_toml_data(None)
        
        
    def reload_toml_data(self, path: str | None):
        if path:
            with open(path, "r") as f:
                full_toml_dict = toml.load(f)

            data = full_toml_dict.get("tool", {}).get("kivy-school", {})

            if "android" in data:
                self.android = self.Android(data["android"])
            else:
                self.android = None

            if "ios" in data:
                self.ios = self.IOS(data["ios"])
            else:
                self.ios = None
            
            if "macos" in data:
                self.macos = self.MacOS(data["macos"])
            else:
                self.macos = None
        else:
            self.ios = None
            self.macos = None
            self.android = None

    def add_observer(self, path: str) -> None:
        #self.watchdog_handler = TomlChangeHandler(self, path)
        self.observer.schedule(self, os.path.dirname(path), recursive=False)
    
    def remove_observer(self) -> None:
        if hasattr(self, "watchdog_handler"):
            self.observer.unschedule(self.watchdog_handler)
            del self.watchdog_handler

    def save(self, *args) -> None:
        """
        Saves the current data state back to the pyproject.toml file.
        Preserves all other sections of the TOML file and handles custom service attributes.
        """
        if not self.data:
            print("[Save] No data to save.")
            return

        try:
            if hasattr(self, "watchdog_handler"):
                self.watchdog_handler.pause_temporarily()

            toml_file = os.path.join(os.getcwd(), "pyproject.toml")
            if os.path.exists(toml_file):
                with open(toml_file, "r") as f:
                    full_toml_dict = toml.load(f)
            else:
                full_toml_dict = {}

            if "tool" not in full_toml_dict:
                full_toml_dict["tool"] = {}

            new_kivy_school_dict = {
                "app_name": self.app_name,
                "ios": {
                    "bundle_id": self.ios.bundle_id,
                    "info_plist": self.ios.info_plist,
                    "entitlements": self.ios.entitlements,
                    "permissions": self.ios.permissions,
                    "frameworks": self.ios.frameworks,
                    "site_frameworks": self.ios.site_frameworks,
                    "developer_team": self.ios.developer_team,
                },
                "macos": {
                    "bundle_id": self.macos.bundle_id,
                    "info_plist": self.macos.info_plist,
                    "entitlements": self.macos.entitlements,
                    "developer_team": self.macos.developer_team,
                },
                "android": {
                    "package_name": self.android.package_name,
                    "archs": [arch.value for arch in self.android.archs],
                    "api": self.android.api,
                    "min_api": self.android.min_api,
                    "sdk": self.android.sdk,
                    "ndk": self.android.ndk,
                    "ndk_api": self.android.ndk_api,
                    "sdk_path": str(self.android.sdk_path),
                    "ndk_path": self.android.ndk_path,
                    "java_path": self.android.java_path,
                    "global_tools": self.android.global_tools,
                    "global_tools_path": self.android.global_tools_path,
                    "icon": self.android.icon,
                    "presplash": self.android.presplash,
                    "presplash_color": self.android.presplash_color,
                    "presplash_lottie": self.android.presplash_lottie,
                    "permissions": self.android.permissions,
                    "meta_data": self.android.meta_data,
                    "gradle_dependencies": self.android.gradle_dependencies,

                    "services": (
                        [
                            {
                                "name": getattr(s, "name", ""),
                                "start_type": getattr(
                                    s, "start_type", "START_NOT_STICKY"
                                ),
                                "entrypoint": getattr(s, "entrypoint", ""),
                                "foreground": getattr(s, "foreground", True),
                                "foreground_service_type": getattr(
                                    s, "foreground_service_type", ""
                                ),
                                "notification_title": getattr(
                                    s, "notification_title", ""
                                ),
                                "notification_text": getattr(
                                    s, "notification_text", ""
                                ),
                                "notification_icon": getattr(
                                    s, "notification_icon", ""
                                ),
                            }
                            for s in self.android.services
                        ]
                        if self.android.services
                        else []
                    ),
                },
            }

            for platform in ["ios", "macos", "android"]:
                new_kivy_school_dict[platform] = {
                    k: v
                    for k, v in new_kivy_school_dict[platform].items()
                    if v is not None
                }

            full_toml_dict["tool"]["kivy-school"] = new_kivy_school_dict

            with open(toml_file, "w") as f:
                toml.dump(full_toml_dict, f)

            print("[Save] Successfully saved to pyproject.toml")

        except Exception as e:
            print(f"[Save] Error saving to pyproject.toml: {e}")

            if hasattr(self, "watchdog_handler"):
                self.watchdog_handler._is_paused = False


class TomlChangeHandler(FileSystemEventHandler):
    """Watches for changes to the pyproject.toml file and reloads the datamodel."""

    def __init__(self, datamodel, toml_path):
        self.datamodel = datamodel
        self.toml_path = os.path.abspath(toml_path)

    def on_modified(self, event):
        if os.path.abspath(event.src_path) == self.toml_path:
            print(f"[Watchdog] Detected change in {self.toml_path}. Reloading...")
            self.reload_toml()

    @mainthread
    def reload_toml(self):
        """
        Reads the TOML file and updates the Kivy datamodel.
        The @mainthread decorator ensures UI bindings trigger safely on the main Kivy thread.
        """
        try:
            time.sleep(0.1)

            with open(self.toml_path, "r") as f:
                full_toml_dict = toml.load(f)

            kivy_school_dict = full_toml_dict.get("tool", {}).get("kivy-school", {})
            # TODO: fix
            # new_kivyschool_data = KivySchoolData(data=kivy_school_dict)

            # self.datamodel.data = new_kivyschool_data
            print("[Watchdog] Successfully updated PyProjectData.")

        except Exception as e:
            print(f"[Watchdog] Failed to reload TOML file: {e}")


# toml_path = os.path.join(os.getcwd(), "pyproject.toml")

# with open(toml_path, "r") as f:
#     full_toml_dict = toml.load(f)

# kivy_school_dict = full_toml_dict.get("tool", {}).get("kivy-school", {})
# datamodel = PyProjectData(data=kivy_school_dict)
# #datamodel.data = KivySchoolData(data=kivy_school_dict)
# datamodel.pyproject_toml = toml.dumps(full_toml_dict)

# event_handler = TomlChangeHandler(datamodel, toml_path)
# observer = Observer()

# target_dir = os.path.dirname(toml_path)
# observer.schedule(event_handler, target_dir, recursive=False)
# observer.start()
