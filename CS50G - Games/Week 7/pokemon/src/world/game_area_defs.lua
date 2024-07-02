--[[
    Functions to create the content of each game area (there is only 1 area implemented)
    The GameArea class members get set by these functions
    The functions are returned in a table at the end of this file
]]

local function generateArea_1_1(area)
    area.num_tiles_hor = 53
    area.num_tiles_vert = 40

    area.base_layer = {}
    area.grass_layer = {}
    area.collidable_layer = {}
    area.entities = {}

    table.insert(area.entities, area.player)
    -- create NPC
    local npc_def = deepcopy(ENTITY_DEFS['npc1'])
    npc_def.grid_x, npc_def.grid_y = 12, 17
    npc_def.area = area
    npc_def.direction = 'right'
    npc_def.onInteraction = function(self, entity)
        self:faceEntity(entity)
        gStateStack:push(getDialogueBoxState("Hi, I'm a helpful NPC.",
        function()
            gStateStack:push(getQuestionBoxState("Do you want me to heal your Pokemon?",
            function()
                gSounds['heal']:play()
                for _, pokemon in pairs(entity.party) do
                    pokemon.hp = pokemon.hp_max
                end
                gStateStack:push(getDialogueBoxState('Your Pokemon have been healed!'))
            end))
        end))
    end
    table.insert(area.entities, NPC(npc_def))

    -- have an area with higher wild Pokemon levels
    area.getWildPokemonLvlRange = function(self)
        local pkmn_lvl_min, pkmn_lvl_max = 2, 6
        if self.player.grid_x > 20 and self.player.grid_x < 30 and self.player.grid_y > 4 and self.player.grid_y < 15 then
            pkmn_lvl_min, pkmn_lvl_max = 6, 10
        end
        return pkmn_lvl_min, pkmn_lvl_max
    end
    area.getWildPokemon = function(self)
        return Pokemon(POKEMON_DEFS[math.random(#POKEMON_DEFS)], math.random(self:getWildPokemonLvlRange()))
    end

    -- fill the base layer tile table with random (base) grass Tiles
    for grid_y = 1, area.num_tiles_vert do
        area.base_layer[grid_y] = {}
        for grid_x = 1, area.num_tiles_hor do
            area.base_layer[grid_y][grid_x] = Tile(grid_x, grid_y,
                TILE_ID_BASE_GRASS, TILE_FRAME_IDS_BASE_GRASS[math.random(#TILE_FRAME_IDS_BASE_GRASS)])
        end
    end

    -- fill grass layer
    for grid_y = 1, area.num_tiles_vert do
        area.grass_layer[grid_y] = {}
        for grid_x = 1, area.num_tiles_hor do
            local tile = nil
            -- grass
            if (grid_x > 20 and grid_x < 30 and grid_x ~= 25 and grid_y > 4 and grid_y < 10) or
                (grid_x > 6 and grid_x < 19 and grid_y > 6 and grid_y < 14)
            then
                tile = Tile(grid_x, grid_y, TILE_ID_GRASS, TILE_FRAME_ID_GRASS)
            -- stairs
            elseif (grid_x == 22 or grid_x == 28) and grid_y == 15 then
                tile = Tile(grid_x, grid_y, TILE_ID_STAIRS, TILE_FRAME_ID_STAIRS_FULL_ROCKY_UP)
            elseif (grid_x == 13 or grid_x == 14) and grid_y == 22 then
                tile = Tile(grid_x, grid_y, TILE_ID_STAIRS, TILE_FRAME_ID_STAIRS_HALF_UP)
            elseif grid_x == 30 and grid_y == 19 then
                tile = Tile(grid_x, grid_y, TILE_ID_STAIRS, TILE_FRAME_ID_STAIRS_HALF_LEFT)
            -- flowers
            elseif grid_x > 20 and grid_x < 30 and grid_x ~= 25 and grid_y > 10 and grid_y < 14 then
                tile = Tile(grid_x, grid_y, TILE_ID_FLOWER, TILE_FRAME_IDS_FLOWER_RED[math.random(#TILE_FRAME_IDS_FLOWER_RED)])
            end
            area.grass_layer[grid_y][grid_x] = tile
        end
    end

    -- fill collidable layer
    for grid_y = 1, area.num_tiles_vert do
        area.collidable_layer[grid_y] = {}
        for grid_x = 1, area.num_tiles_hor do
            local tile = nil
            -- fences
            if grid_x == 5 and grid_y == 5 then
                tile = Tile(grid_x, grid_y, TILE_ID_FENCE, TILE_FRAME_ID_FENCE_DEFAULT_CORNER_TOP_LEFT)
            elseif grid_x > 5 and grid_x < area.num_tiles_hor - 5 and
                ((grid_y == 5 and (grid_x < 19 or grid_x > 31)) or grid_y == area.num_tiles_vert - 5)
            then
                tile = Tile(grid_x, grid_y, TILE_ID_FENCE, TILE_FRAME_ID_FENCE_DEFAULT_CONNECTION_HOR)
            elseif grid_x == area.num_tiles_hor - 5 and grid_y == 5 then
                tile = Tile(grid_x, grid_y, TILE_ID_FENCE, TILE_FRAME_ID_FENCE_DEFAULT_CORNER_TOP_RIGHT)
            elseif grid_x == area.num_tiles_hor - 5 and grid_y > 5 and grid_y < area.num_tiles_vert - 5 then
                tile = Tile(grid_x, grid_y, TILE_ID_FENCE, TILE_FRAME_ID_FENCE_DEFAULT_CONNECTION_VERT_RIGHT)
            elseif grid_x == area.num_tiles_hor - 5 and grid_y == area.num_tiles_vert - 5 then
                tile = Tile(grid_x, grid_y, TILE_ID_FENCE, TILE_FRAME_ID_FENCE_DEFAULT_CORNER_BOTTOM_RIGHT)
            elseif grid_x == 5 and grid_y == area.num_tiles_vert - 5 then
                tile = Tile(grid_x, grid_y, TILE_ID_FENCE, TILE_FRAME_ID_FENCE_DEFAULT_CORNER_BOTTOM_LEFT)
            elseif grid_x == 5 and grid_y > 5 and grid_y < area.num_tiles_vert - 5 and grid_y ~= 15 and grid_y ~= 14 then
                tile = Tile(grid_x, grid_y, TILE_ID_FENCE, TILE_FRAME_ID_FENCE_DEFAULT_CONNECTION_VERT_LEFT)
            elseif grid_x == 19 and (grid_y == 5 or grid_y == 15) then
                tile = Tile(grid_x, grid_y, TILE_ID_FENCE, TILE_FRAME_ID_FENCE_DEFAULT_ENDING_RIGHT)
            elseif grid_x == 5 and grid_y == 14 then
                tile = Tile(grid_x, grid_y, TILE_ID_FENCE, TILE_FRAME_ID_FENCE_DEFAULT_ENDING_DOWN_LEFT)
            elseif grid_x == 5 and grid_y == 15 then
                tile = Tile(grid_x, grid_y, TILE_ID_FENCE, TILE_FRAME_ID_FENCE_DEFAULT_CORNER_TOP_LEFT)
            elseif grid_x > 5 and grid_x < 19 and (grid_x < 12 or grid_x > 15) and grid_y == 15 then
                tile = Tile(grid_x, grid_y, TILE_ID_FENCE, TILE_FRAME_ID_FENCE_DEFAULT_CONNECTION_HOR)
            elseif grid_x == 12 and grid_y == 15 then
                tile = Tile(grid_x, grid_y, TILE_ID_FENCE, TILE_FRAME_ID_FENCE_DEFAULT_ENDING_RIGHT)
            elseif (grid_x == 15 and grid_y == 15) or (grid_x == 31 and grid_y == 5) then
                tile = Tile(grid_x, grid_y, TILE_ID_FENCE, TILE_FRAME_ID_FENCE_DEFAULT_ENDING_LEFT)
            -- large cliffs
            elseif grid_x == 20 and grid_y == 4 then
                tile = Tile(grid_x, grid_y, TILE_ID_LARGE_CLIFF, TILE_FRAME_ID_LARGE_CLIFF_CORNER_TOP_LEFT)
            elseif grid_x > 20 and grid_x < 30 and grid_y == 4 then
                tile = Tile(grid_x, grid_y, TILE_ID_LARGE_CLIFF, TILE_FRAME_ID_LARGE_CLIFF_CONNECTION_HOR_UP)
            elseif grid_x == 30 and grid_y == 4 then
                tile = Tile(grid_x, grid_y, TILE_ID_LARGE_CLIFF, TILE_FRAME_ID_LARGE_CLIFF_CORNER_TOP_RIGHT)
            elseif grid_x == 30 and grid_y > 4 and grid_y < 15 then
                tile = Tile(grid_x, grid_y, TILE_ID_LARGE_CLIFF, TILE_FRAME_ID_LARGE_CLIFF_CONNECTION_VERT_RIGHT)
            elseif grid_x == 30 and grid_y == 15 then
                tile = Tile(grid_x, grid_y, TILE_ID_LARGE_CLIFF, TILE_FRAME_ID_LARGE_CLIFF_CORNER_BOTTOM_RIGHT)
            elseif grid_x > 20 and grid_x < 30 and grid_y == 15 and grid_x ~= 22 and grid_x ~= 28 then
                tile = Tile(grid_x, grid_y, TILE_ID_LARGE_CLIFF, TILE_FRAME_ID_LARGE_CLIFF_CONNECTION_HOR_DOWN)
            elseif grid_x == 20 and grid_y == 15 then
                tile = Tile(grid_x, grid_y, TILE_ID_LARGE_CLIFF, TILE_FRAME_ID_LARGE_CLIFF_CORNER_BOTTOM_LEFT)
            elseif grid_x == 20 and grid_y > 4 and grid_y < 15 then
                tile = Tile(grid_x, grid_y, TILE_ID_LARGE_CLIFF, TILE_FRAME_ID_LARGE_CLIFF_CONNECTION_VERT_LEFT)
            -- small cliffs
            elseif grid_x == 6 and grid_y == 22 then
                tile = Tile(grid_x, grid_y, TILE_ID_SMALL_CLIFF_JUMPABLE, TILE_FRAME_ID_SMALL_CLIFF_ENDING_HOR_BOTTOM_LEFT)
            elseif grid_x > 6 and grid_x < 30 and grid_x ~= 13 and grid_x ~= 14 and grid_y == 22 then
                tile = Tile(grid_x, grid_y, TILE_ID_SMALL_CLIFF_JUMPABLE, TILE_FRAME_ID_SMALL_CLIFF_CONNECTION_HOR_BOTTOM)
            elseif grid_x == 30 and grid_y == 22 then
                tile = Tile(grid_x, grid_y, TILE_ID_SMALL_CLIFF, TILE_FRAME_ID_SMALL_CLIFF_CORNER_OUTER_BOTTOM_RIGHT)
            elseif grid_x == 30 and grid_y > 16 and grid_y < 22 and grid_y ~= 19 then
                tile = Tile(grid_x, grid_y, TILE_ID_SMALL_CLIFF_JUMPABLE, TILE_FRAME_ID_SMALL_CLIFF_CONNECTION_VERT_RIGHT)
            elseif grid_x == 30 and grid_y == 16 then
                tile = Tile(grid_x, grid_y, TILE_ID_SMALL_CLIFF_JUMPABLE, TILE_FRAME_ID_SMALL_CLIFF_ENDING_VERT_RIGHT_UP)
            elseif (grid_x > 33 and grid_x < 45 and grid_y == 22) or (grid_x > 35 and grid_x < 43 and grid_y == 24) or (grid_x > 37 and grid_x < 41 and grid_y == 26) then
                tile = Tile(grid_x, grid_y, TILE_ID_SMALL_CLIFF_JUMPABLE, TILE_FRAME_ID_SMALL_CLIFF_CONNECTION_HOR_BOTTOM)
            elseif (grid_x > 33 and grid_x < 45 and grid_y == 33) or (grid_x > 35 and grid_x < 43 and grid_y == 31) or (grid_x > 37 and grid_x < 41 and grid_y == 29) then
                tile = Tile(grid_x, grid_y, TILE_ID_SMALL_CLIFF_JUMPABLE, TILE_FRAME_ID_SMALL_CLIFF_CONNECTION_HOR_TOP)
            elseif (grid_x == 32 and grid_y > 22 and grid_y < 33) or (grid_x == 34 and grid_y > 24 and grid_y < 31) or (grid_x == 36 and grid_y > 26 and grid_y < 29) then
                tile = Tile(grid_x, grid_y, TILE_ID_SMALL_CLIFF_JUMPABLE, TILE_FRAME_ID_SMALL_CLIFF_CONNECTION_VERT_RIGHT)
            elseif (grid_x == 46 and grid_y > 22 and grid_y < 33) or (grid_x == 44 and grid_y > 24 and grid_y < 31) or (grid_x == 42 and grid_y > 26 and grid_y < 29) then
                tile = Tile(grid_x, grid_y, TILE_ID_SMALL_CLIFF_JUMPABLE, TILE_FRAME_ID_SMALL_CLIFF_CONNECTION_VERT_LEFT)
            end
            area.collidable_layer[grid_y][grid_x] = tile
        end
    end
end

return {
    [1] = generateArea_1_1
}
