yosys -import

if { [info procs ql-qlf-k6n10f] == {} } { plugin -i ql-qlf }
yosys -import  ;

read_verilog $::env(DESIGN_TOP).v
design -save sim_dsp_simd

select sim_dsp_simd
select *
synth_quicklogic -family qlf_k6n10f -top sim_dsp_simd
opt_expr -undriven
opt_clean
stat
write_verilog sim/sim_dsp_simd_post_synth.v
select -assert-count 1 t:QL_DSP2_MULT

select -clear
design -load sim_dsp_simd
select sim_dsp_simd_explicit
select *
synth_quicklogic -family qlf_k6n10f -top sim_dsp_simd_explicit
opt_expr -undriven
opt_clean
stat
write_verilog sim/sim_dsp_simd_explicit_post_synth.v
select -assert-count 1 t:QL_DSP2_MULT_REGIN
