--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Player = Class{__includes = Entity}

function Player:init(def)
    Entity.init(self, def)
    self.state_machine = StateMachine({
        ['idle'] = function() return PlayerIdleState(self) end,
        ['walk'] = function() return PlayerWalkState(self) end,
        ['jump'] = function() return PlayerJumpState(self) end
    })
    self.state_machine:change('idle')
    -- table of all Pokemon that the player is carrying
    self.party = def.party
end

-- if standing in front of an NPC, trigger the NPC's onInteraction function
function Player:doInteraction()
    local check_grid_x, check_grid_y = self.grid_x, self.grid_y
    if self.direction == 'left' then
        check_grid_x = check_grid_x - 1
    elseif self.direction == 'right' then
        check_grid_x = check_grid_x + 1
    elseif self.direction == 'up' then
        check_grid_y = check_grid_y - 1
    else
        check_grid_y = check_grid_y + 1
    end

    for _, entity in pairs(self.area.entities) do
        if entity.grid_x == check_grid_x and entity.grid_y == check_grid_y then
            entity:onInteraction(self)
        end
    end
end

-- return the movement input direction or nil if there is no keyboard input
function Player:getMovementInput()
    local direction
    if love.keyboard.isDown(table.unpack(KEYS_LEFT)) then
        direction = 'left'
    elseif love.keyboard.isDown(table.unpack(KEYS_RIGHT)) then
        direction = 'right'
    elseif love.keyboard.isDown(table.unpack(KEYS_UP)) then
        direction = 'up'
    elseif love.keyboard.isDown(table.unpack(KEYS_DOWN)) then
        direction = 'down'
    end
    return direction
end

-- If the player presses the movement keys and there is no obstacle, tween the player 1 tile in movement direction.
-- If input_dir_override is specified, don't check for movement key input, but set the movement direction directly.
-- A new player state may be set in a collision callback function.
-- return true if the player position will be tweened, false if there is no movement or a collision.
function Player:doMovement(input_dir_override)
    self.is_moving = false
    local to_grid_x, to_grid_y = self.grid_x, self.grid_y

    local input_direction = input_dir_override and input_dir_override or self:getMovementInput()
    if input_direction == 'left' then
        to_grid_x = to_grid_x - 1
    elseif input_direction == 'right' then
        to_grid_x = to_grid_x + 1
    elseif input_direction == 'up' then
        to_grid_y = to_grid_y - 1
    elseif input_direction == 'down' then
        to_grid_y = to_grid_y + 1
    else
        return false
    end

    self.direction = input_direction

    if self:checkCollision(to_grid_x, to_grid_y) then
        return false
    end

    self.is_moving = true

    self.grid_x, self.grid_y = to_grid_x, to_grid_y
    local to_x, to_y = self:getPositionFromGrid()

    local animation_base_name = 'walk'
    local speed = self.walking_speed
    if love.keyboard.isDown(table.unpack(KEYS_RUNNING)) then
        speed = self.running_speed
        animation_base_name = 'run'
    end
    local time_per_tile = 1 / speed

    local new_animation_name = animation_base_name .. '-' .. self.direction
    if self.current_animation ~= self.animations[new_animation_name] then
        self:changeAnimation(new_animation_name)
    end

    Timer.tween(time_per_tile, {
        [self] = {x = to_x, y = to_y}
    }):finish(function()
        self.is_moving = false
        -- check for wild Pokemon encounters at the end of the movement
        self:checkEncounter()
    end)

    return true
end

-- If the player is walking in grass, push the BattleState with a certain probability
function Player:checkEncounter()
    local is_encounter = false

    local encounter_prob = 0.1
    if
        self.area.grass_layer[self.grid_y] and
        self.area.grass_layer[self.grid_y][self.grid_x] and
        self.area.grass_layer[self.grid_y][self.grid_x].id == TILE_ID_GRASS and
        math.random() < encounter_prob
    then
        is_encounter = true
        -- force idle state
        self.state_machine:change('idle')
        self.new_state, self.new_state_params = nil, nil

        -- checkEncounter() is called when a timer is elapsed.
        -- Timer are updated before calling the State Stack update function.
        -- When pushing a new state, this new state is updated after the timer update,
        -- so the current state cannot react to the latest change in the Player coordinates in this frame.
        -- Update the camera now, so it does not adjust to the latest coordinates when the GameArea can
        -- update again (after the encounter)
        self.area:updateCamera()

        gSounds['field-music']:pause()
        gSounds['battle-music']:setLooping(true)
        gSounds['battle-music']:play()

        -- fade out PlayState
        gStateStack:push(FadeState({255/255, 255/255, 255/255, 0/255}, 255/255, 1,
        function()
            gStateStack:push(BattleState(self))
            -- don't render the PlayState any more for optimization purposes
            gStateStack:renderFromHere()
            -- fade in BattleState
            gStateStack:push(FadeState({255/255, 255/255, 255/255, 255/255}, 0/255))
        end))
    end
    return is_encounter
end
