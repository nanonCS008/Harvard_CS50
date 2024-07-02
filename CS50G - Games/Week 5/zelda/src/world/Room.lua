--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Room inside the dungeon with entities and objects.
]]

Room = Class{}

-- room_x, room_y: index in the rooms table from the Dungeon Class (position of the room in the dungeon)
-- player, dungeon: reference to player and dungeon
-- doorways_lrtb: for every side of the room, specify if a doorway to another room shall be generated
function Room:init(room_x, room_y, player, dungeon, doorways_lrtb)
    self.room_x = room_x
    self.room_y = room_y

    -- room dimensions in tiles
    self.grid_width = ROOM_GRID_WIDTH
    self.grid_height = ROOM_GRID_HEIGHT

    -- number of enemies in the room. used to determine if a Room has been cleared
    self.num_enemies = 0

    -- dungeon reference. needs to be supplied for the entity/ object initialization
    self.dungeon = dungeon

    -- generate tiles (walls, floor)
    self.tiles = {}
    self:generateTiles()

    -- generate game objects
    self.objects = {}
    self:generateObjects(doorways_lrtb)

    -- generate entities
    -- add the player before the other entities, that means the player will get updated and rendered first.
    -- all other entities will be drawn over the player (same behavior as in "A Link to the Past")
    self.entities = {}
    table.insert(self.entities, player)
    self:generateEntities()

    -- render offset used when this room is the next room during a room transition
    self.shift_screen_offset_x = 0
    self.shift_screen_offset_y = 0

    -- list of objects and entities that shall be rendered to the screen.
    -- the elements will be drawn after all elements in self.tiles
    self.render_list = {}
end

