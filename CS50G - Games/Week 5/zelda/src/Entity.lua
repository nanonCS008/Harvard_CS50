--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Entities are all living things.
    Base Class for all entities.
]]

Entity = Class{}

function Entity:init(def)
    -- entity behavior and properties is modeled in terms of data instead of classes (see Entity definitions file).
    -- data is passed in the input parameter def. The data handling is up to this Base class.

    -- valid directions: 'left', 'right', 'up', 'down'
    -- affects things like: current Animation (active frames), direction of actions (e.g. sword slash), direction in which enemies move
    self.direction = 'down'

    -- pixel position
    self.x = def.x or 0
    self.y = def.y or 0
    -- dimensions
    self.width = def.width
    self.height = def.height

    -- velocity
    self.dx, self.dy = 0, 0
    -- max velocity when moving
    self.move_speed = def.move_speed or CREATURE_MOVE_SPEED

    -- state machine to switch between entity states. entity states are Classes with their own update functions
    self.state_machine = def.state_machine
    -- store the state if a State change occurs.
    -- switch to the new state at the end of the update function, to not accidentally instantiate multiple State classes in one frame.
    -- A change to the same state is possible. In this case a new object from the same State Class gets instantiated.
    self.new_state, self.new_state_params = nil, nil

    -- The Animation Class switches between the textures (frames) of the Entity to create the animation.
    -- Instantiate all possible animations. Animations are changed in the State machine Classes
    self.animations = {}
    self.current_animation = nil
    for k, animation_def in pairs(def.animations) do
        self.animations[k] = Animation({
            texture = animation_def.texture or def.texture,
            frames = animation_def.frame_ids,
            interval = animation_def.interval
        })
    end

    -- Render offsets for padded sprites.
    -- It moves the quad to the top left position in the render function to compensate the spacing in the Sprite Sheet.
    -- The entity dimensions may differ from the width and height used in the GenerateQuads() function if the sprite is padded.
    self.render_offset_x = def.render_offset_x or 0
    self.render_offset_y = def.render_offset_y or 0

    -- 1 heart = 2 health
    self.max_health = def.max_health or 0
    self.health = def.max_health

    -- reference to the dungeon (e.g. to be able to check collisions against other entities and objects)
    self.dungeon = def.dungeon

    -- name of the sound that should play if the entity gets hit and takes damage
    self.hit_sound = def.hit_sound or 'enemy-hit'

    -- set after the entity takes damage. This flag prevents the entity from getting hit every frame
    self.is_invulnerable = false
    -- gets set to INVULNERABILITY_DURATION when hit. The entity will render as flashing while the timer is counting down.
    self.invulnerable_timer = 0
    -- timer that counts up for turning transparency on and off to create a flashing effect while invulnerable
    self.flash_timer = 0

    -- is_alive = false when entity dies. A death animation may play.
    -- is_remove = true after optional death animation. It then gets removed from the entity table
    self.is_alive = true
    self.is_remove = false

    -- reference to an object that is being carried
    self.carry = nil

    -- render order:
    -- Primarily defined by render_prio. Lower numbers mean a lower priority.
    -- The entity with the highest priority will be drawn last (over the others).
    -- Secondarily defined by y coordinate (entities/ objects with lower y get rendered first).
    self.render_prio = def.render_prio or RENDER_PRIO_2

    -- ID to differentiate between entities
    self.id = def.id

    -- Due to the top-down perspective of the game, the part of objects or entities that touches the ground is at the bottom.
    -- The body hitbox of every entity represents that and is (about) at the bottom half of the sprite.
    -- available hitbox properties:
    --  x, y, width, height
    --  x_offset, y_offset: needed to realign the entity to the hitbox coordinates or the hitbox to the entity coordinates (after rebound or after set position)
    --  is_solid (default true): solid entity hitboxes get rebounded on solid object hitboxes
    --  is_grab (default nil): objects that can be picked up (e.g. pots), react on this flag
    --  takes_damage (default nil)
    --  deals_damage (default nil)
    --  damage (default nil)
    --  -> If a Hitbox that 'takes_damage' collides with a hitbox that 'deals_damage', the entity will take 'damage' amount of damage
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
            hitbox.is_solid = true
        end
    end

    -- store the side with which the entity collided with an object for every frame
    self.is_collision_obj_lrtb = {false, false, false, false}
    -- store references to objects and entities that collided with the entity in the current frame
    self.collided_objects = {}
    self.collided_entities = {}

    -- function that gets called when an entity collided with another entity.
    -- self_collision_data, opponent_collision_data: input. Entity data before the collision.
    -- contains members: entity: reference to the colliding Entity; hitbox: entity hitbox that collided; dx, dy: entity velocity
    self.doCollideWithEntity = def.doCollideWithEntity or function(self, self_collision_data, opponent_collision_data)
        -- enemies can get damaged by the players sword hitbox and the player can get damaged by enemies
        if
            self_collision_data.hitbox.takes_damage and opponent_collision_data.hitbox.deals_damage and not self.is_invulnerable and
            not (self.id ~= ENTITY_ID_PLAYER and opponent_collision_data.entity.id ~= ENTITY_ID_PLAYER)
        then
            gSounds[self.hit_sound]:play()

            self.health = math.max(0, self.health - opponent_collision_data.hitbox.damage)
            self:goInvulnerable(INVULNERABILITY_DURATION)

            if self.health <= 0 then
                self:onDeath()
            end
        end
    end

    -- function that gets called when an entity collided with an object.
    -- collision_data has the same content as in doCollideWithEntity()
    self.doCollideWithObject = def.doCollideWithObject or function(self, self_collision_data, object_collision_data)
        -- get damage from an object that can deal damage, but only if its not thrown by self
        if
            self_collision_data.hitbox.takes_damage and object_collision_data.hitbox.deals_damage and
            not self.is_invulnerable and object_collision_data.object.thrown_by ~= self
        then
            gSounds[self.hit_sound]:play()

            self.health = math.max(0, self.health - object_collision_data.hitbox.damage)
            self:goInvulnerable(INVULNERABILITY_DURATION)

            if self.health <= 0 then
                self:onDeath()
            end
        end
    end
