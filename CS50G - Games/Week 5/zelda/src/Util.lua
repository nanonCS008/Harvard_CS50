--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Helper functions.
]]

--[[
    atlas: spritesheet.
    tilewidth, tileheight: width and height for the tiles in the spritesheet
    The returned 1 dimensional spritesheet table indexes the quads from left to right and top to bottom (starting index: 1)
]]
function GenerateQuads(atlas, tilewidth, tileheight)
    local sheet_width = atlas:getWidth() / tilewidth
    local sheet_height = atlas:getHeight() / tileheight

    local sheet_counter = 1
    local spritesheet = {}

    for y = 0, sheet_height - 1 do
        for x = 0, sheet_width - 1 do
            spritesheet[sheet_counter] =
                love.graphics.newQuad(x * tilewidth, y * tileheight, tilewidth, tileheight, atlas:getDimensions())
            sheet_counter = sheet_counter + 1
        end
    end

    return spritesheet
end

-- convert hitbox data into hitbox objects
-- hitboxes_def: input. table with subtables that contain hitbox properties (see entity/ object definition files).
-- supported hitbox properties: x_offset, y_offset, is_solid, takes_damage, deals_damage, damage, is_grab
-- return: table with hitbox objects
function getHitboxesFromDefinition(hitboxes_def)
    if not hitboxes_def then
        return nil
    end
    local hitboxes = {}
    for _, hitbox_def in pairs(hitboxes_def) do
        local hitbox = Rect(0, 0, hitbox_def.width, hitbox_def.height)
        hitbox.x_offset = hitbox_def.x_offset
        hitbox.y_offset = hitbox_def.y_offset
        hitbox.is_solid = hitbox_def.is_solid
        hitbox.takes_damage = hitbox_def.takes_damage
        hitbox.deals_damage = hitbox_def.deals_damage
        hitbox.damage = hitbox_def.damage
        hitbox.is_grab = hitbox_def.is_grab
        table.insert(hitboxes, hitbox)
    end

    return hitboxes
end
