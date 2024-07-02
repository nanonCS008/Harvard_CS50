PlayerGrabState = Class{__includes = BaseState}

function PlayerGrabState:init(owner)
    self.owner = owner

    self.owner.render_offset_y = 5
    self.owner.render_offset_x = 0

    -- create a separate hitbox that is used to scan objects in front of the player that can be grabbed.
    -- It will only be active during this state
    -- edge length of the grab hitbox
    local grab_range = 3

    -- aligned at middle of the player body hitbox (which is at the bottom half of the player sprite)
    if self.owner.direction == 'left' then
        self.hitbox_grab = Rect(self.owner.x - grab_range, self.owner.y + self.owner.height * 3 / 4 - grab_range / 2, grab_range, grab_range)
    elseif self.owner.direction == 'right' then
        self.hitbox_grab = Rect(self.owner.x + self.owner.width, self.owner.y + self.owner.height * 3 / 4 - grab_range / 2, grab_range, grab_range)
    elseif self.owner.direction == 'up' then
        self.hitbox_grab = Rect(self.owner.x + self.owner.width / 2 - grab_range / 2, self.owner.y + self.owner.height / 2 - grab_range, grab_range, grab_range)
    else
        self.hitbox_grab = Rect(self.owner.x + self.owner.width / 2 - grab_range / 2, self.owner.y + self.owner.height, grab_range, grab_range)
    end
    -- calculate x_offset and y_offset from x and y
    self.hitbox_grab.x_offset, self.hitbox_grab.y_offset = self.hitbox_grab.x - self.owner.x, self.hitbox_grab.y - self.owner.y

    -- grab hitbox does not trigger the door transition trigger + switch trigger, because is_solid = false
    -- the is_grab flag will trigger an action from grabbable objects in the collision detection function.
    -- if grabbed something, the carry member of the player will be set to the object that was grabbed
    self.hitbox_grab.is_solid = false
    self.hitbox_grab.is_grab = true
    -- append hitbox to hitboxes table
    table.insert(self.owner.hitboxes, self.hitbox_grab)

    -- check if something was grabbed in the first frame of this state.
    -- only play the grab animation if something was grabbed.
    -- set to false after the first frame is over.
    self.first_frame = true
end

function PlayerGrabState:exit()
    -- remove grab hitbox when leaving this state
    local hitbox_k = table.findkey(self.owner.hitboxes, self.hitbox_grab)
    if hitbox_k then
        table.remove(self.owner.hitboxes, hitbox_k)
    end
end

function PlayerGrabState:updateStage1(dt)
    -- set velocity to 0, as it is not set to 0 when coming directly from walk state
    -- this is not set in the init function to only modify velocity at a consistent point in the update function
    self.owner.dx, self.owner.dy = 0, 0

    -- if grabbed something and played the grab animation, go into the carry state
    if not self.first_frame and self.owner.current_animation.loop_count > 0 then
        self.owner.new_state = 'carry-idle'
    end

    self.owner:checkObjectCollisions()
end

function PlayerGrabState:updateStage2(dt)
    self.owner:checkEntityCollisions()
end

function PlayerGrabState:updateStage3(dt)
    if self.first_frame and not self.owner.new_state then
        -- if nothing was grabbed
        if not self.owner.carry then
            self.owner.new_state = 'idle'
        else
            self.owner:changeAnimation('grab-' .. self.owner.direction)
            gSounds['player-lift']:play()
        end
    end

    self.first_frame = false
end
