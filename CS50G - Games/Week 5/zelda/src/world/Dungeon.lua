--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The Dungeon consists of multiple Rooms
]]

Dungeon = Class{}

function Dungeon:init(player)
    self.player = player

    -- table with room objects arranged in matrix form.
    -- every subtable represents one row of rooms
    -- The table layout specifies the room positions in the game/ dungeon
    self.rooms = {}

    -- room that gets updated and where the player is
    self.current_room = nil

    -- gets set on a room transition. The camera is moved towards this room during a transition
    -- after the transition, this becomes current_room
    self.next_room = nil

    -- number of rooms that fit into the dungeon horizontally and vertically (max size of the dungeon)
    self.rooms_num_hor = 4
    self.rooms_num_vert = 4

    -- camera position used in love.graphics.translate(). Only used when shifting rooms
    self.cam_x = 0
    self.cam_y = 0
    self.is_shifting = false

    -- Event handler functions
    -- Event.on() will be called immediately after Event.dispatch()
    -- If multiple Events with the same event handler name are registered with Event.on(),
    -- they all get executed on the corresponding Event.dispatch().
    -- That means the previous Event Handlers must be removed before instantiating a new dungeon (see PlayState)

    -- initiate a room transition.
    -- Event.dispatch() in the collision callback function of Doorway
    Event.on('room-shift', function(shift_dir)
        self:shiftRooms(shift_dir)
    end)

    -- open all doors that are connected to a switch that was pressed
    -- Event.dispatch() in the collision callback function of the switch object
    Event.on('switch-pressed', function(switch)
        for _, doorway in pairs(switch.connected_doors) do
            doorway:doStateChange('opened')
        end
        gSounds['door']:play()
    end)

    -- when all enemies in the dungeon (in all rooms) were killed, the player has won.
    -- Event.dispatch() in the Room class after after all entity update functions and
    -- when all enemies in that room were killed
    Event.on('room-cleared', function()
        for room_y = 1, self.rooms_num_vert do
            for room_x = 1, self.rooms_num_hor do
                if self.rooms[room_y][room_x] and self.rooms[room_y][room_x].num_enemies > 0 then
                    return
                end
            end
        end

        -- if the player did not die in the same frame
        if self.player.is_alive then
            self.player.state_machine:change('game-over', 'victory')
            self.player.new_state, self.player.new_state_params = nil, nil
        end
    end)

    -- create the dungeon
    self:generate()
end

