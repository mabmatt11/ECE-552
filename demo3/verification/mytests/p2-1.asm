////////////////////////////////////////////////
// Demonstrate good use of branch prediction //
// Author: Amanda Becker /////////////////////
/////////////////////////////////////////////

lbi r1, 4	//start counter at 4
lbi r2, 8	//test adder val
lbi r3, 1	//subtractor
.loop:
sub r1, r3, r1	//subtract 1 from r1 until r1 < 0
bgez r1, .loop	//loop up if r1 >= 0
add r1, r1, r2	//should be 7 if loop completed
halt
