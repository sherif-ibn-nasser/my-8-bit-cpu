start:
    mov al, 0xF
    mov BL, CL
    jmp start2

start2:
    MUL AL, BL

start3:
    div DL, CL

Z? add al, 0x55


jmp start3