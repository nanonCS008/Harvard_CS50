--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayState = Class{__includes = BaseState}

-- The PlayState is the base state after going through the StartState.
-- It will be present as long as the player is in-game.
-- It will be active when the player moves in the game world.
function PlayState:enter(params)
    self.id = PLAY_STATE_ID
    -- The player will get the starter Pokemon selected in the StartState
    local player_def = {
        grid_x = 1, grid_y = 1,
        party = params.pokemon
    }
    table.extend(player_def, ENTITY_DEFS['player'])
    self.player = Player(player_def)

    self.area = GameArea(self.player)
    self.player.area = self.area

    gSounds['field-music']:setLooping(true)
    gSounds['field-music']:play()

    gStateStack:push(getDialogueBoxState(
        "Welcome to the world of 50Mon! You chose " .. self.player.party[1].name ..
        " as your starting Pokemon. You can fight or catch other Pokemon by walking in the grass.\n" ..
        "Good luck!"
    ))
end

function PlayState:update(dt)
    self.area:update(dt)
end

function PlayState:render()
    self.area:render()
end
