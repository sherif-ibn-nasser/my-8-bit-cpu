module alu (
    input wire [7:0] a, b, cpu_flags,
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
    reg SF, ZF, AF, VF, PF, CF;
    reg [3:0] t0;
    reg [7:0] t1;

    wire
        CPU_SF = cpu_flags[5],
        CPU_ZF = cpu_flags[4],
        CPU_AF = cpu_flags[3],
        CPU_VF = cpu_flags[2],
        CPU_PF = cpu_flags[1],
        CPU_CF = cpu_flags[0];

    always @* begin
        SF = CPU_SF;
        ZF = CPU_ZF;
        AF = CPU_AF;
        VF = CPU_VF;
        PF = CPU_PF;
        CF = CPU_CF;
        case (op)
            OP_AND:    begin
                c = a & b;
                CF = 0;
                VF = 0;
            end
            OP_NAND:   begin
                c = ~(a & b);
                CF = 0;
                VF = 0;
            end
            OP_OR:     begin
                c = a | b;
                CF = 0;
                VF = 0;
            end
            OP_NOR:    begin
                c = ~(a | b);
                CF = 0;
                VF = 0;
            end
            OP_XOR:    begin
                c = a ^ b;
                CF = 0;
                VF = 0;
            end
            OP_XNOR:   begin
                c = ~(a ^ b);
                CF = 0;
                VF = 0;
            end
            OP_ADD:    begin
                {CF, c} = a + b;
                {AF, t0} = a[3:0] + b[3:0];
                VF = (a[7]==b[7]) && (a[7]!=c[7]);
            end
            OP_SUB:    begin
                c = a - b; // Perform subtraction
                CF = (a < b); // Set CF to indicate a borrow
                AF = (a[3:0] < b[3:0]); // Auxiliary CF for the lower nibble
                VF = (a[7] != b[7]) && (a[7] != c[7]);
            end
            OP_NOT: c = ~a;
            OP_NEG:    begin
                CF = -a;
                CF = a != 0;
                {AF, t0} = -a[3:0];
                VF = (a[7]!=b[7]) && (a[7]!=c[7]);
            end
            OP_INC:    begin
                c = a + 1;
                {AF, t0} = a[3:0] + 1;
                VF = (a[7]!=b[7]) && (a[7]!=c[7]);
            end
            OP_DEC:   begin
                c = a - 1;
                {AF, t0} = a[3:0] - 1;
                VF = (a[7]!=b[7]) && (a[7]!=c[7]);
            end
            OP_SHR:    begin
                t1 = a >> (b-1);
                {c, CF} = {1'b0, t1};
            end
            OP_SHL:    begin
                t1 = a << (b-1);
                {CF, c} = {t1, 1'b0};
            end
            OP_SAR:    begin
                t1 = a >>> (b-1);
                {c, CF} = {t1[7], t1};
            end
            OP_MIRROR: c = {a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7]}; // Mirror bits
        endcase

        if (op != OP_NOT && op != OP_MIRROR) begin
            ZF = (c == 8'b0);
            SF = c[7];
            PF = ~^c;                   // Parity flag (1 for even parity, 0 for odd parity)
        end

        flags = {2'b0, SF, ZF, AF, VF, PF, CF};
    end
endmodule
