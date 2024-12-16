`timescale 1ns/1ns
`include "verilog/reg_file.v"

module reg_file_tb;

    // Testbench Signals
    reg clk, reg_r, reg_w, reset;
    reg [7:0] reg_w_line, reg_w_select, reg_r_select;
    wire [7:0] reg_r_line, al, bl, cl, dl;

    // Instantiate the Unit Under Test (UUT)
    reg_file uut(
        .clk(clk),
        .reg_r(reg_r),
        .reg_w(reg_w),
        .reset(reset),
        .reg_w_line(reg_w_line),
        .reg_w_select(reg_w_select),
        .reg_r_select(reg_r_select),
        .reg_r_line(reg_r_line),
        .al(al),
        .bl(bl),
        .cl(cl),
        .dl(dl)
    );

    // Clock Generation
    always #5 clk = ~clk; // Generate a clock with a period of 10ns (5ns high, 5ns low)

    // Initial Block for Test Scenarios
    initial begin
        // Enable VCD Dump for GTKWave
        $dumpfile("reg_file_wave.vcd"); // Specify the output VCD file
        $dumpvars(0, reg_file_tb);      // Dump all variables in the scope

        // Monitor Outputs for Debugging
        $monitor("Time: %0t | Reset: %b | Write: %b | Read: %b | W_Data: %b | W_Sel: %b | R_Sel: %b | R_Data: %b | AL: %b | BL: %b | CL: %b | DL: %b", 
                 $time, reset, reg_w, reg_r, reg_w_line, reg_w_select, reg_r_select, reg_r_line, al, bl, cl, dl);

        // Initialize Inputs
        clk = 0;
        reset = 0;
        reg_r = 0;
        reg_w = 0;
        reg_w_line = 8'b00000000;
        reg_w_select = 8'b00000000;
        reg_r_select = 8'b00000000;

        // Apply Reset
        $display("Applying Reset...");
        reset = 1;
        #10;
        reset = 0;

        // Write to Register AL
        $display("Writing to Register AL...");
        reg_w = 1;
        reg_w_line = 8'hAA; // Data to write
        reg_w_select = uut.AL;    // Select AL register
        #10;

        // Write to Register BL
        $display("Writing to Register BL...");
        reg_w_line = 8'hBB; // Data to write
        reg_w_select = uut.BL;    // Select BL register
        #10;

        // Write to Register CL
        $display("Writing to Register CL...");
        reg_w_line = 8'hCC; // Data to write
        reg_w_select = uut.CL;    // Select CL register
        #10;

        // Write to Register DL
        $display("Writing to Register DL...");
        reg_w_line = 8'hDD; // Data to write
        reg_w_select = uut.DL;    // Select DL register
        #10;

        // Disable Write
        reg_w = 0;

        // Read from Register AL
        $display("Reading from Register AL...");
        reg_r = 1;
        reg_r_select = uut.AL;
        #10;

        // Read from Register BL
        $display("Reading from Register BL...");
        reg_r_select = uut.BL;
        #10;

        // Read from Register CL
        $display("Reading from Register CL...");
        reg_r_select = uut.CL;
        #10;

        // Read from Register DL
        $display("Reading from Register DL...");
        reg_r_select = uut.DL;
        #10;

        // Apply Reset
        $display("Applying Reset...");
        reset = 1;
        #10;

        // End Testbench
        $display("Testbench Finished.");
        $finish;
    end

endmodule
