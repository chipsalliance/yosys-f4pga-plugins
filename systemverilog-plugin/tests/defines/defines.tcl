yosys -import
if { [info procs read_uhdm] == {} } { plugin -i systemverilog }
yosys -import  ;# ingest plugin commands

set TMP_DIR /tmp
if { [info exists ::env(TMPDIR) ] } {
  set TMP_DIR $::env(TMPDIR)
}

systemverilog_defines -DPONA
read_systemverilog $::env(DESIGN_TOP).v
hierarchy
write_verilog
