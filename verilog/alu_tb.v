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
        $display("Flags: overflow, parity, sign, zero, aux_carry, carry");
        $monitor("Time=%0t | a=%b, b=%b, op=%b, c=%b, FLAGS=%b", $time, a, b, op, c, flags);
        
        a = 8'b11001010; b = 8'b10101010; op = uut.OP_AND;    #10;
        a = 8'b11001010; b = 8'b10101010; op = uut.OP_NAND;   #10;
        a = 8'b11001010; b = 8'b10101010; op = uut.OP_OR;     #10;
        a = 8'b11001010; b = 8'b10101010; op = uut.OP_NOR;    #10;
        a = 8'b11001010; b = 8'b10101010; op = uut.OP_XOR;    #10;
        a = 8'b11001010; b = 8'b10101010; op = uut.OP_XNOR;   #10;
        a = 8'b11001010; b = 8'b10101010; op = uut.OP_ADD;    #10;
        a = 8'b11001010; b = 8'b10101010; op = uut.OP_SUB;    #10;
        a = 8'b11001010; b = 8'b10101010; op = uut.OP_NOT;    #10;
        a = 8'b11001010; b = 8'b10101010; op = uut.OP_NEG;    #10;
        a = 8'b11001010; b = 8'b10101010; op = uut.OP_INC;    #10;
        a = 8'b11001010; b = 8'b10101010; op = uut.OP_DEC;    #10;
        a = 8'b11001010; b = 8'h2; op = uut.OP_SHR;    #10;
        a = 8'b11001010; b = 8'h1; op = uut.OP_SHL;    #10;
        a = 8'b11001010; b = 8'h2; op = uut.OP_SAR;    #10;
        a = 8'b00101111; b = 8'b00000000; op = uut.OP_MIRROR; #10;
        $display("Bin: 01100000 : %b", ~(^8'b01100000));
        
        $finish;
    end
endmodule
