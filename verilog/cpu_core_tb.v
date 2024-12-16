`timescale 1ns/1ns
`include "verilog/cpu_core.v"

module cpu_core_tb;
    
    localparam RAM_SIZE = 4;

    reg [(RAM_SIZE * 32) - 1:0] ram;
    reg clk, reset, inst_condition, end_inst, jmp_inst, hlt_inst;
    reg [7:0] jmp_address;

    wire [31:0] ir;
    wire [15:0] clks;
    wire [7:0] pc;
    wire [1:0] state;

    // Instantiate the Unit Under Test (UUT)
    cpu_core #(RAM_SIZE) uut(
        .ram(ram),
        .clk(clk), .reset(reset), .inst_condition(inst_condition),
        .end_inst(end_inst), .jmp_inst(jmp_inst), .hlt_inst(hlt_inst),
        .jmp_address(jmp_address),
        .ir(ir), .clks(clks), .pc(pc), .state(state)
    );

    // Clock Generation
    always #5 clk = ~clk; // Generate a clock with a period of 10ns (5ns high, 5ns low)


    // Initial Block for Test Scenarios
    initial begin
        // Enable VCD Dump for GTKWave
        $dumpfile("cpu_core_wave.vcd"); // Specify the output VCD file
        $dumpvars(0, cpu_core_tb);      // Dump all variables in the scope


        // Initialize Inputs

        ram [31:0] = 32'h00112233;
        ram [63:32] = 32'h44556677;
        ram [95:64] = 32'h8899AABB;
        ram [127:96] = 32'hCCDDEEFF;

        clk = 0;
        reset = 0;
        inst_condition = 0;
        end_inst = 0;
        jmp_inst = 0;
        hlt_inst = 0;
        jmp_address = 0;


        // Apply Reset
        $display("Applying Reset...");
        reset = 1;
        #10;

        reset = 0;
        inst_condition = 1;
        #40;
        end_inst = 1;
        #40;
        jmp_inst = 1;
        #10;
        jmp_inst = 0;
        #40;
        end_inst = 0;
        #25;
        jmp_address = 1;
        jmp_inst = 1;
        end_inst = 1;
        #40;
        hlt_inst = 1;
        #20;
        hlt_inst = 0;
        reset = 1;
        #5
        reset = 0;
        #45;

        $finish;
    end

endmodule