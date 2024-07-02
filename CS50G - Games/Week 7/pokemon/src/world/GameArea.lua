--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Class that contains all tiles and entities that will be rendered/ updated
]]

GameArea = Class{}

function GameArea:init(player)
    -- variables will be set by calling GameAreaGenerator
    -- Area dimensions in tiles
    self.num_tiles_hor = 0
    self.num_tiles_vert = 0
    -- Tables that contain the tiles arranged in a matrix. Each subtable represents a row of tiles.
    -- For every layer there can only be 1 element at a position. The tables are rendered in this order.
    -- Tiles in the collidable_layer are treated as solid (cannot move through) and they might have a
    -- collision callback function that is called on collision with an entity.
    self.base_layer = {}
    self.grass_layer = {}
    self.collidable_layer = {}
    -- list of entities
    self.entities = {}
    -- function that returns the min, max wild Pokemon level in the current area
    self.getWildPokemonLvlRange = function() return 1, 1 end
    -- function that returns a Pokemon object specific for the current area. Used for the BattleState.
    self.getWildPokemon = function() return Pokemon(POKEMON_DEFS[1]) end

    self.player = player
    self.player:setGridPosition(14, 17)

    -- generate level
    GameAreaGenerator[1](self)
    self:updateCamera()
    self:renderListSync()
end

-- The camera is centered on the player and constrained by the area size
function GameArea:updateCamera()
    self.cam_x = math.max(0,
        math.min(TILE_SIZE * self.num_tiles_hor - VIRTUAL_WIDTH,
        self.player.x - (VIRTUAL_WIDTH / 2 - self.player.width / 2)))
    self.cam_y = math.max(0,
        math.min(TILE_SIZE * self.num_tiles_vert - VIRTUAL_HEIGHT,
        self.player.y + self.player.height - VIRTUAL_HEIGHT / 2))
end

-- Create a sorted render list that is used to draw entities in the render function.
-- The entities will be drawn after all other tiles.
-- Order the entities after their y coordinate. Entities with higher y should be drawn last (on top).
-- The tile textures cannot overlap with an entity that is above the tile.
-- Thats why tiles don't need to be sorted in this list.
function GameArea:renderListSync()
    -- update the render list by calling this function in this frame number interval (to not call it every frame)
    self.sync_render_list_interval = 7
    self.sync_render_list_counter = 0
    self.render_list = {}
    self.elem_y_list = {}
    table.extend(self.render_list, self.entities)
    for _, elem in pairs(self.render_list) do
        table.insert(self.elem_y_list, elem.y)
    end
    self.render_list, self.elem_y_list = sortStableWithHelperTbl(self.render_list, self.elem_y_list)
end

function GameArea:update(dt)
    for _, entity in pairs(self.entities) do
        entity:update(dt)
    end

    self.sync_render_list_counter = self.sync_render_list_counter + 1
    if self.sync_render_list_counter >= self.sync_render_list_interval then
        self:renderListSync()
    end

    self:updateCamera()
end

function GameArea:render()
    love.graphics.push()
    love.graphics.translate(-math.floor(self.cam_x), -math.floor(self.cam_y))

    local layers = {self.base_layer, self.grass_layer, self.collidable_layer}

    -- only render tiles that are on the screen.
    -- The offset specifies how many pixel off the screen are still rendered.
    local off_camera_render_offset = 0
    for _, layer in pairs(layers) do
        for _, row in pairs(layer) do
            for _, tile in pairs(row) do
                if tile and
                    tile.x + TILE_SIZE >= self.cam_x - off_camera_render_offset and
                    tile.x <= self.cam_x + VIRTUAL_WIDTH + off_camera_render_offset and
                    tile.y + TILE_SIZE >= self.cam_y - off_camera_render_offset and
                    tile.y <= self.cam_y + VIRTUAL_HEIGHT + off_camera_render_offset
                then
                    tile:render()
                end
            end
        end
    end

    for _, elem in pairs(self.render_list) do
        elem:render()
    end

    love.graphics.pop()

    if IS_DEBUG then
        local lvl_min, lvl_max = self:getWildPokemonLvlRange()
        love.graphics.setFont(gFonts['small'])
        love.graphics.print("x: " .. tostring(self.player.x), 10, 5)
        love.graphics.print("y: " .. tostring(self.player.y), 10, 15)
        love.graphics.print("z: " .. tostring(self.player.proj_z), 10, 25)
        love.graphics.print("grid x: " .. tostring(self.player.grid_x), 10, 35)
        love.graphics.print("grid y: " .. tostring(self.player.grid_y), 10, 45)
        love.graphics.print("cam x: " .. tostring(self.cam_x), 10, 55)
        love.graphics.print("cam y: " .. tostring(self.cam_y), 10, 65)
        love.graphics.print("state: " .. self.player.state_machine.current.name, 10, 75)
        love.graphics.print("wild PKMN lvl range: " .. tostring(lvl_min) .. " - " .. tostring(lvl_max), 10, 85)
    end
end
