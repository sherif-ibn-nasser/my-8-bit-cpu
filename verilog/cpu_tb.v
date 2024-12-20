`timescale 1ns/1ns
`include "verilog/cpu.v"

module cpu_tb;

    localparam RAM_SIZE = 8;
    
    reg [31:0] ram [0:RAM_SIZE-1]; // Memory array for RAM
    reg [(RAM_SIZE * 32) - 1:0] ram_flat;
    reg clk, reset;
    wire [7:0] flags, al, bl, cl, dl;
    wire [31:0] ir;
    wire [15:0] clks;
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
        .ir(ir),
        .clks(clks),
        .pc(pc),
        .state(state)
    );

    integer i;

    // Clock Generation
    always #5 clk = ~clk; // Generate a clock with a period of 10ns (5ns high, 5ns low)

    // Initial Block for Test Scenarios
    initial begin
        // Enable VCD Dump for GTKWave
        $dumpfile("cpu_wave.vcd"); // Specify the output VCD file
        $dumpvars(0, cpu_tb);      // Dump all variables in the scope
        
        // Monitor Outputs for Debugging
        $monitor("Time: %0t | Reset: %b | AL: %h | BL: %h | CL: %h | DL: %h", 
                 $time, reset, al, bl, cl, dl);

        // Initialize Inputs
        $readmemh("../verilog/programs/mov_and_jmp.hex", ram);

        for (i = 0; i < RAM_SIZE; i = i + 1) begin
            ram_flat[(i+1)*32-1 -: 32] = ram[i];
        end

        clk = 0;
        reset = 1;
        #5;
        reset = 0;
        #200;
        $finish;
    end
    
endmodule