end

-- change and/ or restart the current Animation
-- name: input. name of the new animation
function Entity:changeAnimation(name)
    self.current_animation = self.animations[name]
    self.current_animation:restart()
end

-- set Entity Position to x, y and align hitbox coordinates
function Entity:setPosition(x, y)
    self.x = x
    self.y = y
    -- update also hitbox position
    for _, hitbox in pairs(self.hitboxes) do
        hitbox.x, hitbox.y = self.x + hitbox.x_offset, self.y + hitbox.y_offset
    end
end

-- update entity position according to its velocity
function Entity:updatePosition(dt)
    self:setPosition(self.x + self.dx * dt, self.y + self.dy * dt)
end

-- make the entity invulnerable for duration seconds
function Entity:goInvulnerable(duration)
    self.is_invulnerable = true
    self.invulnerable_timer = duration
end

-- default function called when entity health reaches 0
function Entity:onDeath()
    -- remove the entity without a death Animation
    self.is_alive = false
    self.is_remove = true

    -- spawn a heart with a certain probability and with some delay,
    -- so the heart is not picked up immediately with the same sword slash that killed the enemy.
    if math.random() < CREATURE_HEART_DROP_P then
        Timer.after(0.21, function()
            local heart_def = deepcopy(GAME_OBJECT_DEFS['heart'])
            table.extend(heart_def, {
                x = math.floor(self.x),
                y = math.floor(self.y + self.height - heart_def.height),
                hitboxes = getHitboxesFromDefinition(heart_def.hitboxes)
            })
            table.insert(self.dungeon.current_room.objects, GameObject(heart_def))
        end)
    end
end

