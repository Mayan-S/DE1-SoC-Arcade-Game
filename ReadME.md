# Asteroids

## Overview

Navigate your spaceship through waves of asteroids coming from all four directions while defending yourself with rapid-fire bullets. The game tests your reflexes and navigation skills as you try to survive as long as possible. Your survival time is displayed on the board's HEX displays, tracking every second you stay alive.

The complete Verilog implementation can be found in the 'Game_Code' directory.

## Hardware Requirements

- **FPGA Board**: DE1-SoC Development Board
- **Display**: VGA-compatible monitor
- **Input**: PS/2 Keyboard
- **Clock**: 50MHz system clock

## How to Play

### Getting Started

1. **Start**: The game begins automatically when powered on
2. **Movement**: Use WASD keys to navigate your spaceship around the 640×480 screen
3. **Combat**: Press SPACEBAR to fire bullets in the direction your ship is facing
4. **Objective**: Dodge the asteroids coming from all four sides and destroy them with your bullets
5. **Collision**: The game freezes when your ship collides with any asteroid
6. **Timer**: The HEX displays count up from 000000, showing your survival time in seconds
7. **Reset**: Press KEY[0] to clear the screen and restart

### Controls

- **W** - Move forward 
- **A** - Turn left 
- **S** - Move backward
- **D** - Turn right
- **SPACEBAR** - Fire bullets
- **KEY[0]** - Reset game

### Game Preview
![20260107_205118](https://github.com/user-attachments/assets/2e8057c6-02f0-4d5f-a76b-05231ea0d059)

![another_photo](https://github.com/user-attachments/assets/3970d3a4-d557-42cf-b988-931dacbfd524)

