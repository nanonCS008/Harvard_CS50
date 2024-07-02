--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GameOverState = Class{__includes = BaseState}

-- The Game Over Screen can display either a Victory or Defeat Text
function GameOverState:enter(params)
    self.game_over_text = ""
    if params and params == 'victory' then
        self.game_over_text = "VICTORY"
    else
        self.game_over_text = "YOU DIED"
    end
end

function GameOverState:update(dt)
    if keyboardWasPressed('escape') then
        love.event.quit()
    elseif keyboardWasPressed(KEYS_CONFIRM) then
        gSounds['confirm']:play()
        gStateMachine:change('start')
    end
end

function GameOverState:render()
    love.graphics.setFont(gFonts['zelda'])
    love.graphics.setColor(175/255, 53/255, 42/255, 255/255)
    love.graphics.printf(self.game_over_text, 0, VIRTUAL_HEIGHT / 2 - 48, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(gFonts['zelda-small'])
    love.graphics.printf('Press Enter', 0, VIRTUAL_HEIGHT / 2 + 16, VIRTUAL_WIDTH, 'center')
    love.graphics.setColor(255/255, 255/255, 255/255, 255/255)
end
