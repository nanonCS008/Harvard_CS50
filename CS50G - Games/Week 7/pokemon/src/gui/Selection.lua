--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The Selection consists of other GUI elements that can be arranged in a matrix. It uses a Panel as background.
    GUI Elements must implement the functions getDimensions() and setPosition().
    Each element can be selected and the callback function of that element is called when pressing the 'confirm' key.
]]

Selection = Class{__includes = Panel}

function Selection:init(def)
    Panel.init(self, def)

    -- Each element in item_mat is a table with following content:
    -- {item = <class instance of GUI element>, onSelect = <optional select callback function>}
    -- The layout of item_mat, corresponds to the layout of the Selection.
    -- Every subtable is a new row and the elements in a subtable specify the columns.
    -- A section is the place for 1 item. The sections are the same size and evenly placed directly next to each other.
    self.item_mat = def.item_mat
    -- number of rows
    self.section_num_vert = #self.item_mat
    -- set number of columns according to the row with the most items
    self.section_num_hor = 0
    for i = 1, #self.item_mat do
        self.section_num_hor = math.max(self.section_num_hor, #self.item_mat[i])
    end

    -- calculate section dimensions according to the background Panel dimensions and number of items
    self.section_width = (self.width - self.margin * 2) / self.section_num_hor
    self.section_height = (self.height - self.margin * 2) / self.section_num_vert

    -- offset and alignment for every item in every section. offset is applied after alignment
    self.align_vert, self.align_hor = def.align_vert or 'top', def.align_hor or 'left'
    self.offset_x, self.offset_y = def.offset_x or 0, def.offset_y or 0
    -- if items are selectable and a cursor is rendered (default true)
    self.has_cursor = def.has_cursor == nil and true or def.has_cursor

    -- additional callback functions.
    -- self.onSelect is executed before the onSelect function of the selected item
    -- self.onBack is executed when the 'back' key is pressed
    self.onSelect = def.onSelect or function() end
    self.onBack = def.onBack or function() end

    -- set position of each item
    local section_y = self.y + self.margin
    for sect_vert = 1, self.section_num_vert do
        local section_x = self.x + self.margin
        for sect_hor = 1, self.section_num_hor do
            local elem = self.item_mat[sect_vert][sect_hor]
            if elem then
                local item_x, item_y = section_x, section_y
                local item_width, item_height = elem.item:getDimensions()
                if self.align_vert == 'center' then
                    item_y = item_y + self.section_height / 2 - item_height / 2
                elseif self.align_vert == 'bottom' then
                    item_y = item_y + self.section_height - item_height
                end
                if self.align_hor == 'center' then
                    item_x = item_x + self.section_width / 2 - item_width / 2
                elseif self.align_hor == 'right' then
                    item_x = item_x + self.section_width - item_width
                end
                item_x = item_x + (self.offset_x)
                item_y = item_y + (self.offset_y)

                elem.item:setPosition(item_x, item_y)
            end
            section_x = section_x + self.section_width
        end
        section_y = section_y + self.section_height
    end

    -- grid position of currently selected/ highlighted item
    self.selected_hor, self.selected_vert = 1, 1
    self.highlighted_hor, self.highlighted_vert = nil, nil

    -- if an item is highlighted an additional cursor will blink at the item position
    self.highlight_cursor_is_blinking = false
    self.highlight_cursor_blink_timer = nil
end

-- highlight the item at the specified grid position with a blinking cursor
function Selection:highlightSection(highlight_hor, highlight_vert)
    self.highlighted_hor, self.highlighted_vert = highlight_hor, highlight_vert
    self.highlight_cursor_blink_timer = Timer.every(0.1, function()
        self.highlight_cursor_is_blinking = not self.highlight_cursor_is_blinking
    end)
end

-- stop highlighting
function Selection:unhighlightSection()
    self.highlighted_hor, self.highlighted_vert = nil, nil
    self.highlight_cursor_is_blinking = false
    if self.highlight_cursor_blink_timer then self.highlight_cursor_blink_timer:remove() end
end

function Selection:update(dt)
    local selected_hor_prev, selected_vert_prev = self.selected_hor, self.selected_vert
    if self.has_cursor and keyboardWasPressed(KEYS_LEFT) then
        self.selected_hor = (self.selected_hor - 2) % self.section_num_hor + 1
    elseif self.has_cursor and keyboardWasPressed(KEYS_RIGHT) then
        self.selected_hor = self.selected_hor % self.section_num_hor + 1
    elseif self.has_cursor and keyboardWasPressed(KEYS_UP) then
        self.selected_vert = (self.selected_vert - 2) % self.section_num_vert + 1
    elseif self.has_cursor and keyboardWasPressed(KEYS_DOWN) then
        self.selected_vert = self.selected_vert % self.section_num_vert + 1
    elseif keyboardWasPressed(KEYS_CONFIRM) then
        self:onSelect()
        local elem = self.item_mat[self.selected_vert][self.selected_hor]
        if elem and elem.onSelect then
            -- call onSelect with self, so the function has access to this class instance
            elem.onSelect(self)
        end
    elseif keyboardWasPressed(KEYS_BACK) then
        self:onBack()
    end
    -- when moved the cursor
    if selected_hor_prev ~= self.selected_hor or selected_vert_prev ~= self.selected_vert then
        gSounds['select']:stop()
        gSounds['select']:play()
    end
end

function Selection:render()
    Panel.render(self)

    local section_y = self.y + self.margin
    for sect_vert = 1, self.section_num_vert do
        local section_x = self.x + self.margin
        for sect_hor = 1, self.section_num_hor do
            local elem = self.item_mat[sect_vert][sect_hor]
            local cursor_gap = 3
            local cursor_x = section_x + self.section_width / 2 - TILE_SIZE - cursor_gap
            local cursor_y = section_y + self.section_height / 2 - TILE_SIZE / 2
            if elem then
                elem.item:render()
                local _, item_height = elem.item:getDimensions()
                cursor_x = elem.item.x - TILE_SIZE - cursor_gap
                cursor_y = elem.item.y + item_height / 2 - TILE_SIZE / 2
            end
            -- render cursor/ highlight cursor in front of the selected/ highlighted item
            if self.has_cursor then
                if sect_hor == self.highlighted_hor and sect_vert == self.highlighted_vert then
                    love.graphics.setColor(255/255, 255/255, 255/255, self.highlight_cursor_is_blinking and 50/255 or 255/255)
                    love.graphics.draw(gTextures['ui-assets'], gFrames['ui-assets'][FRAME_ID_CURSOR],
                        math.floor(cursor_x), math.floor(cursor_y))
                    love.graphics.setColor(255/255, 255/255, 255/255, 255/255)
                elseif sect_hor == self.selected_hor and sect_vert == self.selected_vert then
                    love.graphics.draw(gTextures['ui-assets'], gFrames['ui-assets'][FRAME_ID_CURSOR],
                        math.floor(cursor_x), math.floor(cursor_y))
                end
            end
            section_x = section_x + self.section_width
        end
        section_y = section_y + self.section_height
    end
end
