--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerIdleState = Class{__includes = BaseState}

function PlayerIdleState:init(entity)
    self.entity = entity
    self.name = 'idle'
    self.entity:changeAnimation('idle-' .. self.entity.direction)

    -- Only start moving when a movement key is hold for a certain threshold time.
    -- The player direction gets changed immediately however.
    self.threshold_time = 0.07
    -- If there is a collision, wait longer before trying to move again in the same direction
    -- (does not apply when the direction is changed after the collision).
    -- This is also the frequency at which the bump sound effect is played.
    self.threshold_time_after_col = 0.5
    self.threshold_timer = self.threshold_time
end

function PlayerIdleState:update(dt)
    local input_direction = self.entity:getMovementInput()
    if input_direction then
        if self.entity.direction ~= input_direction then
            self.threshold_timer = self.threshold_time
            self.entity.direction = input_direction
            self.entity:changeAnimation('idle-' .. self.entity.direction)
        else
            self.threshold_timer = math.max(0, self.threshold_timer - dt)
            if self.threshold_timer <= 0 then
                -- If there is an obstacle and no other state (e.g. jump) was set in the collision callback,
                -- the player stays in idle state
                if self.entity:doMovement(input_direction) then
                    self.entity.new_state = 'walk'
                elseif not self.entity.new_state then
                    -- When the collision happened inside the walk state the player will go into idle state and
                    -- the bump sound effect only plays after the self.threshold_time delay.
                    -- After that it will play periodically with self.threshold_time_after_col.
                    gSounds['bump']:stop()
                    gSounds['bump']:play()
                    self.threshold_timer = self.threshold_time_after_col
                end
            end
        end
    else
        self.threshold_timer = self.threshold_time
    end

    -- Allow opening menus/ interactions only in idle state. If a menu would be opened during the tween
    -- from one tile to another, the animation would stop but the player would finish the current tween process.
    -- The camera would get updated after the menu is closed and jump to the new player position.
    if keyboardWasPressed(KEYS_MENU) then
        gSounds['confirm']:play()
        gStateStack:push(getPartyMenuState(self.entity.party))
    elseif keyboardWasPressed(KEYS_CONFIRM) then
        self.entity:doInteraction()
    end
end
