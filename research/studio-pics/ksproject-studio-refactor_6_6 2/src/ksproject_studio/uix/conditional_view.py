from kivy.uix.widget import Widget
from kivy.properties import ObjectProperty, BooleanProperty

from carbonkivy.uix.boxlayout import CBoxLayout

from kivy.factory import Factory
from typing import Callable


class ConditionalView:
    condition = BooleanProperty(False) 
    last_state = False

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.bind(condition=self.update_view)

    def update_view(self, _, state: bool) -> None:  
        print(f"ConditionalView condition updated: {state}")
        if state == self.last_state:
            return   
        if state:
            content = self.get_content()
            if content:
                if content.parent != self:
                    #raise Exception("ConditionalView get_content returned a widget that is not a child of the ConditionalView. Please ensure that the widget returned by get_content is added as a child of the ConditionalView.")
                    self.clear_widgets()
                    self.add_widget(content)
        else:
            self.clear_widgets()
        self.last_state = state

    def get_content(self) -> Widget | None:
        raise NotImplementedError("Subclasses of ConditionalView must implement the get_content method to return the appropriate content widget based on the condition.")




Factory.register("ConditionalView", cls="ksproject_studio.uix.conditional_view.ConditionalView")
