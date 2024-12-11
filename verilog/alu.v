module alu (
    input wire [7:0] a, b,
    input wire [3:0] op,
    output reg [7:0] c,
    output reg [7:0] flags
);
    always @* begin
        case (op)
            0: c = a & b;
            1: c = ~(a & b);
            2: c = a | b;
            3: c = ~(a | b);
            4: c = a ^ b;
            5: c = ~(a ^ b);
            6: c = a + b;
            7: c = a - b;
            8: c = ~a;
            9: c = -a;
            10: c = a+1;
            11: c = a-1;
            12: c = a>>b;
            13: c = a<<b;
            14: c = a<<<b;
            15: c = {a[7], a[6], a[5], a[4], a[3], a[2], a[1], a[0]};
        endcase
        
    end
endmodule