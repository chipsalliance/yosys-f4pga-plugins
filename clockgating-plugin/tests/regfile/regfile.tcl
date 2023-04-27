yosys -import
if { [info procs reg_clock_gating] == {} } { plugin -i clockgating }
yosys -import  ;# ingest plugin commands

set LIBDIR [file dirname $::env(DESIGN_TOP)]/lib

read_verilog $::env(DESIGN_TOP).v
read_liberty -lib -ignore_miss_dir -setattr blackbox $LIBDIR/sky130_fd_sc_hd.lib
read_verilog $LIBDIR/sky130_hd_clkg_blackbox.v
hierarchy -check -auto-top


reg_clock_gating $LIBDIR/sky130_hd_ff_map.v
opt_clean -purge
synth -top top
dfflibmap -liberty $LIBDIR/sky130_fd_sc_hd.lib
abc -D 1250 -liberty $LIBDIR/sky130_fd_sc_hd.lib
splitnets
opt_clean -purge
hilomap -hicell sky130_fd_sc_hd__conb_1 HI -locell sky130_fd_sc_hd__conb_1 LO
splitnets
opt_clean -purge
insbuf -buf sky130_fd_sc_hd__buf_2 A X
dffinit
flatten
opt;;
#check
write_verilog -noattr -noexpr -nohex -nodec -defparam [test_output_path "clockgated_regfile.v"]
