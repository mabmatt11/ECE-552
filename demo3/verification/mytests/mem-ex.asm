///////////////////////////////////////
// Demonstrate Mem -> Ex Forwarding //
// Author: Amanda Becker ////////////
////////////////////////////////////

lbi r1, 0	//test first mem location
lbi r2, 4	//test second mem location
lbi r3, 12	//value to store
st r3, r2, 0	//store val 12 at second mem location
ld r1, r2, 0	//load val 12 from second mem location
st r2, r1, 4	//store val 12 at second mem location + 4
halt
