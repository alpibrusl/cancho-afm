#!/bin/sh
# docs/dynamics.md: real-curve loader, end to end on files whose maker is known (twin curves exported as text). Needs only CANCHO. Run from the repository root:  CANCHO=... sh tests/fcload_flow.sh
set -e
cd "$(dirname "$0")/.."
: "${CANCHO:?set CANCHO}"
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
LIB="sim/fcmodels.cho sim/adequacy.cho sim/vesicles.cho sim/nucleation.cho sim/bilayer.cho sim/forcecurve.cho sim/dfs.cho"
"$CANCHO" build host/fc_export.cho sim/domains.cho sim/fcmodels.cho sim/bilayer.cho sim/forcecurve.cho sim/dfs.cho --std -o "$W/exp" > /dev/null
"$CANCHO" build host/fc_load.cho sim/fcload.cho $LIB --std -o "$W/load" > /dev/null
for m in 1 2; do
    mkdir "$W/m$m"
    for c in 0 1 2 3 4 5 6 7; do "$W/exp" $m 321 $c > "$W/m$m/c$c.csv"; done
    out=$("$W/load" 350 320 0 0 0 1 0 "$W/m$m"/c*.csv)
    echo "$out" | grep '^closest' 
    echo "$out" | grep -q "^closest: m$m " || { echo "FAILED: files made under model $m were not named model $m"; exit 1; }
done
# the measured spread (a bootstrap of the curves): the same files are still named correctly
out=$("$W/load" 350 320 0 0 1 1 0 "$W/m2"/c*.csv)
echo "$out" | grep -q "spread: MEASURED" || { echo "FAILED: the measured spread was not used"; exit 1; }
echo "$out" | grep -q "^closest: m2 " || { echo "FAILED: with the measured spread the melted files were not named model 2"; exit 1; }
# fewer than 8 analysed curves: it falls back to the twin's spread and says so
"$W/load" 350 320 0 0 1 1 0 "$W/m2/c0.csv" "$W/m2/c1.csv" | grep -q "the twin's spread is used" || { echo "FAILED: the fallback was not reported"; exit 1; }
# a file that cannot be read, and one that is too short, are reported and do not stop the run
printf '1,2\n3,4\n' > "$W/short.csv"
"$W/load" 350 320 0 0 0 1 0 "$W/short.csv" "$W/m1/c0.csv" "$W/none.csv" | grep -q "REFUSED, tag 9" || { echo "FAILED: a short file was not refused with tag 9"; exit 1; }
"$W/load" 350 320 0 0 0 1 0 "$W/none.csv" | grep -q "cannot be read" || { echo "FAILED: a missing file was not reported"; exit 1; }
# a lever other than the library's is warned about
"$W/load" 100 200 0 0 0 1 0 "$W/m1/c0.csv" | grep -q "WARNING" || { echo "FAILED: a different lever was not warned about"; exit 1; }
echo ok
