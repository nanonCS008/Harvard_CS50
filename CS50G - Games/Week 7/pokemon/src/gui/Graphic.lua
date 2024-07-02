--[[
    Class that can render a texture or a quad in a spritesheet
]]

Graphic = Class{}

function Graphic:init(def)
    self.x, self.y = def.x or 0, def.y or 0
    -- texture name or function that returns a texture name (as pointer arithmetic replacement)
    self.texture = def.texture
    -- optional frame ID to specify a quad
    self.frame_id = def.frame_id
    local texture = type(self.texture) == 'function' and self.texture() or self.texture
    if self.frame_id then
        -- if quad
        self.width, self.height = gFrames[texture][self.frame_id]:getTextureDimensions()
    else
        -- if texture in a single file
        self.width = gTextures[texture]:getWidth()
        self.height = gTextures[texture]:getHeight()
    end
end

function Graphic:getDimensions()
    return self.width, self.height
end

function Graphic:setPosition(x, y)
    self.x, self.y = x, y
end

function Graphic:render()
    local texture = type(self.texture) == 'function' and self.texture() or self.texture
    love.graphics.draw(table.unpack({gTextures[texture], self.frame_id and gFrames[texture][self.frame_id] or nil}),
        math.floor(self.x), math.floor(self.y))
end
