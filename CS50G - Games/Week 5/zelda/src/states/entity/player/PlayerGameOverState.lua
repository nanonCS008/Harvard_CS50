PlayerGameOverState = Class{__includes = BaseState}

function PlayerGameOverState:init(owner)
    self.owner = owner

    self.owner.render_offset_y = 5
    self.owner.render_offset_x = 0

    -- substate can be 'victory' or 'death' passed in the enter Parameters of this state
    self.substate = nil

    -- stop blinking from invulnerability
    self.owner.is_invulnerable = false
    self.owner.invulnerable_timer = 0
    self.owner.flash_timer = 0

    -- Event.on() inside PlayState Class
    Timer.after(1, function()
        Event.dispatch('player-game-over', self.substate)
    end)
end

function PlayerGameOverState:enter(params)
    if params == 'victory' then
        self.owner:changeAnimation('victory')
        self.substate = 'victory'
        gSounds['player-victory']:play()
    else
        self.owner:changeAnimation('death')
        self.substate = 'death'
        -- Note: enemies cannot hit the player any more when is_alive = false
        self.owner.is_alive = false
        gSounds['player-death']:play()
    end
    gSounds['music']:stop()
end

function PlayerGameOverState:updateStage1(dt) end

function PlayerGameOverState:updateStage2(dt) end

function PlayerGameOverState:updateStage3(dt) end
