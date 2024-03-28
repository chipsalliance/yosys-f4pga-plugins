yosys -import
if { [info procs quicklogic_eqn] == {} } { plugin -i ql-qlf}
yosys -import  ;# ingest plugin commands

set TOP "mult16x16"
read_verilog $::env(DESIGN_TOP).v
design -save read

#Infer QL_DSP
hierarchy -top $TOP
synth_quicklogic_f4pga -family qlf_k6n10 -top $TOP
yosys cd $TOP
stat
select -assert-count 1 t:QL_DSP

#Test no_dsp arg
design -load read
hierarchy -top $TOP
synth_quicklogic_f4pga -family qlf_k6n10 -top $TOP -no_dsp
yosys cd $TOP
stat
select -assert-count 0 t:QL_DSP
