--[[
    This file contains functions that return definitions to instantiate GUI Classes.
    The GUI Elements described in these definitions are used throughout the game.
    The callback function of the GUI Elements can also contain game logic.
    Other functions defined here return a GUIState that can be pushed on the state stack.
]]

-- definition for a Collection Class.
-- Used in the BattleState to display information about the player Pokemon
-- Because the displayed values are returned by functions, they get updated automatically when the value changes.
function getPlayerBattleHudDef(pokemon)
    return {
        x = VIRTUAL_WIDTH - 160, y = VIRTUAL_HEIGHT - 110,
        pkmn_name = {
            initialize = Text,
            text = function() return pokemon.name end,
            color = {0/255, 0/255, 0/255, 255/255},
            x_rel = 0, y_rel = 0,
        },
        pkmn_lvl = {
            initialize = Text,
            text = function() return 'LV: ' .. tostring(pokemon.level) end,
            color = {0/255, 0/255, 0/255, 255/255},
            x_rel = 0, y_rel = 0,
            limit = 150,
            align = 'right',
        },
        health_bar = {
            initialize = ProgressBar,
            x_rel = 0,
            y_rel = 10,
            width = 152,
            height = 6,
            color = {189/255, 32/255, 32/255, 255/255},
            value = function() return pokemon.hp end,
            value_max = function() return pokemon.hp_max end
        },
        pkmn_health = {
            initialize = Text,
            text = function() return tostring(math.floor(pokemon.hp)) .. ' / ' .. tostring(pokemon.hp_max) end,
            color = {0/255, 0/255, 0/255, 255/255},
            x_rel = 0,
            y_rel = 18,
            limit = 150,
            align = 'right',
        },
        exp_bar = {
            initialize = ProgressBar,
            x_rel = 0,
            y_rel = 30,
            width = 152,
            height = 6,
            color = {32/255, 32/255, 189/255, 255/255},
            value = function() return pokemon.exp end,
            value_max = function() return pokemon.exp_to_next_lvl end
        }
    }
end

function getPlayerBattleHud(pokemon)
    return Collection(getPlayerBattleHudDef(pokemon))
end

-- Used in the BattleState to display information about the opponent Pokemon.
-- Similar to player HUD (see above), but without health values and exp bar.
function getOpponentBattleHudDef(pokemon)
    local player_hud_def = getPlayerBattleHudDef(pokemon)
    local hud_def = {
        x = 8, y = 16,
        pkmn_name = player_hud_def.pkmn_name,
        pkmn_lvl = player_hud_def.pkmn_lvl,
        health_bar = player_hud_def.health_bar
    }
    hud_def.pkmn_name.text = function() return pokemon.name end
    hud_def.pkmn_lvl.text = function() return 'LV: ' .. tostring(pokemon.level) end
    hud_def.pkmn_lvl.value = function() return pokemon.hp end
    hud_def.pkmn_lvl.value_max = function() return pokemon.hp_max end
    return hud_def
end

function getOpponentBattleHud(pokemon)
    return Collection(getOpponentBattleHudDef(pokemon))
end

