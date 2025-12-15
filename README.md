# Matrix-Based Tic-Tac-Toe in x86 Assembly

### Overview
This project is a CLI-based Tic-Tac-Toe game developed in **16-bit x86 Assembly language** (.MODEL SMALL). Unlike simple implementations, this project uses **matrix logic** to manage the game state, treating the linear memory segment as a 3x3 grid through offset calculations.

### Key Features
* **Game Modes:** Supports both Player vs. Player (PvP) and Player vs. Computer (PvE).
* **Matrix Logic:** Implements a coordinate system to map user input (1-9) to specific memory addresses using row/column offset calculations (`[BX][SI]`).
* **Input Validation:** Robust checking for invalid keys and occupied slots.
* **Modular Code:** Organized into procedures (`PROC`) for board initialization, rendering, move validation, and victory checking.

### How to Run
Requires an x86 emulator like **DOSBox** and an assembler like **TASM** or **MASM**.
1. Assemble the code: `tasm jgdv.asm`
2. Link the object file: `tlink jgdv.obj`
3. Run the executable: `jgdv.exe`
