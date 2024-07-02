require("src/config")
require("src/map")
require("src/ghost")
require("src/pacman")

gfx = {}
sfx = {}

points = 0
fruitStartTimer = 0
gameOver = false
gameWin = false
remainingCheese = 0

function love.load()
    love.filesystem.setIdentity(config.gameName)
    love.keyboard.setKeyRepeat(true)
    love.graphics.setBackgroundColor(104, 136, 248)
    love.window.setTitle(config.windowTitle)
    love.window.setMode(config.screenWidth, config.screenHeight)

    sfx.cheese = love.audio.newSource("sounds/cheese.ogg", "static")

    gfx.tile = love.graphics.newImage("graphics/tile.png")
    gfx.black = love.graphics.newImage("graphics/black.png")
    gfx.pacman = love.graphics.newImage("graphics/pacman.png")
    gfx.pacmanUp = love.graphics.newImage("graphics/pacmanUp.png")
    gfx.pacmanDown = love.graphics.newImage("graphics/pacmanDown.png")
    gfx.pacmanLeft = love.graphics.newImage("graphics/pacmanLeft.png")
    gfx.pacmanRight = love.graphics.newImage("graphics/pacmanRight.png")
    gfx.ghost0 = love.graphics.newImage("graphics/ghost0.png")
    gfx.ghost1 = love.graphics.newImage("graphics/ghost1.png")
    gfx.ghost2 = love.graphics.newImage("graphics/ghost2.png")
    gfx.ghostEat = love.graphics.newImage("graphics/ghostEat.png")
    gfx.cheese = love.graphics.newImage("graphics/cheese.png")
    gfx.fruit = love.graphics.newImage("graphics/fruit.png")

    pacman.gfx = gfx.pacman
    for i = 0, 4 do 												
    	ghosts[i] = {}
    	setmetatable(ghosts[i], ghost)
    	ghosts[i]:init()
    end

    map.loadData()
	countCheese()
end

function countCheese()
	remainingCheese = 1
	for i = 0, 20 do
		for j = 0, 20 do
			if map[i][j] == gfx.cheese then
				remainingCheese = remainingCheese + 1
			end
		end
	end
end

function love.keypressed(key)
	if key == "up" then
        newDirection = 1
    end
	if key == "down" then
        newDirection = 2
    end
	if key == "left" then
        newDirection = 3
    end
	if key == "right" then
        newDirection = 4
    end
	if key == "escape" then
        love.event.quit()
    end
end

function love.update()
    if not gameOver and not gameWin then
        pacman.movement()
    end

    for i = 0, #ghosts do
		ghosts[i]:movement()
	end

	if pacman.sx < -10 then
        pacman.sx = 36 + (32 * 20)
        pacman.x = 20
	elseif pacman.sx > 46 + (32 * 20) then
        pacman.sx = 1
        pacman.x = 0
	end

	for i = 0, #ghosts do 
		if ghosts[i].sx < -10 then
            ghosts[i].sx = 36 + (32 * 20)
            ghosts[i].x = 20
		elseif ghosts[i].sx > 36 + (32 * 20) then
            ghosts[i].sx = 1
            ghosts[i].x = 0
		end
	end

	animationTime = animationTime + 1

    if map[pacman.x][pacman.y] == gfx.cheese then
		points = points + 1
		map[pacman.x][pacman.y] = gfx.black
		remainingCheese = remainingCheese - 1
		sfx.cheese:play()

		if remainingCheese == 0 then
			gameWin = true
		end
	elseif map[pacman.x][pacman.y] == gfx.fruit then
		pacman.canEatGhosts = true
		
        for i = 0, #ghosts do
			ghosts[i].gfx = gfx.ghostEat
		end

		map[pacman.x][pacman.y] = gfx.black
		fruitStartTimer = love.timer.getTime()
	end

	if love.timer.getTime() - fruitStartTimer > 10 then
		pacman.canEatGhosts = false
		
        for i = 0, #ghosts do
			if ghosts[i].eaten == nil or ghosts[i].eaten ~= 1 then
				ghosts[i].gfx = ghosts[i].initGfx
			end
		end

		fruitStartTimer = 0
	end

    for i = 0, #ghosts do
		if pacman.x == ghosts[i].x and pacman.y == ghosts[i].y then			
			if pacman.canEatGhosts then
				ghosts[i]:eat()
			else
				gameOver = true
			end
		end

		if ghosts[i].eaten == 1 then
			if love.timer.getTime() - ghosts[i].respawnTimer > 30 then
				ghosts[i]:respawn()
			end
		end
	end
