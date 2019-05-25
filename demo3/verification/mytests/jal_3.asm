lbi r1, 10 //increment pc
lbi r2, 20 //increment pc
jal -6     //should jump to first instruction creating infinite loop
halt
