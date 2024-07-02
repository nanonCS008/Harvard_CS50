--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A Panel can be used for GUI windows.
    The Panel renders a texture as 9-Slice. The 9-Slice is implemented with the library love9slice.
    The 9-Slice splits a texture into 9 quads.
    A-B----C-D
    E-F----G-H
    | |    | |
    I-J----K-L
    M-N----O-P
    There is no need to resize the whole texture or making various sized textures from the same image.
    Only the quads that need to be resized get resized. Corners always stay the same size.
    The middle part gets stretched and not tiled (repeated).
    Example: If the texture gets stretched vertically, only the 3 quads inside the rectangle EHIL get stretched.
]]

Panel = Class{}

function Panel:init(def)
    self.texture = def.texture or 'panel-default'
    self.x, self.y = def.x or 0, def.y or 0
    -- desired dimensions of the Panel
    self.width = def.width or gTextures[self.texture]:getWidth()
    self.height = def.height or gTextures[self.texture]:getHeight()
    -- horizontal and vertical margin from the texture edges that defines the quad partitioning
    self.margin = def.margin or 5
    -- create 9-slice with left, top, right, bottom: coordinates of inner rectangle FGJK
    self.panel_img = Image9Slice:new(gTextures[self.texture], self.margin, self.margin,
        gTextures[self.texture]:getWidth() - self.margin, gTextures[self.texture]:getHeight() - self.margin)
    self.panel_img:resize(self.width, self.height)
end

function Panel:getDimensions()
    return self.width, self.height
end

function Panel:setPosition(x, y)
    self.x, self.y = x, y
end

function Panel:render()
    self.panel_img:draw(math.floor(self.x), math.floor(self.y))
end
