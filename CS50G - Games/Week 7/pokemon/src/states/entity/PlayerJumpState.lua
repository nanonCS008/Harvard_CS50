PlayerJumpState = Class{__includes = BaseState}

-- The jump contains of movement in the player direction and on the y (proj_z) axis.
-- The direction movement is done by tweening the entity 2 tiles in entity direction and
-- the y (proj_z) movement is calculated from jump velocity and gravity.
-- Both movements should finish at about the same time to create a proper jump parabola.
-- The direction movement tween time will be set to the time that it takes to finish proj_z movement
-- (entity landed on the ground with proj_z = 0). The time can be found by measuring and printing it or
-- by using the (quadratic) formula for the movement and finding the zero points.
-- Formula (see 6b_Angry_Birds): d(n) = a * t^2 * (n^2 + n) / 2 + v(0) * t * n + d(0)
-- n: frame number, d(n): position on the n-th frame, t: frame time, v(0): starting velocity, a: gravity
-- After solving for zero points (assume d(0) = 0): n = 2 * v(0) / (a * t) + 1
-- The resulting frame number can be multiplied by the frame time to get the jump duration.
function PlayerJumpState:init(entity)
    self.entity = entity
    self.name = 'jump'
    self.entity:changeAnimation('jump-' .. self.entity.direction)

    gSounds['jump']:play()

    local to_grid_x, to_grid_y = self.entity.grid_x, self.entity.grid_y
    if self.entity.direction == 'left' then
        to_grid_x = to_grid_x - 2
    elseif self.entity.direction == 'right' then
        to_grid_x = to_grid_x + 2
    elseif self.entity.direction == 'up' then
        to_grid_y = to_grid_y - 2
    else
        to_grid_y = to_grid_y + 2
    end

    self.entity.is_moving = true
    self.entity.grid_x, self.entity.grid_y = to_grid_x, to_grid_y
    local to_x, to_y = self.entity:getPositionFromGrid()

    -- jumping velocity (for entity.proj_z)
    self.dz = -100
    -- if entity.proj_z has reached 0 after the jump
    self.is_landed = false

    Timer.tween(0.53, {
        [self.entity] = {x = to_x, y = to_y}
    }):finish(function()
        self.entity.proj_z = 0
        self.entity.is_moving = false
        -- If there is an encounter, entity.new_state is set to 'idle'. Don't do movement in this case.
        if self.entity:checkEncounter() then return end
        -- The next state can be 'idle', 'walk' or 'jump' (set in collision callback function)
        if self.entity:doMovement() then
            self.entity.new_state = 'walk'
        elseif not self.entity.new_state then
            self.entity.new_state = 'idle'
        end
    end)
end

function PlayerJumpState:update(dt)
    -- do the proj_z movement
    if not self.is_landed then
        self.dz = self.dz + GRAVITY * dt
        self.entity.proj_z = math.max(0, self.entity.proj_z - self.dz * dt)
        -- if landed on the ground
        if self.entity.proj_z <= 0 then
            self.dz = 0
            self.is_landed = true
        end
    end
end
