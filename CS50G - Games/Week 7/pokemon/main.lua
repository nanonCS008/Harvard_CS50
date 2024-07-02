--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Few franchises have achieved the degree of fame as Pokemon, short for "Pocket Monsters",
    a Japanese monster-catching phenomenon that took the world by storm in the late 90s. Even
    to this day, Pokemon is hugely successful, with games, movies, and various other forms of
    merchandise selling like crazy. The game formula itself is an addicting take on the JRPG,
    where the player can not only fight random creatures in the wild but also recruit them to
    be in his or her party at all times, where they can level up, learn new abilities, and even
    evolve.

    This proof of concept demonstrates basic GUI usage, random encounters, creatures that the
    player can fight and catch with their own creatures, and basic NPC interaction in the form of
    simple dialogue.

    Art:
        Tile sprites: https://opengameart.org/users/buch
        Player Character: https://opengameart.org/users/isaiah658
    Pokemon sprites:
        Aardart: https://wiki.tuxemon.org/index.php?title=Aardart
        Agnite: https://wiki.tuxemon.org/index.php?title=Agnite
        Anoleaf: https://wiki.tuxemon.org/index.php?title=Anoleaf
        Bamboon: https://wiki.tuxemon.org/index.php?title=Bamboon
        Cardiwing: https://wiki.tuxemon.org/index.php?title=Cardiwing
    Music:
        Field: https://freesound.org/people/tyops/sounds/341729/
        Battle: https://freesound.org/people/Sirkoto51/sounds/414214/
]]

require 'src/Dependencies'

local keys_pressed = {}

function love.load()
    love.window.setTitle('50Mon')
    love.graphics.setDefaultFilter('nearest', 'nearest')
    math.randomseed(os.time())

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })

    -- Use a State Stack to represent the Game State instead of a single State Machine.
    -- By default all states are rendered and only the state at the top (last pushed) is updated,
    -- but it would be possible to implement multiple state updating functionality with simple modifications.
	-- There are different behaviors that a state can have on the stack:
    -- 	1. Push the state and allow input. The state gets popped when it is closed by the player.
    --  The clean up is handled by the state itself.
    -- 	2. Push the state and don't allow input. The state gets popped after a Timer that gets started outside of
    --  the State class. The cleanup is done by the Timer finish function.
    --  3. After the state is pushed, there will be a timer inside the state that pops itself and does the cleanup.
    gStateStack = StateStack()
    gStateStack:push(StartState())

    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    if love.keyboard.isDown('lalt') and key == 'return' then
        push:switchFullscreen()
        return
    elseif key == 'escape' then
        if gStateStack.states[1].id == START_STATE_ID then
            love.event.quit()
        else
            -- go back to the start state
            for _, sound in pairs(gSounds) do
                sound:stop()
            end
            gSounds['back']:play()
            Timer.clear()
            gStateStack:clear()
            gStateStack:push(StartState())
        end
    end
    keys_pressed[key] = true
end

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

function love.update(dt)
    dt = math.min(dt, 0.07)
    Timer.update(dt)
    gStateStack:update(dt)

    keys_pressed = {}
end

function love.draw()
    push:start()
    gStateStack:render()
    push:finish()
end