-- instantiate all rooms in the dungeon and fill the self.rooms table
function Dungeon:generate()
    -- create the dungeon map (arrangement of rooms), without instantiating room objects yet
    -- table with the same layout as self.rooms that contains metadata for each room position:
    -- connections_lrtb:
    --      boolean value for every side of the room that specifies if there is a connection to another room or not
    --      the values are set randomly, and are used as the base for the random dungeon generation
    -- is_initialized:
    --      set to true when the iteration reaches this room.
    --      When this is set to true, connections_lrtb will have its final content that does not get changed any more
    -- after populating room_layout, instantiate every room from the collected metadata and populate self.rooms.
    -- nil values in this table will result in nil values in self.rooms (no room generated at this position)
    local room_layout = {}
    for _ = 1, self.rooms_num_vert do
        table.insert(room_layout, {})
    end

    -- room coordinates where the dungeon generation starts. this is also the room where the player starts.
    local start_room_x, start_room_y = math.random(self.rooms_num_hor), math.random(self.rooms_num_vert)

    -- coordinates for the currently selected room to initialize
    local select_room_x, select_room_y = start_room_x, start_room_y
    room_layout[select_room_y][select_room_x] = {
        is_initialized = false,
        connections_lrtb = {false, false, false, false},
    }

    -- probability for each side of a room to create a connection to another room (generate doorways)
    local connection_p = 0.5

    -- stop the loop if every room got initialized (if no room with is_initialized = false could be found)
    while select_room_x > 0 and select_room_y > 0 do
        -- set room to initialize
        local room_selected = room_layout[select_room_y][select_room_x]
        room_selected.is_initialized = true
        -- reference to the room to the left, right, top and bottom of the selected room (if not nil value)
        local room_lrtb = {}
        -- for every room side determine if a connection is theoretically possible
        local connections_available_lrtb = {true, true, true, true}

        -- if the room is at the edge of the dungeon, connections that would face to the outside are not possible
        if select_room_x < 2 then
            connections_available_lrtb[1] = false
        end
        if select_room_x > self.rooms_num_hor - 1 then
            connections_available_lrtb[2] = false
        end
        if select_room_y < 2 then
            connections_available_lrtb[3] = false
        end
        if select_room_y > self.rooms_num_vert - 1 then
            connections_available_lrtb[4] = false
        end

        -- set references to adjacent rooms (could also be a nil value, if the metadata for that room is not set)
        if connections_available_lrtb[1] then
            room_lrtb[1] = room_layout[select_room_y][select_room_x - 1]
        end
        if connections_available_lrtb[2] then
            room_lrtb[2] = room_layout[select_room_y][select_room_x + 1]
        end
        if connections_available_lrtb[3] then
            room_lrtb[3] = room_layout[select_room_y - 1][select_room_x]
        end
        if connections_available_lrtb[4] then
            room_lrtb[4] = room_layout[select_room_y + 1][select_room_x]
        end

        -- If an adjacent room was already created and it has no connection that is facing the current room,
        -- respect that decision and don't insert a connection in that direction either.
        if room_lrtb[1] and room_lrtb[1].is_initialized and not room_lrtb[1].connections_lrtb[2] then
            connections_available_lrtb[1] = false
        end
        if room_lrtb[2] and room_lrtb[2].is_initialized and not room_lrtb[2].connections_lrtb[1] then
            connections_available_lrtb[2] = false
        end
        if room_lrtb[3] and room_lrtb[3].is_initialized and not room_lrtb[3].connections_lrtb[4] then
            connections_available_lrtb[3] = false
        end
        if room_lrtb[4] and room_lrtb[4].is_initialized and not room_lrtb[4].connections_lrtb[3] then
            connections_available_lrtb[4] = false
        end

        for i = 1, #connections_available_lrtb do
            -- for every side i, set connections_lrtb to true with probability connection_p if available connection and if not already true
            if connections_available_lrtb[i] and not room_selected.connections_lrtb[i] then
                room_selected.connections_lrtb[i] = math.random() < connection_p and true or false
            end
            -- when a connection to another room shall be made
            if room_selected.connections_lrtb[i] then
                -- helper variable to get the index of the opposite side of a room
                -- e.g. a connection to the right for the current room must be accompanied by a connection to the left for the room on the right
                local opposite_direction_index_offset = i % 2 == 1 and 1 or -1
                -- for an adjacent room with a desired connection to this room that is not initialized yet,
                -- set the according connections_lrtb for the other room to true
                if not room_lrtb[i] then
                    -- set metadata members. That room will get initialized later.
                    room_lrtb[i] = {
                        is_initialized = false,
                        connections_lrtb = {false, false, false, false}
                    }
                    -- make a preset for connections_lrtb that will be preserved for the initialization of that room
                    room_lrtb[i].connections_lrtb[i + opposite_direction_index_offset] = true
                    -- because room_lrtb[i] was a nil value before and not a reference to a table, assign back to room_layout
                    if i == 1 then
                        room_layout[select_room_y][select_room_x - 1] = room_lrtb[1]
                    elseif i == 2 then
                        room_layout[select_room_y][select_room_x + 1] = room_lrtb[2]
                    elseif i == 3 then
                        room_layout[select_room_y - 1][select_room_x] = room_lrtb[3]
                    else
                        room_layout[select_room_y + 1][select_room_x] = room_lrtb[4]
                    end
                elseif not room_lrtb[i].is_initialized then
                    -- make a preset for connections_lrtb that will be preserved for the initialization of that room
                    room_lrtb[i].connections_lrtb[i + opposite_direction_index_offset] = true
                end
                -- for an adjacent initialized room there is no need to make any action
            end
        end

        -- search for the next uninitialized room (that has is_initialized = false set)
        select_room_x, select_room_y = 0, 0
        for room_y = 1, self.rooms_num_vert do
            for room_x = 1, self.rooms_num_hor do
                if room_layout[room_y][room_x] and not room_layout[room_y][room_x].is_initialized then
                    select_room_x, select_room_y = room_x, room_y
                    break
                end
            end
            if select_room_x > 0 and select_room_y > 0 then break end
        end
    end

    -- instantiate room objects for self.rooms based on the metadata in room_layout
    for room_y = 1, self.rooms_num_vert do
        self.rooms[room_y] = {}
        for room_x = 1, self.rooms_num_hor do
            if room_layout[room_y][room_x] then
                self.rooms[room_y][room_x] = Room(room_x, room_y, self.player, self, room_layout[room_y][room_x].connections_lrtb)
            end
        end
    end

    -- set the current room and place the player inside
    self.current_room = self.rooms[start_room_y][start_room_x]
    self.current_room:placeEntity(self.player)
