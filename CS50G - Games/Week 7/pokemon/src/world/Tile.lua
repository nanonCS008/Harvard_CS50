--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Every game area is built out of Tile objects
]]

Tile = Class{}

function Tile:init(grid_x, grid_y, id, frame_id)
    self.grid_x = grid_x
    self.grid_y = grid_y
    self.x = (self.grid_x - 1) * TILE_SIZE
    self.y = (self.grid_y - 1) * TILE_SIZE
    self.id = id
    self.frame_id = frame_id

    -- check if the tile has a corresponding tile definition
    local tile_def = TILE_DEFS[self.id]
    if tile_def then
        -- execute the onInit function that extends the Tile class
        if tile_def.onInit then tile_def.onInit(self) end
        -- add an onCollide function
        if tile_def.onCollide then self.onCollide = tile_def.onCollide end
    end
end

function Tile:render()
    love.graphics.draw(gTextures['tiles'], gFrames['tiles'][self.frame_id], self.x, self.y)
end
