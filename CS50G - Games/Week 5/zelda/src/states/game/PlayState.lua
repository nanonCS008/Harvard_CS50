--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayState = Class{__includes = BaseState}

function PlayState:init()
    -- spawn coordinates of player get determined during dungeon generation
    self.player = Player(0, 0, nil)

    -- generate dungeon
    self.dungeon = Dungeon(self.player)
    self.player.dungeon = self.dungeon

    -- store the state if a State change occurs.
    self.new_state, self.new_state_params = nil, nil
    -- if game is paused
    self.is_pause = false

    -- transition alpha for fade out to Game Over screen
    self.transition_alpha = 0

    -- Event.dispatch() inside PlayerGameOverState, after death or victory animation ended
    Event.on('player-game-over', function(substate)
        -- fade out to Game Over screen
        Timer.tween(1, {
            [self] = {transition_alpha = 255/255}
        })
        :finish(function()
            self.new_state = 'game-over'
            if substate == 'victory' then
                self.new_state_params = 'victory'
                gSounds['victory']:play()
            else
                self.new_state_params = 'death'
                gSounds['defeat']:play()
            end
        end)
    end)
end

function PlayState:update(dt)
    -- toggle pause
    if keyboardWasPressed(KEYS_PAUSE) then
        if self.is_pause then
            gSounds['confirm']:play()
        else
            gSounds['back']:play()
        end
        self.is_pause = not self.is_pause
    end
    if self.is_pause then
        return
    end
    if keyboardWasPressed('escape') then
        self.new_state = 'start'
        gSounds['back']:play()
    end

    -- go back to the Start- or Game Over Screen
    if self.new_state then
        gStateMachine:change(self.new_state, self.new_state_params)
        self.new_state, self.new_state_params = nil, nil

        -- clear all timers (across all states)
        Timer.clear()
        -- remove all event handlers
        Event.handlers = {}
        return
    end

    -- update all timers
    Timer.update(dt)

    self.dungeon:update(dt)
end

function PlayState:render()
    -- clear the stencils. necessary if used love.graphics.stencil() with keepvalues=true
    love.graphics.clear()

    -- render dungeon (room, entities, objects)
    self.dungeon:render()

    -- draw player hearts at the top of the screen. 1 heart = 2 health
    -- heart_frame_id is the frame ID of the current heart to draw (empty, half or full)
    -- fill up the hearts from left to right with the player health
    local heart_frame_id = 1
    local health_left = self.player.health

    for i = 1, math.ceil(self.player.max_health / 2) do
        if health_left > 1 then
            heart_frame_id = 5      -- full
        elseif health_left == 1 then
            heart_frame_id = 3      -- half
        else
            heart_frame_id = 1      -- empty
        end

        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][heart_frame_id],
            (i - 1) * (TILE_SIZE + 1) + 2, 2)

        health_left = health_left - 2
    end

    -- render pause text
    if self.is_pause then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSE", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end

    if self.transition_alpha > 0 then
        -- render fade-out foreground rectangle, if game over
        love.graphics.setColor(0/255, 0/255, 0/255, self.transition_alpha)
        love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
    end
end
