--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Class = require 'lib/class'
Event = require 'lib/knife.event'
push = require 'lib/push'
Timer = require 'lib/knife.timer'
require 'lib/love9slice'
require 'lib/StateMachine'
require 'lib/StateStack'
require 'lib/TableUtil'

require 'src/Animation'
require 'src/BattleSprite'
require 'src/constants'
require 'src/Pokemon'
require 'src/pokemon_defs'
require 'src/Util'

require 'src/entity/entity_defs'
require 'src/entity/Entity'
require 'src/entity/Player'
require 'src/entity/NPC'

require 'src/gui/Panel'
require 'src/gui/ProgressBar'
require 'src/gui/Selection'
require 'src/gui/Textbox'
require 'src/gui/Text'
require 'src/gui/Collection'
require 'src/gui/Graphic'
require 'src/gui/gui_defs'

require 'src/states/BaseState'
require 'src/states/entity/EntityIdleState'
require 'src/states/entity/PlayerIdleState'
require 'src/states/entity/PlayerWalkState'
require 'src/states/entity/PlayerJumpState'

require 'src/states/game/BattleState'
require 'src/states/game/FadeState'
require 'src/states/game/PlayState'
require 'src/states/game/StartState'
require 'src/states/game/TakeTurnState'
require 'src/states/game/GUIState'

GameAreaGenerator = require 'src/world/game_area_defs'
require 'src/world/GameArea'
require 'src/world/Tile'
require 'src/world/tile_defs'

gTextures = {
    ['tiles'] = love.graphics.newImage('graphics/sheet.png'),
    ['characters'] = love.graphics.newImage('graphics/Characters.png'),
    ['background-title'] = love.graphics.newImage('graphics/background_title.png'),
    ['background-battle'] = love.graphics.newImage('graphics/background_battle.png'),
    ['battle-ground'] = love.graphics.newImage('graphics/battle_ground.png'),
    ['panel-default'] = love.graphics.newImage('graphics/panel.png'),
    ['panel-white-border'] = love.graphics.newImage('graphics/panel_white_border.png'),
    ['progress-bar'] = love.graphics.newImage('graphics/progress_bar.png'),
    ['ui-assets'] = love.graphics.newImage('graphics/UIpack.png'),

    ['aardart-back'] = love.graphics.newImage('graphics/pokemon/aardart-back.png'),
    ['aardart-front'] = love.graphics.newImage('graphics/pokemon/aardart-front.png'),
    ['aardart-face'] = love.graphics.newImage('graphics/pokemon/aardart-face.png'),
    ['agnite-back'] = love.graphics.newImage('graphics/pokemon/agnite-back.png'),
    ['agnite-front'] = love.graphics.newImage('graphics/pokemon/agnite-front.png'),
    ['agnite-face'] = love.graphics.newImage('graphics/pokemon/agnite-face.png'),
    ['anoleaf-back'] = love.graphics.newImage('graphics/pokemon/anoleaf-back.png'),
    ['anoleaf-front'] = love.graphics.newImage('graphics/pokemon/anoleaf-front.png'),
    ['anoleaf-face'] = love.graphics.newImage('graphics/pokemon/anoleaf-face.png'),
    ['bamboon-back'] = love.graphics.newImage('graphics/pokemon/bamboon-back.png'),
    ['bamboon-front'] = love.graphics.newImage('graphics/pokemon/bamboon-front.png'),
    ['bamboon-face'] = love.graphics.newImage('graphics/pokemon/bamboon-face.png'),
    ['cardiwing-back'] = love.graphics.newImage('graphics/pokemon/cardiwing-back.png'),
    ['cardiwing-front'] = love.graphics.newImage('graphics/pokemon/cardiwing-front.png'),
    ['cardiwing-face'] = love.graphics.newImage('graphics/pokemon/cardiwing-face.png'),
}

gFrames = {
    ['tiles'] = GenerateQuads(gTextures['tiles'], TILE_SIZE, TILE_SIZE),
    ['characters'] = GenerateQuads(gTextures['characters'], ENTITY_WIDTH, ENTITY_HEIGHT),
    ['ui-assets'] = GenerateQuads(gTextures['ui-assets'], 18, 18, 2)
}

gFonts = {
    ['small'] = love.graphics.newFont('fonts/font.ttf', 8),
    ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
    ['large'] = love.graphics.newFont('fonts/font.ttf', 32)
}

gSounds = {
    ['field-music'] = love.audio.newSource('sounds/field_music.mp3', 'static'),
    ['battle-music'] = love.audio.newSource('sounds/battle_music.mp3', 'static'),
    ['victory-music'] = love.audio.newSource('sounds/victory.mp3', 'static'),
    ['intro-music'] = love.audio.newSource('sounds/intro.mp3', 'static'),
    ['confirm'] = love.audio.newSource('sounds/confirm.wav', 'static'),
    ['select'] = love.audio.newSource('sounds/select.wav', 'static'),
    ['back'] = love.audio.newSource('sounds/back.wav', 'static'),
    ['denied'] = love.audio.newSource('sounds/denied.wav', 'static'),
    ['attack'] = love.audio.newSource('sounds/attack.wav', 'static'),
    ['catch'] = love.audio.newSource('sounds/catch.wav', 'static'),
    ['hit'] = love.audio.newSource('sounds/hit.wav', 'static'),
    ['faint'] = love.audio.newSource('sounds/faint.wav', 'static'),
    ['run'] = love.audio.newSource('sounds/run.mp3', 'static'),
    ['jump'] = love.audio.newSource('sounds/jump.wav', 'static'),
    ['heal'] = love.audio.newSource('sounds/heal.wav', 'static'),
    ['bump'] = love.audio.newSource('sounds/bump.wav', 'static'),
    ['exp'] = love.audio.newSource('sounds/exp.mp3', 'static'),
    ['levelup'] = love.audio.newSource('sounds/levelup.mp3', 'static'),
}
