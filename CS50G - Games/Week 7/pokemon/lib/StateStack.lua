--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

StateStack = Class{}

function StateStack:init()
    self.states = {}
    -- by default all states are rendered.
    -- For optimizing purposes, this can be changed to only render the topmost state(s)
    self.render_from = 1
end

function StateStack:clear()
    self.states = {}
    self.render_from = 1
end

function StateStack:push(state, params)
    table.insert(self.states, state)
    state:enter(params)
end

function StateStack:pop()
    self.states[#self.states]:exit()
    table.remove(self.states)
    if #self.states < self.render_from then
        self.render_from = 1
    end
end

-- render all states (default)
function StateStack:renderFromStart()
    self.render_from = 1
end

-- render only current top state and all following states that will be pushed
function StateStack:renderFromHere()
    self.render_from = #self.states
end

-- update the state that is on top of the stack (last pushed)
function StateStack:update(dt)
    self.states[#self.states]:update(dt)
end

function StateStack:render()
    for i = self.render_from, #self.states do
        self.states[i]:render()
    end
end
