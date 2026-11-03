#!/bin/sh
cd "$(dirname "$0")"
echo "variant B, sweeping Cf, load capacitance and the op-amp's output resistance (overshoot in mV on a 12 V step; bandwidth -3 dB; 10-90% rise)"
for cf in 100p 330p 1n; do
 for cp in 10n 30n 100n 1u; do
  for ro in 10 25 100; do
    sed -e "s/^.param CP=30n RISO=47 RDAC=6.25k ROUT=25 CF=330p/.param CP=$cp RISO=47 RDAC=6.25k ROUT=$ro CF=$cf/" xy_amp_b.cir > /tmp/xyb_case.cir
    out=$(ngspice -b /tmp/xyb_case.cir 2>&1 | grep RESULT | sed 's/RESULT //' | tr '\n' ' ')
    echo "CF=$cf CP=$cp RO=$ro: $out" | sed -e 's/vout_at_midcode = //' -e 's/gain_lf_db = //' -e 's/bw_3db_hz = /bw=/' -e 's/final_v = //' -e 's/overshoot_mV = /over_mV=/' -e 's/rise_10_90_s = /rise=/'
  done
 done
done
