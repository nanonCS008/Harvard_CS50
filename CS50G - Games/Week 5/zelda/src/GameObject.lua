--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Game objects are all non living things including tiles.
    Tiles are very simple objects that have only 1 hitbox (floor, walls)
    Base Class for all objects.
]]

GameObject = Class{}

function GameObject:init(def)
    -- pixel position
    self.x = def.x
    self.y = def.y
    -- dimensions
    self.width = def.width or TILE_SIZE
    self.height = def.height or TILE_SIZE

    -- velocity
    self.dx = 0
    self.dy = 0

    -- proj_z is the height above the ground (e.g. if an object was lifted/ thrown).
    -- this is an offset on the y-axis, between where the sprite is drawn and the actual object/ hitbox coordinates.
    -- positive values move the sprite towards negative y direction
    self.proj_z = 0
    -- velocity for proj_z
    self.dz = 0

    -- ID to differentiate between objects
    self.id = def.id

    -- key string of the gFrames table. Specifies the Spritesheet
    self.texture = def.texture
    -- index in the gFrames table to pick a quad/ texture from the spritesheet
    self.frame_id = def.frame_id or 1

    -- used for floor tiles when generating objects and entities in the room
    -- gets set to true if an object is placed on top of the tile,
    -- so other objects or entities don't get spawned at the same location
    self.is_occupied = false

    -- if this object is being carried by an entity, store a reference to the entity here.
    -- The object will move along with the entity.
    self.mount = nil
    -- the mount point offset defines where the object is mounted relative to the entity coordinates
    self.mount_point_offset_x = 0
    self.mount_point_offset_y = 0
    -- if the object is thrown by an entity, store that entity here to not hurt it in the collision detection function
    self.thrown_by = nil

    -- specify this for objects that need a dungeon reference
    self.dungeon = def.dungeon

    -- if true, the object will get removed from the table in the Room Class
    self.is_remove = false

    -- if false, no collisions will be calculated with that object (hitboxes have no effect)
    self.is_collidable = def.is_collidable or false

    -- if set to true, the objects gets destroyed (removed) when collided with another object/ entity.
    -- only relevant for the pot object when its thrown
    self.is_fragile = def.is_fragile or false

    -- see entity class for hitbox description
    self.hitboxes = def.hitboxes or {Rect(self.x, self.y, self.width, self.height)}
    for _, hitbox in pairs(self.hitboxes) do
        if hitbox.x_offset and hitbox.y_offset then
            -- calculate x and y from x_offset and y_offset
            hitbox.x, hitbox.y = self.x + hitbox.x_offset, self.y + hitbox.y_offset
        else
            -- calculate x_offset and y_offset from x and y
            hitbox.x_offset, hitbox.y_offset = hitbox.x - self.x, hitbox.y - self.y
        end
        if hitbox.is_solid == nil then
            hitbox.is_solid = self.is_collidable
        end
    end

    -- name of the sound that should play when the object gets hit/ destroyed
    self.hit_sound = def.hit_sound

    -- Explanation see Entity Class
    self.render_prio = def.render_prio or RENDER_PRIO_1

    -- simple state machine (optional)
    -- table of all possible state names
    self.states = def.states
    -- current state
    self.state = def.state

    -- function that will get executed inside love.graphics.stencil() when rendering (see Room Class)
    -- specify the geometry that shall get stenciled inside this function
    self.stencilFunction = def.stencilFunction

    -- default function to change the state of the object
    self.doStateChange = def.doStateChange or function(self, new_state, params)
        self.state = new_state
    end

    -- collision callback function prototypes
    -- function that gets called when an object collided with an entity.
    self.doCollideWithEntity = def.doCollideWithEntity or function(self, entity_collision_data, self_collision_data) end
    -- function that gets called when an object collided with another object.
    self.doCollideWithObject = def.doCollideWithObject or function(self, self_collision_data, object_collision_data) end

    -- set initial state. Necessary for Objects that override doStateChange()
    self:doStateChange(self.state)
end

-- set Object Position to x, y
function GameObject:setPosition(x, y)
    self.x = x
    self.y = y
    -- update also hitbox position
    for _, hitbox in pairs(self.hitboxes) do
        hitbox.x, hitbox.y = self.x + hitbox.x_offset, self.y + hitbox.y_offset
    end
end

