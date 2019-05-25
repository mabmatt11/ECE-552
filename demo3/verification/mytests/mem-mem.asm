////////////////////////////////////////
// Demonstrate Mem -> Mem Forwarding //
// Author: Amanda Becker /////////////
/////////////////////////////////////

lbi r1, 0	//test first mem location
lbi r2, 4	//test second mem location
lbi r3, 8	//value to store
lbi r4, 12	//test third mem location
st r3, r2, 0	//store 8 at second mem location
ld r1, r2, 0	//load val 8 from second mem location
st r1, r4, 0	//store val 8 at third mem location
halt