-- check collisions with (collidable) Game objects.
-- entities get rebounded on solid objects and the velocity component pointing to the collision surface gets set to 0.
-- for every collision, collision callback functions for the entity and the object get triggered.
-- only entities check collisions against objects. objects do not check collisions against entities.
function Entity:checkObjectCollisions()
    -- loop through all entity hitboxes in order of priority
    for _, hitbox in pairs(self.hitboxes) do
        -- objects/ tiles that the entity collides/ intersects with
        local objects_collided = {}
        -- list of absolute rebound shift values. contains either the entity shift_x or shift_y value, depending on whats bigger
        -- used to sort the objects later after the collision sizes
        local shift_abs_list = {}

        -- convert coordinates of all 4 entity hitbox corners to tile grid coordinates to select a subset of all tiles to use for collision checks.
        -- in a non-tile based platformer all objects would need to be organized in a quad tree data structure
        -- that spatially partitions the game world in order to do efficient collision detection.
        local check_x_start = math.floor((hitbox.x - ROOM_OFFSET_X) / TILE_SIZE)
        local check_x_end = math.floor((hitbox.x + hitbox.width - ROOM_OFFSET_X) / TILE_SIZE) + 1
        local check_y_start = math.floor((hitbox.y - ROOM_OFFSET_Y) / TILE_SIZE)
        local check_y_end = math.floor((hitbox.y + hitbox.height - ROOM_OFFSET_Y) / TILE_SIZE) + 1
        -- get colliding Tiles. Tiles have only 1 hitbox.
        for x = check_x_start, check_x_end do
            for y = check_y_start, check_y_end do
                if self.dungeon.current_room.tiles[y] and self.dungeon.current_room.tiles[y][x] and self.dungeon.current_room.tiles[y][x].is_collidable then
                    if IS_DEBUG then
                        self.dungeon.current_room.tiles[y][x].hitboxes[1].highlight_check_col = true
                    end
                    local is_intersect, shift_x, shift_y = hitbox:getDisplacement(self.dungeon.current_room.tiles[y][x].hitboxes[1])
                    if is_intersect then
                        table.insert(objects_collided, self.dungeon.current_room.tiles[y][x])
                        table.insert(shift_abs_list, math.max(math.abs(shift_x), math.abs(shift_y)))
                    end
                end
            end
        end
        -- get colliding game objects
        for _, object in pairs(self.dungeon.current_room.objects) do
            if object and object.is_collidable then
                -- get the biggest shift value out of all object hitboxes
                local shift_abs_max = 0
                for _, object_hitbox in pairs(object.hitboxes) do
                    local is_intersect, shift_x, shift_y = hitbox:getDisplacement(object_hitbox)
                    if is_intersect then
                        shift_abs_max = math.max(shift_abs_max, math.max(math.abs(shift_x), math.abs(shift_y)))
                    end
                end
                if shift_abs_max > 0 then
                    table.insert(objects_collided, object)
                    table.insert(shift_abs_list, shift_abs_max)
                end
            end
        end

        -- reverse sort the objects_collided array after the biggest shift_abs value.
        -- the highest shift_abs is obtained from a collision with an object whose center is the closest to the center of the entity (on each dimension).
        -- the collisions get resolved in this order. The advantage is, that if the entity collides with a corner of an object,
        -- but also with other objects (with a potentially bigger collision area), the major collisions get resolved first
        -- and the corner collision cannot push the entity in a potentially wrong direction.
        sortReverseUnstableWithHelperTbl(objects_collided, shift_abs_list)

        -- store entity collision data for the collision callback function
        -- in order to collide with every object in the same way as before the rebound (at least for the current hitbox)
        local self_collision_data = {entity = self,
            hitbox = deepcopy(hitbox),
            dx = self.dx, dy = self.dy
        }

        for _, object in pairs(objects_collided) do
            for _, object_hitbox in pairs(object.hitboxes) do
                -- get the side on which the hitbox is colliding with the object (if any) and rebound accordingly later.
                local intersects_lrtb = hitbox:getIntersectingEdge(object_hitbox)

                -- if do_collision = true, trigger the collision callback functions
                -- a collision with the same object can be triggered multiple times per frame with different entity and object hitboxes
                -- if the entity is too far away from an object after a rebound, don't trigger the collision logic
                -- if the entity intersects only slightly after the rebound, still trigger the collision logic (e.g. when collided with 2 objects simultaneously)
                -- first, a collision with the highest priority (first) entity hitbox is made with the object hitbox that this hitbox has the biggest collision size with.
                local do_collision = false
                if hitbox:intersectsSlightly(object_hitbox) then
                    do_collision = true
                end

                -- rebound, set flags and set the velocity component pointing to the collision surface to 0.
                if table.contains(intersects_lrtb, true) and object_hitbox.is_solid and hitbox.is_solid then
                    if intersects_lrtb[1] then  -- left collision
                        hitbox.x = object_hitbox.x + object_hitbox.width
                        self.is_collision_obj_lrtb[1] = true
                        self.dx = math.max(0, self.dx)
                    elseif intersects_lrtb[2] then  -- right collision
                        hitbox.x = object_hitbox.x - hitbox.width
                        self.is_collision_obj_lrtb[2] = true
                        self.dx = math.min(0, self.dx)
                    elseif intersects_lrtb[3] then  -- top collision
                        hitbox.y = object_hitbox.y + object_hitbox.height
                        self.is_collision_obj_lrtb[3] = true
                        self.dy = math.max(0, self.dy)
                    elseif intersects_lrtb[4] then  -- bottom collision
                        hitbox.y = object_hitbox.y - hitbox.height
                        self.is_collision_obj_lrtb[4] = true
                        self.dy = math.min(0, self.dy)
                    end
                    -- after the hitbox was shifted, align the entity coordinates and all other hitboxes using the hitbox x, y offset values
                    self:setPosition(hitbox.x - hitbox.x_offset, hitbox.y - hitbox.y_offset)
                end

                -- trigger collision callback functions
                if do_collision then
                    local object_collision_data = {object = object,
                        hitbox = deepcopy(object_hitbox),
                        dx = object.dx, dy = object.dy
                    }
                    table.insert(self.collided_objects, object)
                    if IS_DEBUG then
                        object_hitbox.highlight_is_col = true
                    end
                    object:doCollideWithEntity(self_collision_data, object_collision_data)
                    self:doCollideWithObject(self_collision_data, object_collision_data)
                end
            end
        end
    end
