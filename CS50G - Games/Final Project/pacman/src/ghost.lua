ghost = {}
ghost.__index = ghost
ghosts = {}

function ghost:tileChangeCheck()
	if self.sy < self.y * 32 - 16 then
        self.y = self.y - 1
        return true
    end
	if self.sy > self.y * 32 + 44 then
        self.y = self.y + 1
        return true
    end
	if self.sx < self.x * 32 - 16 then
        self.x = self.x - 1
        return true
    end
	if self.sx > self.x * 32 + 44 then
        self.x = self.x + 1
        return true
    end
end

function ghost:movement()
	if self.move == 1 then
		if map[self.x][self.y-1] == gfx.tile then
            self.move = 0 
		else
            self.sy = self.sy-config.ghostSpeed
        end
	end
	if self.move == 2 then
		if map[self.x][self.y+1] == gfx.tile then
            self.move = 0 
		else
            self.sy = self.sy+config.ghostSpeed
        end
	end
	if self.move == 3 then
		if map[self.x-1][self.y] == gfx.tile then
            self.move = 0 
		else
            self.sx = self.sx-config.ghostSpeed
        end
	end
	if self.move == 4 then
		if map[self.x+1][self.y] == gfx.tile then
            self.move = 0 
		else
            self.sx = self.sx+config.ghostSpeed
        end
	end

	self.newTile = self:tileChangeCheck()
	self:newMoveDirection()

	if self.newTile or self.move == 0 then
		if self.canMoveForward or self.canMoveRight or self.canMoveLeft then
			self.move = self.nextMove
		end
	end
end

