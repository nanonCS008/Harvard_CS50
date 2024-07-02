--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Entity definitions file. Data that defines the properties of the entities in the game.
    The data is passed to the Entity Base Class for entity initialization.
]]

ENTITY_DEFS = {
    ['player'] = {
        texture = 'characters',
        width = ENTITY_WIDTH,
        height = ENTITY_HEIGHT,
        animations = {
            ['idle-left'] = {
                frame_ids = {13},
            },
            ['idle-right'] = {
                frame_ids = {19},
            },
            ['idle-up'] = {
                frame_ids = {7},
            },
            ['idle-down'] = {
                frame_ids = {1},
            },
            ['walk-left'] = {
                frame_ids = {14, 13, 15, 13},
                interval = 0.15,
            },
            ['walk-right'] = {
                frame_ids = {20, 19, 21, 19},
                interval = 0.15,
            },
            ['walk-up'] = {
                frame_ids = {8, 7, 9, 7},
                interval = 0.15,
            },
            ['walk-down'] = {
                frame_ids = {2, 1, 3, 1},
                interval = 0.15,
            },
            ['run-left'] = {
                frame_ids = {14, 13, 15, 13},
                interval = 0.1,
            },
            ['run-right'] = {
                frame_ids = {20, 19, 21, 19},
                interval = 0.1,
            },
            ['run-up'] = {
                frame_ids = {8, 7, 9, 7},
                interval = 0.1,
            },
            ['run-down'] = {
                frame_ids = {2, 1, 3, 1},
                interval = 0.1,
            },
            ['jump-left'] = {
                frame_ids = {14},
            },
            ['jump-right'] = {
                frame_ids = {20},
            },
            ['jump-up'] = {
                frame_ids = {8},
            },
            ['jump-down'] = {
                frame_ids = {2},
            }
        }
    },
    ['npc1'] = {
        texture = 'characters',
        width = ENTITY_WIDTH,
        height = ENTITY_HEIGHT,
        animations = {
            ['idle-left'] = {
                frame_ids = {16},
            },
            ['idle-right'] = {
                frame_ids = {22},
            },
            ['idle-up'] = {
                frame_ids = {10},
            },
            ['idle-down'] = {
                frame_ids = {4},
            },
            ['walk-left'] = {
                frame_ids = {17, 16, 18, 16},
                interval = 0.15,
            },
            ['walk-right'] = {
                frame_ids = {23, 22, 24, 22},
                interval = 0.15,
            },
            ['walk-up'] = {
                frame_ids = {11, 10, 12, 10},
                interval = 0.15,
            },
            ['walk-down'] = {
                frame_ids = {5, 4, 6, 4},
                interval = 0.15,
            }
        }
    }
}
