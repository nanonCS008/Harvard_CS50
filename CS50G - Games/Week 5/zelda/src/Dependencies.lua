
Class = require 'lib/class'
Event = require 'lib/knife.event'
push = require 'lib/push'
Timer = require 'lib/knife.timer'
require 'lib/StateMachine'
require 'lib/Rect'
require 'lib/TableUtil'

require 'src/Animation'
require 'src/constants'
require 'src/Entity'
require 'src/entity_defs'
require 'src/GameObject'
require 'src/game_object_defs'
require 'src/Player'
require 'src/Util'

require 'src/world/Doorway'
require 'src/world/Dungeon'
require 'src/world/Room'

require 'src/states/BaseState'

require 'src/states/entity/EntityIdleState'
require 'src/states/entity/EntityWalkState'

require 'src/states/entity/player/PlayerGameOverState'
require 'src/states/entity/player/PlayerIdleState'
require 'src/states/entity/player/PlayerWalkState'
require 'src/states/entity/player/PlayerSwingSwordState'
require 'src/states/entity/player/PlayerGrabState'
require 'src/states/entity/player/PlayerCarryIdleState'
require 'src/states/entity/player/PlayerCarryWalkState'

require 'src/states/game/GameOverState'
require 'src/states/game/PlayState'
require 'src/states/game/StartState'

gTextures = {
    ['tiles'] = love.graphics.newImage('graphics/tilesheet.png'),
    ['background'] = love.graphics.newImage('graphics/background.png'),
    ['character-walk'] = love.graphics.newImage('graphics/character_walk.png'),
    ['character-swing-sword'] = love.graphics.newImage('graphics/character_swing_sword.png'),
    ['character-lift'] = love.graphics.newImage('graphics/character_lift.png'),
    ['character-carry-walk'] = love.graphics.newImage('graphics/character_carry_walk.png'),
    ['hearts'] = love.graphics.newImage('graphics/hearts.png'),
    ['switches'] = love.graphics.newImage('graphics/switches.png'),
    ['creatures'] = love.graphics.newImage('graphics/creatures.png')
}

gFrames = {
    ['tiles'] = GenerateQuads(gTextures['tiles'], TILE_SIZE, TILE_SIZE),
    ['character-walk'] = GenerateQuads(gTextures['character-walk'], 16, 32),
    ['character-swing-sword'] = GenerateQuads(gTextures['character-swing-sword'], 32, 32),
    ['character-lift'] = GenerateQuads(gTextures['character-lift'], 16, 32),
    ['character-carry-walk'] = GenerateQuads(gTextures['character-carry-walk'], 16, 32),
    ['creatures'] = GenerateQuads(gTextures['creatures'], CREATURE_SIZE, CREATURE_SIZE),
    ['hearts'] = GenerateQuads(gTextures['hearts'], TILE_SIZE, TILE_SIZE),
    ['switches'] = GenerateQuads(gTextures['switches'], 16, 18)
}

gFonts = {
    ['small'] = love.graphics.newFont('fonts/font.ttf', 8),
    ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
    ['large'] = love.graphics.newFont('fonts/font.ttf', 32),
    ['gothic-medium'] = love.graphics.newFont('fonts/GothicPixels.ttf', 16),
    ['gothic-large'] = love.graphics.newFont('fonts/GothicPixels.ttf', 32),
    ['zelda'] = love.graphics.newFont('fonts/zelda.otf', 64),
    ['zelda-small'] = love.graphics.newFont('fonts/zelda.otf', 32)
}

gSounds = {
    ['music'] = love.audio.newSource('sounds/music.mp3', 'static'), -- https://www.dl-sounds.com/royalty-free/dungeon-master/
    ['confirm'] = love.audio.newSource('sounds/confirm.wav', 'static'),
    ['back'] = love.audio.newSource('sounds/back.wav', 'static'),
    ['sword'] = love.audio.newSource('sounds/sword.wav', 'static'),
    ['enemy-hit'] = love.audio.newSource('sounds/enemy_hit.wav', 'static'),
    ['player-hit'] = love.audio.newSource('sounds/player_hit.wav', 'static'),
    ['player-death'] = love.audio.newSource('sounds/player_death.wav', 'static'),
    ['player-victory'] = love.audio.newSource('sounds/player_victory.wav', 'static'),
    ['player-lift'] = love.audio.newSource('sounds/player_lift.wav', 'static'),
    ['heart-pickup'] = love.audio.newSource('sounds/heart_pickup.mp3', 'static'),  -- https://www.zapsplat.com/music/game-tone-positive-action-level-up-gain-life-etc-22/
    ['pot-break'] = love.audio.newSource('sounds/pot_break.mp3', 'static'),
    ['door'] = love.audio.newSource('sounds/door.wav', 'static'),
    ['victory'] = love.audio.newSource('sounds/victory.wav', 'static'),
    ['defeat'] = love.audio.newSource('sounds/defeat.mp3', 'static')  -- https://www.zapsplat.com/music/8-bit-game-over-80s-arcade-simple-alert-notification-for-game-2/
}
