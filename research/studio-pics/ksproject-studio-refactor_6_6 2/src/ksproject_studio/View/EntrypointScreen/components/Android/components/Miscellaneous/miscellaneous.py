from datetime import datetime
from zoneinfo import ZoneInfo

from carbonkivy.uix.tab import CTab
from carbonkivy.uix.boxlayout import CBoxLayout
from carbonkivy.uix.stacklayout import CStackLayout

from kivy.factory import Factory

from kivy.properties import StringProperty, ObjectProperty
from kivy.clock import Clock

from ksproject_studio.View.components.PreviewPane import PreviewPane
from ksproject_studio.libs.datamodel import PyProjectData as KivySchoolData
from ksproject_studio.uix.conditional_view import ConditionalView



class AndroidPane(PreviewPane):
    time = StringProperty()
    data = ObjectProperty() # type: ObjectProperty[KivySchoolData.Android]

    def __init__(self, *args, **kwargs):
        super(AndroidPane, self).__init__(*args, **kwargs)
        Clock.schedule_interval(self.update_time, 1.0)

    def update_time(self, *args) -> None:
        self.time = datetime.now(ZoneInfo("UTC")).strftime("%H:%M")




class Miscellaneous(CStackLayout):
    data = ObjectProperty() # type: ObjectProperty[KivySchoolData.Android]

    def __init__(self, data: KivySchoolData.Android, **kwargs):
        self.data = data
        super(Miscellaneous, self).__init__(**kwargs)

class MiscellaneousTab(CTab, ConditionalView):
    data = ObjectProperty() # type: ObjectProperty[KivySchoolData]

    def __init__(self, *args, **kwargs):
        super(MiscellaneousTab, self).__init__(*args, **kwargs)


# class MiscellaneousView(ConditionalView):
#     data = ObjectProperty() # type: ObjectProperty[KivySchoolData]
#     def __init__(self, *args, **kwargs):
#         super(MiscellaneousView, self).__init__(*args, **kwargs)

    def on_data(self, _, data: KivySchoolData) -> None:
        #data.bind(android=self.on_android_data)
        #if data.android:
        self.on_android_data(self, data)
    
    def on_android_data(self, _, android_data: KivySchoolData.Android | None) -> None:
        self.condition = android_data != None

    def get_content(self) -> Miscellaneous | None:
        if self.data:
            if self.data.android:
                return None
                #raise Exception("MiscellaneousTab content is not implemented yet.")
                return Miscellaneous(self.data.android)
        return None


class MiscellaneousLayout(CBoxLayout):
    data = ObjectProperty() # type: ObjectProperty[KivySchoolData.Android]
    def __init__(self, *args, **kwargs):
        super(MiscellaneousLayout, self).__init__(*args, **kwargs)

