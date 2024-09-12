# My 8-bit CPU

This 8-bit CPU represents a unique project where I designed and imagined a custom 8-bit processor. It showcases my vision of how a simple yet functional processor can be built and simulated.

## Features

- **8-bit Data Bus**: The CPU processes 8-bit instructions and data, ideal for simple computation tasks.
- **Instruction Set Architecture (ISA)**: A custom instruction set has been designed to control the CPU, allowing for operations like addition, subtraction, logical operations, and jumps.
- **Logisim Implementation**: The design is implemented using Logisim, a graphical tool for designing and simulating logic circuits. You can visualize the entire flow of instructions and data in the system.
- **Control Unit & ALU**: The CPU contains a basic ALU (Arithmetic Logic Unit) and a control unit to manage the execution of instructions.

## Instruction Set Manual

A detailed description of the instruction set can be found in the [Instruction Set Manual](https://github.com/sherif2003/my-8-bit-cpu/blob/main/My%208-bit%20CPU%20Instruction%20Set%20MANUAL.pdf), which includes:

- **Basic Instructions**: Load, move, and arithmetic operations.
- **Control Flow Instructions**: Jump, conditional branches, etc.
- **Logical Operations**: AND, OR, NOT, XOR, etc.

## Full Screenshot

Below is a full screenshot of the 8-bit CPU design in Logisim:

![Full Screenshot](assets/full-screenshot.png)

This image shows the entire layout of the CPU, including the control unit, ALU, data bus, and more.

## Demo

You can see the CPU in action by watching the demo video

The video shows the execution of a sample program written in machine code using the [instruction set](https://github.com/sherif2003/my-8-bit-cpu/blob/main/My%208-bit%20CPU%20Instruction%20Set%20Manual.pdf).

<video width="320" height="240" controls>
  <source src="assets/demo.mp4" type="video/mp4">
</video>


## How to Run

1. Download and install [Logisim](https://github.com/logisim-evolution/logisim-evolution).
2. Clone this repository to your local machine:
   ```bash
   git clone https://github.com/sherif2003/my-8-bit-cpu.git
   ```
3. Open the project file (`cpu.circ`) in Logisim.
4. Follow the [Instruction Set Manual](https://github.com/sherif2003/my-8-bit-cpu/blob/main/My%208-bit%20CPU%20Instruction%20Set%20Manual.pdf) to write your program
5. Write your program as a text file in the form of machine code as in [this example](https://github.com/sherif2003/my-8-bit-cpu/blob/main/example)
6. Simulate the CPU and observe the results of various instructions by stepping through the execution cycle.