-- definition for a Selection Class.
-- The battle menu is shown in the BattleState before every turn, so the player can select his next action.
-- battle_state: reference to the BattleState object
function getBattleMenuDef(battle_state)
    local menu_width = 180
    return {
        x = VIRTUAL_WIDTH - menu_width,
        y = VIRTUAL_HEIGHT - battle_state.bottom_panel.height,
        width = menu_width,
        height = battle_state.bottom_panel.height,
        align_vert = 'center',
        offset_x = 5,
        onSelect = function(selection)
            gSounds['confirm']:play()
        end,
        item_mat = {
            {{
                item = Text({text = 'Fight', font = gFonts['medium']}),
                onSelect = function(selection)
                    -- pop BattleMenu
                    gStateStack:pop()
                    gStateStack:push(getBattleAttackSelectionState(battle_state))
                end
            },
            {
                item = Text({text = 'Catch', font = gFonts['medium']}),
                onSelect = function(selection)
                    -- pop BattleMenu
                    gStateStack:pop()
                    -- Catching Pokemon always succeeds when having enough space.
                    -- The opponent Pokemon will be added to the players party and the battle ends.
                    if #battle_state.player.party < PARTY_SIZE_MAX then
                        gSounds['catch']:play()
                        gStateStack:push(getBattleTextboxState(battle_state.opponent_pokemon.name .. ' was caught!',
                        function()
                            table.insert(battle_state.player.party, battle_state.opponent_pokemon)
                            gStateStack:push(FadeState({255/255, 255/255, 255/255, 0/255}, 255/255, 1,
                            function()
                                -- pop BattleState
                                gStateStack:pop()
                                gStateStack:push(FadeState({255/255, 255/255, 255/255, 255/255}, 0/255))
                            end))
                        end))
                    else
                        gStateStack:push(getBattleTextboxState('Your Party is already full!',
                        function()
                            gStateStack:push(getBattleMenuState(battle_state))
                        end))
                    end
                end
            }},
            {{
                item = Text({text = 'Pokemon', font = gFonts['medium']}),
                -- show the party menu so the player can switch Pokemon
                onSelect = function(selection)
                    local onSelect = getPartyMenuBattleOnSelect(battle_state)
                    local onBack = getPartyMenuBattleOnBack()
                    gStateStack:push(getPartyMenuState(battle_state.player.party, onSelect, onBack))
                end
            },
            {
                item = Text({text = 'Run', font = gFonts['medium']}),
                -- run always succeeds
                onSelect = function(selection)
                    -- pop BattleMenu
                    gStateStack:pop()
                    gSounds['run']:play()

                    gStateStack:push(getBattleTextboxState('You fled successfully!', nil, false))
                    Timer.after(0.5, function()
                        gStateStack:push(FadeState({255/255, 255/255, 255/255, 0/255}, 255/255, 1,
                        function()
                            -- pop BattleTextbox message
                            gStateStack:pop()
                            -- pop BattleState
                            gStateStack:pop()
                            gStateStack:push(FadeState({255/255, 255/255, 255/255, 255/255}, 0/255))
                        end))
                    end)
                end
            }}
        }
    }
end

function getBattleMenuState(battle_state)
    return GUIState(Selection(getBattleMenuDef(battle_state)))
end

-- onSelect function used for the Party menu when opening it in the field
function getPartyMenuFieldOnSelect(party)
    return function (selection)
        -- The vertical Selection index corresponds to the index in the player Pokemon party
        if selection.highlighted_vert then
            -- swap previously highlighted with the now selected Pokemon in the party list
            if party[selection.selected_vert] and party[selection.highlighted_vert] then
                gSounds['confirm']:play()
                local pkmn_tmp = party[selection.selected_vert]
                party[selection.selected_vert] = party[selection.highlighted_vert]
                party[selection.highlighted_vert] = pkmn_tmp
            else
                gSounds['denied']:play()
            end
            selection:unhighlightSection()
        else
            -- first, a Pokemon must be highlighted
            selection:highlightSection(selection.selected_hor, selection.selected_vert)
            gSounds['select']:play()
        end
    end
end

-- onBack function used for the Party menu when opening it in the field
function getPartyMenuFieldOnBack()
    return function(selection)
        gSounds['back']:play()
        if selection.highlighted_vert then
            selection:unhighlightSection()
        else
            gStateStack:pop()
        end
    end
end

-- onSelect function used for the Party menu when opening it in battle via the BattleMenu
function getPartyMenuBattleOnSelect(battle_state)
    return function (selection)
        -- index of selected Pokemon
        local pkmn_i = selection.selected_vert
        if battle_state:canSwitchPlayerPokemon(pkmn_i) then
            gSounds['confirm']:play()
            gStateStack:push(getQuestionBoxState(
                'Do you want to send ' .. battle_state.player.party[pkmn_i].name .. ' into the battle?',
                -- if selected yes
                function()
                    -- pop PartyMenu
                    gStateStack:pop()
                    -- pop BattleMenu
                    gStateStack:pop()
                    battle_state:switchPlayerPokemon(pkmn_i)
                end
            ))
        else
            gSounds['denied']:stop()
            gSounds['denied']:play()
        end
    end
end

-- onBack function used for the Party menu when opening it in battle via the BattleMenu
function getPartyMenuBattleOnBack()
    return function(selection)
        gSounds['back']:play()
        -- pop PartyMenu
        gStateStack:pop()
    end
