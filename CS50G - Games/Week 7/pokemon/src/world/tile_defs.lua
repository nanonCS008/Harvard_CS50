--[[
    Definitions to add more functionality to the Tile Class for Tiles that have special behavior
    Tile definitions are identified by the tile ID
]]

TILE_DEFS = {
    -- small cliff where an entity can jump down
    [TILE_ID_SMALL_CLIFF_JUMPABLE] = {
        onInit = function(self)
            -- determine the direction that the entity can jump down on from the frame ID
            if self.frame_id == TILE_FRAME_ID_SMALL_CLIFF_ENDING_VERT_LEFT_UP or
                self.frame_id == TILE_FRAME_ID_SMALL_CLIFF_ENDING_VERT_LEFT_DOWN or
                self.frame_id == TILE_FRAME_ID_SMALL_CLIFF_CONNECTION_VERT_LEFT
            then
                self.direction = 'left'
            elseif self.frame_id == TILE_FRAME_ID_SMALL_CLIFF_ENDING_VERT_RIGHT_UP or
                self.frame_id == TILE_FRAME_ID_SMALL_CLIFF_ENDING_VERT_RIGHT_DOWN or
                self.frame_id == TILE_FRAME_ID_SMALL_CLIFF_CONNECTION_VERT_RIGHT
            then
                self.direction = 'right'
            elseif self.frame_id == TILE_FRAME_ID_SMALL_CLIFF_ENDING_HOR_TOP_LEFT or
                self.frame_id == TILE_FRAME_ID_SMALL_CLIFF_ENDING_HOR_TOP_RIGHT or
                self.frame_id == TILE_FRAME_ID_SMALL_CLIFF_CONNECTION_HOR_TOP
            then
                self.direction = 'up'
            elseif self.frame_id == TILE_FRAME_ID_SMALL_CLIFF_ENDING_HOR_BOTTOM_LEFT or
                self.frame_id == TILE_FRAME_ID_SMALL_CLIFF_ENDING_HOR_BOTTOM_RIGHT or
                self.frame_id == TILE_FRAME_ID_SMALL_CLIFF_CONNECTION_HOR_BOTTOM
            then
                self.direction = 'down'
            end
        end,
        onCollide = function(self, entity)
            if self.direction == entity.direction then
                entity.new_state = 'jump'
            end
        end
    }
}
