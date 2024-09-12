
def fmt(a:int):
    return f"0x{a:02x}"

AL=0x2c
BL=0x03

clk=0
A_ALU=AL
shiftedBit=BL&0x1
R_L_H=BL>>1


print("CLK",clk,": A_ALU =",fmt(A_ALU),", B_ALU = 0xUU , R_ALU = 0xUU , R_L_H = 0xUUUU, shiftedBit = U , C_out = U")

while clk<9:
    clk+=1
    B_ALU=R_L_H >> 8
    R_ALU=(A_ALU+B_ALU)&0xff
    C_out=(A_ALU+B_ALU)>>8

    print("CLK",clk,": A_ALU =",fmt(A_ALU),", B_ALU =",fmt(B_ALU), ", R_ALU =",fmt(R_ALU), ", R_L_H =", f"0x{R_L_H:04x}" ", shiftedBit =",shiftedBit, ", C_out =", C_out)

    # CLK trigger
    
    if shiftedBit==1:
        R_L_H=(R_ALU<<8) | R_L_H&0xff
    
    shiftedBit=R_L_H&0x1
    R_L_H=R_L_H>>1 | C_out<<15
    

print("Result: ", f"0x{AL*BL:04x}")