end

-- callback function that is triggered when the player enters a doorway to another room
-- The camera will get moved to the next room and the next room will be new current room.
-- shift_dir: shift direction string. 'left', 'right', 'up' or 'down'
function Dungeon:shiftRooms(shift_dir)
    -- when the room shifting is initiated, the current room will not get updated any more
    self.is_shifting = true

    -- pixel coordinates that the camera will move towards (current camera position is at 0, 0)
    local shift_x, shift_y = 0, 0

    -- tween the player position to a destination inside the next room to move through the doorway
    local player_dest_x, player_dest_y = self.player.x, self.player.y

    -- remove objects that are currently thrown (in the air).
    -- otherwise they will continue to render and fly through the air when returning to this room
    -- by setting the is_remove flag, the object will be removed at the end of the update function of the current frame
    for i = 1, #self.current_room.objects do
        if self.current_room.objects[i].state == 'thrown' then
            self.current_room.objects[i].is_remove = true
        end
    end

    -- set next_room, camera shift, player destination position, and player direction based on the shift direction
    -- distance from edge of the screen to inside the next room: ROOM_OFFSET + TILE_SIZE
    -- where TILE_SIZE is the size of the walls that surround the room
    if shift_dir == 'left' then
        shift_x = -VIRTUAL_WIDTH
        player_dest_x = -ROOM_OFFSET_X - TILE_SIZE - self.player.width
        self.next_room = self.rooms[self.current_room.room_y][self.current_room.room_x - 1]
        self.player.direction = 'left'
    elseif shift_dir == 'right' then
        shift_x = VIRTUAL_WIDTH
        player_dest_x = VIRTUAL_WIDTH + ROOM_OFFSET_X + TILE_SIZE
        self.next_room = self.rooms[self.current_room.room_y][self.current_room.room_x + 1]
        self.player.direction = 'right'
    elseif shift_dir == 'up' then
        shift_y = -VIRTUAL_HEIGHT
        player_dest_y = -ROOM_OFFSET_Y - TILE_SIZE - self.player.height
        self.next_room = self.rooms[self.current_room.room_y - 1][self.current_room.room_x]
        self.player.direction = 'up'
    else
        shift_y = VIRTUAL_HEIGHT
        -- self.player.height / 2 because the body hitbox of the player is at the bottom half of the player sprite
        player_dest_y = VIRTUAL_HEIGHT + ROOM_OFFSET_Y + self.player.height / 2
        self.next_room = self.rooms[self.current_room.room_y + 1][self.current_room.room_x]
        self.player.direction = 'down'
    end

    -- force walking state. this sets the walking animation in the corresponding direction.
    -- also unexpected states are overwritten
    -- (in case there is movement possible in another state which could lead to activating this transition)
    self.player.state_machine:change('walk')
    -- this function gets entered during the entity-object collision check phase.
    -- overwrite any state change requests that happened this frame,
    -- otherwise they would get applied at the end of the update function of the current frame
    -- however the death state can still happen afterwards in the entity-entity collision check phase and overwrite the walk state again.
    self.player.new_state, self.player.new_state_params = nil, nil

    -- backup the state of the doorways in the room.
    -- open all doors in the next room and revert to the backed-up state when the player entered the room
    local doorway_state_backup = {}
    for i = 1, #self.next_room.doorways do
        doorway_state_backup[i] = self.next_room.doorways[i].state
        self.next_room.doorways[i]:doStateChange('opened')
    end

    -- the next room gets rendered with this offset
    -- after moving the camera to this offset, the next room render offset and camera position gets set to 0 again
    self.next_room.shift_screen_offset_x = shift_x
    self.next_room.shift_screen_offset_y = shift_y

    -- tween player and camera coordinates to the next room. The player will walk through the stenciled black space between the rooms.
    -- because the room will not get updated, the player hitbox stays in place and the player can move through the door without collisions.
    Timer.tween(1, {
        [self] = {cam_x = shift_x, cam_y = shift_y},
        [self.player] = {x = player_dest_x, y = player_dest_y}
    }):finish(function()
        -- start updating again with the next room as the new current room
        self.is_shifting = false
        self.current_room = self.next_room
        self.next_room = nil

        -- reset camera position and room render offset
        self.cam_x, self.cam_y = 0, 0
        self.current_room.shift_screen_offset_x = 0
        self.current_room.shift_screen_offset_y = 0

        -- set player position to adjust to the resetted room offset
        self.player.x = self.player.x - shift_x
        self.player.y = self.player.y - shift_y

        -- close the doors again that were previously closed in the current room
        for i = 1, #self.current_room.doorways do
            self.current_room.doorways[i]:doStateChange(doorway_state_backup[i])
        end
        if table.contains(doorway_state_backup, 'closed') then
            gSounds['door']:play()
        end
    end)
