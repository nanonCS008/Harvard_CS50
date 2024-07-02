--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Non player character
]]

NPC = Class{__includes = Entity}

function NPC:init(def)
    Entity.init(self, def)

    -- function that will be called when the player presses the 'confirm key' while standing in front of the NPC
    self.onInteraction = def.onInteraction or function() end

    self.state_machine = StateMachine({
        ['idle'] = function() return EntityIdleState(self) end
    })
    self.state_machine:change('idle')
end

-- Can be used in the onInteraction function. Default behavior when talking to a NPC
function NPC:faceEntity(entity)
    if entity.direction == 'left' then
        self.direction = 'right'
    elseif entity.direction == 'right' then
        self.direction = 'left'
    elseif entity.direction == 'up' then
        self.direction = 'down'
    else
        self.direction = 'up'
    end
    self.state_machine:change('idle')
end
