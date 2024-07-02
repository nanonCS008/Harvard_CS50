--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

StartState = Class{__includes = BaseState}

function StartState:enter()
    -- start music again in case it was stopped from a game over
    gSounds['music']:play()
end

function StartState:update(dt)
    if keyboardWasPressed('escape') then
        love.event.quit()
    elseif keyboardWasPressed(KEYS_CONFIRM) then
        gSounds['confirm']:play()
        gStateMachine:change('play')
    end
end

function StartState:render()
    love.graphics.draw(gTextures['background'], 0, 0, 0,
        VIRTUAL_WIDTH / gTextures['background']:getWidth(),
        VIRTUAL_HEIGHT / gTextures['background']:getHeight())

    love.graphics.setFont(gFonts['zelda'])
    love.graphics.setColor(34/255, 34/255, 34/255, 255/255)
    love.graphics.printf(GAME_TITLE, 2, VIRTUAL_HEIGHT / 2 - 30, VIRTUAL_WIDTH, 'center')

    love.graphics.setColor(175/255, 53/255, 42/255, 255/255)
    love.graphics.printf(GAME_TITLE, 0, VIRTUAL_HEIGHT / 2 - 32, VIRTUAL_WIDTH, 'center')

    love.graphics.setColor(255/255, 255/255, 255/255, 255/255)
    love.graphics.setFont(gFonts['zelda-small'])
    love.graphics.printf('Press Enter', 0, VIRTUAL_HEIGHT / 2 + 64, VIRTUAL_WIDTH, 'center')
end
