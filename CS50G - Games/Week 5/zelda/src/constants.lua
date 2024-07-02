--[[
    GD50
    Legend of Zelda

    -- constants --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

-- starting window size
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- resolution to emulate with push
VIRTUAL_WIDTH = 384
VIRTUAL_HEIGHT = 216

GAME_TITLE = 'Legend of 50'

-- if true, make hitboxes visible
-- IS_DEBUG = true
IS_DEBUG = false

-- global tile size
-- the game world consists out of a grid of regular-shaped images called tiles.
-- the tile size for this game is 16 x 16. Most of the game objects are exactly this size.
TILE_SIZE = 16

-- all creature sprites are tile sized
CREATURE_SIZE = TILE_SIZE

-- player sprite dimensions
PLAYER_HEIGHT = 22
PLAYER_WIDTH = TILE_SIZE

-- Gravity in pixel per second per second.
-- Gravity applies if an object is falling to the ground (if thrown)
GRAVITY = 370

-- move speed in pixel per second
PLAYER_WALK_SPEED = 60
CREATURE_MOVE_SPEED = 20    -- default value
CREATURE_SLIME_MOVE_SPEED = 10
CREATURE_BAT_MOVE_SPEED = 30
-- probability for an enemy to drop a heart when killed
CREATURE_HEART_DROP_P = 0.08

-- Render Priority constants. Used to define the render order.
-- used for objects on the floor.
RENDER_PRIO_1 = 1
-- used for entities/ larger objects.
RENDER_PRIO_2 = 2
-- used for objects that are above the head.
RENDER_PRIO_3 = 3

-- player controls
KEYS_CONFIRM = {'e', 'kp1', 'return'}
KEYS_ATTACK = {'space', 'kp2'}      -- swing the sword
KEYS_GRAB = {'e', 'kp1'}            -- lift up a pot
KEYS_PAUSE = {'p', 'kp-'}           -- pause the game
KEYS_LEFT = {'left', 'a'}           -- movement
KEYS_RIGHT = {'right', 'd'}
KEYS_UP = {'up', 'w'}
KEYS_DOWN = {'down', 's'}

-- an entity goes invulnerable if hit by something. The entity sprite will then render as flashing.
INVULNERABILITY_DURATION = 1.5          -- in seconds
INVULNERABILITY_FLASH_PERIOD = 0.06     -- in seconds

-- entity ID's. Used to differentiate Entities
-- only needed here to differentiate between player and enemies
ENTITY_ID_PLAYER = 1

-- object ID's. Used to differentiate objects
OBJECT_ID_GROUND = 101
OBJECT_ID_WALL = 102
OBJECT_ID_DOOR = 103
OBJECT_ID_SWITCH = 104
OBJECT_ID_STATUE = 105
OBJECT_ID_HEART = 106
OBJECT_ID_POT = 107

-- Dimensions of every Room in Tiles
-- leave 1 TILE_SIZE margin from the screen edges for rendering the room
ROOM_GRID_WIDTH = math.floor(VIRTUAL_WIDTH / TILE_SIZE) - 2
ROOM_GRID_HEIGHT = math.floor(VIRTUAL_HEIGHT / TILE_SIZE) - 2

-- calculate the room offset to the screen edges from its width and height,
-- so it can be rendered in the center
ROOM_OFFSET_X = (VIRTUAL_WIDTH - (ROOM_GRID_WIDTH * TILE_SIZE)) / 2
ROOM_OFFSET_Y = (VIRTUAL_HEIGHT - (ROOM_GRID_HEIGHT * TILE_SIZE)) / 2

-- tile frame ID's. They are used as an index in a corresponding gFrames table to get the desired quad.
-- other entity and object frame ID's are stored in the data definition files
-- walls. There are 4 different wall sprites for every direction a wall can face
TILE_FRAME_IDS_WALL_FACE_S = {40, 58, 59, 60}
TILE_FRAME_IDS_WALL_FACE_N = {2, 79, 80, 81}
TILE_FRAME_IDS_WALL_FACE_E = {22, 77, 96, 115}
TILE_FRAME_IDS_WALL_FACE_W = {20, 78, 97, 116}

-- wall corners
TILE_FRAME_ID_TOP_LEFT_INNER_CORNER = 4
TILE_FRAME_ID_TOP_RIGHT_INNER_CORNER = 5
TILE_FRAME_ID_BOTTOM_LEFT_INNER_CORNER = 23
TILE_FRAME_ID_BOTTOM_RIGHT_INNER_CORNER = 24

TILE_FRAME_ID_TOP_LEFT_OUTER_CORNER = 1
TILE_FRAME_ID_TOP_RIGHT_OUTER_CORNER = 3
TILE_FRAME_ID_BOTTOM_LEFT_OUTER_CORNER = 39
TILE_FRAME_ID_BOTTOM_RIGHT_OUTER_CORNER = 41

TILE_FRAME_ID_EMPTY = 19

-- different types of floor sprites
TILE_FRAME_IDS_FLOOR = {
    7, 8, 9, 10, 11, 12, 13,
    26, 27, 28, 29, 30, 31, 32,
    45, 46, 47, 48, 49, 50, 51,
    64, 65, 66, 67, 68, 69, 70,
    88, 89, 107, 108
}