end

-- onSelect function used for the Party menu when it is opened after a player Pokemon fainted
function getPartyMenuBattleFaintedOnSelect(battle_state)
    return function (selection)
        -- index of selected Pokemon
        local pkmn_i = selection.selected_vert
        if battle_state:canSwitchPlayerPokemon(pkmn_i) then
            gSounds['confirm']:play()
            gStateStack:push(getQuestionBoxState(
                'Do you want to send ' .. battle_state.player.party[pkmn_i].name .. ' into the battle?',
                -- if selected yes
                function()
                    -- pop PartyMenu
                    gStateStack:pop()
                    battle_state:slideInPlayerPokemon(selection.selected_vert)
                end
            ))
        else
            gSounds['denied']:stop()
            gSounds['denied']:play()
        end
    end
end

-- onBack function used for the Party menu when it is opened after a player Pokemon fainted
function getPartyMenuBattleFaintedOnBack()
    -- prohibit going back, the player must select a Pokemon to fight with
    return function(selection)
        gSounds['denied']:stop()
        gSounds['denied']:play()
    end
end

-- definition for a Selection Class.
-- Menu that shows information about every Pokemon in the party.
-- Depending on where the Party Menu is opened, a different onSelect or onBack function can be used.
function getPartyMenuDef(party, onSelect, onBack)
    onSelect = onSelect or getPartyMenuFieldOnSelect(party)
    onBack = onBack or getPartyMenuFieldOnBack()
    -- every Selection section is a Collection object.
    -- Each Collection contains GUI Elements that represent Pokemon information and stats
    local item_mat_def = {}
    for i = 1, PARTY_SIZE_MAX do
        local info_box_def = {
            outline = {
                initialize = Panel,
                x_rel = 0, y_rel = 0,
                width = 210,
                height = 27,
                texture = 'panel-white-border',
                margin = 2
            },
            party_nr = {
                initialize = Text,
                text = tostring(i),
                font = gFonts['medium'],
                x_rel = 3, y_rel = 1,
            },
        }
        if party[i] then
            table.extend(info_box_def, {
                pkmn_name = {
                    initialize = Text,
                    text = function() return party[i].name end,
                    x_rel = 15, y_rel = 2,
                },
                pkmn_lvl = {
                    initialize = Text,
                    text = function() return 'LV: ' .. tostring(party[i].level) end,
                    x_rel = 75, y_rel = 2,
                },
                pkmn_exp = {
                    initialize = Text,
                    text = function()
                        return 'EXP: ' .. tostring(party[i].exp) .. ' / ' .. tostring(party[i].exp_to_next_lvl) end,
                    x_rel = 115, y_rel = 2,
                },
                pkmn_atk = {
                    initialize = Text,
                    text = function() return 'ATK: ' .. tostring(party[i].attack) end,
                    x_rel = 15, y_rel = 10,
                },
                pkmn_def = {
                    initialize = Text,
                    text = function() return 'DEF: ' .. tostring(party[i].defense) end,
                    x_rel = 65, y_rel = 10,
                },
                pkmn_sp = {
                    initialize = Text,
                    text = function() return 'SP: ' .. tostring(party[i].speed) end,
                    x_rel = 115, y_rel = 10,
                },
                health_bar = {
                    initialize = ProgressBar,
                    x_rel = 15,
                    y_rel = 19,
                    width = 60,
                    height = 6,
                    color = {189/255, 32/255, 32/255, 255/255},
                    value = function() return party[i].hp end,
                    value_max = function() return party[i].hp_max end
                },
                pkmn_hp = {
                    initialize = Text,
                    text = function()
                        return 'HP: ' .. tostring(party[i].hp) .. ' / ' .. tostring(party[i].hp_max) end,
                    x_rel = 80, y_rel = 18,
                },
                pkmn_graphic = {
                    initialize = Graphic,
                    texture = function() return party[i].texture_face end,
                    x_rel = 192, y_rel = 9,
                }
            })
        end
        item_mat_def[i] = {{
            item = Collection(info_box_def),
        }}
    end

    local menu_width, menu_height = 256, 184
    return {
        x = VIRTUAL_WIDTH / 2 - menu_width / 2,
        y = VIRTUAL_HEIGHT / 2 - menu_height / 2,
        width = menu_width,
        height = menu_height,
        align_hor = 'center',
        align_vert = 'center',
        onSelect = onSelect,
        onBack = onBack,
        item_mat = item_mat_def
    }
