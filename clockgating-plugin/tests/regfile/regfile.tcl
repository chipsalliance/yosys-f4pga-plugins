yosys -import
if { [info procs getparam] == {} } { plugin -i params }
yosys -import  ;# ingest plugin commands

read_verilog $::env(DESIGN_TOP).v
read_liberty -lib -ignore_miss_dir -setattr blackbox ./lib/sky130_fd_sc_hd.lib 
read_verilog ./lib/sky130_hd_clkg_blackbox.v
hierarchy -check -auto-top


reg_clock_gating ./lib/sky130_hd_ff_map.v
opt_clean -purge
synth -top top
dfflibmap -liberty ./lib/sky130_fd_sc_hd.lib 
abc -D 1250 -liberty ./lib/sky130_fd_sc_hd.lib 
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
write_verilog -noattr -noexpr -nohex -nodec -defparam clockgated_regfile.v
            