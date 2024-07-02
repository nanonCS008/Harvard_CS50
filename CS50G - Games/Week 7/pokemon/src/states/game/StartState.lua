--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

StartState = Class{__includes = BaseState}

-- First State after starting the game. A starter Pokemon can be selected by pressing left or right.
-- When pressing 'confirm' a transition to the PlayState will be initiated.
function StartState:init()
    self.id = START_STATE_ID
    gSounds['intro-music']:setLooping(true)
    gSounds['intro-music']:play()

    -- available starter Pokemon
    local starting_lvl = 5
    self.start_pokemon = {
        Pokemon(POKEMON_DEFS[1], starting_lvl),
        Pokemon(POKEMON_DEFS[2], starting_lvl),
        Pokemon(POKEMON_DEFS[3], starting_lvl)
    }
    -- display the front Pokemon battle sprite (initialize position outside of screen)
    for _, pokemon in pairs(self.start_pokemon) do
        pokemon:activateBattleSprite(
            -POKEMON_BATTLE_TEXTURE_SIZE, VIRTUAL_HEIGHT / 2 - POKEMON_BATTLE_TEXTURE_SIZE / 2)
    end
    -- index into self.start_pokemon for the currently selected Pokemon
    self.sel_ind = 1
    -- position to place a Pokemon in the horizontal center of the screen
    self.pokemon_screen_center = VIRTUAL_WIDTH / 2 - POKEMON_BATTLE_TEXTURE_SIZE / 2
    self.start_pokemon[self.sel_ind].battle_sprite.x = self.pokemon_screen_center
    -- as long as the next Pokemon gets tweened in after pressing left or right, disable input
    self.can_input = true
end

-- fade out of the Start state. Pass the selected starter Pokemon to the PlayState
function StartState:transitionPlayState()
    gStateStack:push(FadeState({255/255, 255/255, 255/255, 0/255}, 255/255, 1,
    function()
        gSounds['intro-music']:stop()
        -- pop StartState
        gStateStack:pop()
        gStateStack:push(PlayState(), {pokemon = {self.start_pokemon[self.sel_ind]}})
        gStateStack:push(FadeState({255/255, 255/255, 255/255, 255/255}, 0/255))
    end))
end

function StartState:update(dt)
    if not self.can_input then return end

    if keyboardWasPressed(KEYS_CONFIRM) then
        gSounds['confirm']:play()
        self:transitionPlayState()
    elseif keyboardWasPressed(KEYS_LEFT) then
        self.can_input = false
        gSounds['select']:stop()
        gSounds['select']:play()
        local sel_ind_prev = self.sel_ind
        self.sel_ind = (self.sel_ind - 2) % #self.start_pokemon + 1
        self.start_pokemon[self.sel_ind].battle_sprite.x = VIRTUAL_WIDTH
        Timer.tween(0.2, {
            [self.start_pokemon[sel_ind_prev].battle_sprite] = {x = -POKEMON_BATTLE_TEXTURE_SIZE},
            [self.start_pokemon[self.sel_ind].battle_sprite] = {x = self.pokemon_screen_center}
        }):finish(function() self.can_input = true end)
    elseif keyboardWasPressed(KEYS_RIGHT) then
        self.can_input = false
        gSounds['select']:stop()
        gSounds['select']:play()
        local sel_ind_prev = self.sel_ind
        self.sel_ind = self.sel_ind % #self.start_pokemon + 1
        self.start_pokemon[self.sel_ind].battle_sprite.x = -POKEMON_BATTLE_TEXTURE_SIZE
        Timer.tween(0.2, {
            [self.start_pokemon[sel_ind_prev].battle_sprite] = {x = VIRTUAL_WIDTH},
            [self.start_pokemon[self.sel_ind].battle_sprite] = {x = self.pokemon_screen_center}
        }):finish(function() self.can_input = true end)
    end
end

function StartState:render()
    love.graphics.draw(gTextures['background-title'], 0, 0)

    love.graphics.setColor(24/255, 24/255, 24/255, 255/255)
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf('50Mon!', 0, 16, VIRTUAL_WIDTH, 'center')
    love.graphics.setFont(gFonts['small'])
    love.graphics.printf('Choose your Pokemon', 0, 54, VIRTUAL_WIDTH, 'center')
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Press Enter', 0, VIRTUAL_HEIGHT / 2 + 68, VIRTUAL_WIDTH, 'center')
    love.graphics.setFont(gFonts['small'])

    love.graphics.setColor(255/255, 255/255, 255/255, 255/255)
    love.graphics.draw(gTextures['ui-assets'], gFrames['ui-assets'][FRAME_ID_ARROW_LEFT_SMALL],
        90, VIRTUAL_HEIGHT / 2 - TILE_SIZE)
    love.graphics.draw(gTextures['ui-assets'], gFrames['ui-assets'][FRAME_ID_ARROW_RIGHT_SMALL],
        VIRTUAL_WIDTH - 90, VIRTUAL_HEIGHT / 2 - TILE_SIZE)
    love.graphics.draw(gTextures['battle-ground'],
        VIRTUAL_WIDTH / 2 - gTextures['battle-ground']:getWidth() / 2,
        VIRTUAL_HEIGHT / 2 + POKEMON_BATTLE_TEXTURE_SIZE / 2 - gTextures['battle-ground']:getHeight() / 2)

    for _, pokemon in pairs(self.start_pokemon) do
        pokemon:render()
    end
end
