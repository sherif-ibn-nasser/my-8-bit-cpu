module alu (
    input wire [7:0] a, b,
    input wire [3:0] op,          // Extend op to 4 bits to support operations 8-15
    output reg [7:0] c,
    output reg [7:0] flags        // Reserved for flags
);
    // Define operation codes using localparam
    localparam [3:0]
        OP_AND       = 4'b0000,
        OP_NAND      = 4'b0001,
        OP_OR        = 4'b0010,
        OP_NOR       = 4'b0011,
        OP_XOR       = 4'b0100,
        OP_XNOR      = 4'b0101,
        OP_ADD       = 4'b0110,
        OP_SUB       = 4'b0111,
        OP_NOT       = 4'b1000,
        OP_NEGATE    = 4'b1001,
        OP_INC       = 4'b1010,
        OP_DEC       = 4'b1011,
        OP_SHR       = 4'b1100,
        OP_SHL       = 4'b1101,
        OP_SAR       = 4'b1110,
        OP_MIRROR    = 4'b1111;

    always @* begin
        case (op)
            OP_AND:    c = a & b;                       // AND
            OP_NAND:   c = ~(a & b);                    // NAND
            OP_OR:     c = a | b;                       // OR
            OP_NOR:    c = ~(a | b);                    // NOR
            OP_XOR:    c = a ^ b;                       // XOR
            OP_XNOR:   c = ~(a ^ b);                    // XNOR
            OP_ADD:    c = a + b;                       // ADD
            OP_SUB:    c = a - b;                       // SUBTRACT
            OP_NOT:    c = ~a;                          // NOT
            OP_NEGATE: c = -a;                          // NEGATE
            OP_INC:    c = a + 1;                       // INCREMENT
            OP_DEC:    c = a - 1;                       // DECREMENT
            OP_SHR:    c = a >> b;                      // SHIFT RIGHT
            OP_SHL:    c = a << b;                      // SHIFT LEFT
            OP_SAR:   c = a <<< b;                      // ROTATE LEFT
            OP_MIRROR: c = {a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7]}; // Mirror bits
        endcase
    end
endmodule
