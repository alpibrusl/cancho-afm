#!/bin/sh
# docs/dynamics.md: the force-volume map loader, end to end on a 16 x 16 map of files whose truth is known (the twin's gel-disk pattern exported as one text file per pixel). Needs only CANCHO.
# Run from the repository root:  CANCHO=... sh tests/fcmap_flow.sh
set -e
cd "$(dirname "$0")/.."
: "${CANCHO:?set CANCHO}"
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
"$CANCHO" build host/fc_export.cho sim/domains.cho sim/fcmodels.cho sim/bilayer.cho sim/forcecurve.cho sim/dfs.cho --std -o "$W/exp" > /dev/null
"$CANCHO" build host/fc_map.cho sim/fcload.cho sim/forcecurve.cho host/png.cho --std -o "$W/map" > /dev/null
"$CANCHO" build host/fv_twin.cho sim/histogram.cho sim/domains.cho sim/bilayer.cho sim/livecurve.cho sim/forcecurve.cho sim/dfs.cho --std -o "$W/fv" > /dev/null
N=16
: > "$W/raster.txt"; : > "$W/snake.txt"
iy=0
while [ $iy -lt $N ]; do
    ix=0
    while [ $ix -lt $N ]; do
        "$W/exp" 9 $N $ix $iy > "$W/p_${iy}_${ix}.csv"
        echo "$W/p_${iy}_${ix}.csv" >> "$W/raster.txt"
        ix=$((ix+1))
    done
    if [ $((iy % 2)) -eq 0 ]; then
        ix=0; while [ $ix -lt $N ]; do echo "$W/p_${iy}_${ix}.csv" >> "$W/snake.txt"; ix=$((ix+1)); done
    else
        ix=$((N-1)); while [ $ix -ge 0 ]; do echo "$W/p_${iy}_${ix}.csv" >> "$W/snake.txt"; ix=$((ix-1)); done
    fi
    iy=$((iy+1))
done
rep=$("$W/map" 350 320 0 0 $N $N 0 0 "$W/raster.txt")
echo "$rep" | head -1
echo "$rep" | grep -q "256 of 256 pixels analysed" || { echo "FAILED: not every pixel was analysed"; exit 1; }
# the true number of gel pixels, from the twin's own map of the same pattern; the two-class split must find them all (Otsu on the breakthrough force)
gel=$("$W/fv" $N | grep -c '"truth":1')
found=$(echo "$rep" | sed -n 's/.*above it \([0-9]*\) pixels.*/\1/p')
echo "gel pixels: true $gel, found above the Otsu threshold $found"
[ "$found" = "$gel" ] || { echo "FAILED: the two-class split did not find the true gel pixels"; exit 1; }
# the same map taken in snake order (manifest reordered) is the same map
snk=$("$W/map" 350 320 0 0 $N $N 1 0 "$W/snake.txt")
[ "$snk" = "$(echo "$rep" | sed 's/raster order/snake order/')" ] || { echo "FAILED: the snake-ordered manifest did not give the same map"; exit 1; }
# the maps are PNGs
for m in 1 2 3; do
    "$W/map" 350 320 0 0 $N $N 0 $m "$W/raster.txt" | head -c 4 | tail -c 3 | grep -q PNG || { echo "FAILED: mode $m is not a PNG"; exit 1; }
done
# a pixel whose file is missing is refused with tag 7 and the rest are still analysed; a missing manifest and a map too large are reported
sed '5s#.*#/nonexistent.csv#' "$W/raster.txt" > "$W/bad.txt"
"$W/map" 350 320 0 0 $N $N 0 0 "$W/bad.txt" | grep -q "refused, tag 7 (file cannot be read): 1 pixels" || { echo "FAILED: a missing file was not reported as tag 7"; exit 1; }
"$W/map" 350 320 0 0 $N $N 0 0 "$W/none.txt" | grep -q "manifest cannot be read" || { echo "FAILED: a missing manifest was not reported"; exit 1; }
"$W/map" 350 320 0 0 40 40 0 0 "$W/raster.txt" | grep -q "usage" || { echo "FAILED: a 40 x 40 map was not refused"; exit 1; }
echo ok
