yosys -import
if { [info procs read_uhdm] == {} } { plugin -i systemverilog }
yosys -import  ;# ingest plugin commands

set TMP_DIR /tmp
if { [info exists ::env(TMPDIR) ] } {
  set TMP_DIR $::env(TMPDIR)
}

# Define forbidden value
systemverilog_defaults -add -DPAKALA
# Stash it
systemverilog_defaults -push
systemverilog_defaults -clear
read_systemverilog $::env(DESIGN_TOP).v
# Allow parsing the module again
delete top
systemverilog_defaults -pop
# Skip check for forbidden value
systemverilog_defaults -add -Pbypass=1
read_systemverilog $::env(DESIGN_TOP).v
hierarchy
write_verilog
