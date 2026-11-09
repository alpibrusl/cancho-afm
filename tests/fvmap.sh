#!/bin/sh
# docs/dynamics.md, "Force-volume map": the acceptance of the map of a mixed gel and fluid bilayer. Predictions of the twin, not measurements. Needs only CANCHO.
# Run from the repository root:  CANCHO=... sh tests/fvmap.sh
set -e
cd "$(dirname "$0")/.."
: "${CANCHO:?set CANCHO}"
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
"$CANCHO" build host/fv_twin.cho sim/domains.cho sim/bilayer.cho sim/livecurve.cho sim/forcecurve.cho sim/dfs.cho --std -o "$W/fv" > /dev/null
"$W/fv" 32 > "$W/a"
"$W/fv" 32 > "$W/b"
cmp -s "$W/a" "$W/b" || { echo "FAILED: two runs differ (acceptance 4)"; exit 1; }
# one value per line from the JSON: truth, ok, e, bt_nn, zc_nm
sed 's/.*"truth":\([0-9]*\),"ok":\([0-9]*\),"why":\([0-9]*\)\(.*\)/\1 \2 \3 \4/' "$W/a" | sed 's/,"e":\([-0-9.]*\),"bt_nn":\([-0-9.]*\),"height_nm":[-0-9.]*,"zc_nm":\([-0-9.]*\),.*/ \1 \2 \3/' > "$W/t"
awk '
{ n++; if ($2 != 1) { refused++; next }
  t = $1; e = $4; bt = $5; zc = $6
  cnt[t]++; zs[t] += zc
  if ((bt > 8) != t) wrong_bt++
  if ((e > 14) != t) wrong_e++ }
END {
  printf "pixels %d, refused %d, gel %d, fluid %d\n", n, refused, cnt[1], cnt[0]
  printf "classified wrongly by breakthrough force > 8 nN: %d; by modulus > 14 MPa: %d\n", wrong_bt, wrong_e
  step = zs[1] / cnt[1] - zs[0] / cnt[0]
  printf "contact-point step read: %.2f nm (1.00 put in)\n", step
  if (refused != 0) { print "FAILED: a curve was refused (acceptance 5 wants every refusal counted and none expected here)"; exit 1 }
  if (wrong_bt > 0) { print "FAILED: the breakthrough force did not recover the phase (acceptance 1/3)"; exit 1 }
  if (wrong_e > 3) { print "FAILED: the modulus misclassified more than 3 pixels (acceptance 3)"; exit 1 }
  if (step < 0.5 || step > 2.0) { print "FAILED: the contact-point step is not between 0.5 and 2 nm"; exit 1 }
}' "$W/t"
echo "ok"
