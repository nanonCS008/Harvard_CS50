PlayerCarryWalkState = Class{__includes = BaseState}

-- enter from PlayerCarryIdleState
function PlayerCarryWalkState:init(owner)
    self.owner = owner

    self.owner.render_offset_y = 5
    self.owner.render_offset_x = 0

    self.owner:changeAnimation('carry-walk-' .. self.owner.direction)
end

function PlayerCarryWalkState:updateStage1(dt)
    self.owner:doMovement(dt, 'carry-walk')

    -- if pressed Attack don't swing the sword, but throw the carried object
    if keyboardWasPressed(KEYS_ATTACK) then
        self.owner.carry:doStateChange('thrown', {direction = self.owner.direction})
        self.owner.carry = nil
        self.owner.new_state = 'idle'
    elseif self.owner.dx == 0 and self.owner.dy == 0 then
        self.owner.new_state = 'carry-idle'
    end

    self.owner:checkObjectCollisions()
end

function PlayerCarryWalkState:updateStage2(dt)
    self.owner:checkEntityCollisions()
end

function PlayerCarryWalkState:updateStage3(dt) end