end

function getPartyMenuState(party, onSelect, onBack)
    return GUIState(Selection(getPartyMenuDef(party, onSelect, onBack)))
end

-- definition for a Textbox Class.
function getDialogueBoxDef(text, onComplete)
    onComplete = onComplete or function() end
    local textbox_width = 368
    return {
        x = VIRTUAL_WIDTH / 2 - textbox_width / 2, y = 6,
        width = textbox_width, height = 64,
        text = text, font = gFonts['small'],
        onClose = function(textbox)
            -- pop GUIState that contains this Textbox
            gStateStack:pop()
            onComplete()
        end
    }
end

function getDialogueBoxState(text, onComplete)
    return GUIState(Textbox(getDialogueBoxDef(text, onComplete)))
end

-- definition for a Textbox Class.
function getBattleTextboxDef(text, onComplete, can_input)
    onComplete = onComplete or function() end
    local textbox_height = 64
    return {
        x = 0, y = VIRTUAL_HEIGHT - textbox_height,
        width = VIRTUAL_WIDTH, height = textbox_height,
        text = text, font = gFonts['medium'], can_input = can_input,
        onClose = function(textbox)
            -- pop GUIState that contains this Textbox
            gStateStack:pop()
            onComplete()
        end
    }
end

function getBattleTextboxState(text, onComplete, can_input)
    return GUIState(Textbox(getBattleTextboxDef(text, onComplete, can_input)))
end

-- definition for a Selection Class.
-- After pressed 'Fight' in the BattleMenu, show player Pokemon attacks.
-- The selected attack is used in the next turn against the opponent Pokemon.
function getBattleAttackSelectionDef(battle_state)
    local attacks = battle_state.player_pokemon.attacks
    -- Use the same dimensions as the BattleTextbox
    local textbox_def = getBattleTextboxDef()
    -- Display the attacks of the player Pokemon in a 2x2 Matrix
    local item_mat_def = {}
    local n_attack = 1
    for n_row = 1, 2 do
        table.insert(item_mat_def, {})
        for n_col = 1, 2 do
            local attack_name = attacks[n_attack] and attacks[n_attack].name or '-'
            item_mat_def[n_row][n_col] = {item = Text({
                text = attack_name,
                font = gFonts['medium']
            })}
            n_attack = n_attack + 1
        end
    end
    return {
        x = textbox_def.x,
        y = textbox_def.y,
        width = textbox_def.width,
        height = textbox_def.height,
        align_vert = 'center',
        align_hor = 'center',
        onSelect = function(selection)
            -- convert the selected attack in the Selection matrix back to the attack list index
            n_attack = (selection.selected_vert - 1) * selection.section_num_hor + selection.selected_hor
            if attacks[n_attack] then
                gSounds['confirm']:play()
                -- pop Attack Selection
                gStateStack:pop()
                gStateStack:push(TakeTurnState(battle_state, attacks[n_attack]))
            else
                gSounds['denied']:play()
            end
        end,
        onBack = function(selection)
            gSounds['back']:play()
            -- pop Attack Selection
            gStateStack:pop()
            gStateStack:push(getBattleMenuState(battle_state))
        end,
        item_mat = item_mat_def
    }
end

function getBattleAttackSelectionState(battle_state)
    return GUIState(Selection(getBattleAttackSelectionDef(battle_state)))
end

