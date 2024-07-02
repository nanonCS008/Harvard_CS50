pacman = {}
pacman.x = 1		
pacman.y = 1		
pacman.sx = 14+32	
pacman.sy = 14+32	
pacman.canEatGhosts = false
pacman.move = 0

animationTime = 0			
animationFrame = 5			

function pacman.movement()
	if pacman.move == 1 then
		if map[pacman.x][pacman.y-1] == gfx.tile then
            pacman.move = 0
		else
			pacman.sy = pacman.sy - config.pacmanSpeed
			
			if pacman.gfx == gfx.pacman and animationTime > animationFrame then
				pacman.gfx = gfx.pacmanUp
				animationTime = 0
			elseif animationTime > animationFrame then
				pacman.gfx = gfx.pacman
				animationTime = 0
			end	
		end	
	elseif pacman.move == 2 then
		if map[pacman.x][pacman.y+1] == gfx.tile then
            pacman.move = 0 
		else
			pacman.sy = pacman.sy + config.pacmanSpeed
			if pacman.gfx == gfx.pacman and animationTime > animationFrame then
				pacman.gfx = gfx.pacmanDown
				animationTime = 0
			elseif animationTime > animationFrame then
				pacman.gfx = gfx.pacman
				animationTime = 0
			end
		end
	elseif pacman.move == 3 then
		if map[pacman.x-1][pacman.y] == gfx.tile then
            pacman.move = 0 
		else
			pacman.sx = pacman.sx - config.pacmanSpeed
			if pacman.gfx == gfx.pacman and animationTime > animationFrame then
				pacman.gfx = gfx.pacmanLeft
				animationTime = 0
			elseif animationTime > animationFrame then
				pacman.gfx = gfx.pacman
				animationTime = 0
			end	
		end
	elseif pacman.move == 4 then
		if map[pacman.x+1][pacman.y] == gfx.tile then
            pacman.move = 0 
		else
			pacman.sx = pacman.sx + config.pacmanSpeed
			if pacman.gfx == gfx.pacman and animationTime > animationFrame then
				pacman.gfx = gfx.pacmanRight
				animationTime = 0
			elseif animationTime > animationFrame then
				pacman.gfx = gfx.pacman
				animationTime = 0
			end	
		end
	end

	newTile = pacman.tileChangeCheck()
	pacman.movementCheck()

	if newTile or pacman.move == 0 then
		if newDirection == 1 and canMoveUp then
            pacman.move = 1
		elseif newDirection == 2 and canMoveDown then
            pacman.move = 2
		elseif newDirection == 3 and canMoveLeft then
            pacman.move = 3
		elseif newDirection == 4 and canMoveRight then
            pacman.move = 4 
		end
	end
end

function pacman.tileChangeCheck()
	if pacman.sy < pacman.y * 32 - 16 then
        pacman.y = pacman.y - 1
        return true
    end
	if pacman.sy > pacman.y * 32 + 44 then
        pacman.y = pacman.y + 1
        return true
    end
	if pacman.sx < pacman.x * 32 - 16 then
        pacman.x = pacman.x - 1
        return true
    end
	if pacman.sx > pacman.x * 32 + 44 then
        pacman.x = pacman.x + 1
        return true
    end
end

function pacman.movementCheck()
	if map[pacman.x][pacman.y-1] ~= gfx.tile then
        canMoveUp = true
    else
        canMoveUp = false
    end
	if map[pacman.x][pacman.y+1] ~= gfx.tile then
        canMoveDown = true 
    else
        canMoveDown = false
    end
	if map[pacman.x-1][pacman.y] ~= gfx.tile then
        canMoveLeft = true
    else
        canMoveLeft = false
    end
	if map[pacman.x+1][pacman.y] ~= gfx.tile then
        canMoveRight = true
    else
        canMoveRight = false
    end
end