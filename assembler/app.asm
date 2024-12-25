mov al, 0xF
mov BL, CL
jmp al
jmp 0x88
MUL AL, BL
div DL, CL

Z? add al, 0x55