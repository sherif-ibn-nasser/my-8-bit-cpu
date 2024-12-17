// Instruction decoder

// xxxx_xxxx xxxx_xxxx xxxx_xxxx xxxx_xxxx
// |||| |||| |||| |||| |||| |||| ^^^^_^^^^ Possible arg 2
// |||| |||| |||| |||| |||| ||||
// |||| |||| |||| |||| ^^^^_^^^^ Possible arg 1
// |||| |||| |||| ^^^^ Function opcode
// |||| |||| ^^^^ Subgroup of instructions
// |||| |^^^ Supergroup of instructions
// ^^^^_^ Execution condition

`include "verilog/cpu_core.v"
`include "verilog/reg_file.v"
module cpu #(
    parameter RAM_SIZE = 256  // Number of 32-bit words in RAM
)(
    input wire [(RAM_SIZE * 32) - 1:0] ram,
    input clk, reset,
    output reg [7:0] flags,
    output [7:0] al, bl, cl, dl,
    output [31:0] ir,
    output [15:0] clks,
    output [7:0] pc,
    output [1:0] state
);

    reg [44:0] main_w_line;
    reg [39:0] alu_w_line;

    reg
        condition_result, // If set, the instruction will be executed, otherwise it will be skipped
        jmp_inst,
        hlt_inst;

    reg [7:0] jmp_address;
    

    wire [4:0] condition = ir[31:27];

    wire [2:0] super_group_inst = ir[26:24];

    wire [3:0]
        sub_group_inst = ir[23:20],
        funct = ir[19:16];
    
    wire [7:0] 
        arg1 = ir[15:8],
        arg2 = ir[7:0];

    wire
        VF = flags[5],
        PF = flags[4],
        SF = flags[3],
        ZF = flags[2],
        AF = flags[1],
        CF = flags[0];
    
    reg [7:0]
        reg_r_select,
        reg_w_select,
        reg_w_line,
        mem_select,
        mem_w_line;
    
    // wire [7:0] 
    //     reg_r_select = main_w_line [7:0],
    //     reg_w_select = main_w_line [15:8],
    //     reg_w_line = main_w_line [23:16],
    //     mem_select = main_w_line [31:24],
    //     mem_w_line = main_w_line [39:32];

    reg 
        reg_r,
        reg_w,
        mem_r,
        mem_w,
        end_inst;

    // wire /* Execution state signals */
    //     reg_r = main_w_line [40],
    //     reg_w = main_w_line [41],
    //     mem_r = main_w_line [42],
    //     mem_w = main_w_line [43];
    //     end_inst = main_w_line [44];
    
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

    wire [7:0] reg_r_line;

    cpu_core #(RAM_SIZE) core(
        .ram(ram),
        .clk(clk), .reset(reset), .inst_condition(condition_result),
        .end_inst(end_inst), .jmp_inst(jmp_inst), .hlt_inst(hlt_inst),
        .jmp_address(jmp_address),
        .ir(ir), .clks(clks), .pc(pc), .state(state)
    );

    reg_file regs(
        .clk(clk),
        .reset(reset),
        .reg_r(reg_r),
        .reg_w(reg_w),
        .reg_w_line(reg_w_line),
        .reg_w_select(reg_w_select),
        .reg_r_select(reg_r_select),
        .reg_r_line(reg_r_line),
        .al(al),
        .bl(bl),
        .cl(cl),
        .dl(dl)
    );

    always @* begin

        reg_w = 0;
        reg_r = 0;
        jmp_inst = 0;
        end_inst = 0;

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

        if (super_group_inst) begin
            // TODO
        end
        else begin
            case (funct)
                0: begin /* NOP */
                    end_inst = state[0];
                end
                1: begin /* HLT */
                    hlt_inst = state[0];
                end
                2: begin /* JMP Label */
                    jmp_inst = 1;
                    jmp_address = arg1;
                    end_inst = state[0];
                end
                3: begin /* JMP REG */
                    jmp_inst = 1;
                    reg_r = 1;
                    reg_r_select = arg1;
                    jmp_address = reg_r_line;
                    end_inst = state[0];
                end
                4: begin /* MOV REG, IMM */
                    reg_w = 1;
                    reg_w_select = arg1;
                    reg_w_line = arg2;
                    end_inst = state[0];
                end
                5: begin /* MOV REG, REG */
                    reg_w = 1;
                    reg_w_select = arg1;
                    reg_r = 1;
                    reg_r_select = arg2;
                    reg_w_line = reg_r_line;
                    end_inst = state[0];
                end
                6: begin /* MUL REG, REG */
                    // TODO
                end
                7: begin /* DIV REG, REG */
                    // TODO
                end
            endcase
        end
    end
    
    
endmodule