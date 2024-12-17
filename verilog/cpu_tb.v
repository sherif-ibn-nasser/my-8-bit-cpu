`timescale 1ns/1ns
`include "verilog/cpu.v"

module cpu_tb;

    localparam RAM_SIZE = 8;

    reg [(RAM_SIZE * 32) - 1:0] ram;
    reg clk, reset;
    wire [7:0] flags, al, bl, cl, dl;
    wire [31:0] ir;
    wire [15:0] clks;
    wire [7:0] pc;
    wire [1:0] state;

    // Instantiate the Unit Under Test (UUT)
    cpu #(RAM_SIZE) uut (
        .ram(ram),
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
        ram [31:0]    = 32'h000400AA; // mov AL, 0xAA
        ram [63:32]   = 32'h000401BB; // mov BL, 0xBB
        ram [95:64]   = 32'h00050200; // mov CL, AL
        ram [127:96]  = 32'h00050301; // mov DL, BL
        ram [159:128] = 32'h00040002; // mov AL, 02
        ram [191:160] = 32'h000401DD; // mov BL, DD
        ram [223:192] = 32'h00030000; // jmp AL
        clk = 0;
        reset = 1;
        #5;
        reset = 0;
        #200;
        $finish;
    end
    
endmodule