-- generate the walls and floors of the room
function Room:generateTiles()
    self.tiles = {}
    for grid_y = 1, self.grid_height do
        table.insert(self.tiles, {})
        for grid_x = 1, self.grid_width do
            -- go through every grid position of the room and determine the tile type from its position
            -- if there is a variety of sprites/ frame IDs available for the same tile, choose randomly
            local frame_id = TILE_FRAME_ID_EMPTY
            local id = OBJECT_ID_WALL
            local is_wall = true

            -- room corners
            if grid_x == 1 and grid_y == 1 then
                frame_id = TILE_FRAME_ID_TOP_LEFT_INNER_CORNER
            elseif grid_x == self.grid_width and grid_y == 1 then
                frame_id = TILE_FRAME_ID_TOP_RIGHT_INNER_CORNER
            elseif grid_x == 1 and grid_y == self.grid_height then
                frame_id = TILE_FRAME_ID_BOTTOM_LEFT_INNER_CORNER
            elseif grid_x == self.grid_width and grid_y == self.grid_height then
                frame_id = TILE_FRAME_ID_BOTTOM_RIGHT_INNER_CORNER
            -- room walls (when placing a doorway the walls at that position get removed)
            elseif grid_x == 1 then
                frame_id = TILE_FRAME_IDS_WALL_FACE_E[math.random(#TILE_FRAME_IDS_WALL_FACE_E)]
            elseif grid_x == self.grid_width then
                frame_id = TILE_FRAME_IDS_WALL_FACE_W[math.random(#TILE_FRAME_IDS_WALL_FACE_W)]
            elseif grid_y == 1 then
                frame_id = TILE_FRAME_IDS_WALL_FACE_S[math.random(#TILE_FRAME_IDS_WALL_FACE_S)]
            elseif grid_y == self.grid_height then
                frame_id = TILE_FRAME_IDS_WALL_FACE_N[math.random(#TILE_FRAME_IDS_WALL_FACE_N)]
            -- room floor
            else
                frame_id = TILE_FRAME_IDS_FLOOR[math.random(#TILE_FRAME_IDS_FLOOR)]
                id = OBJECT_ID_GROUND
                is_wall = false
            end

            -- instantiate tile
            local tile = GameObject({
                x = (grid_x - 1) * TILE_SIZE + ROOM_OFFSET_X,
                y = (grid_y - 1) * TILE_SIZE + ROOM_OFFSET_Y,
                id = id,
                texture = 'tiles',
                frame_id = frame_id,
                is_collidable = is_wall,
            })

            table.insert(self.tiles[grid_y], tile)
        end
    end

    -- generate a pillar in the middle of the room with a certain chance
    -- a pillar is an empty area surrounded by walls
    local gen_pillar_p = 0.5
    if math.random() < gen_pillar_p then
        -- choose the dimensions randomly between min and max dimensions
        local pillar_max_grid_width = math.floor((ROOM_GRID_WIDTH - 2) / 2)
        local pillar_max_grid_height = math.floor((ROOM_GRID_HEIGHT - 2) / 2)
        local pillar_min_grid_length = 2
        local pillar_grid_width = math.random(pillar_min_grid_length, pillar_max_grid_width)
        local pillar_grid_height = math.random(pillar_min_grid_length, pillar_max_grid_height)
        -- make width an even number for symmetry and aesthetics
        pillar_grid_width = pillar_grid_width % 2 == 0 and pillar_grid_width or pillar_grid_width - 1

        -- align to the middle of the room
        local pillar_grid_x = math.floor(ROOM_GRID_WIDTH / 2 - pillar_grid_width / 2 + 1)
        local pillar_grid_y = math.floor(ROOM_GRID_HEIGHT / 2 - pillar_grid_height / 2 + 1)

        -- place tiles to generate the pillar
        for grid_y = pillar_grid_y, pillar_grid_y + pillar_grid_height - 1 do
            for grid_x = pillar_grid_x, pillar_grid_x + pillar_grid_width - 1 do
                local frame_id = TILE_FRAME_ID_EMPTY
                local is_wall = true

                -- corners
                if grid_x == pillar_grid_x and grid_y == pillar_grid_y then
                    frame_id = TILE_FRAME_ID_TOP_LEFT_OUTER_CORNER
                elseif grid_x == pillar_grid_x + pillar_grid_width - 1 and grid_y == pillar_grid_y then
                    frame_id = TILE_FRAME_ID_TOP_RIGHT_OUTER_CORNER
                elseif grid_x == pillar_grid_x and grid_y == pillar_grid_y + pillar_grid_height - 1 then
                    frame_id = TILE_FRAME_ID_BOTTOM_LEFT_OUTER_CORNER
                elseif grid_x == pillar_grid_x + pillar_grid_width - 1 and grid_y == pillar_grid_y + pillar_grid_height - 1 then
                    frame_id = TILE_FRAME_ID_BOTTOM_RIGHT_OUTER_CORNER
                -- walls
                elseif grid_x == pillar_grid_x then
                    frame_id = TILE_FRAME_IDS_WALL_FACE_W[math.random(#TILE_FRAME_IDS_WALL_FACE_W)]
                elseif grid_x == pillar_grid_x + pillar_grid_width - 1 then
                    frame_id = TILE_FRAME_IDS_WALL_FACE_E[math.random(#TILE_FRAME_IDS_WALL_FACE_E)]
                elseif grid_y == pillar_grid_y then
                    frame_id = TILE_FRAME_IDS_WALL_FACE_N[math.random(#TILE_FRAME_IDS_WALL_FACE_N)]
                elseif grid_y == pillar_grid_y + pillar_grid_height - 1 then
                    frame_id = TILE_FRAME_IDS_WALL_FACE_S[math.random(#TILE_FRAME_IDS_WALL_FACE_S)]
                -- empty space (only remove the floor)
                else
                    is_wall = false
                end

                -- replace previous tiles
                if is_wall then
                    self.tiles[grid_y][grid_x] = GameObject({
                        x = (grid_x - 1) * TILE_SIZE + ROOM_OFFSET_X,
                        y = (grid_y - 1) * TILE_SIZE + ROOM_OFFSET_Y,
                        id = OBJECT_ID_WALL,
                        texture = 'tiles',
                        frame_id = frame_id,
                        is_collidable = true,
                    })
                -- remove previous tiles
                else
                    self.tiles[grid_y][grid_x] = nil
                end
            end
        end
    end
end

-- used for the object/ entity generation
-- return a table with ground tile objects that are not occupied
-- this table can then be used to get possible object/ entity spawn points
function Room:getFreeGroundTiles()
    local free_ground_tiles = {}

    for grid_y = 1, self.grid_height do
        for grid_x = 1, self.grid_width do
            if
                self.tiles[grid_y] and self.tiles[grid_y][grid_x]
                and self.tiles[grid_y][grid_x].id == OBJECT_ID_GROUND
                and not self.tiles[grid_y][grid_x].is_occupied
            then
                table.insert(free_ground_tiles, self.tiles[grid_y][grid_x])
            end
        end
    end

    return free_ground_tiles
end

-- used for the object/ entity generation to impose restrictions on the eligible spawning ground tiles.
-- each tile is checked to have a minimum distance to other entities/ objects (specified in 'nodes')
-- tiles: table with tile objects
-- nodes: table with elements (necessary members: x, y, width, height),
--      that each tile in the input tiles table must have a certain distance to
-- distance: threshold distance in pixels between tiles and nodes
-- return: a subset of the tiles input table. Each tile in this table has at least a distance of 'distance' to each node.
function Room:subtractTilesMinDist(tiles, nodes, distance)
    local eligible_tiles = {}

    for _, tile in pairs(tiles) do
        local is_eligible = true

        for _, node in pairs(nodes) do
            -- use distance from center to center
            if
                math.sqrt(((tile.x + TILE_SIZE / 2) - (node.x + node.width / 2))^2
                + ((tile.y + TILE_SIZE / 2) - (node.y + node.height / 2))^2) < distance
            then
                is_eligible = false
                break
            end
        end
        if is_eligible then
            table.insert(eligible_tiles, tile)
        end
    end

    return eligible_tiles
end

-- generate game objects in the room
-- doorways_lrtb: specifies on which sides of the room a doorway shall be created
function Room:generateObjects(doorways_lrtb)
    self.objects = {}
    -- table of doorways that lead to other dungeon rooms
    -- the extra door references are needed, because the doors need to be opened and closed during a room transition
    self.doorways = {}
    if doorways_lrtb[1] then
        table.insert(self.doorways, Doorway('left', self))
    end
    if doorways_lrtb[2] then
        table.insert(self.doorways, Doorway('right', self))
    end
    if doorways_lrtb[3] then
        table.insert(self.doorways, Doorway('top', self))
    end
    if doorways_lrtb[4] then
        table.insert(self.doorways, Doorway('bottom', self))
    end
    -- add to list of objects
    for _, doorway in pairs(self.doorways) do
        table.insert(self.objects, doorway)
    end

    -- switch, that opens the doors in the room
    if #self.doorways > 0 then
        -- spawn switch on any free ground tile
        local spawn_ground_tiles = self:getFreeGroundTiles()
        local spawn_ground_tile = spawn_ground_tiles[math.random(#spawn_ground_tiles)]
        spawn_ground_tile.is_occupied = true

        -- object hitbox definitions get converted into hitbox objects.
        -- The new hitboxes key overwrites the old one inside the objects def.
        -- GAME_OBJECT_DEFS must be deepcopied to not get modified.
        local switch_def = deepcopy(GAME_OBJECT_DEFS['switch'])
        table.extend(switch_def, {
            x = spawn_ground_tile.x, y = spawn_ground_tile.y,
            hitboxes = getHitboxesFromDefinition(switch_def.hitboxes)
        })

        local switch = GameObject(switch_def)

        -- The switch points to the doors it opens (all doors in the room)
        switch.connected_doors = self.doorways

        table.insert(self.objects, switch)
    end

    -- big statue, for decoration
    -- only spawn statues with a certain probability. spawn a certain number of statues if they should spawn
    local spawn_statue_p = 0.5
    local num_statues_avail = {1, 2, 4}
    local num_statues = num_statues_avail[math.random(#num_statues_avail)]
    num_statues = math.random() < spawn_statue_p and num_statues or 0

    -- use the hitbox dimensions for positioning, as they define the footprint of the object
    -- the statue only has 1 hitbox, which represents where it touches the ground
    local statue_hitbox = GAME_OBJECT_DEFS['big_statue'].hitboxes[1]
    local statue_grid_width = math.floor(statue_hitbox.width / TILE_SIZE)
    local statue_grid_height = math.floor(statue_hitbox.height / TILE_SIZE)
    -- hardcode possible grid spawn points depending on how many statues shall spawn
    local statue_grid_points = {}

    if num_statues == 1 then
        -- align to the middle of the room
        statue_grid_points = {{
            x = math.floor(ROOM_GRID_WIDTH / 2 - statue_grid_width / 2 + 1),
            y = math.floor(ROOM_GRID_HEIGHT / 2 - statue_grid_height / 2 + 1)
        }}
    elseif num_statues > 1 then
        statue_grid_points = {
            -- top left
            {x = 3, y = 3},
            -- top right
            {x = ROOM_GRID_WIDTH - 1 - statue_grid_width, y = 3},
            -- bottom left
            {x = 3, y = ROOM_GRID_HEIGHT - 1 - statue_grid_height},
            -- bottom right
            {x = ROOM_GRID_WIDTH - 1 - statue_grid_width, y = ROOM_GRID_HEIGHT - 1 - statue_grid_height},
        }

        -- remove 2 possible spawn points randomly if there shall be only 2 statues instead of 4
        if num_statues == 2 then
            table.remove(statue_grid_points, math.random(#statue_grid_points))
            table.remove(statue_grid_points, math.random(#statue_grid_points))
        end
    end

    -- place the statues
    for _, statue_grid_point in pairs(statue_grid_points) do
        -- scan the ground on which the statue shall be placed. if it does not consist of free ground tiles, don't spawn the statue
        local do_spawn = true
        for grid_y = statue_grid_point.y, statue_grid_point.y + statue_grid_height - 1 do
            for grid_x = statue_grid_point.x, statue_grid_point.x + statue_grid_width - 1 do
                if not self.tiles[grid_y][grid_x] or self.tiles[grid_y][grid_x].id ~= OBJECT_ID_GROUND or self.tiles[grid_y][grid_x].is_occupied then
                    do_spawn = false
                    break
                end
            end
            if not do_spawn then break end
        end

        if do_spawn then
            -- flag the ground tiles as occupied
            for grid_y = statue_grid_point.y, statue_grid_point.y + statue_grid_height - 1 do
                for grid_x = statue_grid_point.x, statue_grid_point.x + statue_grid_width - 1 do
                    self.tiles[grid_y][grid_x].is_occupied = true
                end
            end

            local statue_def = deepcopy(GAME_OBJECT_DEFS['big_statue'])
            -- place the hitbox at the spawn position
            table.extend(statue_def, {
                x = (statue_grid_point.x - 1) * TILE_SIZE + ROOM_OFFSET_X - statue_hitbox.x_offset,
                y = (statue_grid_point.y - 1) * TILE_SIZE + ROOM_OFFSET_Y - statue_hitbox.y_offset,
                hitboxes = getHitboxesFromDefinition(statue_def.hitboxes)
            })
            table.insert(self.objects, GameObject(statue_def))
        end
    end

    -- pot, that can be lifted and thrown
    -- spawn random number of pots
    local max_num_pots = 2
    local num_pots = math.random(0, max_num_pots)
    for _ = 1, num_pots do
        -- get possible tiles to spawn on. don't spawn in front of doorway
        local spawn_ground_tiles = self:getFreeGroundTiles()
        spawn_ground_tiles = self:subtractTilesMinDist(spawn_ground_tiles, self.doorways, TILE_SIZE * 2)

        if #spawn_ground_tiles > 0 then
            local spawn_ground_tile = spawn_ground_tiles[math.random(#spawn_ground_tiles)]
            spawn_ground_tile.is_occupied = true

            local pot_def = deepcopy(GAME_OBJECT_DEFS['pot'])
            -- the pot needs a dungeon reference, because it needs to check collisions against objects/ entities when thrown
            table.extend(pot_def, {
                x = spawn_ground_tile.x, y = spawn_ground_tile.y,
                hitboxes = getHitboxesFromDefinition(pot_def.hitboxes),
                dungeon = self.dungeon
            })
            table.insert(self.objects, GameObject(pot_def))
        else
            break
        end
    end
end

-- set entity position to a free ground tile
-- this should be called after all objects were generated and placed
-- return true if the entity was placed. false otherwise (happens only when there is no ground tiles in the room)
function Room:placeEntity(entity)
    local is_placed = false
    -- get possible ground tiles to spawn on (with imposed restrictions)
    local spawn_ground_tiles = self:getFreeGroundTiles()
    -- The ground tile must have a certain distance from a doorway, so the player does not walk into an enemy right away when entering a new room
    local spawn_ground_tiles_restr = self:subtractTilesMinDist(spawn_ground_tiles, self.doorways, TILE_SIZE * 3)
    -- for the starting room, this function gets called manually to place the player in the room
    -- the player should have a certain distance to enemies when spawning
    -- also enemies should try to not spawn on top if each other
    local entity_spawn_d = 0
    if entity.id == ENTITY_ID_PLAYER then
        entity_spawn_d = TILE_SIZE * 2 + 1
    else
        entity_spawn_d = TILE_SIZE / 2 + 1
    end
    -- instead of using the entity coordinates for the distance check, use the entity hitboxes.
    -- every room has a player reference in the entity list, so skip this one. Also skip self in the entity list.
    -- the player must check the distance to other entities and not the other way around (because only the starting room actually spawns the player)
    local entities_hitbox_check = {}
    for _, loop_entity in pairs(self.entities) do
        if loop_entity ~= entity and loop_entity.id ~= ENTITY_ID_PLAYER then
            for _, hitbox in pairs(loop_entity.hitboxes) do
                table.insert(entities_hitbox_check, hitbox)
            end
        end
    end
    spawn_ground_tiles_restr = self:subtractTilesMinDist(spawn_ground_tiles_restr, entities_hitbox_check, entity_spawn_d)

    -- if no ground tile was found eligible for a spawn point, use any free ground tile without the restrictions
    spawn_ground_tiles = #spawn_ground_tiles_restr > 0 and spawn_ground_tiles_restr or spawn_ground_tiles

    if #spawn_ground_tiles > 0 then
        is_placed = true
        local spawn_ground_tile = spawn_ground_tiles[math.random(#spawn_ground_tiles)]

        -- the body hitbox of every entity is (about) at the bottom half of the sprite
        -- rather than setting the coordinates of the sprite, set the coordinates of the hitbox
        -- that way the entity hitbox can not spawn inside a wall when the entity height is greater than TILE_SIZE
        entity:setPosition(spawn_ground_tile.x, spawn_ground_tile.y - entity.height / 2)
    end

    return is_placed
end

-- generate enemies in the room
function Room:generateEntities()
    -- available enemy types to spawn (see entity definition file). choose randomly from this list for every enemy to spawn.
    local types = {'skeleton', 'slime', 'bat', 'ghost', 'spider'}

    local max_num_enemies = 5
    local num_enemies = math.random(max_num_enemies)
    for _ = 1, num_enemies do
        local type = types[math.random(#types)]

        local entity_def = deepcopy(ENTITY_DEFS[type])
        table.extend(entity_def, {
            hitboxes = getHitboxesFromDefinition(entity_def.hitboxes),
            dungeon = self.dungeon
        })
        local entity = Entity(entity_def)

        -- set position
        if not self:placeEntity(entity) then
            entity = nil
            break
        end
        -- every enemy uses the same state machine
        entity.state_machine = StateMachine({
            ['walk'] = function() return EntityWalkState(entity) end,
            ['idle'] = function() return EntityIdleState(entity) end
        })
        -- set initial state
        local entity_state = math.random() < 0.5 and 'idle' or 'walk'
        entity.state_machine:change(entity_state)

        table.insert(self.entities, entity)

        self.num_enemies = self.num_enemies + 1
    end
end

-- This function is called every frame before rendering.
-- Create a sorted render list that is used to draw objects and entities in the render function
function Room:renderListSync()
    self.render_list = {}
    table.extend(self.render_list, self.objects)
    table.extend(self.render_list, self.entities)

    -- Order self.render_list after the y coordinate of the first hitbox (secondary ordering).
    -- Using the hitbox is better than using the y coordinate. E.g. a long pillar has only a hitbox
    -- at the bottom of its sprite and an entity must be drawn behind the pillar if standing above the hitbox.
    self.elem_y_list = {}
    for _, elem in pairs(self.render_list) do
        table.insert(self.elem_y_list, elem.hitboxes[1].y)
    end
    self.render_list, self.elem_y_list = sortStableWithHelperTbl(self.render_list, self.elem_y_list)

    -- Order self.render_list after the render_prio of each element (primary ordering).
    -- The element with the highest render_prio will be last in the list (drawn on top).
    -- The order of the elements with the same render_prio will not be changed (stable sorting algorithm necessary).
    self.render_prio_list = {}
    for _, elem in pairs(self.render_list) do
        table.insert(self.render_prio_list, elem.render_prio)
    end
    self.render_list, self.render_prio_list = sortStableWithHelperTbl(self.render_list, self.render_prio_list)
end

-- update entities and game objects in the room.
function Room:update(dt)
    -- update objects before the entities, so the entities can react to a change in the same frame
    for _, object in pairs(self.objects) do
        object:update(dt)
    end

    -- execute all update stages of entities (see Entity class)
    for _, entity in pairs(self.entities) do
        entity:updateStage1(dt)
    end
    for _, entity in pairs(self.entities) do
        entity:updateStage2(dt)
    end
    for _, entity in pairs(self.entities) do
        entity:updateStage3(dt)
    end

    -- remove entities and objects that have their is_remove member set.
    -- iterate backwards to not skip the element that comes after a removed element
    -- (when removing, all elements after the removed one decrement their index)
    for i = #self.objects, 1, -1 do
        if self.objects[i].is_remove then
            table.remove(self.objects, i)
        end
    end

    for i = #self.entities, 1, -1 do
        if self.entities[i].is_remove then
            if self.entities[i].id ~= ENTITY_ID_PLAYER then
                self.num_enemies = self.num_enemies - 1
                if self.num_enemies <= 0 then
                    Event.dispatch('room-cleared')
                end
            end
            table.remove(self.entities, i)
        end
    end
end

-- render tiles and the objects/ entities inside self.render_list
function Room:render()
    -- Both the current room and the next room have a player reference that gets rendered during a room transition.
    -- But because the next room gets rendered at shift_screen_offset, the player in the next room is constantly rendered off screen.
    -- This is true also when the camera fully moved to the next room, because the player also gets tweened in the direction of the next room.

    -- The current room must be rendered after the next room during a room transition:
    --  -> to not draw the next room over the player.
    --  -> so the stencil functions from the current room and the next room both apply to the player.

    -- stenciled pixels are pixels that have an invisible stencil value. A stencil value gets set with
    -- love.graphics.stencil(stencilfunction, action, value, keepvalues)
    -- stencilfunction: function that draws a geometry with love.graphics.<shape>(). Pixels inside this geometry get the stencil value.
    -- action: here 'replace'. set the stencil value.
    -- value: numeric stencil value to set
    -- keepvalues: if false, set every pixel's stencil value to 0 before executing the stencil function. if true preserve the stencil values.

    -- perform tests on pixels according to their stencil values with love.graphics.setStencilTest(comparemode, comparevalue)
    -- The comparemode ('less', 'greater' or 'equal') specifies the operation to compare the pixel stencil value to the comparevalue.
    -- Only if the operation is true, draw the pixels to the screen.

    -- pixels that are drawn in a stenciled area after love.graphics.stencil() with a stencil value less than 1 are not drawn to the screen.
    -- only objects have a stencilFunction() in this game.
    -- apply stencil values after rendering the object to assign the stencil value 1 to the object pixels.
    -- The stenciled pixels will draw over everything, because things that drawn later are affected by the stenciling and
    -- things that are drawn before are overdrawn by this object anyways.
    -- because keepvalues=true, the stencil values from the next room apply also in the current room.

    self:renderListSync()

    -- start stencil testing
    love.graphics.setStencilTest('less', 1)

    for y = 1, self.grid_height do
        for x = 1, self.grid_width do
            if self.tiles[y][x] then
                self.tiles[y][x]:render(self.shift_screen_offset_x, self.shift_screen_offset_y)
            end
        end
    end

    for _, elem in pairs(self.render_list) do
        elem:render(self.shift_screen_offset_x, self.shift_screen_offset_y)
        if elem.stencilFunction then
            love.graphics.stencil(function()
                elem:stencilFunction(self.shift_screen_offset_x, self.shift_screen_offset_y)
            end, 'replace', 1, true)
        end
    end

    -- disable stencil testing
    love.graphics.setStencilTest()
end
