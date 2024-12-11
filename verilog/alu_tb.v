`include "verilog/alu.v"
module tb_alu;

    reg  [7:0] a, b;
    reg  [3:0] op;
    wire [7:0] c;
    wire [7:0] flags;

    alu uut (
        .a(a),
        .b(b),
        .op(op),
        .c(c),
        .flags(flags)
    );

    initial begin
        $monitor("Time=%0t | a=%b, b=%b, op=%b, c=%b", $time, a, b, op, c);
        
        a = 8'b11001010; b = 8'b10101010; op = uut.OP_AND;    #10;
        a = 8'b11001010; b = 8'b10101010; op = uut.OP_ADD;    #10;
        a = 8'b11001010; b = 8'b10101010; op = uut.OP_SUB;    #10;
        a = 8'b00101111; b = 8'b00000000; op = uut.OP_MIRROR; #10;
        
        $stop;
    end
endmodule
