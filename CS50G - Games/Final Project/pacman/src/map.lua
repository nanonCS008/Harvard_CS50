map = {}

function map.loadData()
	for i = -5, 22 do
        map[i] = {}
    end		
  
    for x = -5, 21 do
    	for y = -5, 20 do
    		map[x][y] = gfx.cheese
    	end
    end

    for i = 0, 20 do
    	map[i][0] = gfx.tile
    	map[i][20] = gfx.tile
	end

	for i = 0, 20 do 
		if i ~= 10 then
			map[0][i] = gfx.tile
    		map[20][i] = gfx.tile
		end
	end

	map[4][4] = gfx.fruit

	map[10][8] = gfx.black
	map[8][9] = gfx.black
	map[8][10] = gfx.black
	map[8][11] = gfx.black
	map[9][9] = gfx.black
	map[9][10] = gfx.black
	map[9][11] = gfx.black
	map[10][9] = gfx.black
	map[10][10] = gfx.tile
	map[10][11] = gfx.black
	map[11][9] = gfx.black
	map[11][10] = gfx.black
	map[11][11] = gfx.black
	map[12][9] = gfx.black
	map[12][10] = gfx.black
	map[12][11] = gfx.black

	map[7][8] = gfx.tile
	map[8][8] = gfx.tile
	map[9][8] = gfx.tile

	map[11][8] = gfx.tile
	map[12][8] = gfx.tile
	map[13][8] = gfx.tile

	map[7][9] = gfx.tile
	map[13][9] = gfx.tile

	map[7][10] = gfx.tile
	map[13][10] = gfx.tile

	map[7][11] = gfx.tile
	map[13][11] = gfx.tile

	map[7][12] = gfx.tile
	map[8][12] = gfx.tile
	map[9][12] = gfx.tile
	map[10][12] = gfx.tile
	map[11][12] = gfx.tile
	map[12][12] = gfx.tile
	map[13][12] = gfx.tile

	map[7][5] = gfx.tile
	map[7][6] = gfx.tile
	map[8][5] = gfx.tile
	map[8][6] = gfx.tile
	map[9][5] = gfx.tile
	map[9][6] = gfx.tile
	map[10][5] = gfx.tile
	map[10][6] = gfx.tile
	map[11][5] = gfx.tile
	map[11][6] = gfx.tile
	map[12][5] = gfx.tile
	map[12][6] = gfx.tile
	map[13][5] = gfx.tile
	map[13][6] = gfx.tile

	map[7][14] = gfx.tile
	map[7][15] = gfx.tile
	map[8][14] = gfx.tile
	map[8][15] = gfx.tile
	map[9][14] = gfx.tile
	map[9][15] = gfx.tile
	map[10][14] = gfx.tile
	map[10][15] = gfx.tile
	map[11][14] = gfx.tile
	map[11][15] = gfx.tile
	map[12][14] = gfx.tile
	map[12][15] = gfx.tile
	map[13][14] = gfx.tile
	map[13][15] = gfx.tile

	map[2][2] = gfx.tile
	map[3][2] = gfx.tile
	map[4][2] = gfx.tile
	map[2][3] = gfx.tile
	map[3][3] = gfx.tile
	map[4][3] = gfx.tile

	map[6][2] = gfx.tile
	map[7][2] = gfx.tile
	map[8][2] = gfx.tile
	map[9][2] = gfx.tile
	map[6][3] = gfx.tile
	map[7][3] = gfx.tile
	map[8][3] = gfx.tile
	map[9][3] = gfx.tile

	map[2][5] = gfx.tile
	map[3][5] = gfx.tile
	map[4][5] = gfx.tile
	map[5][5] = gfx.tile
	map[2][6] = gfx.tile
	map[3][6] = gfx.tile
	map[4][6] = gfx.tile
	map[5][6] = gfx.tile
	map[2][7] = gfx.tile
	map[3][7] = gfx.tile
	map[4][7] = gfx.tile
	map[5][7] = gfx.tile

	map[1][9] = gfx.tile
	map[2][9] = gfx.tile
	map[3][9] = gfx.tile
	map[4][9] = gfx.tile
	map[5][9] = gfx.tile

	map[1][11] = gfx.tile
	map[2][11] = gfx.tile
	map[3][11] = gfx.tile
	map[4][11] = gfx.tile
	map[5][11] = gfx.tile

	map[2][13] = gfx.tile
	map[3][13] = gfx.tile
	map[4][13] = gfx.tile
	map[5][13] = gfx.tile
	map[2][14] = gfx.tile
	map[3][14] = gfx.tile
	map[4][14] = gfx.tile
	map[5][14] = gfx.tile
	map[2][15] = gfx.tile
	map[3][15] = gfx.tile
	map[4][15] = gfx.tile
	map[5][15] = gfx.tile

	map[2][17] = gfx.tile
	map[3][17] = gfx.tile
	map[4][17] = gfx.tile
	map[2][18] = gfx.tile
	map[3][18] = gfx.tile
	map[4][18] = gfx.tile

	map[6][17] = gfx.tile
	map[7][17] = gfx.tile
	map[8][17] = gfx.tile
	map[9][17] = gfx.tile
	map[6][18] = gfx.tile
	map[7][18] = gfx.tile
	map[8][18] = gfx.tile
	map[9][18] = gfx.tile

	map[11][2] = gfx.tile
	map[12][2] = gfx.tile
	map[13][2] = gfx.tile
	map[14][2] = gfx.tile
	map[11][3] = gfx.tile
	map[12][3] = gfx.tile
	map[13][3] = gfx.tile
	map[14][3] = gfx.tile

	map[16][2] = gfx.tile
	map[17][2] = gfx.tile
	map[18][2] = gfx.tile
	map[16][3] = gfx.tile
	map[17][3] = gfx.tile
	map[18][3] = gfx.tile

	map[15][5] = gfx.tile
	map[16][5] = gfx.tile
	map[17][5] = gfx.tile
	map[18][5] = gfx.tile
	map[15][6] = gfx.tile
	map[16][6] = gfx.tile
	map[17][6] = gfx.tile
	map[18][6] = gfx.tile
	map[15][7] = gfx.tile
	map[16][7] = gfx.tile
	map[17][7] = gfx.tile
	map[18][7] = gfx.tile

	map[15][9] = gfx.tile
	map[16][9] = gfx.tile
	map[17][9] = gfx.tile
	map[18][9] = gfx.tile
	map[19][9] = gfx.tile

	map[15][11] = gfx.tile
	map[16][11] = gfx.tile
	map[17][11] = gfx.tile
	map[18][11] = gfx.tile
	map[19][11] = gfx.tile
	
	map[16][13] = gfx.tile
	map[15][13] = gfx.tile
	map[17][13] = gfx.tile
	map[18][13] = gfx.tile
	map[15][14] = gfx.tile
	map[16][14] = gfx.tile
	map[17][14] = gfx.tile
	map[18][14] = gfx.tile
	map[15][15] = gfx.tile
	map[16][15] = gfx.tile
	map[17][15] = gfx.tile
	map[18][15] = gfx.tile

	map[11][17] = gfx.tile
	map[12][17] = gfx.tile
	map[13][17] = gfx.tile
	map[14][17] = gfx.tile
	map[11][18] = gfx.tile
	map[12][18] = gfx.tile
	map[13][18] = gfx.tile
	map[14][18] = gfx.tile

	map[16][17] = gfx.tile
	map[17][17] = gfx.tile
	map[18][17] = gfx.tile
	map[16][18] = gfx.tile
	map[17][18] = gfx.tile
	map[18][18] = gfx.tile
end