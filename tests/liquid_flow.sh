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
# the force map (mode 8): a PNG; with a stiffness it differs from the blank map of a scan without one
"$W/scan_twin" 2 0 500 8 0 0 0 0 0 0 30 0 0 15 0 100 > "$W/f.png"
"$W/scan_twin" 2 0 500 8 > "$W/f0.png"
[ "$(head -c 4 "$W/f.png" | tail -c 3)" = "PNG" ] || { echo "FAILED: force map is not a PNG"; exit 1; }
cmp -s "$W/f.png" "$W/f0.png" && { echo "FAILED: force map ignores the force"; exit 1; } || true
echo "force next to the image in the report: ok"
# the Z range (docs/liquid.md, "What the Z range found"): at the twin's 10 nm range a 3 nm step is read within 2%, a 20 nm step is not (the loop runs out of range)
step_of() { sed 's/.*"step_pm":\([0-9.]*\).*/\1/' "$1"; }
"$W/scan_twin" 2 0 500 5 0 0 0 0 0 0 30 0 0 15 0 100 0 100 0 0 3000 > "$W/z3.json"
"$W/scan_twin" 2 0 500 5 0 0 0 0 0 0 30 0 0 15 0 100 0 100 0 0 20000 > "$W/z20.json"
awk -v a="$(step_of "$W/z3.json")" 'BEGIN { exit !(a > 2940 && a < 3060) }' || { echo "FAILED: a 3 nm step not read within 2%"; exit 1; }
awk -v a="$(step_of "$W/z20.json")" 'BEGIN { exit !(a < 18000) }' || { echo "FAILED: a 20 nm step was read in full at a 10 nm Z range (the claim of docs/liquid.md is false)"; exit 1; }
echo "Z range: a 3 nm step read within 2%, a 20 nm step not: ok"
# the Z range rule (docs/liquid.md, "What the Z range found"; docs/high-speed.md, HS2): a 100 nm range completes and reads a 20 nm step within 2%; a 1 um range, whose worst-case approach does not fit
# in the step budget, is refused before anything moves with code 35 (rule 5); the 10 nm range is unchanged
wide() {  # $1 = the range in pm; builds $W/scan_$1
    sed "s/pub fn zmax() -> \\[\\] int { return 10000; }/pub fn zmax() -> [] int { return $1; }/" host/session.cho > "$W/session_$1.cho"
    grep -q "return $1; }" "$W/session_$1.cho" || { echo "FAILED: the $1 pm session was not made"; exit 1; }
    "$CANCHO" build host/scan_twin.cho $(echo "$MODS" | sed "s#host/session.cho#$W/session_$1.cho#") --std -o "$W/scan_$1" > /dev/null
}
wide 100000; wide 1000000
"$W/scan_100000" 2 0 500 0 | head -n 1 | grep -qF 'failure code 0,' || { echo "FAILED: a 100 nm range did not complete"; "$W/scan_100000" 2 0 500 0 | head -n 1; exit 1; }
"$W/scan_100000" 2 0 500 5 0 0 0 0 0 0 30 0 0 15 0 100 0 100 0 0 20000 > "$W/w20.json"
awk -v a="$(step_of "$W/w20.json")" 'BEGIN { exit !(a > 19600 && a < 20400) }' || { echo "FAILED: at a 100 nm range a 20 nm step was not read within 2%"; exit 1; }
"$W/scan_1000000" 2 0 500 0 | head -n 1 | grep -qF 'failure code 35,' || { echo "FAILED: a 1 um range was not refused with code 35"; "$W/scan_1000000" 2 0 500 0 | head -n 1; exit 1; }
"$W/scan_twin" 2 0 500 0 | head -n 1 | grep -qF 'failure code 0,' || { echo "FAILED: the 10 nm range no longer succeeds"; exit 1; }
echo "Z range rule: 100 nm completes and reads a 20 nm step, 1 um refused with code 35: ok"
echo "liquid flow: passed"
