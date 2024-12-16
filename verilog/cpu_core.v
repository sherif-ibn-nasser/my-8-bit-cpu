module cpu_core #(
    parameter RAM_SIZE = 256  // Number of 32-bit words in RAM
)(
    input wire [(RAM_SIZE * 32) - 1:0] ram,
    input wire clk, reset, inst_condition, end_inst, jmp_inst,
    input wire [7:0] jmp_address,
    output reg [31:0] ir,   // instruction register
    output reg [15:0] clks, // clk counter
    output reg [7:0] pc,    // program counter
    output reg [1:0] state
);

    // Internal RAM mapping
    wire [31:0] ram_array [RAM_SIZE-1:0];
    genvar i;
    generate
        for (i = 0; i < RAM_SIZE; i = i + 1) begin
            assign ram_array[i] = ram[i * 32 +: 32];
        end
    endgenerate

    localparam
        CLK_0 = 16'b0000_0000__0000_0001,
        CLK_1 = 16'b0000_0000__0000_0010,
        CLK_2 = 16'b0000_0000__0000_0100,
        CLK_3 = 16'b0000_0000__0000_1000,
        CLK_4 = 16'b0000_0000__0001_0000,
        CLK_5 = 16'b0000_0000__0010_0000,
        CLK_6 = 16'b0000_0000__0100_0000,
        CLK_7 = 16'b0000_0000__1000_0000,
        CLK_8 = 16'b0000_0001__0000_0000,
        CLK_9 = 16'b0000_0010__0000_0000,
        CLK_A = 16'b0000_0100__0000_0000,
        CLK_B = 16'b0000_1000__0000_0000,
        CLK_C = 16'b0001_0000__0000_0000,
        CLK_D = 16'b0010_0000__0000_0000,
        CLK_E = 16'b0100_0000__0000_0000,
        CLK_F = 16'b1000_0000__0000_0000;

    localparam
        IF = 0,  // Instruction fetch
        IE = 1,  // Instruction execute
        HLT = 2; // Halt

    reg [15:0] next_clks;

    always @* begin
        case (clks)
            CLK_0:    next_clks = CLK_1;
            CLK_1:    next_clks = CLK_2;
            CLK_2:    next_clks = CLK_3;
            CLK_3:    next_clks = CLK_4;
            CLK_4:    next_clks = CLK_5;
            CLK_5:    next_clks = CLK_6;
            CLK_6:    next_clks = CLK_7;
            CLK_7:    next_clks = CLK_8;
            CLK_8:    next_clks = CLK_9;
            CLK_9:    next_clks = CLK_A;
            CLK_A:    next_clks = CLK_B;
            CLK_B:    next_clks = CLK_C;
            CLK_C:    next_clks = CLK_D;
            CLK_D:    next_clks = CLK_E;
            CLK_E:    next_clks = CLK_F;
            default:  next_clks = CLK_0;
        endcase
    end

    always @(posedge clk or posedge reset) begin

        if (reset) begin // Forced reset
            clks <= 0;
            state <= IF;
            pc <= 0;
            ir <= 0;
        end
        else begin
            case (state)
                IF: begin
                    clks <= CLK_0;
                    state <= IE;
                    ir <= ram_array[pc];
                end
                IE: begin
                    if (end_inst || !inst_condition) begin
                        pc <= (jmp_inst)? jmp_address : pc + 1;
                        state <= IF;
                    end
                    else clks <= next_clks;
                end
                default: clks <= next_clks;
            endcase 
        end
    
    end
endmodule