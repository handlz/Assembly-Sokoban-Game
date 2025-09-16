# 🧩 Sokoban Puzzle in RISC-V Assembly

A fully interactive implementation of the **Sokoban puzzle game** written in **RISC-V assembly**.  
This project demonstrates **low-level systems programming**, memory management, and creative game design at the assembly level.

---

## 🎮 Features

- **Core Gameplay**
  - 8×8 grid with ASCII rendering (`#` = wall, `P` = player, `B` = box, `T` = target, `+` = empty).
  - Player movement via `W` (up), `A` (left), `S` (down), `D` (right).
  - Restart with `R`.

- **Procedural Map Generation**
  - Randomized player, box, and target positions using a pseudo-random generator.
  - Ensures no overlapping entities and enforces solvable conditions (e.g., if box spawns on an edge, target is forced on the same edge).

- **Replay System**
  - All moves logged to the stack.
  - At the end of the game, replays each player’s moves step by step.

- **Multiplayer Mode**
  - Supports multiple players with fair turn rotation.
  - Each player’s moves tracked independently using stack pointers.

- **Leaderboard**
  - Displays number of moves taken per player.
  - Announces winner at the end of replays.

---

## ⚙️ Technical Highlights

- **Stack-based memory management** for storing move history and isolating multiplayer sessions.
- **ASCII gameboard rendering** using nested loops, conditional branching, and syscalls.
- **Collision detection** prevents pushing boxes into walls or corners.
- **Replay + Multiplayer Enhancements** extend the base assignment requirements with additional system design complexity.

---

## 📂 Project Structure

- `sokobanpuzzle_gurnoor.s`  
  Entire implementation, including:
  - Data section (grid size, entities, replay state, strings).  
  - `create_map` → random, solvable board generation.  
  - `print_gameboard` → ASCII rendering of grid.  
  - `play_game` → input handling, movement, and collision checks.  
  - `show_leaderboard` → replay and scoring output.  
  - `notrand` → simple pseudo-random function.

---

## 🚀 Running the Game

### Requirements
- A RISC-V simulator such as:
  - [RARS](https://github.com/TheThirdOne/rars)  
  - [Venus](https://kvakil.github.io/venus/)  
  - [CPulator (online)](https://cpulator.01xz.net/?sys=rv32-spim)

### Steps
1. Clone the repo:
   ```bash
   git clone https://github.com/<your-username>/sokoban-riscv.git
   cd sokoban-riscv

