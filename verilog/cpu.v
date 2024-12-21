// Instruction decoder

// xxxx_xxxx xxxx_xxxx xxxx_xxxx xxxx_xxxx
// |||| |||| |||| |||| |||| |||| ^^^^_^^^^ Possible arg 2
// |||| |||| |||| |||| |||| ||||
// |||| |||| |||| |||| ^^^^_^^^^ Possible arg 1
// |||| |||| |||| ^^^^ Function opcode
// |||| |||| ^^^^ Subgroup of instructions
// |||| |^^^ Supergroup of instructions
// ^^^^_^ Execution condition

`include "cpu_core.v"
`include "reg_file.v"
`include "alu.v"

module cpu #(
    parameter RAM_SIZE = 256  // Number of 32-bit words in RAM
) (
    input wire [(RAM_SIZE * 32) - 1:0] ram,
    input clk, reset,
    output reg [7:0] flags,
    output [7:0] al, bl, cl, dl,
    output reg [15:0] r_l_h,
    output reg r_l_h_bit,
    output [31:0] ir,
    output [15:0] clks,
    output [7:0] pc,
    output [1:0] state
);

    reg
        condition_result,  // If set, the instruction will be executed, otherwise it will be skipped
        jmp_inst,
        hlt_inst;

    reg [7:0] jmp_address;

    wire [4:0] condition = ir[31:27];

    wire [2:0] super_group_inst = ir[26:24];

    wire [3:0] sub_group_inst = ir[23:20], funct = ir[19:16];

    wire [7:0] arg1 = ir[15:8], arg2 = ir[7:0];

    wire SF = flags[5], ZF = flags[4], AF = flags[3], VF = flags[2], PF = flags[1], CF = flags[0];

    reg [7:0] reg_r_select, reg_w_select, reg_w_line, mem_select, mem_w_line;

    reg reg_r, reg_w, mem_r, mem_w, end_inst;

    reg shl_r_alu, shr_r_alu;

    wire [7:0] reg_r_line;

    cpu_core #(RAM_SIZE) core (
        .ram(ram),
        .clk(clk),
        .reset(reset),
        .inst_condition(condition_result),
        .end_inst(end_inst),
        .jmp_inst(jmp_inst),
        .hlt_inst(hlt_inst),
        .jmp_address(jmp_address),
        .ir(ir),
        .clks(clks),
        .pc(pc),
        .state(state)
    );

    reg_file regs (
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


    reg [7:0] a_alu, b_alu;
    reg [3:0] op_alu;
    wire [7:0] c_alu, flags_alu;

    alu alu (
        .a(a_alu),
        .b(b_alu),
        .cpu_flags(flags),
        .op(op_alu),
        .c(c_alu),
        .flags(flags_alu)
    );

    always @* begin

        reg_w = 0;
        reg_r = 0;
        jmp_inst = 0;
        end_inst = 0;
        shl_r_alu = 0;
        shr_r_alu = 0;

        case (condition)
            'h00:    condition_result = 1;                  /* Execute unconditionally */
            'h08:    condition_result = ZF;                 /* ZF */
            'h10:    condition_result = ~ZF;                /* Z / E */
            'h20:    condition_result = SF;                 /* S */
            'h30:    condition_result = ~SF;                /* NS */
            'h40:    condition_result = ~(ZF | (SF ^ VF));  /* G / NLE */
            'h50:    condition_result = ~(SF ^ VF);         /* GE / NL */
            'h60:    condition_result = SF ^ VF;            /* L / NGE */
            'h70:    condition_result = ZF | (SF ^ VF);     /* LE / NG */
            'h80:    condition_result = ~(ZF | CF);         /* A / NBE */
            'h90:    condition_result = ~CF;                /* NC / AE / NB */
            'hA0:    condition_result = CF;                 /* C / B / NAE */
            'hB0:    condition_result = ZF | CF;            /* BE / NA */
            'hC0:    condition_result = VF;                 /* V */
            'hD0:    condition_result = ~VF;                /* NV */
            'hE0:    condition_result = PF;                 /* P */
            'hF0:    condition_result = ~PF;                /* NP */
            'hE1:    condition_result = AF;                 /* HC */
            'hF1:    condition_result = ~AF;                /* NHC */
            default: condition_result = 0;                  /* Illegal condition code */
        endcase

        if (state == core.IE) begin
            if (super_group_inst) begin
                if (sub_group_inst) begin  /* math with immediates sub group */
                    reg_r = 1;
                    reg_r_select = arg1;
                    a_alu = reg_r_line;
                    b_alu = arg2;
                    op_alu = funct;
                    reg_w = 1;
                    reg_w_select = arg1;
                    reg_w_line = c_alu;
                    flags = flags_alu;
                    end_inst = 1;
                end else begin
                    case (funct)
                        'h8: begin  /* CMP REG, IMM */
                            reg_r = 1;
                            reg_r_select = arg1;
                            a_alu = reg_r_line;
                            b_alu = arg2;
                            op_alu = alu.OP_SUB;
                            flags = flags_alu;
                            end_inst = 1;
                        end
                        'h9: begin  /* CMP REG, REG */
                            if (clks == core.CLK_0) begin
                                reg_r = 1;
                                reg_r_select = arg1;
                                r_l_h[7:0] <= reg_r_line;
                            end else begin
                                reg_r = 1;
                                reg_r_select = arg2;
                                a_alu = r_l_h[7:0];
                                b_alu = reg_r_line;
                                op_alu = alu.OP_SUB;
                                flags = flags_alu;
                                end_inst = 1;
                            end
                        end
                        'hA: begin  /* TEST REG, IMM */
                            reg_r = 1;
                            reg_r_select = arg1;
                            a_alu = reg_r_line;
                            b_alu = arg2;
                            op_alu = alu.OP_AND;
                            flags = flags_alu;
                            end_inst = 1;
                        end
                        'hB: begin  /* TEST REG, REG */
                            if (clks == core.CLK_0) begin
                                reg_r = 1;
                                reg_r_select = arg1;
                                r_l_h[7:0] <= reg_r_line;
                            end else begin
                                reg_r = 1;
                                reg_r_select = arg2;
                                a_alu = r_l_h[7:0];
                                b_alu = reg_r_line;
                                op_alu = alu.OP_AND;
                                flags = flags_alu;
                                end_inst = 1;
                            end
                        end
                        default: begin
                            if (clks == core.CLK_0) begin
                                reg_r = 1;
                                reg_r_select = arg1;
                                r_l_h[7:0] = reg_r_line;
                            end else begin
                                reg_r = 1;
                                reg_r_select = arg2;
                                a_alu = r_l_h[7:0];
                                b_alu = reg_r_line;
                                op_alu = funct;
                                reg_w = 1;
                                reg_w_select = arg1;
                                reg_w_line = c_alu;
                                flags = flags_alu;
                                end_inst = 1;
                            end
                        end
                    endcase
                end
            end else begin
                case (funct)
                    'h0: begin  /* NOP */
                        end_inst = 1;
                    end
                    'h1: begin  /* HLT */
                        hlt_inst = 1;
                    end
                    'h2: begin  /* JMP Label */
                        jmp_inst = 1;
                        jmp_address = arg1;
                        end_inst = 1;
                    end
                    'h3: begin  /* JMP REG */
                        jmp_inst = 1;
                        reg_r = 1;
                        reg_r_select = arg1;
                        jmp_address = reg_r_line;
                        end_inst = 1;
                    end
                    'h4: begin  /* MOV REG, IMM */
                        reg_w = 1;
                        reg_w_select = arg1;
                        reg_w_line = arg2;
                        end_inst = 1;
                    end
                    'h5: begin  /* MOV REG, REG */
                        reg_w = 1;
                        reg_w_select = arg1;
                        reg_r = 1;
                        reg_r_select = arg2;
                        reg_w_line = reg_r_line;
                        end_inst = 1;
                    end
                    'h6: begin  /* MUL REG, REG */
                        case (clks)
                            core.CLK_0: begin
                                // Load the multiplier into RL and zeroize RH
                                reg_r = 1;
                                reg_r_select = arg2;
                                {r_l_h, r_l_h_bit} = {1'b0, reg_r_line};
                            end
                            core.CLK_9: begin
                                reg_w = 1;
                                reg_w_select = arg1;
                                reg_w_line = r_l_h[7:0];
                            end
                            core.CLK_A: begin
                                reg_w = 1;
                                reg_w_select = arg2;
                                reg_w_line = r_l_h[15:8];
                                flags[0] = r_l_h[15:8] != 0;
                            end
                            core.CLK_B: begin
                                end_inst = 1;
                            end
                            default: begin
                                reg_r = 1;
                                reg_r_select = arg1;
                                a_alu = reg_r_line;
                                b_alu = r_l_h[15:8];
                                op_alu = alu.OP_ADD;
                                shr_r_alu = 1;
                            end
                        endcase
                    end
                    'h7: begin  /* DIV REG, REG */
                        case (clks)
                            core.CLK_0: begin
                                // Load the dividend into RL and zeroize RH
                                reg_r = 1;
                                reg_r_select = arg1;
                                {r_l_h_bit, r_l_h} = {reg_r_line, 1'b0};
                            end
                            core.CLK_9: begin
                                reg_w = 1;
                                reg_w_select = arg1;
                                reg_w_line = r_l_h[7:0];
                            end
                            core.CLK_A: begin
                                reg_w = 1;
                                reg_w_select = arg2;
                                reg_w_line = {r_l_h_bit, r_l_h[15:9]};
                                flags[0] = {r_l_h_bit, r_l_h[15:9]} != 0;
                            end
                            core.CLK_B: begin
                                end_inst = 1;
                            end
                            default: begin
                                a_alu = r_l_h[15:8];
                                reg_r = 1;
                                reg_r_select = arg2;
                                b_alu = reg_r_line;
                                op_alu = alu.OP_SUB;
                                shl_r_alu = 1;
                            end
                        endcase
                    end
                endcase
            end
        end
    end

    always @(posedge clk) begin
        if (shr_r_alu) begin
            if (r_l_h_bit) {r_l_h, r_l_h_bit} = {alu.CF, c_alu, r_l_h[7:0]};
            else {r_l_h, r_l_h_bit} = {1'b0, r_l_h};
        end
        if (shl_r_alu) begin
            if (alu.SF) {r_l_h_bit, r_l_h} = {r_l_h, 1'b0};
            else {r_l_h_bit, r_l_h} = {c_alu, r_l_h[7:0], 1'b1};
        end
    end
endmodule
