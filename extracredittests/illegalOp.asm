//Garret Huibregtse

//Program to Test illegal opcode instruction. Exception handler loads 0xBADD into R7 when illegal opcode is encountered

j .realstart  //jump to the beginning of program

lbi r7, 16  //exception handler
ld r7, r7, 0
rti

.realstart:
lbi r0, 0
siic r0
invalid_inst    //This is an invalid instruction, should go to handler but assembler just ignores it
addi r0, r0, 10 //this should get executed after the exception handler is returned
halt

data 0xbadd //This data will be loaded into R7 if exception handler is called
