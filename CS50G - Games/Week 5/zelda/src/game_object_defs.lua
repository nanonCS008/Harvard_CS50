--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Game Object definitions file. Data that defines the properties of the Game Objects in the game.
    The data is passed to the Game Object Base Class for object initialization.
]]

GAME_OBJECT_DEFS = {
    ['switch'] = {      -- opens doors when pressed
        id = OBJECT_ID_SWITCH,
        texture = 'switches',
        frame_id = 2,
        width = TILE_SIZE,
        height = TILE_SIZE,
        is_collidable = true,
        hitboxes = {
            {
                x_offset = 4,
                y_offset = 4,
                width = TILE_SIZE / 2,
                height = TILE_SIZE / 2,
                is_solid = false
            }
        },
        states = {
            'unpressed', 'pressed'
        },
        state = 'unpressed',    -- starting (default) state
        doStateChange = function(self, new_state)
            self.state = new_state
            if new_state == 'unpressed' then
                self.frame_id = 2
                self.is_collidable = true
            elseif new_state == 'pressed' then
                self.frame_id = 1
                self.is_collidable = false
            end
        end,
        doCollideWithEntity = function(self, entity_collision_data, self_collision_data)
            -- only the Player can activate the switch.
            -- The doors that are associated with the switch will get opened in the event handler function.
            if self.state == 'unpressed' and entity_collision_data.entity.id == ENTITY_ID_PLAYER and entity_collision_data.hitbox.is_solid then
                self:doStateChange('pressed')
                Event.dispatch('switch-pressed', self)
            end
        end
    },
    ['big_statue'] = {      -- for decoration
        id = OBJECT_ID_STATUE,
        texture = 'tiles',
        frame_id = {{131, 132}, {150, 151}, {169, 170}},
        width = TILE_SIZE * 2,
        height = TILE_SIZE * 3,
        is_collidable = true,
        render_prio = RENDER_PRIO_2,
        hitboxes = {
            {
                x_offset = 0,
                y_offset = TILE_SIZE,
                width = TILE_SIZE * 2,
                height = TILE_SIZE * 2,
            }
        }
    },
    ['heart'] = {       -- is dropped by enemies and heals the player when picked up
        id = OBJECT_ID_HEART,
        texture = 'hearts',
        frame_id = 6,
        width = TILE_SIZE / 2,
        height = TILE_SIZE / 2,
        hitboxes = {
            {
                x_offset = 0,
                y_offset = TILE_SIZE / 4,
                width = TILE_SIZE / 2,
                height = TILE_SIZE / 4,
                is_solid = false
            }
        },
        is_collidable = true,
        doCollideWithEntity = function(self, entity_collision_data, self_collision_data)
            -- 1 heart is 2 health
            -- can only be picked up by the player with the sword or body hitbox
            if entity_collision_data.entity.id == ENTITY_ID_PLAYER and not entity_collision_data.hitbox.is_grab then
                gSounds['heart-pickup']:play()
                entity_collision_data.entity.health =
                    math.min(entity_collision_data.entity.max_health, entity_collision_data.entity.health + 2)
                self.is_remove = true
            end
        end
    },
    ['pot'] = {     -- can be lifted and thrown by the player
        id = OBJECT_ID_POT,
        texture = 'tiles',
        frame_id = 14,
        width = TILE_SIZE,
        height = TILE_SIZE,
        hit_sound = 'pot-break',
        hitboxes = {
            {
                x_offset = 0,
                y_offset = 0,
                width = TILE_SIZE,
                height = TILE_SIZE,
            }
        },
        is_collidable = true,
        states = {
            'on-ground', 'mounted', 'thrown', 'broken'
        },
        state = 'on-ground',    -- starting (default) state
        doStateChange = function(self, new_state, params)
            self.state = new_state
            if new_state == 'on-ground' then
                -- reset properties to the default.
                -- If the pot would not have the is_fragile flag when thrown, it would go back to this state again after throwing.
                self.is_fragile = false
                self.is_collidable = true
                self.hitboxes[1].is_solid = true
                self.hitboxes[1].y_offset = 0
                self.hitboxes[1].height = self.height
                self.hitboxes[1].deals_damage = false
                self:setPosition(self.x, self.y)
                self.thrown_by = nil
                self.mount = nil
                self.proj_z = 0
                self.dx, self.dy = 0, 0
                self.render_prio = RENDER_PRIO_1
            elseif new_state == 'mounted' then
                -- if the Player lifts and carries the pot
                self.is_collidable = false
                -- shrink the hitbox to half of its height.
                -- This way it will not immediately hit something if the player stands directly below a wall and throws the pot.
                self.hitboxes[1].y_offset = self.height / 2
                self.hitboxes[1].height = self.height / 2
                self.mount = params.entity
                params.entity.carry = self
                self.thrown_by = nil
                self.dx, self.dy = 0, 0
                -- align at bottom of mount. This becomes the y projection of the pot to the ground.
                -- The actual sprite will be rendered at the top of the entity through proj_z.
                self.mount_point_offset_x = 0
                self.mount_point_offset_y = self.mount.height - self.height

                -- difference between y projection to the ground and the sprite
                self.proj_z = self.mount.height - 6

                -- set a render priority that is higher than the one of the player, to draw the pot over the player
                self.render_prio = RENDER_PRIO_3
            elseif new_state == 'thrown' then
                -- throw the pot in the direction in which the player was facing
                -- it will fly in this direction and to the ground (decrement proj_z)
                -- it can damage enemies. If hit something it will break (because is_fragile is set)
                if not self.mount or not params.direction then
                    return
                end

                self.thrown_by = self.mount
                self.mount = nil
                self.is_collidable = true
                self.is_fragile = true
                self.hitboxes[1].is_solid = false
                self.hitboxes[1].deals_damage = true
                self.hitboxes[1].damage = 1

                local throw_vel = 15 * TILE_SIZE
                self.dx, self.dy = 0, 0
                if params.direction == 'left' then
                    self.dx = -throw_vel
                elseif params.direction == 'right' then
                    self.dx = throw_vel
                elseif params.direction == 'up' then
                    self.dy = -throw_vel
                else
                    self.dy = throw_vel
                end
            elseif new_state == 'broken' then
                -- remove the pot (no animation)
                gSounds[self.hit_sound]:play()
                self.is_remove = true
            end
        end,
        doCollideWithEntity = function(self, entity_collision_data, self_collision_data)
            if entity_collision_data.hitbox.is_solid and self.is_fragile and self.thrown_by ~= entity_collision_data.entity then
                -- when its thrown, the pot sets is_fragile. It breaks (get removed) when hit something (except the entity that threw it)
                self:doStateChange('broken')
            elseif entity_collision_data.hitbox.is_grab and not entity_collision_data.entity.carry and self.state == 'on-ground' then
                -- can only be picked up by a hitbox with the flag is_grab and only when its on the ground
                -- if the entity is_grab hitbox touches 2 pots at the same time, only one must be picked up
                -- pot cannot be placed again after pick up
                self:doStateChange('mounted', {entity = entity_collision_data.entity})
            end
        end,
        doCollideWithObject = function(self, self_collision_data, object_collision_data)
            if object_collision_data.hitbox.is_solid and self.is_fragile then
                self:doStateChange('broken')
            end
        end
    }
}
