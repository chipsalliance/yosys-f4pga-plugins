yosys -import
if { [info procs read_uhdm] == {} } { plugin -i systemverilog }
yosys -import  ;# ingest plugin commands

set TMP_DIR /tmp
if { [info exists ::env(TMPDIR) ] } {
  set TMP_DIR $::env(TMPDIR)
}

# Testing simple round-trip
read_systemverilog -report $TMP_DIR/report-flag-test -odir $TMP_DIR/report-flag-test -defer $::env(DESIGN_TOP)-pkg.sv
read_systemverilog -report $TMP_DIR/report-flag-test -odir $TMP_DIR/report-flag-test -defer $::env(DESIGN_TOP)-buf.sv
read_systemverilog -report $TMP_DIR/report-flag-test -odir $TMP_DIR/report-flag-test -defer $::env(DESIGN_TOP).v
read_systemverilog -report $TMP_DIR/report-flag-test -odir $TMP_DIR/report-flag-test -link
hierarchy
write_verilog
