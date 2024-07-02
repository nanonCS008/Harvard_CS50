--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Helper functions.
]]

--[[
    atlas: spritesheet.
    tile_width, tile_height: width and height for the tiles in the spritesheet including spacing
    spacing (default 0): space between the quads in the spritesheet.
        The space to the right and bottom of the tile specified by spacing will not be part of the quad.
    The returned 1 dimensional spritesheet table indexes the quads from left to right and top to bottom (starting index: 1)
]]
function GenerateQuads(atlas, tile_width, tile_height, spacing)
    spacing = spacing or 0
    local sheet_width = atlas:getWidth() / tile_width
    local sheet_height = atlas:getHeight() / tile_height

    local sheet_counter = 1
    local spritesheet = {}

    for y = 0, sheet_height - 1 do
        for x = 0, sheet_width - 1 do
            spritesheet[sheet_counter] = love.graphics.newQuad(x * tile_width, y * tile_height,
                tile_width - spacing, tile_height - spacing, atlas:getDimensions())
            sheet_counter = sheet_counter + 1
        end
    end

    return spritesheet
end
