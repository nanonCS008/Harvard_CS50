--[[
    State that will be active when the Player is in a Menu, Textbox, etc.
    The GUI Object is passed as an input Parameter to this state.
]]

GUIState = Class{__includes = BaseState}

function GUIState:init(gui)
    self.id = GUI_STATE_ID
    self.gui = gui
end

function GUIState:update(dt)
    self.gui:update(dt)
end

function GUIState:render()
    self.gui:render()
end
