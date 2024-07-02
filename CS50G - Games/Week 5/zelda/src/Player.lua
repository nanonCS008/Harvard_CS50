--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Player = Class{__includes = Entity}

function Player:init(x, y, dungeon)
    -- construct the complete definition for the Player
    -- Player hitbox definitions get converted into hitbox objects.
    -- The new hitboxes key overwrites the old one inside player_def.
    -- ENTITY_DEFS must be deepcopied to not get modified.
    local player_def = deepcopy(ENTITY_DEFS['player'])
    table.extend(player_def, {
        x = x, y = y,
        hitboxes = getHitboxesFromDefinition(player_def.hitboxes),
        dungeon = dungeon
    })

    Entity.init(self, player_def)

    -- the StateMachine Classes get a reference to the player, supplied as a parameter to their init methods when instantiated
    self.state_machine = StateMachine({
        ['walk'] = function() return PlayerWalkState(self) end,
        ['idle'] = function() return PlayerIdleState(self) end,
        ['swing-sword'] = function() return PlayerSwingSwordState(self) end,
        ['grab'] = function() return PlayerGrabState(self) end,
        ['carry-idle'] = function() return PlayerCarryIdleState(self) end,
        ['carry-walk'] = function() return PlayerCarryWalkState(self) end,
        ['game-over'] = function() return PlayerGameOverState(self) end
    })

    -- set initial state
    self.state_machine:change('idle')
end

-- overrides Entity:onDeath()
-- new_state should not get set after this call (after checkEntityCollisions()), to not overwrite the death state
function Player:onDeath()
    self.new_state = 'game-over'
    self.new_state_params = 'death'
end

-- this function changes the player velocity based on the keyboard input
-- update the players position based on the velocity afterwards
-- The player Animation gets set according to his direction
-- animation_base_name: the new direction appended to the animation base name is the new animation name
-- return: true if there is a keyboard input, false otherwise
function Player:doMovement(dt, animation_base_name)
    -- no keyboard input means the velocity gets set to 0
    self.dx, self.dy = 0, 0
    local is_movement = false

    -- store the vertical and horizontal direction that is moved towards in a list
    local direction_list = {}

    if love.keyboard.isDown(table.unpack(KEYS_LEFT)) then
        table.insert(direction_list, 'left')
        self.dx = -self.move_speed
    elseif love.keyboard.isDown(table.unpack(KEYS_RIGHT)) then
        table.insert(direction_list, 'right')
        self.dx = self.move_speed
    end

    if love.keyboard.isDown(table.unpack(KEYS_UP)) then
        table.insert(direction_list, 'up')
        self.dy = -self.move_speed
    elseif love.keyboard.isDown(table.unpack(KEYS_DOWN)) then
        table.insert(direction_list, 'down')
        self.dy = self.move_speed
    end

    if #direction_list > 0 then
        is_movement = true
        -- only change the direction if the previous direction is not represented by any input any more.
        -- e.g. if facing right and change walking from right-down to right-up, the direction will still be right.
        local new_direction = self.direction
        if #direction_list == 1 then
            new_direction = direction_list[1]
        else
            if not table.contains(direction_list, self.direction) then
                new_direction = direction_list[1]
            end
            -- normalize the velocity so the player does not get faster if walking diagonal
            self.dx = self.dx / math.sqrt(2)
            self.dy = self.dy / math.sqrt(2)
        end
        if new_direction ~= self.direction then
            -- set a new direction + Animation
            self.direction = new_direction
            if animation_base_name then
                self:changeAnimation(animation_base_name .. '-' .. self.direction)
            end
        end
    end

    self:updatePosition(dt)

    return is_movement
end
