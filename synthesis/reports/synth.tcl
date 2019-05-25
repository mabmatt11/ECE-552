echo "********** CS552 Reading files begin ********************"
set my_verilog_files [list alu.v and16.v barrelShifter.v cache.v cla_16b.v cla_4b.v controlhazard.v control.v dffe.v dff.v final_memory.syn.v four_bank_mem.v fullAdder_1b.v invalidOpCode.v lrotate16.v lshift16.v memc.syn.v memStateMachine_Set.v mem_system.v memv.syn.v mirror.v mux2_1_16b.v or16.v pipe1.v pipe2.v pipe3.v pipe4.v proc.v r16_b.v r1_b.v r3_b.v rf_bypass.v rf.v rrotate16.v rshift16.v stage1.v stage2.v stage3.v stage4.v stage5.v waySelect.v xor16.v  ]
set my_toplevel proc
define_design_lib WORK -path ./WORK
analyze -f verilog $my_verilog_files
elaborate $my_toplevel -architecture verilog
echo "********** CS552 Reading files end ********************"
current_design stage1
ungroup -all -flatten
current_design stage2
ungroup -all -flatten
current_design stage3
ungroup -all -flatten
current_design stage4
ungroup -all -flatten
current_design stage5
ungroup -all -flatten
set_dont_touch stage1
set_dont_touch stage2
set_dont_touch stage3
set_dont_touch stage4
set_dont_touch stage5
current_design proc
ungroup -all -flatten
set_dont_touch stage1 false
set_dont_touch stage2 false
set_dont_touch stage3 false
set_dont_touch stage4 false
set_dont_touch stage5 false
#/* The name of the clock pin. If no clock-pin     */
#/* exists, pick anything                          */
set my_clock_pin clk

#/* Target frequency in MHz for optimization       */
set my_clk_freq_MHz 1000

#/* Delay of input signals (Clock-to-Q, Package etc.)  */
set my_input_delay_ns 0.1

#/* Reserved time for output signals (Holdtime etc.)   */
set my_output_delay_ns 0.1


#/**************************************************/
#/* No modifications needed below                  */
#/**************************************************/
set verilogout_show_unconnected_pins "true"


# analyze -f verilog $my_verilog_files
# elaborate $my_toplevel -architecture verilog
# current_design $my_toplevel

report_hierarchy 
link
uniquify

set my_period [expr 1000 / $my_clk_freq_MHz]

set find_clock [ find port [list $my_clock_pin] ]
if {  $find_clock != [list] } {
   set clk_name $my_clock_pin
   create_clock -period $my_period $clk_name
} else {
   set clk_name vclk
   create_clock -period $my_period -name $clk_name
} 

set_driving_cell  -lib_cell INVX1  [all_inputs]
set_input_delay $my_input_delay_ns -clock $clk_name [remove_from_collection [all_inputs] $my_clock_pin]
set_output_delay $my_output_delay_ns -clock $clk_name [all_outputs]

compile -map_effort low  -area_effort low

check_design -summary
report_constraint -all_violators

set filename [format "%s%s"  $my_toplevel ".syn.v"]
write -hierarchy -f verilog $my_toplevel -output synth/$filename
set filename [format "%s%s"  $my_toplevel ".ddc"]
write -hierarchy -format ddc -output synth/$filename

report_reference > synth/reference_report.txt
report_area > synth/area_report.txt
report_cell > synth/cell_report.txt
report_timing -max_paths 20 > synth/timing_report.txt
report_power > synth/power_report.txt

quit

