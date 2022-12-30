yosys -import

if { [info procs ql-qlf-k6n10f] == {} } { plugin -i ql-qlf }
yosys -import  ;

read_verilog $::env(DESIGN_TOP).v
design -save bram18k_sfifo

select f1024x18_1024x18
select *
synth_quicklogic -family qlf_k6n10f -top f1024x18_1024x18 -bram_types
opt_expr -undriven
opt_clean
stat
write_verilog sim/f1024x18_1024x18_post_synth.v
select -assert-count 1 t:TDP36K_FIFO_SYNC_WR_X18_RD_X18_split

select -clear
design -load bram18k_sfifo
select f1024x16_1024x16
select *
synth_quicklogic -family qlf_k6n10f -top f1024x16_1024x16 -bram_types
opt_expr -undriven
opt_clean
stat
write_verilog sim/f1024x16_1024x16_post_synth.v
select -assert-count 1 t:TDP36K_FIFO_SYNC_WR_X18_RD_X18_split

select -clear
design -load bram18k_sfifo
select f2048x9_2048x9
select *
synth_quicklogic -family qlf_k6n10f -top f2048x9_2048x9 -bram_types
opt_expr -undriven
opt_clean
stat
write_verilog sim/f2048x9_2048x9_post_synth.v
select -assert-count 1 t:TDP36K_FIFO_SYNC_WR_X9_RD_X9_split

select -clear
design -load bram18k_sfifo
select f2048x8_2048x8
select *
synth_quicklogic -family qlf_k6n10f -top f2048x8_2048x8 -bram_types
opt_expr -undriven
opt_clean
stat
write_verilog sim/f2048x8_2048x8_post_synth.v
select -assert-count 1 t:TDP36K_FIFO_SYNC_WR_X9_RD_X9_split