function ghost:newMoveDirection()
	self.canMoveLeft = false
	self.canMoveRight = false
	self.canMoveForward = false
	self.canMove = 0

	if self.move == 1 then
		if map[self.x][self.y-1] ~= gfx.tile then
            self.canMove = self.canMove + 1
            self.canMoveForward = true
        end
		if map[self.x-1][self.y] ~= gfx.tile then
            self.canMove = self.canMove + 2
            self.canMoveLeft = true
        end
		if map[self.x+1][self.y] ~= gfx.tile then
            self.canMove = self.canMove + 4
            self.canMoveRight = true
        end

		if self.canMove == 7 then
			local n = love.math.random(3) 
			if n == 1 then
                self.nextMove = 1 
			elseif 	n == 2 then
                self.nextMove = 3 
			elseif 	n == 3 then
                self.nextMove = 4
            end
		elseif self.canMove == 6 then
			local n = love.math.random(2) 
			if n == 1 then
                self.nextMove = 3 
			elseif n == 2 then
                self.nextMove = 4
            end
		elseif self.canMove == 5 then
			local n = love.math.random(2) 
			if n == 1 then
                self.nextMove = 1 
			elseif 	n == 2 then
                self.nextMove = 4
            end
		elseif self.canMove == 4 then
			self.nextMove = 4		
		elseif self.canMove == 3 then
			local n = love.math.random(2) 
			if n == 1 then
                self.nextMove = 1 
			elseif 	n == 2 then
                self.nextMove = 3
            end
		elseif self.canMove == 2 then
			self.nextMove = 3
		elseif self.canMove == 1 then
			self.nextMove = 1
		end
	elseif self.move == 2 then
		if map[self.x][self.y+1] ~= gfx.tile then
            self.canMove = self.canMove + 1
            self.canMoveForward = true
        end
		if map[self.x+1][self.y] ~= gfx.tile then
            self.canMove = self.canMove + 2
            self.canMoveLeft = true
        end
		if map[self.x-1][self.y] ~= gfx.tile then
            self.canMove = self.canMove + 4
            self.canMoveRight = true
        end

		if self.canMove == 7 then
			local n = love.math.random(3) 
			if n == 1 then
                self.nextMove = 2 
			elseif n == 2 then
                self.nextMove = 4 
			elseif n == 3 then
                self.nextMove = 3
            end
		elseif self.canMove == 6 then
			local n = love.math.random(2) 
			if n == 1 then
                self.nextMove = 4 
			elseif n == 2 then
                self.nextMove = 3
            end
		elseif self.canMove == 5 then
			local n = love.math.random(2) 
			if n == 1 then
                self.nextMove = 2 
			elseif n == 2 then
                self.nextMove = 3
            end
		elseif self.canMove == 4 then
			self.nextMove = 3		
		elseif self.canMove == 3 then
			local n = love.math.random(2) 
			if n == 1 then
                self.nextMove = 2 
			elseif n == 2 then
                self.nextMove = 4
            end
		elseif self.canMove == 2 then
			self.nextMove = 4
		elseif self.canMove == 1 then
			self.nextMove = 2
		end
	elseif self.move == 3 then
		if map[self.x-1][self.y] ~= gfx.tile then
            self.canMove = self.canMove + 1
            self.canMoveForward = true
        end
		if map[self.x][self.y+1] ~= gfx.tile then
            self.canMove = self.canMove + 2
            self.canMoveLeft = true
        end
		if map[self.x][self.y-1] ~= gfx.tile then
            self.canMove = self.canMove + 4
            self.canMoveRight = true
        end

		if self.canMove == 7 then
			local n = love.math.random(3) 
			if 		n == 1 then self.nextMove = 3 
			elseif 	n == 2 then self.nextMove = 2 
			elseif 	n == 3 then self.nextMove = 1 end
		elseif self.canMove == 6 then
			local n = love.math.random(2) 
			if 		n == 1 then self.nextMove = 2 
			elseif 	n == 2 then self.nextMove = 1 end
		elseif self.canMove == 5 then
			local n = love.math.random(2) 
			if 		n == 1 then self.nextMove = 3 
			elseif 	n == 2 then self.nextMove = 1 end
		elseif self.canMove == 4 then
			self.nextMove = 1		
		elseif self.canMove == 3 then
			local n = love.math.random(2) 
			if 		n == 1 then self.nextMove = 3 
			elseif 	n == 2 then self.nextMove = 2 end
		elseif self.canMove == 2 then
			self.nextMove = 2
		elseif self.canMove == 1 then
			self.nextMove = 3
		end
	elseif self.move == 4 then
		if map[self.x+1][self.y] ~= gfx.tile then
            self.canMove = self.canMove + 1
            self.canMoveForward = true
        end
		if map[self.x][self.y-1] ~= gfx.tile then
            self.canMove = self.canMove + 2
            self.canMoveLeft = true
        end
		if map[self.x][self.y+1] ~= gfx.tile then
            self.canMove = self.canMove + 4
            self.canMoveRight = true
        end

		if self.canMove == 7 then
			local n = love.math.random(3) 
			if n == 1 then
                self.nextMove = 4 
			elseif n == 2 then
                self.nextMove = 1 
			elseif n == 3 then
                self.nextMove = 2
            end
		elseif self.canMove == 6 then
			local n = love.math.random(2) 
			if n == 1 then
                self.nextMove = 1 
			elseif n == 2 then
                self.nextMove = 2
            end
		elseif self.canMove == 5 then
			local n = love.math.random(2) 
			if n == 1 then
                self.nextMove = 4 
			elseif n == 2 then
                self.nextMove = 2
            end
		elseif self.canMove == 4 then
			self.nextMove = 2		
		elseif self.canMove == 3 then
			local n = love.math.random(2) 
			if n == 1 then
                self.nextMove = 4 
			elseif n == 2 then
                self.nextMove = 1
            end
		elseif self.canMove == 2 then
			self.nextMove = 1
		elseif self.canMove == 1 then
			self.nextMove = 4
		end
	end
end

function ghost:eat()
	self.move = 0
	self.eaten = 1
	self.respawnTimer = love.timer.getTime()
	self.gfx = nil
	self.spawnX, self.spawnY = ghost.getGhostSpawnPoint()
	self.x = self.spawnX
	self.y = self.spawnY
	self.sx = 14 + 32 * self.x
	self.sy = 14 + 32 * self.y
end

function ghost:respawn()
	self.gfx = self.initGfx
	self.eaten = 0
	self.move = 1
end

function ghost:init()
	self.spawnX, self.spawnY = ghost.getGhostSpawnPoint()
	self.x = self.spawnX
	self.y = self.spawnY
	self.sx = 14 + 32 * self.x
	self.sy = 14 + 32 * self.y
	self.move = 1
	
	local n = love.math.random(3)
	if n == 1 then
        self.gfx = gfx.ghost0
        self.initGfx = gfx.ghost0
	elseif n == 2 then
        self.gfx = gfx.ghost1
        self.initGfx = gfx.ghost1
	elseif n == 3 then
        self.gfx = gfx.ghost2
        self.initGfx = gfx.ghost2
    end
end

function ghost.getGhostSpawnPoint()
	local random = love.math.random(5)
	if random == 1 then
        return 9, 10
    end
	if random == 2 then
        return 9, 11
    end
	if random == 3 then
        return 11, 10
    end
	if random == 4 then
        return 11, 11
    end
	if random == 5 then
        return 10, 10
    end
end