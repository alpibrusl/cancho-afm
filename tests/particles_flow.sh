#!/bin/sh
# The flow of docs/image-processing.md I3: the twin's scan -> particles.csv -> cancho-table. Needs CANCHO (the compiler) and TABLE (a built `table`, github.com/alpibrusl/cancho-table).
# Run from the repository root:  CANCHO=... TABLE=... sh tests/particles_flow.sh
set -e
cd "$(dirname "$0")/.."
: "${CANCHO:?set CANCHO}"; : "${TABLE:?set TABLE}"
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
"$CANCHO" build host/scan_twin.cho $(ls sim/*.cho) host/regs.cho gen/ir.cho gen/pid_ir.cho gen/raster_ir.cho gen/lockin_ir.cho host/proto.cho host/twin_link.cho host/script.cho host/run_twin.cho host/session.cho host/image.cho host/metrics.cho host/features.cho host/drift.cho host/report.cho host/png.cho host/force.cho --std -o "$W/scan_twin" > /dev/null
# the high-speed profile, 500 kHz cantilever, ideal Z scanner; the mode that prints particles.csv
"$W/scan_twin" 1 0 500 3 > "$W/particles.csv"
head -1 "$W/particles.csv" | grep -qx 'x,y,height_pm,area_px'
check() { # name, expected substring of table's answer, table args...
  name=$1; want=$2; shift 2
  out=$("$TABLE" "$@" "$W/particles.csv")
  echo "$out" | grep -qF "$want" || { echo "FAILED $name: wanted $want, got $out"; exit 1; }
  echo "$name: ok"
}
# three particles in the file
check "three rows" '"row_count":3' --select x,y,height_pm
# the aggregate over exact decimals: count 3, and the highest is one of the two 600 pm particles as the twin's tracking leaves it (505 to 530 pm)
out=$("$TABLE" --agg "count,max:height_pm:dec(2)" "$W/particles.csv")
echo "$out" | grep -qF '"rows":[["3","5' || { echo "FAILED aggregate: $out"; exit 1; }
echo "count and max: ok"
# a filter on a declared decimal: the two tall particles (above 450 pm), not the 450 pm one
check "filter above 450 pm" '"row_count":2' --where "height_pm:dec(2) > 450" --select x,y
# a decimal that is not declared is refused with its rule, not read as a number
out=$("$TABLE" --agg "max:height_pm" "$W/particles.csv" || true)
echo "$out" | grep -qF 'value.not-integer' || { echo "FAILED refusal: $out"; exit 1; }
echo "undeclared decimal refused (value.not-integer): ok"
echo "particles flow: passed"
