yosys -import
if { [info procs read_uhdm] == {} } { plugin -i systemverilog }
yosys -import  ;# ingest plugin commands

set TMP_DIR /tmp
if { [info exists ::env(TMPDIR) ] } {
  set TMP_DIR $::env(TMPDIR)
}

# Testing simple round-trip
read_systemverilog -debug -odir $TMP_DIR/debug-flag-test -defer $::env(DESIGN_TOP)-pkg.sv
read_systemverilog -debug -odir $TMP_DIR/debug-flag-test -defer $::env(DESIGN_TOP)-buf.sv
read_systemverilog -debug -odir $TMP_DIR/debug-flag-test -defer $::env(DESIGN_TOP).v
read_systemverilog -debug -odir $TMP_DIR/debug-flag-test -link
hierarchy
write_verilog
