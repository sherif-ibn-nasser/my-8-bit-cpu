module alu (
    input wire [7:0] a, b,
    input wire [3:0] op,
    output reg [7:0] c,
    output reg [7:0] flags
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
        OP_NEG       = 4'b1001,
        OP_INC       = 4'b1010,
        OP_DEC       = 4'b1011,
        OP_SHR       = 4'b1100,
        OP_SHL       = 4'b1101,
        OP_SAR       = 4'b1110,
        OP_MIRROR    = 4'b1111;

    // Local flag wires
    reg overflow, parity, sign, zero, aux_carry, carry;
    reg [3:0] t0;
    reg [7:0] t1;

    always @* begin
        case (op)
            OP_AND:    begin
                c = a & b; 
                carry = 0;
                overflow = 0;
            end
            OP_NAND:   begin
                c = ~(a & b);
                carry = 0;
                overflow = 0;
            end
            OP_OR:     begin
                c = a | b;
                carry = 0;
                overflow = 0;
            end
            OP_NOR:    begin
                c = ~(a | b);
                carry = 0;
                overflow = 0;
            end
            OP_XOR:    begin
                c = a ^ b;
                carry = 0;
                overflow = 0;
            end
            OP_XNOR:   begin
                c = ~(a ^ b);
                carry = 0;
                overflow = 0;
            end
            OP_ADD:    begin
                {carry, c} = a + b;
                {aux_carry, t0} = a[3:0] + b[3:0];
                overflow = (a[7]==b[7]) && (a[7]!=c[7]);
            end
            OP_SUB:    begin
                c = a - b; // Perform subtraction
                carry = (a < b); // Set carry to indicate a borrow
                aux_carry = (a[3:0] < b[3:0]); // Auxiliary carry for the lower nibble
                overflow = (a[7] != b[7]) && (a[7] != c[7]);
            end
            OP_NOT:    c = ~a;
            OP_NEG:    begin
                {carry, c} = 0 - a;
                {aux_carry, t0} = 0 - a[3:0];
                overflow = (a[7]!=b[7]) && (a[7]!=c[7]);
            end
            OP_INC:    begin
                {carry, c} = a + 1;
                {aux_carry, t0} = a[3:0] + 1;
                overflow = (a[7]!=b[7]) && (a[7]!=c[7]);
            end
            OP_DEC:   begin
                {carry, c} = a - 1;
                {aux_carry, t0} = a[3:0] - 1;
                overflow = (a[7]!=b[7]) && (a[7]!=c[7]);
            end
            OP_SHR:    begin
                c = a >> b;
                t1 = a >> (b-1);
                carry = t1[0];
            end
            OP_SHL:    begin
                t1 = a << (b-1);
                carry = t1[0];
                c = a << 1;
            end
            OP_SAR:    begin
                t1 = a >>> (b-1);
                carry = t1[0];
                c = t1 >>> 1;
            end
            OP_MIRROR: c = {a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7]}; // Mirror bits
        endcase

        zero = (c == 8'b0);
        sign = c[7];
        parity = ~^c;                   // Parity flag (1 for even parity, 0 for odd parity)

        flags = {2'b0, overflow, parity, sign, zero, aux_carry, carry};
    end
endmodule
