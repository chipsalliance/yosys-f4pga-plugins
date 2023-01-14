yosys -import

if { [info procs ql-qlf-k6n10f] == {} } { plugin -i ql-qlf }
yosys -import  ;

read_verilog $::env(DESIGN_TOP).v
design -save bram36_sdp

select spram_36x1024
select *
synth_quicklogic -family qlf_k6n10f -top spram_36x1024 -bram_types
opt_expr -undriven
opt_clean
stat
write_verilog sim/spram_36x1024_post_synth.v
select -assert-count 1 t:TDP36K_BRAM_WR_X36_RD_X36_nonsplit

select -clear
design -load bram36_sdp
select spram_32x1024
select *
synth_quicklogic -family qlf_k6n10f -top spram_32x1024 -bram_types
opt_expr -undriven
opt_clean
stat
write_verilog sim/spram_32x1024_post_synth.v
select -assert-count 1 t:TDP36K_BRAM_WR_X36_RD_X36_nonsplit

select -clear
design -load bram36_sdp
select spram_18x2048
select *
synth_quicklogic -family qlf_k6n10f -top spram_18x2048 -bram_types
opt_expr -undriven
opt_clean
stat
write_verilog sim/spram_18x2048_post_synth.v
select -assert-count 1 t:TDP36K_BRAM_WR_X18_RD_X18_nonsplit

select -clear
design -load bram36_sdp
select spram_16x2048
select *
synth_quicklogic -family qlf_k6n10f -top spram_16x2048 -bram_types
opt_expr -undriven
opt_clean
stat
write_verilog sim/spram_16x2048_post_synth.v
select -assert-count 1 t:TDP36K_BRAM_WR_X18_RD_X18_nonsplit

select -clear
design -load bram36_sdp
select spram_9x4096
select *
synth_quicklogic -family qlf_k6n10f -top spram_9x4096 -bram_types
opt_expr -undriven
opt_clean
stat
write_verilog sim/spram_9x4096_post_synth.v
select -assert-count 1 t:TDP36K_BRAM_WR_X9_RD_X9_nonsplit

select -clear
design -load bram36_sdp
select spram_8x4096
select *
synth_quicklogic -family qlf_k6n10f -top spram_8x4096 -bram_types
opt_expr -undriven
opt_clean
stat
write_verilog sim/spram_8x4096_post_synth.v
select -assert-count 1 t:TDP36K_BRAM_WR_X9_RD_X9_nonsplit
