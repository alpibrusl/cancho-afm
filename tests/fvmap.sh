#!/bin/sh
# docs/dynamics.md, "Force-volume map": the acceptance of the map of a mixed gel and fluid bilayer. Predictions of the twin, not measurements. Needs only CANCHO.
# Run from the repository root:  CANCHO=... sh tests/fvmap.sh
set -e
cd "$(dirname "$0")/.."
: "${CANCHO:?set CANCHO}"
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
"$CANCHO" build host/fv_twin.cho sim/histogram.cho sim/domains.cho sim/bilayer.cho sim/livecurve.cho sim/forcecurve.cho sim/dfs.cho --std -o "$W/fv" > /dev/null
"$W/fv" 32 > "$W/a"
"$W/fv" 32 > "$W/b"
cmp -s "$W/a" "$W/b" || { echo "FAILED: two runs differ (acceptance 4)"; exit 1; }
# one value per line from the JSON: truth, ok, e, bt_nn, zc_nm
grep '^{"px"' "$W/a" | sed 's/.*"truth":\([0-9]*\),"ok":\([0-9]*\),"why":\([0-9]*\)\(.*\)/\1 \2 \3 \4/' | sed 's/,"e":\([-0-9.]*\),"bt_nn":\([-0-9.]*\),"height_nm":[-0-9.]*,"zc_nm":\([-0-9.]*\),.*/ \1 \2 \3/' > "$W/t"
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
# the histograms (sim/histogram.cho, printed by fv_twin as its last line): the counts add up to the pixels, and the two peaks are where the phases are
tail -1 "$W/a" | awk '
function arr(key,   i, a, s) { s = $0; sub(".*\"" key "\":\\[", "", s); sub("\\].*", "", s); return s }
{ n = split(arr("bt_all"), a, ","); tot = 0; best = 1; for (i = 1; i <= n; i++) { tot += a[i] }
  nf = split(arr("bt_fluid"), f, ","); bf = 1; for (i = 1; i <= nf; i++) if (f[i] > f[bf]) bf = i
  ng = split(arr("bt_gel"), g, ","); bg = 1; for (i = 1; i <= ng; i++) if (g[i] > g[bg]) bg = i
  ne = split(arr("e_all"), e, ","); te = 0; for (i = 1; i <= ne; i++) te += e[i]
  printf "histogram: %d values in the breakthrough bins, %d in the modulus bins; fluid peak %.2f to %.2f nN, gel peak %.2f to %.2f nN (0.5 nN bins)\n", tot, te, (bf - 1) * 0.5, bf * 0.5, (bg - 1) * 0.5, bg * 0.5
  if (tot != 1024 || te != 1024) { print "FAILED: the histogram counts do not add up to the 1024 pixels"; exit 1 }
  if (bf >= 12 || bg < 20) { print "FAILED: the histogram peaks are not where the phases are"; exit 1 }
}'
echo "ok"
