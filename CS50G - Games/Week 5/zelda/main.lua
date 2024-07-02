--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Top down Action-Adventure game in the style of the first Zelda.
    The Player spawns in a Dungeon with randomly generated Rooms.
    The Player can Attack with a Sword, lift and throw Pots and open doors through switches.
    If all Enemies in every room were defeated, the Player has won.
]]

require 'src/Dependencies'

local keys_pressed = {}

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setFont(gFonts['small'])
    love.window.setTitle(GAME_TITLE)

    math.randomseed(os.time())

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })

    gStateMachine = StateMachine {
        ['start'] = function() return StartState() end,
        ['play'] = function() return PlayState() end,
        ['game-over'] = function() return GameOverState() end
    }
    gStateMachine:change('start')

    gSounds['music']:setLooping(true)
    gSounds['music']:setVolume(0.7)
    gSounds['music']:play()
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    if love.keyboard.isDown('lalt') and key == 'return' then
        push:switchFullscreen()
        return
    end
    keys_pressed[key] = true
end

-- if the input is multiple keys in a table, return true if any of the keys was pressed
function keyboardWasPressed(key)
    if type(key) == 'table' then
        for _, v in pairs(key) do
            if keys_pressed[v] then
                return true
            end
        end
    else
        return keys_pressed[key]
    end
    return false
end

function getKeysPressed()
    return keys_pressed
end

function love.update(dt)
    -- limit dt
    dt = math.min(dt, 0.07)

    gStateMachine:update(dt)

    keys_pressed = {}
end

function love.draw()
    push:start()
    gStateMachine:render()
    push:finish()
end
