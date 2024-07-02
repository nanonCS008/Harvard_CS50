--[[
    Class to render text
]]

Text = Class{}

function Text:init(def)
    -- string or a function that returns a string (as pointer arithmetic replacement)
    self.text = def.text or ""
    self.font = def.font or gFonts['small']
    self.color = def.color or {255/255, 255/255, 255/255, 255/255}
    -- wrap text with this limit
    self.limit = def.limit or VIRTUAL_WIDTH
    self.align = def.align or 'left'
    self.x, self.y = def.x or 0, def.y or 0
end

function Text:getDimensions()
    local text = type(self.text) == 'function' and self.text() or self.text
    local width, lines = self.font:getWrap(text, self.limit)
    local height = self.font:getHeight() * #lines
    return width, height
end

function Text:setPosition(x, y)
    self.x, self.y = x, y
end

function Text:render()
    local text = type(self.text) == 'function' and self.text() or self.text
    love.graphics.setColor(self.color)
    love.graphics.setFont(self.font)
    love.graphics.printf(text, math.floor(self.x), math.floor(self.y), self.limit, self.align)
    love.graphics.setColor(255/255, 255/255, 255/255, 255/255)
end
