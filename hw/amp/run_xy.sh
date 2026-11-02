#!/bin/sh
# Sweep the load capacitance (the piezo disk, not yet measured) and the op-amp's output resistance (not in my model's datasheet source).
cd "$(dirname "$0")"
for cp in 10n 30n 100n 300n 1u; do
  for ro in 10 25 100; do
    sed -e "s/^.param CP=30n RISO=47 RDAC=6.25k ROUT=25/.param CP=$cp RISO=47 RDAC=6.25k ROUT=$ro/" xy_amp.cir > /tmp/xy_case.cir
    out=$(ngspice -b /tmp/xy_case.cir 2>&1 | grep RESULT | tr '\n' ' ')
    echo "CP=$cp RO=$ro: $out"
  done
done
