--[[
    GD50
    Pokemon

    -- Animation Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Animation Helper Class. Switches between the textures (frames) according to the update interval to create an Animation Effect.
]]

Animation = Class{}

function Animation:init(def)
    self.texture = def.texture              -- key string of the gFrames table. Specifies the Spritesheet
    self.frames = def.frames or {1}         -- table of frame ID's. used as an index in the gFrames table
    self.interval = def.interval or 1       -- frame changing period in seconds
    self.looping = def.looping or true      -- if animation should loop or stop at the last frame
    self.loop_count = 0                     -- count the number of full animation loops
    self.timer = 0                          -- to count the display time of the current frame
    self.current_frame = 1                  -- index into self.frames to get the currently active frame
end

-- the animation will start playing from the first frame again when called
function Animation:restart()
    self.timer = 0
    self.current_frame = 1
    self.loop_count = 0
end

-- increment the timer and update self.current_frame if the timer has reached the update interval
function Animation:update(dt)
    -- do not update if not a looping animation and it was played already once
    if not self.looping and self.loop_count > 0 then
        return
    end

    -- no need to update if animation is only one frame
    if #self.frames > 1 then
        self.timer = self.timer + dt

        if self.timer > self.interval then
            self.timer = self.timer % self.interval

            self.current_frame = (self.current_frame % #self.frames) + 1

            -- if looped back to the beginning, increment self.loop_count
            if self.current_frame == 1 then
                self.loop_count = self.loop_count + 1
            end
        end
    end
end

-- return the current frame ID. Can be used in the love.graphics.draw() function
function Animation:getCurrentFrame()
    return self.frames[self.current_frame]
end
