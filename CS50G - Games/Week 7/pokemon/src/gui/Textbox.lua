--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A Textbox displays Text inside a Panel. By pressing 'confirm' the next text chunk can be reached.
    A chunk is the text that fits in the Panel at a time.
]]

Textbox = Class{__includes = Panel}

function Textbox:init(def)
    Panel.init(self, def)

    self.text = def.text or ""
    self.font = def.font or gFonts['small']
    self.color = def.color or {255/255, 255/255, 255/255, 255/255}
    -- specifies if the Textbox can be advanced or closed by pressing 'confirm' (default true)
    self.can_input = def.can_input == nil and true or def.can_input
    self.line_spacing = def.line_spacing or 6
    -- function that is called after pressing 'confirm' on the last text chunk
    self.onClose = def.onClose or function() end

    -- returns a table containing each line of text that was wrapped with the specified limit.
    _, self.text_lines = self.font:getWrap(self.text, self.width - self.margin * 2)
    -- text lines that are displayed in the current chunk
    self.text_lines_display = {}

    -- calculate how many text lines fit in one chunk.
    -- The last line does not need the line spacing, so compensate for that in the calculation.
    self.lines_per_chunk =
        math.floor((self.height - self.margin * 2 + self.line_spacing) / (self.font:getHeight() + self.line_spacing))

    -- index for self.text_lines
    self.line_counter = 1
    self.is_end_of_text = false
    self.is_closed = false

    self:next()
end

-- called when the next text chunk shall be displayed
function Textbox:next()
    if self.is_closed then return end
    if self.is_end_of_text then
        self.is_closed = true
        self:onClose()
        return
    end

    self.text_lines_display = {}
    for _ = 1, self.lines_per_chunk do
        table.insert(self.text_lines_display, self.text_lines[self.line_counter])

        -- when reached the number of total lines in the last chunk
        if self.line_counter >= #self.text_lines then
            self.is_end_of_text = true
            return
        end
        self.line_counter = self.line_counter + 1
    end
end

function Textbox:update(dt)
    if self.can_input and keyboardWasPressed(KEYS_CONFIRM) then
        gSounds['select']:play()
        self:next()
    end
end

function Textbox:render()
    if self.is_closed then return end

    Panel.render(self)

    love.graphics.setFont(self.font)
    love.graphics.setColor(self.color)
    for i = 1, #self.text_lines_display do
        love.graphics.print(self.text_lines_display[i],
            math.floor(self.x + self.margin),
            math.floor(self.y + self.margin + (i - 1) * (self.font:getHeight() + self.line_spacing)))
    end
    love.graphics.setColor(255/255, 255/255, 255/255, 255/255)
end
