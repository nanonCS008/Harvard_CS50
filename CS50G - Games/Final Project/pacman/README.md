# Pacman

## Final Project for CS50G - CS50's Introduction to Game Development.

Pacman is a classic arcade-style game recreated in Lua, using the LOVE game engine. The objective is to eat all the yellow dots in the maze while avoiding the ghosts. If you touch a ghost, it's Game Over. However, if you eat the special fruit, you can eat the ghosts for a brief period of time.

### Gameplay
You control Pacman as he navigates through a maze, eating yellow dots (points) and avoiding ghosts. The main objectives are:
- Eat all the yellow dots to win the game.
- Avoid touching the ghosts to stay alive.
- Eat the special fruit to temporarily gain the ability to eat ghosts.

The game starts with Pacman at a specific position in the maze. As you move around, you must avoid the ghosts that wander the maze. When you eat all the yellow dots, you win the game. If a ghost catches you, the game is over. If you eat a fruit, the ghosts become vulnerable for a short time, allowing you to eat them for extra points.

You can press Esc to quit the game at any point.

### Development
The development for this game was a hands-on experience. I had to gather various free assets, including character sprites, ghost sprites, maze tilesets, and sound effects.

#### Core Components
1. **Maze Generation**:
   - The maze is generated using a predefined layout stored in a 2D array. Each element of the array represents a different type of tile (wall, path, dot, fruit, etc.).
   - A Maze class is responsible for drawing the maze and checking collisions with walls.

2. **Player (Pacman)**:
   - Pacman is controlled by the player using the arrow keys.
   - A Player class handles movement, collision detection with walls, and interactions with dots, fruits, and ghosts.

3. **Ghosts**:
   - There are multiple ghosts in the game, each with different movement patterns.
   - Ghosts have two states: Normal and Vulnerable. In the Vulnerable state, they can be eaten by Pacman.
   - A Ghost class manages the movement, state changes, and interactions with Pacman.

4. **Collision Detection**:
   - Collision detection is handled using bounding boxes for Pacman and the ghosts.
   - When Pacman collides with a dot, the dot is eaten, and the score is updated.
   - When Pacman collides with a ghost in the Normal state, the game is over. If the ghost is in the Vulnerable state, the ghost is eaten, and the score is updated.

5. **Fruit**:
   - Fruits appear at specific intervals in the game.
   - When Pacman eats a fruit, all ghosts become Vulnerable for a short period.
   - A Fruit class manages the appearance and effects of the fruit.

### Implementing Game Mechanics

#### Movement and Collision
- **Pacman's Movement**:
  - Pacman moves continuously in the direction of the last arrow key pressed.
  - Collision with walls is checked every frame to ensure smooth movement.

- **Ghosts' Movement**:
  - Ghosts follow specific movement patterns or algorithms (e.g., random movement, targeting Pacman).
  - When in the Vulnerable state, ghosts move away from Pacman.

#### Eating Dots and Fruits
- **Dots**:
  - Each dot eaten increases the player's score.
  - The game checks if all dots are eaten to determine if the player wins.

- **Fruits**:
  - Eating a fruit makes the ghosts vulnerable, allowing Pacman to eat them for additional points.
  - The Vulnerable state lasts for a limited time before the ghosts revert to their Normal state.

### Miscelanious Features
- **Audio Effects**:
  - Different sound effects are used for eating dots, fruits, and ghosts, and for game over.

- **Quit**:
  - Press Esc to quit the game.

- **Visuals**:
  - The game features different sprites for Pacman, ghosts, dots, and fruits.
  - The maze is designed to resemble the classic Pacman layout.

## Final Thoughts

Developing this Pacman game was a challenging and rewarding experience. It deepened my understanding of game development concepts such as collision detection, state management, and sprite animation. I hope you enjoy playing it as much as I enjoyed creating it!
