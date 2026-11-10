#!/bin/sh
# docs/dynamics.md: real-curve loader, end to end on files whose maker is known (twin curves exported as text). Needs only CANCHO. Run from the repository root:  CANCHO=... sh tests/fcload_flow.sh
set -e
cd "$(dirname "$0")/.."
: "${CANCHO:?set CANCHO}"
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
LIB="sim/fcmodels.cho sim/adequacy.cho sim/vesicles.cho sim/nucleation.cho sim/bilayer.cho sim/forcecurve.cho sim/dfs.cho"
"$CANCHO" build host/fc_export.cho sim/fcmodels.cho sim/bilayer.cho sim/forcecurve.cho sim/dfs.cho --std -o "$W/exp" > /dev/null
"$CANCHO" build host/fc_load.cho sim/fcload.cho $LIB --std -o "$W/load" > /dev/null
for m in 1 2; do
    mkdir "$W/m$m"
    for c in 0 1 2 3 4 5 6 7; do "$W/exp" $m 321 $c > "$W/m$m/c$c.csv"; done
    out=$("$W/load" 350 320 0 0 "$W/m$m"/c*.csv)
    echo "$out" | grep '^closest' 
    echo "$out" | grep -q "^closest: m$m " || { echo "FAILED: files made under model $m were not named model $m"; exit 1; }
done
# a file that cannot be read, and one that is too short, are reported and do not stop the run
printf '1,2\n3,4\n' > "$W/short.csv"
"$W/load" 350 320 0 0 "$W/short.csv" "$W/m1/c0.csv" "$W/none.csv" | grep -q "REFUSED, tag 9" || { echo "FAILED: a short file was not refused with tag 9"; exit 1; }
"$W/load" 350 320 0 0 "$W/none.csv" | grep -q "cannot be read" || { echo "FAILED: a missing file was not reported"; exit 1; }
# a lever other than the library's is warned about
"$W/load" 100 200 0 0 "$W/m1/c0.csv" | grep -q "WARNING" || { echo "FAILED: a different lever was not warned about"; exit 1; }
echo ok