end

-- check collisions against all other entities.
-- Entities do not get rebounded on other entities (see 4_Super_Mario_Bros for entity - entity rebounds)
-- for every collision, collision callback functions for both entities get triggered.
function Entity:checkEntityCollisions()
    if not self.is_alive then
        return
    end

    -- entities that the entity collides/ intersects with
    local entities_collided_total = {}

    -- loop through all entity hitboxes in order of priority
    -- every hitbox of this entity checks collisions with all hitboxes of all other entities. And all other entities do the same in every frame.
    for _, hitbox in pairs(self.hitboxes) do
        -- entities that the current entity hitbox collides/ intersects with
        local entities_collided = {}
        -- list of absolute rebound shift values. contains max(shift_x, shift_y) from the opponent entity hitbox with the biggest collision size
        -- used to sort the entities later after the collision sizes
        local shift_abs_list = {}

        -- get the colliding entities
        for _, entity in pairs(self.dungeon.current_room.entities) do
            -- self is in the entity list too
            if self ~= entity and entity.is_alive then
                local shift_abs_max = 0
                -- use the biggest absolute shift value from the entity hitbox with the biggest collision shift value
                for _, entity_hitbox in pairs(entity.hitboxes) do
                    local is_intersect, shift_x, shift_y = hitbox:getDisplacement(entity_hitbox)
                    if is_intersect then
                        shift_abs_max = math.max(shift_abs_max, math.max(math.abs(shift_x), math.abs(shift_y)))
                    end
                end
                if shift_abs_max > 0 then
                    table.insert(entities_collided, entity)
                    table.insert(shift_abs_list, shift_abs_max)
                end
            end
        end

        -- reverse sort the entities_collided array after the biggest shift_abs value. (see also object collisions)
        sortReverseUnstableWithHelperTbl(entities_collided, shift_abs_list)
        -- store self collision data for the collision callback function
        local self_collision_data = {entity = self,
            hitbox = deepcopy(hitbox),
            dx = self.dx, dy = self.dy
        }

        for _, entity in pairs(entities_collided) do
            -- For every hitbox of self that collides with a hitbox of the opponent, the doCollide functions shall be called.
            -- At the end of this function, the opponent entity gets saved in self.collided_entities (and vice versa).
            -- When the opponent entity gets updated later, it will not reach this point of the code again for the same entity.
            -- Even if an entity gets hit by 2 enemies at the same time, it will go invulnerable after processing the callback function for the first collision.
            -- Also if an entity hits an enemy, the enemy will go invulnerable, so a hitbox cannot deal damage every frame.
            if not table.contains(self.collided_entities, entity) then
                for _, entity_hitbox in pairs(entity.hitboxes) do
                    if not table.contains(entities_collided_total, entity) then
                        table.insert(entities_collided_total, entity)
                    end

                    -- trigger collision callback functions (symmetrically for both entities)
                    if hitbox:intersectsSlightly(entity_hitbox) then
                        local opponent_collision_data = {entity = entity,
                            hitbox = deepcopy(entity_hitbox),
                            dx = entity.dx, dy = entity.dy
                        }
                        entity:doCollideWithEntity(opponent_collision_data, self_collision_data)
                        self:doCollideWithEntity(self_collision_data, opponent_collision_data)
                    end
                end
            end
        end
    end

    for _, entity in pairs(entities_collided_total) do
        table.insert(self.collided_entities, entity)
        table.insert(entity.collided_entities, self)
    end
