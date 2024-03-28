yosys -import

if { [info procs ql-qlf-k6n10f] == {} } { plugin -i ql-qlf }
yosys -import  ;

read_verilog $::env(DESIGN_TOP).v
design -save bram18k_afifo

select af1024x18_1024x18
select *
synth_quicklogic_f4pga -family qlf_k6n10f -top af1024x18_1024x18 -bram_types
opt_expr -undriven
opt_clean
stat
write_verilog sim/af1024x18_1024x18_post_synth.v
select -assert-count 1 t:TDP36K_FIFO_ASYNC_WR_X18_RD_X18_split

select -clear
design -load bram18k_afifo
select af1024x16_1024x16
select *
synth_quicklogic_f4pga -family qlf_k6n10f -top af1024x16_1024x16 -bram_types
opt_expr -undriven
opt_clean
stat
write_verilog sim/af1024x16_1024x16_post_synth.v
select -assert-count 1 t:TDP36K_FIFO_ASYNC_WR_X18_RD_X18_split

select -clear
design -load bram18k_afifo
select af2048x9_2048x9
select *
synth_quicklogic_f4pga -family qlf_k6n10f -top af2048x9_2048x9 -bram_types
opt_expr -undriven
opt_clean
stat
write_verilog sim/af2048x9_2048x9_post_synth.v
select -assert-count 1 t:TDP36K_FIFO_ASYNC_WR_X9_RD_X9_split

select -clear
design -load bram18k_afifo
select af2048x8_2048x8
select *
synth_quicklogic_f4pga -family qlf_k6n10f -top af2048x8_2048x8 -bram_types
opt_expr -undriven
opt_clean
stat
write_verilog sim/af2048x8_2048x8_post_synth.v
select -assert-count 1 t:TDP36K_FIFO_ASYNC_WR_X9_RD_X9_split
