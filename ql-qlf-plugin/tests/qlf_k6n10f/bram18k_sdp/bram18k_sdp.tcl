yosys -import

if { [info procs ql-qlf-k6n10f] == {} } { plugin -i ql-qlf }
yosys -import  ;

read_verilog $::env(DESIGN_TOP).v
design -save bram18k_sdp

select spram_18x1024_2x
select *
synth_quicklogic -family qlf_k6n10f -top spram_18x1024_2x -bram_types
opt_expr -undriven
opt_clean
stat
write_verilog sim/spram_18x1024_2x_post_synth.v
select -assert-count 2 t:TDP36K_BRAM_WR_X18_RD_X18_split

select -clear
design -load bram18k_sdp
select spram_9x2048_x2
select *
synth_quicklogic -family qlf_k6n10f -top spram_9x2048_x2 -bram_types
opt_expr -undriven
opt_clean
stat
write_verilog sim/spram_9x2048_x2_post_synth.v
select -assert-count 2 t:TDP36K_BRAM_WR_X9_RD_X9_split

select -clear
design -load bram18k_sdp
select spram_9x2048_18x1024
select *
synth_quicklogic -family qlf_k6n10f -top spram_9x2048_18x1024 -bram_types
opt_expr -undriven
opt_clean
stat
write_verilog sim/spram_9x2048_18x1024_post_synth.v
select -assert-count 1 t:TDP36K_BRAM_WR_X9_RD_X9_split
select -assert-count 1 t:TDP36K_BRAM_WR_X18_RD_X18_split