--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The Doorway connects the Rooms in the dungeon.
]]

Doorway = Class{__includes = GameObject}

local DOORWAY_SIZE = TILE_SIZE * 2

function Doorway:init(direction, room)
    -- valid directions: 'top', 'bottom', 'left', 'right'
    -- the position, texture and hitbox position of the door depend on the direction.
    -- A door with the same direction will always be at the same place in the room.
    self.direction = direction

    -- create hitboxes
    -- At the sides of the door there are hitboxes to represent the doorframe as depicted in the spritesheet.
    -- pillar_thickness is the width in pixels of the doorframe.
    -- There is a hitbox to trigger a Room transition (hitbox_transition_trigger).
    -- It has the is_transition_trigger flag to identify this hitbox in the collision callback function.
    -- A hitbox in the back of the door is needed so entities (that do not trigger a transition) cannot walk outside when the door is opened.
    local pillar_thickness = 5
    local hitbox_left_pillar
    local hitbox_right_pillar
    local hitbox_back

    -- math.floor() to only allow the door placement with tile grid alignment
    local x, y
    if self.direction == 'left' then
        x = ROOM_OFFSET_X - TILE_SIZE
        y = ROOM_OFFSET_Y + math.floor(ROOM_GRID_HEIGHT / 2) * TILE_SIZE - TILE_SIZE

        hitbox_left_pillar = Rect(x, y, DOORWAY_SIZE, pillar_thickness)
        hitbox_right_pillar = Rect(x, y + DOORWAY_SIZE - pillar_thickness, DOORWAY_SIZE, pillar_thickness)
        hitbox_back = Rect(x, y, DOORWAY_SIZE / 2, DOORWAY_SIZE)
    elseif self.direction == 'right' then
        x = ROOM_OFFSET_X + ROOM_GRID_WIDTH * TILE_SIZE - TILE_SIZE
        y = ROOM_OFFSET_Y + math.floor(ROOM_GRID_HEIGHT / 2) * TILE_SIZE - TILE_SIZE

        hitbox_left_pillar = Rect(x, y, DOORWAY_SIZE, pillar_thickness)
        hitbox_right_pillar = Rect(x, y + DOORWAY_SIZE - pillar_thickness, DOORWAY_SIZE, pillar_thickness)
        hitbox_back = Rect(x + DOORWAY_SIZE / 2, y, DOORWAY_SIZE / 2, DOORWAY_SIZE)
    elseif self.direction == 'top' then
        x = ROOM_OFFSET_X + math.floor(ROOM_GRID_WIDTH / 2) * TILE_SIZE - TILE_SIZE
        y = ROOM_OFFSET_Y - TILE_SIZE

        hitbox_left_pillar = Rect(x, y, pillar_thickness, DOORWAY_SIZE)
        hitbox_right_pillar = Rect(x + DOORWAY_SIZE - pillar_thickness, y, pillar_thickness, DOORWAY_SIZE)
        hitbox_back = Rect(x, y, DOORWAY_SIZE, DOORWAY_SIZE / 2)
    else
        x = ROOM_OFFSET_X + math.floor(ROOM_GRID_WIDTH / 2) * TILE_SIZE - TILE_SIZE
        y = ROOM_OFFSET_Y + ROOM_GRID_HEIGHT * TILE_SIZE - TILE_SIZE

        hitbox_left_pillar = Rect(x, y, pillar_thickness, DOORWAY_SIZE)
        hitbox_right_pillar = Rect(x + DOORWAY_SIZE - pillar_thickness, y, pillar_thickness, DOORWAY_SIZE)
        hitbox_back = Rect(x, y + DOORWAY_SIZE / 2, DOORWAY_SIZE, DOORWAY_SIZE / 2)
    end

    -- hitbox_door is present when the door is closed and prevents entities from entering
    self.hitbox_door = Rect(x, y, DOORWAY_SIZE, DOORWAY_SIZE)

    -- place the transition trigger hitbox in the center of the door with a margin to the edges
    local trigger_margin = 10
    local hitbox_transition_trigger = Rect(x + trigger_margin, y + trigger_margin, DOORWAY_SIZE - 2 * trigger_margin, DOORWAY_SIZE - 2 * trigger_margin)
    hitbox_transition_trigger.is_solid = false
    -- Note: The hitbox can't be referenced directly, because its deepcopied inside the collision detection function. So it needs this flag.
    hitbox_transition_trigger.is_transition_trigger = true

    -- flag to deactivate the transition trigger hitbox
    self.is_transition_trigger_active = true
    -- flag to indicate if the player is currently standing on the transition trigger hitbox
    -- if true, is_transition_trigger_active gets set to false and if its released, it gets set to true again.
    -- This is to avoid executing the trigger collision callback multiple times
    -- technically the trigger deactivation is not needed, because the room does not get updated any more after the trigger was hit, but it is safer like this.
    self.is_transition_trigger_pressed = false

    -- stencil the doorway arch and the black space behind it
    -- The stencil is bigger than the actual doorway sprite, to ensure that the player is not visible when walking to the next room
    -- The neighboring wall should not get stenciled
    local stencilFunction = function(self, shift_screen_offset_x, shift_screen_offset_y)
        local _x, _y = self.x + shift_screen_offset_x, self.y + shift_screen_offset_y
        if self.direction == 'left' then
            love.graphics.rectangle('fill', _x, _y, 19, DOORWAY_SIZE)
            love.graphics.rectangle('fill', _x - TILE_SIZE, _y - TILE_SIZE, 2 * TILE_SIZE, DOORWAY_SIZE + 2 * TILE_SIZE)
        elseif self.direction == 'right' then
            love.graphics.rectangle('fill', _x + 13, _y, 19, DOORWAY_SIZE)
            love.graphics.rectangle('fill', _x + TILE_SIZE, _y - TILE_SIZE, 2 * TILE_SIZE, DOORWAY_SIZE + 2 * TILE_SIZE)
        elseif self.direction == 'top' then
            love.graphics.rectangle('fill', _x, _y, DOORWAY_SIZE, 19)
            love.graphics.rectangle('fill', _x - TILE_SIZE, _y - TILE_SIZE, DOORWAY_SIZE + 2 * TILE_SIZE, 2 * TILE_SIZE)
        else
            love.graphics.rectangle('fill', _x, _y + 13, DOORWAY_SIZE, 19)
            love.graphics.rectangle('fill', _x - TILE_SIZE, _y + TILE_SIZE, DOORWAY_SIZE + 2 * TILE_SIZE, 2 * TILE_SIZE)
        end
    end

    local doStateChange = function(self, new_state)
        -- default state: 'closed'
        -- A change in state also changes the texture of the Door
        -- The doors are composite sprites. That means they consist of multiple quads in the tiles spritesheet.
        -- frame_id is represented as a table: every subtable in this table represents one row of quads.
        -- The rows are ordered from top to bottom.
        self.state = new_state
        if new_state == 'opened' then
            if self.direction == 'left' then
                self.frame_id = {{181, 182}, {200, 201}}
            elseif self.direction == 'right' then
                self.frame_id = {{172, 173}, {191, 192}}
            elseif self.direction == 'top' then
                self.frame_id = {{98, 99}, {117, 118}}
            else
                self.frame_id = {{141, 142}, {160, 161}}
            end
            -- remove door hitbox to allow entering the door
            local hitbox_k = table.findkey(self.hitboxes, self.hitbox_door)
            if hitbox_k then
                table.remove(self.hitboxes, hitbox_k)
            end
        elseif new_state == 'closed' then
            if self.direction == 'left' then
                self.frame_id = {{219, 220}, {238, 239}}
            elseif self.direction == 'right' then
                self.frame_id = {{174, 175}, {193, 194}}
            elseif self.direction == 'top' then
                self.frame_id = {{134, 135}, {153, 154}}
            else
                self.frame_id = {{216, 217}, {235, 236}}
            end
            -- prepend door hitbox to prevent from entering the door
            if not table.contains(self.hitboxes, self.hitbox_door) then
                table.insert(self.hitboxes, 1, self.hitbox_door)
            end
        end
    end

    local doCollideWithEntity = function(self, entity_collision_data, self_collision_data)
        -- Only the body hitbox of the player should be able to trigger a room transition.
        -- The player is not allowed to carry something
        if
            entity_collision_data.entity.id == ENTITY_ID_PLAYER and
            entity_collision_data.hitbox.is_solid and
            self_collision_data.hitbox.is_transition_trigger and
            not entity_collision_data.entity.carry
        then
            self.is_transition_trigger_pressed = true
            if self.is_transition_trigger_active then
                self.is_transition_trigger_active = false
                -- Event.on() is inside the Dungeon class and will execute shiftRooms()
                if self.direction == 'left' then
                    Event.dispatch('room-shift', 'left')
                elseif self.direction == 'right' then
                    Event.dispatch('room-shift', 'right')
                elseif self.direction == 'top' then
                    Event.dispatch('room-shift', 'up')
                else
                    Event.dispatch('room-shift', 'down')
                end
            end
        end
    end

    -- init parent
    GameObject.init(self, {
        id = OBJECT_ID_DOOR,
        x = x, y = y,
        width = DOORWAY_SIZE, height = DOORWAY_SIZE,
        texture = 'tiles',
        state = 'closed', states = {'closed', 'opened'},
        is_collidable = true,
        -- The order of the hitboxes in the hitboxes table is the priority.
        -- The priority determines the order in which the hitboxes are checked inside the collision detection functions.
        hitboxes = {self.hitbox_door, hitbox_back, hitbox_left_pillar, hitbox_right_pillar, hitbox_transition_trigger},
        doCollideWithEntity = doCollideWithEntity,
        doStateChange = doStateChange,
        stencilFunction = stencilFunction
    })

    -- remove the tiles where the door is placed
    local grid_y = math.floor((y - ROOM_OFFSET_Y) / TILE_SIZE) + 1
    local grid_x = math.floor((x - ROOM_OFFSET_X) / TILE_SIZE) + 1
    for rem_grid_y = grid_y, grid_y + 1 do
        for rem_grid_x = grid_x, grid_x + 1 do
            if room.tiles[rem_grid_y] and room.tiles[rem_grid_y][rem_grid_x] then
                room.tiles[rem_grid_y][rem_grid_x] = nil
            end
        end
    end
end

function Doorway:update(dt)
    -- Entities are updated after objects, so is_transition_trigger_active can get set to false after this update function.
    -- In the frame afterwards, the next room will get updated already (and not this one).
    -- only after the player comes back to this room, this update function will run and activate the trigger again.
    if not self.is_transition_trigger_pressed and not self.is_transition_trigger_active then
        self.is_transition_trigger_active = true
    end
    self.is_transition_trigger_pressed = false
end
