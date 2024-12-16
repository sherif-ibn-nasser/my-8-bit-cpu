module reg_file (
    input clk, reg_r, reg_w, reset,
    input [7:0] reg_w_line, reg_w_select, reg_r_select,
    output reg [7:0] reg_r_line, al, bl, cl, dl

);

    localparam 
        AL = 0,
        BL = 1,
        CL = 2,
        DL = 3;

    always @* begin
        if (reg_r) // Read is anabled
            case (reg_r_select[3:0])
            AL: reg_r_line = al;
            BL: reg_r_line = bl;
            CL: reg_r_line = cl;
            DL: reg_r_line = dl;
            endcase
        else reg_r_line = 0;
    end
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            al = 0;
            bl = 0;
            cl = 0;
            dl = 0;
        end
        else if (reg_w) begin // Write is enabled
            case (reg_w_select[3:0])
                AL: al = reg_w_line;
                BL: bl = reg_w_line;
                CL: cl = reg_w_line;
                DL: dl = reg_w_line;
            endcase
        end
    end

endmodule