--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

TakeTurnState = Class{__includes = BaseState}

-- The TakeTurnState starts after the player selected a Pokemon attack.
-- The state handles playing the attack sequence of both fighting Pokemon.
-- battle_state: reference to the BattleState object
-- player_attack: reference to the attack selected by the player. An attack is a table defined in pokemon_defs.lua
function TakeTurnState:init(battle_state, player_attack)
    self.id = TAKE_TURN_STATE_ID
    self.battle_state = battle_state
    self.player_pokemon = self.battle_state.player_pokemon
    self.opponent_pokemon = self.battle_state.opponent_pokemon

    -- Pick a random attack for the opponent.
    -- Ensure that the attack list is not longer than POKEMON_ATTACK_NUM_MAX and does not contain nil values.
    local opponent_attacks = {}
    for i = 1, POKEMON_ATTACK_NUM_MAX do
        if self.opponent_pokemon.attacks[i] then
            table.insert(opponent_attacks, self.opponent_pokemon.attacks[i])
        end
    end
    local opponent_attack = opponent_attacks[math.random(#opponent_attacks)]

    -- Sort Pokemon and their attacks. The Pokemon with the higher speed attacks first
    local ordered_pokemon = self.player_pokemon.speed > self.opponent_pokemon.speed and
        {self.player_pokemon, self.opponent_pokemon} or {self.opponent_pokemon, self.player_pokemon}
    local ordered_attacks = ordered_pokemon[1] == self.player_pokemon and
        {player_attack, opponent_attack} or {opponent_attack, player_attack}

    self:attack(ordered_pokemon[1], ordered_pokemon[2], ordered_attacks[1],
    function()
        self:attack(ordered_pokemon[2], ordered_pokemon[1], ordered_attacks[2],
        function()
            -- pop TakeTurnState
            gStateStack:pop()
            gStateStack:push(getBattleMenuState(self.battle_state))
        end)
    end)
end

-- Play attack sequence of a Pokemon
-- attacker, defender: attacking/ defending Pokemon
-- attack: attack of the attacker
-- onComplete is called after the attack finished and if no Pokemon died
function TakeTurnState:attack(attacker, defender, attack, onComplete)
    -- Attack Animation:
    -- First, the attacker sprite blinks white a number of times. A hit sound is played and the defender
    -- blinks by changing the sprite alpha value a number of times.
    -- The blink number is the number of changes in the blink value (blink cycles will be half the value).
    -- After that the HP bar is tweened according to the damage. If a Pokemon fainted, further Animations will play.
    local pokemon_blink_num = 6

    gStateStack:push(getBattleTextboxState(attacker.name .. ' uses ' .. attack.name .. '!', nil, false))
    Timer.after(0.5, function()
        gSounds['attack']:play()
        Timer.every(0.1, function()
            attacker.battle_sprite.is_blinking = not attacker.battle_sprite.is_blinking
        end)
        :limit(pokemon_blink_num)
        :finish(function()
            gSounds['hit']:play()
            Timer.every(0.1, function()
                defender.battle_sprite.alpha = defender.battle_sprite.alpha == 64/255 and 255/255 or 64/255
            end)
            :limit(pokemon_blink_num)
            :finish(function()
                -- the damage formula was taken from https://bulbapedia.bulbagarden.net/wiki/Damage
                local random = math.random(85, 100) / 100
                local dmg = ((2 * attacker.level / 5 + 2) * (attack.strength / 50) *
                    (attacker.attack / defender.defense) + 2) * random
                -- round to the nearest integer number
                dmg = math.floor(dmg + 0.5)

                local hp_new = defender.hp - dmg
                local dmg_overshoot = math.abs(hp_new < 0 and hp_new or 0)
                -- When changing the Pokemon HP, the HP bar will change automatically (see ProgressBar Class).
                -- The HP bar tween speed shall be the same for any amount of damage.
                -- The tween time for the full bar is constant.
                local full_bar_tween_time = 3
                local bar_tween_time = full_bar_tween_time * (dmg - dmg_overshoot) / defender.hp_max

                Timer.tween(bar_tween_time, {
                    [defender] = {hp = math.max(0, hp_new)},
                }):finish(function()
                    -- pop attack message in BattleTextboxState
                    gStateStack:pop()
                    if defender.hp <= 0 then
                        gSounds['faint']:play()
                        -- pop TakeTurnState
                        gStateStack:pop()
                        if defender == self.player_pokemon then
                            self:faint()
                        else
                            self:victory()
                        end
                    else
                        onComplete()
                    end
                end)
            end)
        end)
    end)
end

-- called when player Pokemon fainted
function TakeTurnState:faint()
    -- Tween the player Pokemon sprite below the screen.
    -- When the player still has Pokemon that can fight, open the Party Menu so he can select the next Pokemon.
    Timer.tween(0.2, {
        [self.player_pokemon.battle_sprite] = {y = VIRTUAL_HEIGHT}
    })
    :finish(function()
        gStateStack:push(getBattleTextboxState(self.player_pokemon.name .. ' fainted!',
        function()
            if self.battle_state:getNextPlayerPokemon() then
                local onSelect = getPartyMenuBattleFaintedOnSelect(self.battle_state)
                local onBack = getPartyMenuBattleFaintedOnBack()
                gStateStack:push(getPartyMenuState(self.battle_state.player.party, onSelect, onBack))
            else
                gStateStack:push(getBattleTextboxState('All your Pokemon are K.O.. You fainted!',
                function()
                    self:fadeOutFaint()
                end))
            end
        end))
    end)
end

-- called when opponent Pokemon fainted
function TakeTurnState:victory()
    -- Tween the opponent Pokemon sprite below the screen.
    Timer.tween(0.2, {
        [self.opponent_pokemon.battle_sprite] = {y = VIRTUAL_HEIGHT}
    })
    :finish(function()
        gSounds['battle-music']:stop()
        gSounds['victory-music']:play()
        gStateStack:push(getBattleTextboxState('Victory!',
        function()
            -- calculate the increase in exp by adding the opponent Pokemon's growth values and multiplying by the level
            local exp_gain = (self.opponent_pokemon.hp_growth + self.opponent_pokemon.attack_growth +
                self.opponent_pokemon.defense_growth + self.opponent_pokemon.speed_growth) * self.opponent_pokemon.level

            gStateStack:push(getBattleTextboxState('You earned ' .. tostring(exp_gain) .. ' experience points!',
                nil, false))
            Timer.after(1.5, function()
                -- pop exp message
                gStateStack:pop()
                self:fillExp(exp_gain)
            end)
        end))
    end)
end

-- Fill the exp bar by tweening the player Pokemon's exp value. Level up if exp bar has been filled.
-- When leveled up, call this function recursively with the remaining exp.
function TakeTurnState:fillExp(exp_gain)
    -- if the Pokemon is max level let the exp bar still fill up, but stop when its full
    if self.player_pokemon.exp == self.player_pokemon.exp_to_next_lvl then
        self:fadeOutVictory()
        return
    end

    local exp_new = self.player_pokemon.exp + exp_gain
    -- process the exp overshoot in the next recursive function call
    local exp_overshoot = exp_new > self.player_pokemon.exp_to_next_lvl and
        exp_new - self.player_pokemon.exp_to_next_lvl or 0
    -- have a constant exp bar tween speed
    local full_bar_tween_time = 3
    local bar_tween_time = full_bar_tween_time * (exp_gain - exp_overshoot) / self.player_pokemon.exp_to_next_lvl

    gSounds['exp']:play()
    Timer.tween(bar_tween_time, {
        [self.player_pokemon] = {exp = math.min(exp_new, self.player_pokemon.exp_to_next_lvl)}
    })
    :finish(function()
        gSounds['exp']:stop()
        -- level up if not already max level
        if self.player_pokemon.exp == self.player_pokemon.exp_to_next_lvl and
            self.player_pokemon.level < POKEMON_LEVEL_MAX
        then
            gSounds['levelup']:play()
            self.player_pokemon.exp = 0
            local hp_inc, attack_inc, defense_inc, speed_inc = self.player_pokemon:levelUp()

            gStateStack:push(getBattleTextboxState('Congratulations! Level Up!',
            function()
                gStateStack:push(getLevelUpBoxState(self.player_pokemon, hp_inc, attack_inc, defense_inc, speed_inc,
                function()
                    if exp_overshoot > 0 then
                        self:fillExp(exp_overshoot)
                    else
                        self:fadeOutVictory()
                    end
                end))
            end))
        else
            self:fadeOutVictory()
        end
    end)
end

-- called when the opponent Pokemon was defeated and after gaining exp
function TakeTurnState:fadeOutVictory()
    -- fade out white
    gStateStack:push(FadeState({255/255, 255/255, 255/255, 0/255}, 255/255, 1,
    function()
        gSounds['victory-music']:stop()
        -- pop BattleState
        gStateStack:pop()
        gStateStack:push(FadeState({255/255, 255/255, 255/255, 255/255}, 0/255))
    end))
end

-- called when the last player Pokemon fainted
function TakeTurnState:fadeOutFaint()
    -- fade out black
    gStateStack:push(FadeState({0/255, 0/255, 0/255, 0/255}, 255/255, 1,
    function()
        -- pop BattleState
        gStateStack:pop()
        gStateStack:push(FadeState({0/255, 0/255, 0/255, 255/255}, 0/255, 1,
        function()
            -- heal all Pokemon
            gSounds['heal']:play()
            for _, pokemon in pairs(self.battle_state.player.party) do
                pokemon.hp = pokemon.hp_max
            end
            gStateStack:push(getDialogueBoxState('Your Pokemon have been fully restored. Try again!'))
        end))
    end))
end