end

function drawMap()
	love.graphics.setColor(255,255,255,255)
	for i = 0, 20 do
		for j = 0, 20 do
			love.graphics.draw(gfx.black, 14 + i * 32, 14 + j * 32, 0, 1, 1)
		end
	end
	for i = 0, 20 do
		for j = 0, 20 do
			if map[i][j] ~= nil then
				love.graphics.draw(map[i][j], 14 + i * 32, 14 + j * 32, 0, 1, 1)
			end
		end
	end
end

function love.draw(dt)
	drawMap()

	love.graphics.draw(pacman.gfx, pacman.sx, pacman.sy, 0, 1, 1)

	for i = 0, #ghosts do
		if ghosts[i].gfx ~= nil then
			love.graphics.draw(ghosts[i].gfx, ghosts[i].sx, ghosts[i].sy, 0, 1, 1)
		end
	end

    love.graphics.print('points: ', 280, 20, 0, 1.5, 1.5)
	love.graphics.print(points, 345, 20, 0, 1.5, 1.5)

	if gameOver then
		love.graphics.setColor(0,0,100,255)
		love.graphics.rectangle("fill", config.screenWidth * 0.5 - config.screenWidth * 0.3 , config.screenHeight * 0.5 - config.screenHeight * 0.25, config.screenWidth * 0.6, config.screenHeight * 0.15)
		love.graphics.setColor(255,255,0,255)
		love.graphics.print("Game over!", config.screenWidth * 0.5 - config.screenWidth * 0.25, 200, 0, 5)
	end

	if gameWin then
		love.graphics.setColor(0,0,100,255)
		love.graphics.rectangle("fill", config.screenWidth * 0.5 - config.screenWidth * 0.3 , config.screenHeight * 0.5 - config.screenHeight * 0.25, config.screenWidth * 0.6, config.screenHeight * 0.15)
		love.graphics.setColor(255,255,0,255)
		love.graphics.print("You Win!", config.screenWidth * 0.5 - config.screenWidth * 0.25, 200, 0, 5)
	end
	
	if canMoveUp then
        love.graphics.setColor(0, 255, 0, 255)
    else
        love.graphics.setColor(255, 0, 0, 255)
    end
	love.graphics.rectangle("fill", 200, 10, 5, 5)

	if canMoveDown then
        love.graphics.setColor(0, 255, 0, 255)
    else
        love.graphics.setColor(255, 0, 0, 255)
    end
	love.graphics.rectangle("fill", 200, 20, 5, 5)

	if canMoveLeft then
        love.graphics.setColor(0, 255, 0, 255)
    else
        love.graphics.setColor(255, 0, 0, 255)
    end
	love.graphics.rectangle("fill", 195, 15, 5, 5)

	if canMoveRight then
        love.graphics.setColor(0, 255, 0, 255)
    else
        love.graphics.setColor(255, 0, 0, 255)
    end
	love.graphics.rectangle("fill", 205, 15, 5, 5)

	if ghost.canMoveForward then
        love.graphics.setColor(0, 255, 0, 255)
    else
        love.graphics.setColor(255, 0, 0, 255)
    end
	love.graphics.rectangle("fill", 220, 10, 5, 5)

	if ghost.canMoveLeft then
        love.graphics.setColor(0, 255, 0, 255)
     else
        love.graphics.setColor(255, 0, 0, 255)
    end
	love.graphics.rectangle("fill", 215, 15, 5, 5)

	if ghost.canMoveRight then
        love.graphics.setColor(0, 255, 0, 255)
    else
        love.graphics.setColor(255, 0, 0, 255)
    end
	love.graphics.rectangle("fill", 225, 15, 5, 5)
end