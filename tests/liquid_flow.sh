#!/bin/sh
# docs/liquid.md, S9.7: the two programs that print for the operator, run against the twin: the alignment steps (host/align_twin.cho) and the force next to the image in the console's
# scan.json (host/scan_twin.cho, profile 2). Needs only CANCHO. Run from the repository root:  CANCHO=... sh tests/liquid_flow.sh
set -e
cd "$(dirname "$0")/.."
: "${CANCHO:?set CANCHO}"
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
MODS="$(ls sim/*.cho) host/regs.cho gen/ir.cho gen/pid_ir.cho gen/raster_ir.cho gen/lockin_ir.cho host/proto.cho host/twin_link.cho host/script.cho host/run_twin.cho host/session.cho host/image.cho host/metrics.cho host/features.cho host/drift.cho host/report.cho host/png.cho host/force.cho host/align.cho"
"$CANCHO" build host/align_twin.cho $MODS --std -o "$W/align_twin" > /dev/null
"$CANCHO" build host/scan_twin.cho $MODS --std -o "$W/scan_twin" > /dev/null
# alignment: a hump at position 6 is found, with the steps printed; a hump with 5% of the light is refused with 1; one past the range, with 2
"$W/align_twin" 6 100 > "$W/a.txt"
grep -qF 'step 1: move the screw to position 0' "$W/a.txt" || { echo "FAILED: no steps printed"; exit 1; }
grep -qF 'aligned: leave the screw at position 6' "$W/a.txt" || { echo "FAILED: not aligned at 6"; cat "$W/a.txt"; exit 1; }
"$W/align_twin" 6 5 > "$W/b.txt" && { echo "FAILED: a dark lever was accepted"; exit 1; } || true
grep -qF 'refused, reason 1' "$W/b.txt" || { echo "FAILED: reason 1"; cat "$W/b.txt"; exit 1; }
"$W/align_twin" 12 100 > "$W/c.txt" && { echo "FAILED: a peak past the range was accepted"; exit 1; } || true
grep -qF 'refused, reason 2' "$W/c.txt" || { echo "FAILED: reason 2"; cat "$W/c.txt"; exit 1; }
echo "alignment steps printed, found and refused: ok"
# the report: profile 2, a 0.15 N/m lever, a rigid sample, threshold 60 pN; the JSON carries the force next to the image
"$W/scan_twin" 2 0 500 5 0 0 0 0 0 0 30 0 0 15 0 60 > "$W/s.json"
grep -q '"force_pn_max":[1-9]' "$W/s.json" || { echo "FAILED: no force in the report"; head -c 600 "$W/s.json"; exit 1; }
grep -qF '"force_threshold_pn":60' "$W/s.json" || { echo "FAILED: threshold missing"; exit 1; }
grep -qF '"ra_pm"' "$W/s.json" || { echo "FAILED: image figures missing"; exit 1; }
# a threshold of 1 pN is crossed by pixels; none of 60 pN is, in this run
grep -qF '"force_pixels_over":0' "$W/s.json" || { echo "FAILED: pixels over 60 pN"; exit 1; }
"$W/scan_twin" 2 0 500 5 0 0 0 0 0 0 30 0 0 15 0 1 > "$W/s1.json"
grep -q '"force_pixels_over":[1-9]' "$W/s1.json" || { echo "FAILED: nothing over 1 pN"; exit 1; }
# without a stiffness the force is not claimed
"$W/scan_twin" 2 0 500 5 > "$W/s0.json"
grep -q 'force_pn_max' "$W/s0.json" && { echo "FAILED: force reported without a stiffness"; exit 1; } || true
echo "force next to the image in the report: ok"
echo "liquid flow: passed"
