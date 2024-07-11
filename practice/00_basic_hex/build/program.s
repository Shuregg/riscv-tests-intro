addi x1, x0, 5
addi x2, x0, 10
beq x1, x5, 16
addi x3, x0, 1
sb x3, 64(x0)
jal x0, 0
addi x3, x0, 0
sb x3, 64(x0)
jal x0, 0