--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Colored Bar (rectangle) that represents a value compared to a max value.
]]

ProgressBar = Class{__includes = Panel}

function ProgressBar:init(def)
    -- 9-slice texture to instantiate a Panel. The Panel will be the outline for the inner bar.
    def.texture = def.texture and def.texture or 'progress-bar'
    def.margin = def.margin and def.margin or 4
    Panel.init(self, def)
    -- color of the inner bar
    self.color = def.color
    -- the inner bar represents the value / value_max ratio
    -- number or a function that returns a number (as pointer arithmetic replacement)
    self.value = def.value
    self.value_max = def.value_max
end

function ProgressBar:render()
    local value = type(self.value) == 'function' and self.value() or self.value
    local value_max = type(self.value_max) == 'function' and self.value_max() or self.value_max
    value = math.max(0, value)

    -- The inner bar rectangle is drawn so that it fills 100% of the area when the bar is full,
    -- but does not draw outside of the bar. The progress bar Panel texture is made in a way so that's possible.
    -- The bar always fills from left to right.
    local inner_bar_margin = 1
    -- draw white background
    love.graphics.setColor(255/255, 255/255, 255/255, 255/255)
    love.graphics.rectangle('fill', self.x + inner_bar_margin, self.y + inner_bar_margin,
        math.floor(self.width - inner_bar_margin * 2), math.floor(self.height - inner_bar_margin * 2))
    -- draw inner bar
    love.graphics.setColor(self.color)
    love.graphics.rectangle('fill', self.x + inner_bar_margin, self.y + inner_bar_margin,
        math.floor((value / value_max) * (self.width - inner_bar_margin * 2)),
        math.floor(self.height - inner_bar_margin * 2))
    -- draw outline
    love.graphics.setColor(255/255, 255/255, 255/255, 255/255)
    Panel.render(self)
end
