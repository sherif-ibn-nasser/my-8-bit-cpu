`timescale 1ns/1ns
`include "cpu.v"

module cpu_tb;

    localparam RAM_SIZE = 16;

    reg [31:0] ram [0:RAM_SIZE-1]; // Memory array for RAM
    reg [(RAM_SIZE * 32) - 1:0] ram_flat;
    reg clk, reset;
    wire [7:0] flags, al, bl, cl, dl;
    wire [31:0] ir;
    wire [15:0] clks, r_l_h;
    wire [7:0] pc;
    wire [1:0] state;

    // Instantiate the Unit Under Test (UUT)
    cpu #(RAM_SIZE) uut (
        .ram(ram_flat),
        .clk(clk),
        .reset(reset),
        .flags(flags),
        .al(al),
        .bl(bl),
        .cl(cl),
        .dl(dl),
        .r_l_h(r_l_h),
        .ir(ir),
        .clks(clks),
        .pc(pc),
        .state(state)
    );

    integer i;

    // Clock Generation
    always #5 clk = ~clk; // Generate a clock with a period of 10ns (5ns high, 5ns low)

    // Initial Block for Test Scenarios
    initial
    begin
        // Enable VCD Dump for GTKWave
        $dumpfile("cpu_wave.vcd"); // Specify the output VCD file
        $dumpvars(0, cpu_tb);      // Dump all variables in the scope

        // Monitor Outputs for Debugging
        $monitor("Time: %3t | Reset: %b | AL: %h | BL: %h | CL: %h | DL: %h | RH:RL: %h",
                $time, reset, al, bl, cl, dl, r_l_h);

        // Initialize Inputs
        // $readmemh("../programs/mov_jmp.hex", ram);
        // $readmemh("../programs/math_imm.hex", ram);
        // $readmemh("../programs/mul.hex", ram);
        $readmemh("../programs/div.hex", ram);

        for (i = 0; i < RAM_SIZE; i = i + 1)
        begin
        ram_flat[(i+1)*32-1 -: 32] = ram[i];
        end

        clk = 0;
        reset = 1;
        #1;
        reset = 0;
        #4
        #250;
        $finish;
    end

endmodule
