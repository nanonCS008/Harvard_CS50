--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

FadeState = Class{__includes = BaseState}

-- This state can be pushed on the stack to create a fade out or fade in effect.
-- A screen filling rectangle with the starting color of 'color' will tween its alpha value to
-- 'alpha_end' over a time of 'time'. When the tweening is complete, onComplete will be called.
function FadeState:init(color, alpha_end, time, onComplete)
    self.id = FADE_STATE_ID
    self.color = color or {255/255, 255/255, 255/255, 255/255}
    self.time = time or 1
    self.onComplete = onComplete or function() end

    Timer.tween(self.time, {
        [self.color] = {[4] = alpha_end or (0/255)}
    })
    :finish(function()
        -- pop FadeState
        gStateStack:pop()
        self.onComplete()
    end)
end

function FadeState:render()
    love.graphics.setColor(self.color)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
    love.graphics.setColor(255/255, 255/255, 255/255, 255/255)
end
