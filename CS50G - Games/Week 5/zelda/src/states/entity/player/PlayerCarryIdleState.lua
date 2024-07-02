PlayerCarryIdleState = Class{__includes = BaseState}

-- enter from PlayerGrabState or PlayerCarryWalkState
function PlayerCarryIdleState:init(owner)
    self.owner = owner

    self.owner.render_offset_y = 5
    self.owner.render_offset_x = 0

    self.owner:changeAnimation('carry-idle-' .. self.owner.direction)
end

function PlayerCarryIdleState:updateStage1(dt)
    -- if pressed Attack don't swing the sword, but throw the carried object
    if keyboardWasPressed(KEYS_ATTACK) then
        self.owner.carry:doStateChange('thrown', {direction = self.owner.direction})
        self.owner.carry = nil
        self.owner.new_state = 'idle'
    elseif self.owner:doMovement(dt) then
        self.owner.new_state = 'carry-walk'
    end

    self.owner:checkObjectCollisions()
end

function PlayerCarryIdleState:updateStage2(dt)
    self.owner:checkEntityCollisions()
end

function PlayerCarryIdleState:updateStage3(dt) end
