--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Entity definitions file. Data that defines the properties of the entities in the game.
    The data is passed to the Entity Base Class for entity initialization.
]]

ENTITY_DEFS = {
    ['player'] = {
        id = ENTITY_ID_PLAYER,
        width = PLAYER_WIDTH,
        height = PLAYER_HEIGHT,
        max_health = 6,     -- 3 hearts
        move_speed = PLAYER_WALK_SPEED,
        hit_sound = 'player-hit',
        hitboxes = {
            {
                x_offset = 0,
                y_offset = PLAYER_HEIGHT / 2,
                width = PLAYER_WIDTH,
                height = PLAYER_HEIGHT / 2,
                takes_damage = true,
            }
        },
        animations = {
            ['walk-left'] = {
                frame_ids = {13, 14, 15, 16},
                interval = 0.15,
                texture = 'character-walk'
            },
            ['walk-right'] = {
                frame_ids = {5, 6, 7, 8},
                interval = 0.15,
                texture = 'character-walk'
            },
            ['walk-up'] = {
                frame_ids = {9, 10, 11, 12},
                interval = 0.15,
                texture = 'character-walk'
            },
            ['walk-down'] = {
                frame_ids = {1, 2, 3, 4},
                interval = 0.15,
                texture = 'character-walk'
            },
            ['idle-left'] = {
                frame_ids = {13},
                texture = 'character-walk'
            },
            ['idle-right'] = {
                frame_ids = {5},
                texture = 'character-walk'
            },
            ['idle-up'] = {
                frame_ids = {9},
                texture = 'character-walk'
            },
            ['idle-down'] = {
                frame_ids = {1},
                texture = 'character-walk'
            },
            ['sword-left'] = {
                frame_ids = {13, 14, 15, 16},
                interval = 0.05,
                looping = false,
                texture = 'character-swing-sword'
            },
            ['sword-right'] = {
                frame_ids = {9, 10, 11, 12},
                interval = 0.05,
                looping = false,
                texture = 'character-swing-sword'
            },
            ['sword-up'] = {
                frame_ids = {5, 6, 7, 8},
                interval = 0.05,
                looping = false,
                texture = 'character-swing-sword'
            },
            ['sword-down'] = {
                frame_ids = {1, 2, 3, 4},
                interval = 0.05,
                looping = false,
                texture = 'character-swing-sword'
            },
            ['grab-left'] = {
                frame_ids = {10, 11, 12},
                interval = 0.1,
                looping = false,
                texture = 'character-lift'
            },
            ['grab-right'] = {
                frame_ids = {4, 5, 6},
                interval = 0.1,
                looping = false,
                texture = 'character-lift'
            },
            ['grab-up'] = {
                frame_ids = {7, 8, 9},
                interval = 0.1,
                looping = false,
                texture = 'character-lift'
            },
            ['grab-down'] = {
                frame_ids = {1, 2, 3},
                interval = 0.1,
                looping = false,
                texture = 'character-lift'
            },
            ['carry-walk-left'] = {
                frame_ids = {13, 14, 15, 16},
                interval = 0.15,
                texture = 'character-carry-walk'
            },
            ['carry-walk-right'] = {
                frame_ids = {5, 6, 7, 8},
                interval = 0.15,
                texture = 'character-carry-walk'
            },
            ['carry-walk-up'] = {
                frame_ids = {9, 10, 11, 12},
                interval = 0.15,
                texture = 'character-carry-walk'
            },
            ['carry-walk-down'] = {
                frame_ids = {1, 2, 3, 4},
                interval = 0.15,
                texture = 'character-carry-walk'
            },
            ['carry-idle-left'] = {
                frame_ids = {13},
                texture = 'character-carry-walk'
            },
            ['carry-idle-right'] = {
                frame_ids = {5},
                texture = 'character-carry-walk'
            },
            ['carry-idle-up'] = {
                frame_ids = {9},
                texture = 'character-carry-walk'
            },
            ['carry-idle-down'] = {
                frame_ids = {1},
                texture = 'character-carry-walk'
            },
            ['victory'] = {
                frame_ids = {3},
                looping = false,
                texture = 'character-lift'
            },
            ['death'] = {
                frame_ids = {2},
                looping = false,
                texture = 'character-lift'
            }
        }
    },
    ['skeleton'] = {
        texture = 'creatures',
        move_speed = CREATURE_MOVE_SPEED,
        width = CREATURE_SIZE,
        height = CREATURE_SIZE,
        max_health = 2,
        hitboxes = {
            {
                x_offset = 3,
                y_offset = CREATURE_SIZE / 2,
                width = CREATURE_SIZE - 6,
                height = CREATURE_SIZE / 2,
                takes_damage = true,
                deals_damage = true,
                damage = 1
            }
        },
        animations = {
            ['walk-left'] = {
                frame_ids = {22, 23, 24, 23},
                interval = 0.2
            },
            ['walk-right'] = {
                frame_ids = {34, 35, 36, 35},
                interval = 0.2
            },
            ['walk-up'] = {
                frame_ids = {46, 47, 48, 47},
                interval = 0.2
            },
            ['walk-down'] = {
                frame_ids = {10, 11, 12, 11},
                interval = 0.2
            },
            ['idle-left'] = {
                frame_ids = {23}
            },
            ['idle-right'] = {
                frame_ids = {35}
            },
            ['idle-up'] = {
                frame_ids = {47}
            },
            ['idle-down'] = {
                frame_ids = {11}
            }
        }
    },
    ['slime'] = {
        texture = 'creatures',
        move_speed = CREATURE_SLIME_MOVE_SPEED,
        width = CREATURE_SIZE,
        height = CREATURE_SIZE,
        max_health = 1,
        hitboxes = {
            {
                x_offset = 0,
                y_offset = CREATURE_SIZE / 2,
                width = CREATURE_SIZE,
                height = CREATURE_SIZE / 2,
                takes_damage = true,
                deals_damage = true,
                damage = 1
            }
        },
        animations = {
            ['walk-left'] = {
                frame_ids = {61, 62, 63, 62},
                interval = 0.2
            },
            ['walk-right'] = {
                frame_ids = {73, 74, 75, 74},
                interval = 0.2
            },
            ['walk-up'] = {
                frame_ids = {86, 86, 87, 86},
                interval = 0.2
            },
            ['walk-down'] = {
                frame_ids = {49, 50, 51, 50},
                interval = 0.2
            },
            ['idle-left'] = {
                frame_ids = {62}
            },
            ['idle-right'] = {
                frame_ids = {74}
            },
            ['idle-up'] = {
                frame_ids = {86}
            },
            ['idle-down'] = {
                frame_ids = {50}
            }
        }
    },
    ['bat'] = {
        texture = 'creatures',
        move_speed = CREATURE_BAT_MOVE_SPEED,
        width = CREATURE_SIZE,
        height = CREATURE_SIZE,
        max_health = 1,
        hitboxes = {
            {
                x_offset = 2,
                y_offset = CREATURE_SIZE / 2,
                width = CREATURE_SIZE - 4,
                height = CREATURE_SIZE / 2,
                takes_damage = true,
                deals_damage = true,
                damage = 1
            }
        },
        animations = {
            ['walk-left'] = {
                frame_ids = {64, 65, 66, 65},
                interval = 0.2
            },
            ['walk-right'] = {
                frame_ids = {76, 77, 78, 77},
                interval = 0.2
            },
            ['walk-down'] = {
                frame_ids = {52, 53, 54, 53},
                interval = 0.2
            },
            ['walk-up'] = {
                frame_ids = {88, 89, 90, 89},
                interval = 0.2
            },
            ['idle-left'] = {
                frame_ids = {64, 65, 66, 65},
                interval = 0.2
            },
            ['idle-right'] = {
                frame_ids = {76, 77, 78, 77},
                interval = 0.2
            },
            ['idle-down'] = {
                frame_ids = {52, 53, 54, 53},
                interval = 0.2
            },
            ['idle-up'] = {
                frame_ids = {88, 89, 90, 89},
                interval = 0.2
            }
        }
    },
    ['ghost'] = {
        texture = 'creatures',
        move_speed = CREATURE_MOVE_SPEED,
        width = CREATURE_SIZE,
        height = CREATURE_SIZE,
        max_health = 1,
        hitboxes = {
            {
                x_offset = 2,
                y_offset = CREATURE_SIZE / 2,
                width = CREATURE_SIZE - 4,
                height = CREATURE_SIZE / 2,
                takes_damage = true,
                deals_damage = true,
                damage = 1
            }
        },
        animations = {
            ['walk-left'] = {
                frame_ids = {67, 68, 69, 68},
                interval = 0.2
            },
            ['walk-right'] = {
                frame_ids = {79, 80, 81, 80},
                interval = 0.2
            },
            ['walk-up'] = {
                frame_ids = {91, 92, 93, 92},
                interval = 0.2
            },
            ['walk-down'] = {
                frame_ids = {55, 56, 57, 56},
                interval = 0.2
            },
            ['idle-left'] = {
                frame_ids = {68}
            },
            ['idle-right'] = {
                frame_ids = {80}
            },
            ['idle-up'] = {
                frame_ids = {92}
            },
            ['idle-down'] = {
                frame_ids = {56}
            }
        }
    },
    ['spider'] = {
        texture = 'creatures',
        move_speed = CREATURE_MOVE_SPEED,
        width = CREATURE_SIZE,
        height = CREATURE_SIZE,
        max_health = 1,
        hitboxes = {
            {
                x_offset = 2,
                y_offset = 7,
                width = CREATURE_SIZE - 4,
                height = CREATURE_SIZE - 7,
                takes_damage = true,
                deals_damage = true,
                damage = 2
            }
        },
        animations = {
            ['walk-left'] = {
                frame_ids = {70, 71, 72, 71},
                interval = 0.2
            },
            ['walk-right'] = {
                frame_ids = {82, 83, 84, 83},
                interval = 0.2
            },
            ['walk-up'] = {
                frame_ids = {94, 95, 96, 95},
                interval = 0.2
            },
            ['walk-down'] = {
                frame_ids = {58, 59, 60, 59},
                interval = 0.2
            },
            ['idle-left'] = {
                frame_ids = {71}
            },
            ['idle-right'] = {
                frame_ids = {83}
            },
            ['idle-up'] = {
                frame_ids = {95}
            },
            ['idle-down'] = {
                frame_ids = {59}
            }
        }
    }
}
