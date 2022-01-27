yosys -import
if { [info procs read_sdc] == {} } { plugin -i sdc }
yosys -import  ;# ingest plugin commands

read_verilog $::env(DESIGN_TOP).v
read_verilog -specify -lib -D_EXPLICIT_CARRY +/xilinx/cells_sim.v
read_verilog -lib +/xilinx/cells_xtra.v
hierarchy -check -auto-top
# Start flow after library reading
synth_xilinx -flatten -abc9 -nosrl -nodsp -iopad -run prepare:check

# Read the design's timing constraints
read_sdc $::env(DESIGN_TOP).input.sdc
