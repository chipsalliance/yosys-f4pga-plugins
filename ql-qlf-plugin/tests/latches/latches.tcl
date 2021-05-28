yosys -import
if { [info procs synth_quicklogic] == {} } { plugin -i ql-qlf }
plugin -i ql-dsp
yosys -import  ;# ingest plugin commands

read_verilog $::env(DESIGN_TOP).v
design -save read

# Tests for qlf_k6n10 family
# LATCHP test for qlf_k6n10 family
synth_quicklogic -family qlf_k6n10 -top latchp
yosys cd latchp
stat
select -assert-count 1 t:latchre

# LATCHN test for qlf_k6n10 family
design -load read
synth_quicklogic -family qlf_k6n10 -top latchn
yosys cd latchn
stat
select -assert-count 1 t:\$lut
select -assert-count 1 t:latchre
