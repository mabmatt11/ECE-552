//////////////////////////////////////
// Demonstrate Ex -> Ex Forwarding //
// Author: Amanda Becker ///////////
///////////////////////////////////

lbi r1, 0	//first test val
lbi r2, 4	//second test val
lbi r3, 8	//final location
add r1, r1, r2	//r1 <- 0 + 4
xor r3, r1, r3	//r3 <- 0100 ^ 1000
halt
