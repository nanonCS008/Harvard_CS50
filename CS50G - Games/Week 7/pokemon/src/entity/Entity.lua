--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Entity = Class{}

function Entity:init(def)
    -- valid directions: 'left', 'right', 'up', 'down'
    self.direction = def.direction or 'down'
    -- movement speed in tiles / s
    self.walking_speed = ENTITY_WALKING_SPEED
    self.running_speed = ENTITY_RUNNING_SPEED
    -- gets set to true of entity is in the process of getting tweened from one tile to another
    self.is_moving = false

    -- Instantiate all possible animations. Animations are changed in the entity state machine classes
    self.animations = {}
    self.current_animation = nil
    for k, animation_def in pairs(def.animations) do
        self.animations[k] = Animation({
            texture = animation_def.texture or def.texture,
            frames = animation_def.frame_ids,
            interval = animation_def.interval
        })
    end
    -- GameArea reference
    self.area = def.area
    -- state machine to switch between entity states
    self.state_machine = def.state_machine
    -- store the state if a state change occurs. switch to the new state at the end of the update function
    self.new_state, self.new_state_params = nil, nil

    self.width = def.width
    self.height = def.height
    -- proj_z is the height above the ground (e.g. if an entity is jumping).
    -- this is an offset on the y-axis, between where the sprite is drawn and the actual entity coordinates.
    -- positive values move the sprite towards negative y direction
    self.proj_z = 0

    self:setGridPosition(def.grid_x, def.grid_y)
end

-- get pixel coordinates from entity grid coordinates
function Entity:getPositionFromGrid()
    -- entity bottom is aligned to the lower part of the tile
    local x = (self.grid_x - 1) * TILE_SIZE
    local y = (self.grid_y - 1) * TILE_SIZE - self.height + TILE_SIZE * 0.75
    return x, y
end

-- set entity position according to the supplied grid position
function Entity:setGridPosition(grid_x, grid_y)
    self.grid_x, self.grid_y = grid_x, grid_y
    self.x, self.y = self:getPositionFromGrid()
end

function Entity:changeAnimation(name)
    self.current_animation = self.animations[name]
    self.current_animation:restart()
end

-- check if the entity is colliding with a tile in the collidable layer or with an entity.
-- invoke the collision callback function onCollide of the tile if collided
-- grid_x, grid_y: input. Grid coordinates to check. These are most likely the coordinates that the entity is supposed to move to
-- return the collided object/ entity if collided or nil otherwise
function Entity:checkCollision(grid_x, grid_y)
    local object_collide = self.area.collidable_layer[grid_y] and self.area.collidable_layer[grid_y][grid_x] or nil
    if object_collide then
        if object_collide.onCollide then object_collide:onCollide(self) end
        return object_collide
    end
    for _, entity in pairs(self.area.entities) do
        if entity.grid_x == grid_x and entity.grid_y == grid_y then
            object_collide = entity
            return object_collide
        end
    end
    return nil
end

function Entity:update(dt)
    self.current_animation:update(dt)
    self.state_machine:update(dt)
    -- change to a new entity state if necessary.
    if self.new_state then
        self.state_machine:change(self.new_state, self.new_state_params)
        self.new_state, self.new_state_params = nil, nil
    end
end

function Entity:render()
    love.graphics.draw(gTextures[self.current_animation.texture],
        gFrames[self.current_animation.texture][self.current_animation:getCurrentFrame()],
        math.floor(self.x), math.floor(self.y - self.proj_z))

    -- If the entity stands in the grass, render the bottom grass texture above the entity.
    -- The grid coordinates of the entity get set at the beginning of the coordinate tweening process.
    -- If the entity walks up, only render the bottom grass when the tweening is almost finished,
    -- otherwise the grass would render above the entity body while walking up.
    -- The grass should not render above other entities that are drawn after this entity, that's why its rendered here.
    local _, y_dest = self:getPositionFromGrid()
    if
        self.area.grass_layer[self.grid_y] and
        self.area.grass_layer[self.grid_y][self.grid_x] and
        self.area.grass_layer[self.grid_y][self.grid_x].id == TILE_ID_GRASS and
        self.y - y_dest < 2
    then
        love.graphics.draw(gTextures['tiles'], gFrames['tiles'][TILE_FRAME_ID_GRASS_BOTTOM],
            (self.grid_x - 1) * TILE_SIZE, (self.grid_y - 1) * TILE_SIZE)
    end
end
