--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

BattleState = Class{__includes = BaseState}

-- The Battle State is pushed when an encounter with a wild Pokemon was found.
-- There are only battles against wild Pokemon. There are no trainer Pokemon.
function BattleState:init(player)
    self.id = BATTLE_STATE_ID
    self.player = player

    -- Always render this panel to cover up the bottom of the screen.
    -- Battle Textboxes will get rendered over this Panel later.
    self.bottom_panel = Panel({
        x = 0, y = getBattleTextboxDef().y,
        width = VIRTUAL_WIDTH, height = getBattleTextboxDef().height})

    -- Set to true in the first update call. The first update call happens when
    -- the fade in state is popped that was pushed after instantiating this state.
    -- This state must not push additional states on the stack while the fade in is active (e.g. with a timer),
    -- otherwise the stack could be corrupted when when the fade state does a pop operation.
    self.is_state_started = false

    -- The player must always have a Pokemon that is still alive.
    self.player_pokemon = self:getNextPlayerPokemon()
    self.opponent_pokemon = self.player.area:getWildPokemon()

    -- the HUD shows the Pokemon level, HP bar, etc.. It is shown after Pokemon slide in.
    self.player_hud = getPlayerBattleHud(self.player_pokemon)
    self.opponent_hud = getOpponentBattleHud(self.opponent_pokemon)
    self.do_render_hud = false

    -- distance from the screen edge that the Pokemon and the battle grounds are moved during slide in
    self.slide_pos_rel = 64
    -- x position of the battle ground under the Pokemon. Used for slide in.
    self.player_ground_x = - gTextures['battle-ground']:getWidth()
    self.opponent_ground_x = VIRTUAL_WIDTH + gTextures['battle-ground']:getWidth()

    -- place sprite in the horizontal center of the battle ground, so both have the same velocity when sliding in
    self.player_pokemon:activateBattleSprite(
        self.player_ground_x + gTextures['battle-ground']:getWidth() / 2 - POKEMON_BATTLE_TEXTURE_SIZE / 2,
        VIRTUAL_HEIGHT - self.bottom_panel.height - POKEMON_BATTLE_TEXTURE_SIZE, 'back')
    self.opponent_pokemon:activateBattleSprite(
        self.opponent_ground_x + gTextures['battle-ground']:getWidth() / 2 - POKEMON_BATTLE_TEXTURE_SIZE / 2,
        6, 'front')
end

function BattleState:exit()
    gSounds['battle-music']:stop()
    gSounds['field-music']:play()
end

-- return the next Pokemon in the Player party that can fight or nil
function BattleState:getNextPlayerPokemon()
    for i = 1, PARTY_SIZE_MAX do
        if self.player.party[i] and self.player.party[i].hp > 0 then
            return self.player.party[i]
        end
    end
    return nil
end

-- party_i: index in the player party table
-- return true if the currently fighting Pokemon can be switched with a Pokemon in the Player party.
function BattleState:canSwitchPlayerPokemon(party_i)
    if self.player.party[party_i] and self.player.party[party_i] ~= self.player_pokemon and
        self.player.party[party_i].hp > 0
    then
        return true
    end
    return false
end

-- party_i: index in the player party table
-- slide in a new player Pokemon from his party. This is used on switch Pokemon or after Pokemon faint.
function BattleState:slideInPlayerPokemon(party_i)
    self.player_pokemon = self.player.party[party_i]
    self.player_hud = getPlayerBattleHud(self.player_pokemon)
    self.player_pokemon:activateBattleSprite(-POKEMON_BATTLE_TEXTURE_SIZE,
        VIRTUAL_HEIGHT - self.bottom_panel.height - POKEMON_BATTLE_TEXTURE_SIZE, 'back')
    Timer.tween(1, {
        [self.player_pokemon.battle_sprite] = {x = self.slide_pos_rel - POKEMON_BATTLE_TEXTURE_SIZE / 2}
    })
    :finish(function()
        gStateStack:push(getBattleTextboxState('Go, ' .. self.player_pokemon.name .. '!',
        function()
            gStateStack:push(getBattleMenuState(self))
        end))
    end)
end

-- party_i: index in the player party table
-- Switch currently fighting Pokemon with a Pokemon in the Player party. Switching Pokemon does not take a turn.
function BattleState:switchPlayerPokemon(party_i)
    if not self:canSwitchPlayerPokemon(party_i) then return end

    gStateStack:push(getBattleTextboxState('Come back ' .. self.player_pokemon.name .. '!', nil, false))
    Timer.after(1.5, function()
        Timer.tween(1, {
            [self.player_pokemon.battle_sprite] = {x = -POKEMON_BATTLE_TEXTURE_SIZE}
        })
        :finish(function()
            -- pop Textbox state
            gStateStack:pop()
            self:slideInPlayerPokemon(party_i)
        end)
    end)
end

-- Slide in player/ opponent Pokemon and battle ground at the start of the battle.
-- The Pokemon will be introduced with messages and a battle menu will show that the player can navigate in.
function BattleState:slideIn()
    Timer.tween(1, {
        [self.player_pokemon.battle_sprite] = {x = self.slide_pos_rel - POKEMON_BATTLE_TEXTURE_SIZE / 2},
        [self.opponent_pokemon.battle_sprite] =
            {x = VIRTUAL_WIDTH - self.slide_pos_rel - POKEMON_BATTLE_TEXTURE_SIZE / 2},
        [self] = {
            player_ground_x = self.slide_pos_rel - gTextures['battle-ground']:getWidth() / 2,
            opponent_ground_x = VIRTUAL_WIDTH - self.slide_pos_rel - gTextures['battle-ground']:getWidth() / 2
        }
    })
    :finish(function()
        self.do_render_hud = true
        gStateStack:push(getBattleTextboxState('A wild ' .. self.opponent_pokemon.name .. ' appeared!',
        function()
            gStateStack:push(getBattleTextboxState('Go, ' .. self.player_pokemon.name .. '!',
            function()
                gStateStack:push(getBattleMenuState(self))
            end))
        end))
    end)
end

function BattleState:update(dt)
    -- This will be executed only one time after BattleState is on top of the stack
    if not self.is_state_started then
        self.is_state_started = true
        self:slideIn()
    end
end

function BattleState:render()
    love.graphics.setColor(255/255, 255/255, 255/255, 255/255)
    love.graphics.draw(gTextures['background-battle'], 0, 0)

    love.graphics.draw(gTextures['battle-ground'], self.player_ground_x,
        VIRTUAL_HEIGHT - self.bottom_panel.height - gTextures['battle-ground']:getHeight() / 2)
    love.graphics.draw(gTextures['battle-ground'], self.opponent_ground_x,
        POKEMON_BATTLE_TEXTURE_SIZE - gTextures['battle-ground']:getHeight() / 2)

    self.player_pokemon:render()
    self.opponent_pokemon:render()

    if self.do_render_hud then
        self.player_hud:render()
        self.opponent_hud:render()
    end

    self.bottom_panel:render()
end