end

-- Entities have 3 update stages. Only after all entities have executed a stage, the next update stage shall be executed for all entities.
-- This is needed for a more accurate calculation of the entity - entity collisions, which should be independent of the update order.
-- Entities get updated after all game objects got updated.
-- Most of the update logic is inside the Entity state classes.
-- update stage 1 should contain the movement of the entity followed by the entity - objects collision checks.
-- update stage 2 should contain the entity - entity collision checks.
-- This way it can be ensured that all entities are updated in the current frame and entities from the current frame don't get compared with entities from the last frame
-- update stage 3 may contain an entity state change check, based on the previous calculated collisions.

function Entity:updateStage1(dt)
    -- reset members that get calculated every frame.
    self.is_collision_obj_lrtb = {false, false, false, false}
    self.collided_objects = {}
    self.collided_entities = {}

    -- handle invulnerability. advance timers
    if self.is_invulnerable then
        self.flash_timer = self.flash_timer + dt
        self.invulnerable_timer = math.max(self.invulnerable_timer - dt, 0)

        if self.invulnerable_timer <= 0 then
            self.is_invulnerable = false
            self.flash_timer = 0
        end
    end
    self.current_animation:update(dt)
    self.state_machine.current:updateStage1(dt)
end

function Entity:updateStage2(dt)
    self.state_machine.current:updateStage2(dt)
end

function Entity:updateStage3(dt)
    self.state_machine.current:updateStage3(dt)
    -- change to a new entity state if necessary.
    if self.new_state then
        self.state_machine:change(self.new_state, self.new_state_params)
        self.new_state, self.new_state_params = nil, nil
    end
end

-- Unused. The update stages are executed separately.
function Entity:update(dt)
    self:updateStage1(dt)
    self:updateStage2(dt)
    self:updateStage3(dt)
end

-- shift_screen_offset: only non-zero for the next room during room shifting (see Dungeon and Room Class)
function Entity:render(shift_screen_offset_x, shift_screen_offset_y)
    -- periodically draw sprite slightly transparent if invulnerable
    if self.is_invulnerable and self.flash_timer > INVULNERABILITY_FLASH_PERIOD then
        self.flash_timer = self.flash_timer % INVULNERABILITY_FLASH_PERIOD
        love.graphics.setColor(255/255, 255/255, 255/255, 32/255)
    else
        love.graphics.setColor(255/255, 255/255, 255/255, 255/255)
    end

    local x, y = self.x + (shift_screen_offset_x or 0) - self.render_offset_x, self.y + (shift_screen_offset_y or 0) - self.render_offset_y

    -- get the current frame and texture from the Animation class
    love.graphics.draw(gTextures[self.current_animation.texture], gFrames[self.current_animation.texture][self.current_animation:getCurrentFrame()],
        math.floor(x), math.floor(y))

    love.graphics.setColor(255/255, 255/255, 255/255, 255/255)

    if IS_DEBUG then
        love.graphics.setColor(255/255, 0/255, 255/255, 255/255)
        for _, hitbox in pairs(self.hitboxes) do
            love.graphics.rectangle('line', math.floor(hitbox.x), math.floor(hitbox.y), hitbox.width, hitbox.height)
        end
        love.graphics.setColor(255/255, 255/255, 255/255, 255/255)
    end
end
