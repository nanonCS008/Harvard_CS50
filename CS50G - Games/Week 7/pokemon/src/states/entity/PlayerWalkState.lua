--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerWalkState = Class{__includes = BaseState}

function PlayerWalkState:init(entity)
    self.entity = entity
    self.name = 'walk'
    -- walk animation gets set inside doMovement() function
end

function PlayerWalkState:update(dt)
    if not self.entity.is_moving and not self.entity:doMovement() then
        -- don't override new_state if it got set inside the collision detection function
        if not self.entity.new_state then self.entity.new_state = 'idle' end
    end
end
