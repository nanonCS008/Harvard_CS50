--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerSwingSwordState = Class{__includes = BaseState}

function PlayerSwingSwordState:init(owner)
    self.owner = owner

    self.owner.render_offset_y = 5
    self.owner.render_offset_x = 8

    -- create a separate hitbox for the sword according to the player's direction. It will only be active during this state
    -- create a hitbox with (a = sword_range, b = sword_range * 2) edge length
    local sword_range = 10

    -- aligned at middle of the player body hitbox (which is at the bottom half of the player sprite)
    if self.owner.direction == 'left' then
        self.hitbox_sword = Rect(self.owner.x - sword_range, self.owner.y + self.owner.height * 3 / 4 - sword_range, sword_range, sword_range * 2)
    elseif self.owner.direction == 'right' then
        self.hitbox_sword = Rect(self.owner.x + self.owner.width, self.owner.y + self.owner.height * 3 / 4 - sword_range, sword_range, sword_range * 2)
    elseif self.owner.direction == 'up' then
        self.hitbox_sword = Rect(self.owner.x + self.owner.width / 2 - sword_range, self.owner.y + self.owner.height / 2 - sword_range, sword_range * 2, sword_range)
    else
        self.hitbox_sword = Rect(self.owner.x + self.owner.width / 2 - sword_range, self.owner.y + self.owner.height, sword_range * 2, sword_range)
    end
    -- calculate x_offset and y_offset from x and y
    self.hitbox_sword.x_offset, self.hitbox_sword.y_offset = self.hitbox_sword.x - self.owner.x, self.hitbox_sword.y - self.owner.y

    -- sword hitbox does not trigger the door transition trigger + switch trigger, because is_solid = false
    self.hitbox_sword.is_solid = false
    self.hitbox_sword.takes_damage = false
    self.hitbox_sword.deals_damage = true
    self.hitbox_sword.damage = 1
    -- append hitbox to hitboxes table
    table.insert(self.owner.hitboxes, self.hitbox_sword)

    self.owner:changeAnimation('sword-' .. self.owner.direction)

    -- restart sword swing sound for rapid swinging
    gSounds['sword']:stop()
    gSounds['sword']:play()
end

function PlayerSwingSwordState:exit()
    -- remove sword hitbox when leaving/ re-entering this state
    local hitbox_k = table.findkey(self.owner.hitboxes, self.hitbox_sword)
    if hitbox_k then
        table.remove(self.owner.hitboxes, hitbox_k)
    end
end

function PlayerSwingSwordState:updateStage1(dt)
    -- set velocity to 0, as it is not set to 0 when coming directly from walk state
    -- this is not set in the init function to only modify velocity at a consistent point in the update function
    self.owner.dx, self.owner.dy = 0, 0

    -- re-enter this state if pressed the Attack key
    -- if one animation cycle of the sword animation was played, leave the state
    if keyboardWasPressed(KEYS_ATTACK) then
        self.owner.new_state = 'swing-sword'
    elseif self.owner.current_animation.loop_count > 0 then
        self.owner.new_state = 'idle'
    end

    self.owner:checkObjectCollisions()
end

function PlayerSwingSwordState:updateStage2(dt)
    self.owner:checkEntityCollisions()
end

function PlayerSwingSwordState:updateStage3(dt) end
