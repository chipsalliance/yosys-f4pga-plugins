
# arith-stats

Counts the number of arithmetic cells in each module, also providing a histogram by operand bitwidths.


* Cell types counted:
    `$add $sub $neg $mul $div $lt $le $gt $ge $alu $fa $macc`


* Usually you want to run at least `hierarchy -top <top>`, `proc`, `flatten`, and `clean` before calling `arith_stats`.

* If the design is not flattened, the counts per module refer only to the arithmetic cells directly in that module, not those contained in instantiations of other modules.

* If you run early in the flow, you will see `$add/$sub/$mul/$div` and comparisons.

* If you run after `alumacc`, the count will contain `$alu` and `$macc` cells.

* If you run after `maccmap`, you will see `$fa` and `$alu` counts.

* WARNING: the bitwidth for $macc cells is not currently correct since this pass doesn't parse how `$macc`'s inputs are actually concatenations of multiple inputs.


* This plugin uses C++17.

Sample script:
```
read_verilog test.v
hierarchy -top top
proc
flatten

plugin -i arith-stats
arith-stats
```
