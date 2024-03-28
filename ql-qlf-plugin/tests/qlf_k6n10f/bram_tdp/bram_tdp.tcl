yosys -import

if { [info procs ql-qlf-k6n10f] == {} } { plugin -i ql-qlf }
yosys -import  ;

read_verilog $::env(DESIGN_TOP).v
design -save bram_tdp

select BRAM_TDP_36x1024
select *
synth_quicklogic_f4pga -family qlf_k6n10f -top BRAM_TDP_36x1024 -bram_types
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_tdp_36x1024_post_synth.v
select -assert-count 1 t:TDP36K_BRAM_WR_X36_RD_X36_nonsplit

select -clear
design -load bram_tdp
select BRAM_TDP_32x1024
select *
synth_quicklogic_f4pga -family qlf_k6n10f -top BRAM_TDP_32x1024 -bram_types
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_tdp_32x1024_post_synth.v
select -assert-count 1 t:TDP36K_BRAM_WR_X36_RD_X36_nonsplit

select -clear
design -load bram_tdp
select BRAM_TDP_18x2048
select *
synth_quicklogic_f4pga -family qlf_k6n10f -top BRAM_TDP_18x2048 -bram_types
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_tdp_18x2048_post_synth.v
select -assert-count 1 t:TDP36K_BRAM_WR_X18_RD_X18_nonsplit

select -clear
design -load bram_tdp
select BRAM_TDP_16x2048
select *
synth_quicklogic_f4pga -family qlf_k6n10f -top BRAM_TDP_16x2048 -bram_types
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_tdp_16x2048_post_synth.v
select -assert-count 1 t:TDP36K_BRAM_WR_X18_RD_X18_nonsplit

select -clear
design -load bram_tdp
select BRAM_TDP_9x4096
select *
synth_quicklogic_f4pga -family qlf_k6n10f -top BRAM_TDP_9x4096 -bram_types
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_tdp_9x4096_post_synth.v
select -assert-count 1 t:TDP36K_BRAM_WR_X9_RD_X9_nonsplit

select -clear
design -load bram_tdp
select BRAM_TDP_8x4096
select *
synth_quicklogic_f4pga -family qlf_k6n10f -top BRAM_TDP_8x4096 -bram_types
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_tdp_8x4096_post_synth.v
select -assert-count 1 t:TDP36K_BRAM_WR_X9_RD_X9_nonsplit

select -clear
design -load bram_tdp
select BRAM_TDP_4x8192
select *
synth_quicklogic_f4pga -family qlf_k6n10f -top BRAM_TDP_4x8192 -bram_types
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_tdp_4x8192_post_synth.v
select -assert-count 1 t:TDP36K_BRAM_WR_X4_RD_X4_nonsplit

select -clear
design -load bram_tdp
select BRAM_TDP_2x16384
select *
synth_quicklogic_f4pga -family qlf_k6n10f -top BRAM_TDP_2x16384 -bram_types
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_tdp_2x16384_post_synth.v
select -assert-count 1 t:TDP36K_BRAM_WR_X2_RD_X2_nonsplit

select -clear
design -load bram_tdp
select BRAM_TDP_1x32768
select *
synth_quicklogic_f4pga -family qlf_k6n10f -top BRAM_TDP_1x32768 -bram_types
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_tdp_1x32768_post_synth.v
select -assert-count 1 t:TDP36K_BRAM_WR_X1_RD_X1_nonsplit

