// Instruction decoder

// xxxx_xxxx xxxx_xxxx xxxx_xxxx xxxx_xxxx
// |||| |||| |||| |||| |||| |||| ^^^^_^^^^ Possible arg 2
// |||| |||| |||| |||| |||| ||||
// |||| |||| |||| |||| ^^^^_^^^^ Possible arg 1
// |||| |||| |||| ^^^^ Function opcode
// |||| |||| ^^^^ Subgroup of instructions
// |||| |^^^ Supergroup of instructions
// ^^^^_^ Execution condition

module CPU (
    input clk,
    input [31:0] inst,
    input [7:0] flags
);

    reg [44:0] main_w_line;
    reg [39:0] alu_w_line;
    reg condition_result; // If set, the instruction will be executed, otherwise it will be skipped

    wire [4:0] condition = inst[31:27];
    wire [2:0] super_group_inst = inst[26:24];
    wire [3:0] sub_group_inst = inst[23:20], funct = inst[19:16];
    wire [7:0] 
        arg1 = inst[15:8],
        arg2 = inst[7:0];

    wire
        VF = flags[5],
        PF = flags[4],
        SF = flags[3],
        ZF = flags[2],
        AF = flags[1],
        CF = flags[0];
    
    wire [7:0] 
        reg_r_select = main_w_line [7:0],
        reg_w_select = main_w_line [15:8],
        reg_w_line = main_w_line [23:16],
        mem_select = main_w_line [31:24],
        mem_w_line = main_w_line [39:32];

    wire /* Execution state signals */
        reg_r = main_w_line [40],
        reg_w = main_w_line [41],
        mem_r = main_w_line [42],
        mem_w = main_w_line [43],
        end_inst = main_w_line [44];
    
    wire [7:0] 
        a_alu = alu_w_line [7:0],
        b_alu = alu_w_line [15:8],
        rl_alu_w = alu_w_line [23:16],
        rh_alu_w = alu_w_line [31:24];

    wire [3:0] op_alu = alu_w_line [35:32];
    wire
        load_r_alu = alu_w_line [36],
        shl_r_alu = alu_w_line [37],
        shl_set_r_alu = alu_w_line [38],
        shr_r_alu = alu_w_line [39];

    always @* begin

        case (condition)
            'h00: condition_result = 1;                 /* Execute unconditionally */
            'h08: condition_result = ZF;                /* ZF */
            'h10: condition_result = ~ZF;               /* Z / E */
            'h20: condition_result = SF;                /* S */
            'h30: condition_result = ~SF;               /* NS */
            'h40: condition_result = ~(ZF | (SF ^ VF)); /* G / NLE */
            'h50: condition_result = ~(SF ^ VF);        /* GE / NL */
            'h60: condition_result = SF ^ VF;           /* L / NGE */
            'h70: condition_result = ZF | (SF ^ VF);    /* LE / NG */
            'h80: condition_result = ~(ZF | CF);        /* A / NBE */
            'h90: condition_result = ~CF;               /* NC / AE / NB */
            'hA0: condition_result = CF;                /* C / B / NAE */
            'hB0: condition_result = ZF | CF;           /* BE / NA */
            'hC0: condition_result = VF;                /* V */
            'hD0: condition_result = ~VF;               /* NV */
            'hE0: condition_result = PF;                /* P */
            'hF0: condition_result = ~PF;               /* NP */
            'hE1: condition_result = AF;                /* HC */
            'hF1: condition_result = ~AF;               /* NHC */
            default: condition_result = 0;              /* Illegal condition code */
        endcase

        // TODO
        
        // case (super_group_inst)
        //     h'00: begin
        //         case (funct)
        //             h'00: basic_instructions = 8'b00000001; /* NOP */
        //             h'01: basic_instructions = 8'b00000010; /* HLT */
        //             h'02: basic_instructions = 8'b00000100; /* JMP Label */
        //             h'03: basic_instructions = 8'b00001000; /* JMP REG */
        //             h'04: basic_instructions = 8'b00010000; /* MOV REG, IMM */
        //             h'05: basic_instructions = 8'b00100000; /* MOV REG, REG */
        //             h'06: basic_instructions = 8'b01000000; /* MUL REG, REG */
        //             h'07: basic_instructions = 8'b10000000; /* DIVREG, REG */
        //         endcase
        //     end
                
        //     h'01: begin
                
        //     end
        //     default: begin
                
        //     end
        // endcase
    end
    
endmodule