end

function Dungeon:update(dt)
    -- pause updating when shifting rooms
    if not self.is_shifting then
        self.current_room:update(dt)
    else
        -- still update the player animation while shifting rooms
        -- the player itself must not be updated, to not screw up the animation or the tweening during the transition
        self.player.current_animation:update(dt)
    end
end

-- render a minimap of the dungeon in the top right of the screen
-- for every room in the dungeon, render a rectangle that represents the room position into the minimap
-- highlight the current room (room in which the player is)
function Dungeon:renderMinimap()
    -- set dimensions and position of the minimap
    local minimap_width = TILE_SIZE * 2
    local minimap_height = TILE_SIZE
    local minimap_x = VIRTUAL_WIDTH - minimap_width - 2
    local minimap_y = 2
    -- dimensions of the room rectangles inside the minimap
    local room_minimap_width = minimap_width / self.rooms_num_hor
    local room_minimap_height = minimap_height / self.rooms_num_vert

    for room_y = 1, self.rooms_num_vert do
        for room_x = 1, self.rooms_num_hor do
            if self.current_room == self.rooms[room_y][room_x] then
                love.graphics.setColor(255/255, 70/255, 70/255, 255/255)
            elseif self.rooms[room_y][room_x] then
                love.graphics.setColor(230/255, 230/255, 230/255, 255/255)
            else
                love.graphics.setColor(25/255, 25/255, 25/255, 255/255)
            end

            love.graphics.rectangle('fill',
                minimap_x + (room_x - 1) * room_minimap_width, minimap_y + (room_y - 1) * room_minimap_height,
                room_minimap_width, room_minimap_height
            )
        end
    end
    love.graphics.setColor(255/255, 255/255, 255/255, 255/255)
end

function Dungeon:render()
    -- store the current coordinate transformation state into the transformation stack.
    love.graphics.push()
    -- translation between world coordinates (the position where sprites or other elements are located in the game world) and
    -- screen coordinates (the actual position where those elements are rendered on the screen).
    -- Shifts the coordinate system by x, y for everything drawn after this call.
    -- All the following drawing operations take effect as if their x and y coordinates were x + translate_x and y + translate_y.
    -- Translate the entire scene by the camera scroll amount to emulate a camera.
    -- math.floor is used to prevent tearing/ blurring.
    love.graphics.translate(-math.floor(self.cam_x), -math.floor(self.cam_y))

    -- next_room must be rendered before current_room (see Room Class)
    if self.next_room then
        self.next_room:render()
    end
    self.current_room:render()

    -- revert the current coordinate transformation. Reverse the previous push operation.
    love.graphics.pop()

    self:renderMinimap()
end
