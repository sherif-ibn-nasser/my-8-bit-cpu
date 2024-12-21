
def fmt(a:int):
    return f"0x{a&0xff:02x}"

AL=0x2c
BL=0x03

clk=0
B_ALU=BL
R_L_H=AL<<1


print("CLK",clk,": A_ALU = 0xUU , B_ALU =", fmt(B_ALU),", R_ALU = 0xUU , R_L_H = 0xUUUU , NotNeg = U")

while clk<9:
    clk+=1
    A_ALU=R_L_H >> 8
    R_ALU=(A_ALU-B_ALU)&0xff
    NotNeg=1
    
    if A_ALU<B_ALU:
        NotNeg=0

    print("CLK",clk,": A_ALU =",fmt(A_ALU),", B_ALU =",fmt(B_ALU), ", R_ALU =",fmt(R_ALU), ", R_L_H =", f"0x{R_L_H&0xffff:04x}", ", NotNeg =", NotNeg)

    # CLK trigger
    if NotNeg==1:
        R_L_H=(R_ALU<<8) | R_L_H&0xff
    
    R_L_H=R_L_H<<1 | NotNeg
    

print("Result: ", f"0x{int(AL%BL):02x}{int(AL/BL):02x}")