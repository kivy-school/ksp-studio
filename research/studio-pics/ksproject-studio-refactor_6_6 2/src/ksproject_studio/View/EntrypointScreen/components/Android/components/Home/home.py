from carbonkivy.uix.tab import CTab
from carbonkivy.uix.boxlayout import CBoxLayout
from carbonkivy.uix.stacklayout import CStackLayout

from kivy.properties import ObjectProperty
from ksproject_studio.libs.datamodel import PyProjectData

from ksproject_studio.uix.conditional_view import ConditionalView




class HomeLayout(CBoxLayout):
    data = ObjectProperty() # type: ObjectProperty[PyProjectData.Android]
    def __init__(self, **kwargs):
        #self.data = data.android
        super(HomeLayout, self).__init__( **kwargs)
        
    
    def on_data(self, _, data: PyProjectData.Android) -> None:
        print("HomeLayout received data update:", data)

class Home(CTab, ConditionalView):
    data = ObjectProperty() # type: ObjectProperty[PyProjectData.Android]

    wid: HomeLayout | None = None

    def __init__(self, *args, **kwargs):
        super(Home, self).__init__(*args, **kwargs)
        self.bind(data=self.on_data)
# class HomeView(ConditionalView):
#     data = ObjectProperty(None, allownone=True) # type: ObjectProperty[PyProjectData]
#     def __init__(self, *args, **kwargs):
#         super(HomeView, self).__init__(*args, **kwargs)

    def on_data(self, _, data: PyProjectData.Android) -> None:
        #data.bind(android=self.on_android_data)
        #if data.android:
        self.on_android_data(self, data)
    
    def on_android_data(self, _, android_data: PyProjectData.Android | None) -> None:
        newstate = android_data != None
        # if newstate == self.condition:
        #     self.update_view(self, newstate)
        self.condition = newstate
    
    def get_content(self) -> HomeLayout | None:
        if self.data:
            if self.data.android:
                if self.wid: return self.wid
                self.wid = HomeLayout(data=self.data.android)
                print("HomeView created HomeLayout with data:", self.data)
                return self.wid
        return None
        
class RightLayout(CBoxLayout):
    data = ObjectProperty(None, allownone=True) # type: ObjectProperty[PyProjectData.Android]
    def __init__(self, *args, **kwargs):
        super(RightLayout, self).__init__(*args, **kwargs)