--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerWalkState = Class{__includes = BaseState}

function PlayerWalkState:init(owner)
    self.owner = owner

    self.owner.render_offset_y = 5
    self.owner.render_offset_x = 0

    self.owner:changeAnimation('walk-' .. self.owner.direction)
end

function PlayerWalkState:updateStage1(dt)
    self.owner:doMovement(dt, 'walk')

    if keyboardWasPressed(KEYS_ATTACK) then
        self.owner.new_state = 'swing-sword'
    elseif keyboardWasPressed(KEYS_GRAB) then
        self.owner.new_state = 'grab'
    elseif self.owner.dx == 0 and self.owner.dy == 0 then
        self.owner.new_state = 'idle'
    end

    self.owner:checkObjectCollisions()
end

function PlayerWalkState:updateStage2(dt)
    self.owner:checkEntityCollisions()
end

function PlayerWalkState:updateStage3(dt) end