-- A Question Box is a Collection of a Textbox that does not allow input and
-- a Selection with the items 'Yes' and 'No'
-- text: text to display in the Textbox (should fit in one Textbox chunk)
-- onYes, onNo: callback function called when selected 'Yes' or 'No'
function getQuestionBoxDef(text, onYes, onNo)
    onYes = onYes or function() end
    onNo = onNo or function() end
    local dialogue_def = getDialogueBoxDef(text)
    dialogue_def.can_input = false
    dialogue_def.onClose = function() end
    dialogue_def.initialize = Textbox

    -- 'Yes' or 'No' Selection is aligned to the right edge of the Textbox
    local selection_width, selection_height = 56, 64
    local selection_def = {
        x = dialogue_def.x + dialogue_def.width - selection_width,
        y = dialogue_def.y + dialogue_def.height,
        width = selection_width,
        height = selection_height,
        align_vert = 'center',
        offset_x = 5,
        initialize = Selection,
        onSelect = function(selection)
            gSounds['confirm']:play()
            -- pop QuestionBox
            gStateStack:pop()
        end,
        onBack = function(selection)
            gSounds['back']:stop()
            gSounds['back']:play()
            -- move cursor to 'No'
            selection.selected_vert = 2
        end,
        item_mat = {
            {{
                item = Text({text = 'Yes', font = gFonts['medium']}),
                onSelect = function(selection)
                    onYes()
                end
            }},
            {{
                item = Text({text = 'No', font = gFonts['medium']}),
                onSelect = function(selection)
                    onNo()
                end
            }}
        }
    }
    return {
        textbox = dialogue_def,
        selection = selection_def
    }
end

function getQuestionBoxState(text, onYes, onNo)
    return GUIState(Collection(getQuestionBoxDef(text, onYes, onNo)))
end

-- definition for a Selection Class (Selection without cursor).
-- The Level Up Box is shown after a fight when the player Pokemon leveled up.
-- It shows the previous values for all stats, the increase and the resulting (current) value.
function getLevelUpBoxDef(pokemon, hp_inc, attack_inc, defense_inc, speed_inc, onComplete)
    onComplete = onComplete or function() end
    local hp_prev = pokemon.hp_max - hp_inc
    local attack_prev = pokemon.attack - attack_inc
    local defense_prev = pokemon.defense - defense_inc
    local speed_prev = pokemon.speed - speed_inc
    -- Text that will be shown in the level up box arranged in a table.
    -- Each subtable will be the content of a Collection and will be displayed in a row (one line).
    -- Each subtable element is aligned to a column (with the relative x coordinate of the Collection).
    -- Each Collection will be 1 element of a Selection that has only 1 (vertical) column.
    local stats_info = {
        {'HP:', tostring(hp_prev) .. ' + ' .. tostring(hp_inc), ' => ' .. tostring(pokemon.hp_max)},
        {'Attack:', tostring(attack_prev) .. ' + ' .. tostring(attack_inc), ' => ' .. tostring(pokemon.attack)},
        {'Defense:', tostring(defense_prev) .. ' + ' .. tostring(defense_inc), ' => ' .. tostring(pokemon.defense)},
        {'Speed:', tostring(speed_prev) .. ' + ' .. tostring(speed_inc), ' => ' .. tostring(pokemon.speed)},
    }
    local x_rel_tbl = {0, 84, 156}
    -- list of definitions for a Collection (1 for every stat)
    local collection_defs = {}
    for n_row = 1, #stats_info do
        table.insert(collection_defs, {})
        for n_col = 1, #stats_info[1] do
            collection_defs[n_row][n_col] = {
                initialize = Text,
                text = stats_info[n_row][n_col],
                font = gFonts['medium'],
                x_rel = x_rel_tbl[n_col]
            }
        end
    end
    local item_mat_def = {}
    for i = 1, #collection_defs do
        table.insert(item_mat_def, {{item = Collection(collection_defs[i])}})
    end

    local box_width, box_height = 256, 128
    local onSelect = function(selection)
        gSounds['confirm']:play()
        -- pop Level up Box
        gStateStack:pop()
        onComplete()
    end
    return {
        initialize = Selection,
        x = VIRTUAL_WIDTH / 2 - box_width / 2,
        y = VIRTUAL_HEIGHT / 2 - box_height / 2,
        width = box_width,
        height = box_height,
        align_vert = 'center',
        offset_x = 5,
        has_cursor = false,
        onSelect = onSelect,
        onBack = onSelect,
        item_mat = item_mat_def
    }
end

function getLevelUpBoxState(pokemon, hp_inc, attack_inc, defense_inc, speed_inc, onComplete)
    return GUIState(Selection(getLevelUpBoxDef(pokemon, hp_inc, attack_inc, defense_inc, speed_inc, onComplete)))
end
