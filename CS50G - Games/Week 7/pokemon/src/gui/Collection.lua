--[[
    Collection of GUI Elements. GUI Elements can be the classes defined in the files in this gui folder.
    GUI Elements must implement the functions getDimensions() and setPosition()
]]

Collection = Class{}

-- The 'def' table consists of subtables that contain the definition of other GUI Classes.
-- The GUI class that shall be instantiated is supplied with a table member called 'initialize'.
-- GUI Element definitions can contain relative coordinates with x_rel, y_rel or absolute coordinates with x, y
function Collection:init(def)
    self.x, self.y = def.x or 0, def.y or 0
    -- contains all the GUI Elements that will be stored under the same key as in the def input parameter
    self.elements = {}
    for key, elem_def in pairs(def) do
        if type(elem_def) == 'table' and elem_def.initialize then
            -- if no absolute but relative coordinates were specified, convert to absolute coordinates
            elem_def.x = elem_def.x or (self.x + (elem_def.x_rel or 0))
            elem_def.y = elem_def.y or (self.y + (elem_def.y_rel or 0))
            -- 'initialize' contains the class name that can be instantiated
            self.elements[key] = elem_def.initialize(elem_def)
        end
    end

    self:calcDimensions()
end

-- get position and size of every GUI element and calculate width and height of the Collection
-- don't calculate the Dimensions every time in getDimensions(), but have a separate function for that
function Collection:calcDimensions()
    local top, bottom, left, right
    for _, elem in pairs(self.elements) do
        top, bottom = top or elem.y, bottom or elem.y
        left, right = left or elem.x, right or elem.x
        local elem_width, elem_height = elem:getDimensions()
        top = math.min(top, elem.y)
        bottom = math.max(bottom, elem.y + elem_height)
        left = math.min(left, elem.x)
        right = math.max(right, elem.x + elem_width)
    end
    self.width, self.height = right - left, bottom - top
end

function Collection:getDimensions()
    return self.width, self.height
end

function Collection:setPosition(x, y)
    -- apply the difference in position to all elements
    for _, elem in pairs(self.elements) do
        elem:setPosition(elem.x + x - self.x, elem.y + y - self.y)
    end
    self.x, self.y = x, y
end

function Collection:update(dt)
    for _, elem in pairs(self.elements) do
        if elem.update then elem:update(dt) end
    end
end

function Collection:render()
    for _, elem in pairs(self.elements) do
        elem:render()
    end
end
