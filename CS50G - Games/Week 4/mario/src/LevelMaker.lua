--[[
    GD50
    Super Mario Bros. Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

LevelMaker = Class{}

function LevelMaker.generate(width, height, levelNumber, gkeyColor)
    gKeyFound = false
    local tiles = {}
    local entities = {}
    local objects = {}

    local tileID = TILE_ID_GROUND
    
    -- whether we should draw our tiles with toppers
    local topper = true
    local tileset = math.random(20)
    local topperset = math.random(20)

    local keySpawnX = math.random(width) --spec2
    local lockSpawnX = math.random(width)
    repeat
        lockSpawnX = math.random(width)
    until (lockSpawnX ~= keySpawnX)
    -- print(keySpawnX, lockSpawnX)
    local keyColor = gkeyColor
    local lockColor = keyColor + 4

    -- insert blank tables into tiles for later access
    for x = 1, height do
        table.insert(tiles, {})
    end

    -- column by column generation instead of row; sometimes better for platformers
    for x = 1, width do
        local tileID = TILE_ID_EMPTY
        
        -- lay out the empty space
        for y = 1, 6 do
            table.insert(tiles[y],
                Tile(x, y, tileID, nil, tileset, topperset))
        end

        -- chance to just be emptiness
        if math.random(EMPTYNESS_FREQUENCY) == 1 then
            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, nil, tileset, topperset))
            end
        else
            tileID = TILE_ID_GROUND

            -- height at which we would spawn a potential jump block
            local blockHeight = 4

            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
            end

            -- chance to generate a pillar
            if math.random(8) == 1 then
                blockHeight = 2
                
                -- chance to generate bush on pillar
                if math.random(8) == 1 then
                    table.insert(objects,
                        GameObject {
                            texture = 'bushes',
                            x = (x - 1) * TILE_SIZE,
                            y = (4 - 1) * TILE_SIZE,
                            width = 16,
                            height = 16,
                            
                            -- select random frame from bush_ids whitelist, then random row for variance
                            frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                            collidable = false
                        }
                    )
                end
                
                -- pillar tiles
                tiles[5][x] = Tile(x, 5, tileID, topper, tileset, topperset)
                tiles[6][x] = Tile(x, 6, tileID, nil, tileset, topperset)
                tiles[7][x].topper = nil
            
            -- chance to generate bushes
            elseif math.random(8) == 1 then
                table.insert(objects,
                    GameObject {
                        texture = 'bushes',
                        x = (x - 1) * TILE_SIZE,
                        y = (6 - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                        collidable = false
                    }
                )
            end

            -- spawn a key at random position across the width of the map
            if x == keySpawnX then --spec2
                table.insert(objects,
                    GameObject {
                        texture = 'key-lock',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,

                        frame = keyColor,
                        collidable = false,
                        consumable = true,
                        solid = false,

                        onConsume = function(player, object)
                            gKeyFound = true
                            gSounds['pickup']:play()
                            lockobject = objects[lockIndex]
                            lockobject.solid = false
                            lockobject.consumable = true
                            lockobject.onCollide = nil
                            lockobject.onConsume = function(player, object)
                                gKeyFound = false
                                gSounds['pickup']:play()
                                local flagpole = GameObject { --spec3
                                    texture = 'flag-pole',
                                    x = (width - 2) * TILE_SIZE,
                                    y = 50,
                                    width = 12,
                                    height = 48,
                                    frame = 1,
                                    collidable = true,
                                    consumable = true,
                                    solid = false,
                            
                                    onConsume = function(player, object)
                                        gSounds['pickup']:play()
                                        player.score = player.score + 100
                                        gStateMachine:change('play', {score = player.score, levelNumber = levelNumber + 1})
                                    end
                                }
                                table.insert(objects, flagpole)
                                local flagcloth = GameObject { --spec3
                                    texture = 'flag-pole',
                                    x = (width - 2) * TILE_SIZE + 3,
                                    y = 52,
                                    width = 16,
                                    height = 10,
                                    frame = 2,
                                    collidable = true,
                                    consumable = true,
                                    solid = false,
                            
                                    onConsume = function(player, object)
                                        gSounds['pickup']:play()
                                        player.score = player.score + 100
                                        gStateMachine:change('play', {score = player.score, levelNumber = levelNumber + 1})
                                    end
                                }
                                table.insert(objects, flagcloth)
                            end
                        end
                    }
                )

            -- spawn a lock corresponding the key with same color
            elseif x == lockSpawnX then --spec2
                table.insert(objects,
                    GameObject {
                        texture = 'key-lock',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,

                        frame = lockColor,
                        collidable = true,
                        consumable = false,
                        solid = true,

                        onCollide = function(obj)
                            gSounds['empty-block']:play()
                        end
                    }
                )
                lockIndex = #objects

            -- chance to spawn a block
            elseif math.random(10) == 1 then
                table.insert(objects,

                    -- jump block
                    GameObject {
                        texture = 'jump-blocks',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,

                        -- make it a random variant
                        frame = math.random(#JUMP_BLOCKS),
                        collidable = true,
                        hit = false,
                        solid = true,

                        -- collision function takes itself
                        onCollide = function(obj)

                            -- spawn a gem if we haven't already hit the block
                            if not obj.hit then

                                -- chance to spawn gem, not guaranteed
                                if math.random(5) == 1 then

                                    -- maintain reference so we can set it to nil
                                    local gem = GameObject {
                                        texture = 'gems',
                                        x = (x - 1) * TILE_SIZE,
                                        y = (blockHeight - 1) * TILE_SIZE - 4,
                                        width = 16,
                                        height = 16,
                                        frame = math.random(#GEMS),
                                        collidable = true,
                                        consumable = true,
                                        solid = false,

                                        -- gem has its own function to add to the player's score
                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            player.score = player.score + 100
                                        end
                                    }
                                    
                                    -- make the gem move up from the block and play a sound
                                    Timer.tween(0.1, {
                                        [gem] = {y = (blockHeight - 2) * TILE_SIZE}
                                    })
                                    gSounds['powerup-reveal']:play()

                                    table.insert(objects, gem)
                                end

                                obj.hit = true
                            end

                            gSounds['empty-block']:play()
                        end
                    }
                )
            end
        end
    end

    local map = TileMap(width, height)
    map.tiles = tiles
    
    return GameLevel(entities, objects, map)
end

-- lockOnConsumeFunc = function(player, object)
--     gSounds['pickup']:play()
--     local flagpole = GameObject { --spec3
--         texture = 'flag-pole',
--         x = (width - 1) * TILE_SIZE,
--         y = (blockHeight - 1) * TILE_SIZE - 4,
--         width = 12,
--         height = 48,
--         frame = 1,
--         collidable = true,
--         consumable = true,
--         solid = false,

--         onCollide = function(player, object)
--             gSounds['pickup']:play()
--             player.score = player.score + 100
--         end
--     }
--     table.insert(objects, flagpole)
-- end