--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Pokemon = Class{}

function Pokemon:init(def, level)
    -- Pokemon name that is shown in game
    self.name = def.name

    -- Pokemon icon that is shown in the menu screen
    self.texture_face = def.texture_face
    -- name of the battle sprite textures
    self.texture_battle_front = def.texture_battle_front
    self.texture_battle_back = def.texture_battle_back
    -- gets set to a BattleSprite object that will be rendered when the Pokemon enters a battle
    self.battle_sprite = nil

    -- base stats of the level 1 Pokemon
    self.hp_base = def.hp_base
    self.attack_base = def.attack_base
    self.defense_base = def.defense_base
    self.speed_base = def.speed_base

    -- Growth value for each stat. They define how likely the stat gets increased on level up.
    -- Every Pokemon type has specific growth values.
    -- The original Pokemon game uses a different way to calculate the stats:
    -- https://bulbapedia.bulbagarden.net/wiki/Statistic#Determination_of_stats
    self.hp_growth = def.hp_growth
    self.attack_growth = def.attack_growth
    self.defense_growth = def.defense_growth
    self.speed_growth = def.speed_growth

    -- current stats
    self.hp_max = self.hp_base
    self.hp = self.hp_max
    self.attack = self.attack_base
    self.defense = self.defense_base
    self.speed = self.speed_base
    self.level = level or 1

    -- experience points obtained in the current level
    self.exp = 0
    -- experience points needed to get from the beginning of the current level to the next level
    self.exp_to_next_lvl = self:getExpToNextLvl()

    -- Every Pokemon has the same hardcoded attack. Maximum number of attacks is POKEMON_ATTACK_NUM_MAX
    self.attacks = {ATTACK_DEFS[1]}

    -- set the stats according to the Pokemon level
    for _ = 1, self.level do
        self:statsLevelUp()
    end
end

-- set self.battle_sprite to a BattleSprite object
-- x, y: coordinates where the sprite shall be placed
-- type: valid values: 'front' (used for opponent Pokemon), 'back' (used for player Pokemon)
function Pokemon:activateBattleSprite(x, y, type)
    local texture = self.texture_battle_front
    if type == 'back' then texture = self.texture_battle_back end
    self.battle_sprite = BattleSprite(x, y, texture)
end

-- Roll a dice a number of times for each stat. Compare the growth value for the stat with the dice value.
-- If the growth value is equal or bigger add a point to the stat.
-- return the increase for each stat.
function Pokemon:statsLevelUp()
    local hp_max_prev = self.hp_max
    local attack_prev = self.attack
    local defense_prev = self.defense
    local speed_prev = self.speed

    for _ = 1, LEVEL_DICE_ROLL_NUM_MAX do
        if math.random(LEVEL_DICE_VAL_MAX) <= self.hp_growth then
            self.hp_max = self.hp_max + 1
        end
        if math.random(LEVEL_DICE_VAL_MAX) <= self.attack_growth then
            self.attack = self.attack + 1
        end
        if math.random(LEVEL_DICE_VAL_MAX) <= self.defense_growth then
            self.defense = self.defense + 1
        end
        if math.random(LEVEL_DICE_VAL_MAX) <= self.speed_growth then
            self.speed = self.speed + 1
        end
    end

    local hp_max_inc = self.hp_max - hp_max_prev
    local attack_inc = self.attack - attack_prev
    local defense_inc = self.defense - defense_prev
    local speed_inc = self.speed - speed_prev
    self.hp = self.hp + hp_max_inc

    return hp_max_inc, attack_inc, defense_inc, speed_inc
end

-- used to set self.exp_to_next_lvl
function Pokemon:getExpToNextLvl()
    return math.floor(self.level^2 * 5 * 0.75)
end

-- level up by 1 level and increase the stats accordingly
function Pokemon:levelUp()
    if self.level >= POKEMON_LEVEL_MAX then return end

    self.level = self.level + 1
    self.exp_to_next_lvl = self:getExpToNextLvl()

    return self:statsLevelUp()
end

function Pokemon:render()
    if self.battle_sprite then self.battle_sprite:render() end
end
