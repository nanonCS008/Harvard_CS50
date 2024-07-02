--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerIdleState = Class{__includes = BaseState}

function PlayerIdleState:init(owner)
    self.owner = owner

    self.owner.render_offset_y = 5
    self.owner.render_offset_x = 0

    self.owner:changeAnimation('idle-' .. self.owner.direction)
end

function PlayerIdleState:updateStage1(dt)
    -- if attack/ grab was pressed, don't do Movement
    if keyboardWasPressed(KEYS_ATTACK) then
        self.owner.new_state = 'swing-sword'
    elseif keyboardWasPressed(KEYS_GRAB) then
        self.owner.new_state = 'grab'
    elseif self.owner:doMovement(dt) then
        self.owner.new_state = 'walk'
    end

    self.owner:checkObjectCollisions()
end

function PlayerIdleState:updateStage2(dt)
    self.owner:checkEntityCollisions()
end

function PlayerIdleState:updateStage3(dt) end
