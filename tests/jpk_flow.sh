#!/bin/sh
# docs/dynamics.md, "A JPK reader": the writer and the reader end to end, on SYNTHETIC archives (host/jpk_make.cho, from the same reading of the format as the reader), and the refusals on damaged ones.
# Needs only CANCHO. Run from the repository root:  CANCHO=... sh tests/jpk_flow.sh
set -e
cd "$(dirname "$0")/.."
: "${CANCHO:?set CANCHO}"
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
"$CANCHO" build host/jpk_make.cho sim/jpkmake.cho sim/bilayer.cho sim/forcecurve.cho sim/dfs.cho --std -o "$W/make" > /dev/null
"$CANCHO" build host/jpk_load.cho sim/jpk.cho sim/zipread.cho sim/fcload.cho sim/forcecurve.cho --std -o "$W/load" > /dev/null
"$W/make" 0 1 1 > "$W/one.jpk-force"
"$W/make" 0 0 0 > "$W/stored.jpk-force"
"$W/make" 5 1 1 > "$W/map.jpk-force-map"
out=$("$W/load" 320 0 "$W/one.jpk-force" "$W/stored.jpk-force" "$W/map.jpk-force-map")
echo "$out" | grep -c "curves analysed"
echo "$out" | grep -q "file 1: 720 rows.*k 0.350 N/m, z from the measured height, breakthrough 5.2" || { echo "FAILED: the single curve was not read"; exit 1; }
echo "$out" | grep -q "file 2: 720 rows.*z from the piezo height, breakthrough 5.2" || { echo "FAILED: the piezo-height curve was not read"; exit 1; }
echo "$out" | grep -q "file 3: 5 of 5 curves analysed" || { echo "FAILED: the map's curves were not all analysed"; exit 1; }
# a map's curves: the gel curve (the second) breaks through higher than the fluid one (the first)
echo "$out" | grep -q "file 3 curve 2: .*breakthrough 10\." || { echo "FAILED: the gel curve was not read"; exit 1; }
# the windowed rule is available and finds the same event
"$W/load" 320 10 "$W/one.jpk-force" | grep -q "breakthrough 5.2" || { echo "FAILED: the windowed rule"; exit 1; }
# damaged archives are refused with a tag, none stops the run
head -c 100 "$W/one.jpk-force" > "$W/cut.jpk-force"
"$W/load" 320 0 "$W/cut.jpk-force" | grep -q "REFUSED, tag 11" || { echo "FAILED: a cut archive was not refused with tag 11"; exit 1; }
cp "$W/stored.jpk-force" "$W/flipped.jpk-force"
printf 'X' | dd of="$W/flipped.jpk-force" bs=1 seek=50 conv=notrunc 2> /dev/null
"$W/load" 320 0 "$W/flipped.jpk-force" "$W/one.jpk-force" | grep -q "REFUSED, tag 15" || { echo "FAILED: a flipped byte was not refused with tag 15"; exit 1; }
printf 'not a zip archive, only text, long enough to hold an end record if it were one' > "$W/text.jpk-force"
"$W/load" 320 0 "$W/text.jpk-force" | grep -q "REFUSED, tag 11" || { echo "FAILED: text was not refused with tag 11"; exit 1; }
"$W/load" 320 0 "$W/none.jpk-force" | grep -q "cannot be read" || { echo "FAILED: a missing file was not reported"; exit 1; }
# the container is a real zip: Python's zipfile reads it and its checksums hold
if command -v python3 > /dev/null; then
    python3 -I -c "
import sys, zipfile
for f in sys.argv[1:]:
    z = zipfile.ZipFile(f)
    assert z.testzip() is None, f
    assert 'header.properties' in z.namelist(), f
" "$W/one.jpk-force" "$W/stored.jpk-force" "$W/map.jpk-force-map"
fi
echo ok
