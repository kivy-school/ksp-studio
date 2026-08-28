from kivy.properties import ListProperty, ObjectProperty

from carbonkivy.uix.boxlayout import CBoxLayout

from ksproject_studio.View.base_screen import BaseScreenView
from ksproject_studio.uix.conditional_view import ConditionalView
from ksproject_studio.libs.datamodel import PyProjectData




class AndroidLayout(CBoxLayout):
    data = ObjectProperty() # type: ObjectProperty[PyProjectData.Android]
    def __init__(self, data: PyProjectData.Android, **kwargs):
        self.data = data
        super(AndroidLayout, self).__init__(**kwargs)
        #self.bind(data=self.on_android_data)

    def on_android_data(self, _, android_data: PyProjectData.Android) -> None:
        print("AndroidLayout received Android data update:", android_data)

class Android(BaseScreenView, ConditionalView):
    data = ObjectProperty() # type: ObjectProperty[PyProjectData]

    def __init__(self, *args, **kwargs):
        #raise Exception("Android Screen is not implemented yet.")
        super(Android, self).__init__(*args, **kwargs)
        self.bind(data=self.on_data)

# class AndroidView(ConditionalView):
#     data = ObjectProperty() # type: ObjectProperty[PyProjectData]
#     def __init__(self, *args, **kwargs):
#         super(AndroidView, self).__init__(*args, **kwargs)
#         self.bind(data=self.on_data)
#         #raise Exception("AndroidView content is not implemented yet.")
    
    def on_android_data(self, _, android_data: PyProjectData.Android) -> None:
        print("AndroidView received Android data update:", android_data)
        #raise Exception("AndroidView on_android_data is not implemented yet.")
        self.condition = android_data != None

    def on_data(self, _, data: PyProjectData) -> None:
        #raise Exception("AndroidView on_data is not implemented yet.")
        #data.bind(android=self.on_android_data)
        #if data.android:
        self.on_android_data(self, data.android)
            

    
    def get_content(self) -> AndroidLayout | None:
        data = self.data
        if data:
            #raise Exception("AndroidView get_content is not implemented yet.")
            if data.android:
                wid = AndroidLayout(data=data.android)
                #data.bind(android=wid.setter("data"))
                return wid
            # else:
            #     raise Exception("AndroidView get_content: Android data is None.")
        return None
            
