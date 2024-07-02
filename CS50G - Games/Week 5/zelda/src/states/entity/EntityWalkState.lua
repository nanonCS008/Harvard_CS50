--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Walk state used for all Enemies
]]

EntityWalkState = Class{__includes = BaseState}

function EntityWalkState:init(owner)
    self.owner = owner

    -- set movement direction randomly
    local directions = {'left', 'right', 'up', 'down'}
    self.owner.direction = directions[math.random(#directions)]

    -- change to a new state somewhere in this time window
    self.moving_period_max = 5
    self.moving_period = math.random(self.moving_period_max)
    -- measure time in this state
    self.moving_timer = 0
    -- if the entity bumped into something it should change its direction
    -- if the entity is cornered, it should not change its direction every frame.
    -- self.dir_change_timer gets set to a value after a direction change. It then counts down to 0.
    -- The next direction change can only happen if the timer is at 0.
    self.dir_change_timer = 0

    self.owner:changeAnimation('walk-' .. tostring(self.owner.direction))
end

function EntityWalkState:updateStage1(dt)
    self.dir_change_timer = math.max(0, self.dir_change_timer - dt)

    self.moving_timer = self.moving_timer + dt
    if self.moving_timer >= self.moving_period then
        -- if the next state is 'walk', the entity can have a different direction
        self.owner.new_state = math.random() < 0.5 and 'idle' or 'walk'
    end

    -- set velocity according to walking direction
    -- velocity has to be updated every frame, because it could be lost through collisions
    if self.owner.direction == 'left' then
        self.owner.dx = -self.owner.move_speed
        self.owner.dy = 0
    elseif self.owner.direction == 'right' then
        self.owner.dx = self.owner.move_speed
        self.owner.dy = 0
    elseif self.owner.direction == 'up' then
        self.owner.dx = 0
        self.owner.dy = -self.owner.move_speed
    elseif self.owner.direction == 'down' then
        self.owner.dx = 0
        self.owner.dy = self.owner.move_speed
    end

    self.owner:updatePosition(dt)

    self.owner:checkObjectCollisions()
end

function EntityWalkState:updateStage2(dt)
    self.owner:checkEntityCollisions()
end

function EntityWalkState:updateStage3(dt)
    -- change direction if bumped into a wall
    if table.contains(self.owner.is_collision_obj_lrtb, true) and self.dir_change_timer == 0 then
        -- because there are no moving objects, assume that the obstacle is in front of the entity
        -- choose a different direction than the current one
        local directions = {'left', 'right', 'up', 'down'}
        table.remove(directions, table.findkey(directions, self.owner.direction))
        self.owner.direction = directions[math.random(#directions)]

        self.owner:changeAnimation('walk-' .. tostring(self.owner.direction))
    end
end