-- check collisions with (collidable) Game objects.
-- Objects do not get rebounded on other objects
-- for every collision, the collision callback function of the object is triggered.
-- simplified collision check compared to the the one in the Entity Class
function GameObject:checkObjectCollisions()
    if not self.is_collidable then
        return
    end

    for _, hitbox in pairs(self.hitboxes) do
        local objects_collided = {}

        -- get all tiles and objects that this object collides with
        local check_x_start = math.floor((hitbox.x - ROOM_OFFSET_X) / TILE_SIZE)
        local check_x_end = math.floor((hitbox.x + hitbox.width - ROOM_OFFSET_X) / TILE_SIZE) + 1
        local check_y_start = math.floor((hitbox.y - ROOM_OFFSET_Y) / TILE_SIZE)
        local check_y_end = math.floor((hitbox.y + hitbox.height - ROOM_OFFSET_Y) / TILE_SIZE) + 1
        for x = check_x_start, check_x_end do
            for y = check_y_start, check_y_end do
                if
                    self.dungeon.current_room.tiles[y] and self.dungeon.current_room.tiles[y][x] and
                    self.dungeon.current_room.tiles[y][x].is_collidable and
                    self.dungeon.current_room.tiles[y][x] ~= self and
                    hitbox:intersects(self.dungeon.current_room.tiles[y][x].hitboxes[1])
                then
                    table.insert(objects_collided, self.dungeon.current_room.tiles[y][x])
                end
            end
        end

        for _, object in pairs(self.dungeon.current_room.objects) do
            if object and object.is_collidable and object ~= self then
                for _, object_hitbox in pairs(object.hitboxes) do
                    if hitbox:intersects(object_hitbox) then
                        table.insert(objects_collided, object)
                    end
                end
            end
        end

        -- trigger collision callback function
        local self_collision_data = {object = self,
            hitbox = deepcopy(hitbox),
            dx = self.dx, dy = self.dy
        }
        for _, object in pairs(objects_collided) do
            for _, object_hitbox in pairs(object.hitboxes) do
                if hitbox:intersects(object_hitbox) then
                    local object_collision_data = {object = object,
                        hitbox = deepcopy(object_hitbox),
                        dx = object.dx, dy = object.dy
                    }
                    if IS_DEBUG then
                        object_hitbox.highlight_is_col = true
                    end
                    self:doCollideWithObject(self_collision_data, object_collision_data)
                end
            end
        end
    end
end

function GameObject:update(dt)
    -- this is only relevant for the pot object
    if self.mount then
        self:setPosition(self.mount.x + self.mount_point_offset_x, self.mount.y + self.mount_point_offset_y)
    elseif self.dx ~= 0 or self.dy ~= 0 then
        self:setPosition(self.x + self.dx * dt, self.y + self.dy * dt)
    end
    -- if the object is in falling state and is above the ground
    if self.state == 'thrown' and self.proj_z > 0 then
        -- apply gravity to proj_z for a physically correct falling animation.
        -- update proj_z with Semi-implicit Euler Integration.
        self.dz = self.dz + GRAVITY * dt
        self.proj_z = math.max(0, self.proj_z - self.dz * dt)
        -- if hit the ground
        if self.proj_z <= 0 then
            self.dx, self.dy, self.dz = 0, 0, 0
            if self.is_fragile then
                -- this removes the object, if not already removed from another collision
                self:doStateChange('broken')
            else
                self:doStateChange('on-ground')
            end
        end
    end
    -- save some processing and execute collisions only when the object is fragile
    if self.is_fragile then
        self:checkObjectCollisions()
    end
end

-- shift_screen_offset: only non-zero for the next room during room shifting (see Dungeon and Room Class)
function GameObject:render(shift_screen_offset_x, shift_screen_offset_y)
    -- if texture is distributed across multiple quads (see Doorway)
    -- every subtable in this table represents one row of quads.
    if type(self.frame_id) == "table" and type(self.frame_id[1]) == "table" then
        for y_grid = 0, #self.frame_id - 1 do
            for x_grid = 0, #self.frame_id[1] - 1 do
                love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.frame_id[y_grid + 1][x_grid + 1]],
                    self.x + shift_screen_offset_x + x_grid * TILE_SIZE,
                    self.y + shift_screen_offset_y  - self.proj_z + y_grid * TILE_SIZE)
            end
        end
    else
        love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.frame_id],
            self.x + shift_screen_offset_x, self.y + shift_screen_offset_y - self.proj_z)
    end

    if IS_DEBUG then
        for _, hitbox in pairs(self.hitboxes) do
            if hitbox.highlight_is_col then
                love.graphics.setColor(255/255, 0/255, 0/255, 120/255)
                love.graphics.rectangle("fill", hitbox.x, hitbox.y, hitbox.width, hitbox.height)
                love.graphics.setColor(255/255, 255/255, 255/255, 255/255)
            elseif hitbox.highlight_check_col then
                love.graphics.setColor(255/255, 255/255, 255/255, 120/255)
                love.graphics.rectangle("fill", hitbox.x, hitbox.y, hitbox.width, hitbox.height)
                love.graphics.setColor(255/255, 255/255, 255/255, 255/255)
            end
            hitbox.highlight_check_col = false
            hitbox.highlight_is_col = false

            -- constantly highlight the pot hitbox to see how the projection height variable (proj_z) is working
            if self.id == OBJECT_ID_POT then
                love.graphics.setBlendMode('add')
                love.graphics.setColor(255/255, 255/255, 255/255, 90/255)
                love.graphics.rectangle("fill", hitbox.x, hitbox.y, hitbox.width, hitbox.height)
                love.graphics.setColor(255/255, 255/255, 255/255, 255/255)
                love.graphics.setBlendMode('alpha')
            end
        end
        love.graphics.setColor(255/255, 255/255, 255/255, 96/255)
        if self.stencilFunction then
            self:stencilFunction(shift_screen_offset_x, shift_screen_offset_y)
        end
        love.graphics.setColor(255/255, 255/255, 255/255, 255/255)
    end
end
