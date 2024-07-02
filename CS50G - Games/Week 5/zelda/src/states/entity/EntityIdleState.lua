--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Idle state used for all Enemies
]]

EntityIdleState = Class{__includes = BaseState}

function EntityIdleState:init(owner)
    self.owner = owner

    -- set velocity to 0
    self.owner.dx = 0
    self.owner.dy = 0

    -- change to a new state somewhere in this time window
    self.wait_period_max = 5
    self.wait_period = math.random(self.wait_period_max)
    -- measure the time in this state
    self.wait_timer = 0

    self.owner:changeAnimation('idle-' .. self.owner.direction)
end

function EntityIdleState:updateStage1(dt)
    self.wait_timer = self.wait_timer + dt
    if self.wait_timer >= self.wait_period then
        self.owner.new_state = 'walk'
    end

    -- needed, if the entity experiences any external force that causes velocity (not in this game however)
    self.owner:updatePosition(dt)

    self.owner:checkObjectCollisions()
end

function EntityIdleState:updateStage2(dt)
    self.owner:checkEntityCollisions()
end

function EntityIdleState:updateStage3(dt) end
