#!/bin/sh
# docs/high-speed.md, HS1: the frame rate the twin predicts for the high-speed (1) and liquid (2) profiles when the loop steps per pixel are cut, and what the tune stage does with a real air Q.
# Predictions of the twin, not measurements. Needs only CANCHO. Run from the repository root:  CANCHO=... sh tests/hs_rate.sh
set -e
cd "$(dirname "$0")/.."
: "${CANCHO:?set CANCHO}"
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
MODS="$(ls sim/*.cho) host/regs.cho gen/ir.cho gen/pid_ir.cho gen/raster_ir.cho gen/lockin_ir.cho host/proto.cho host/twin_link.cho host/script.cho host/run_twin.cho SESSION host/image.cho host/metrics.cho host/features.cho host/drift.cho host/report.cho host/png.cho host/force.cho host/align.cho"
OLD='pub fn pixdiv(p: int) -> \[\] int { if fast(p) == 1 { return 20; } return 60; }'
build() {  # $1 loop steps per pixel
    sed "s/$OLD/pub fn pixdiv(p: int) -> [] int { if fast(p) == 1 { return $1; } return 60; }/" host/session.cho > "$W/s$1.cho"
    grep -q "return $1; } return 60;" "$W/s$1.cho" || { echo "FAILED: pixdiv line not found in host/session.cho"; exit 1; }
    "$CANCHO" build host/scan_twin.cho $(echo "$MODS" | sed "s#SESSION#$W/s$1.cho#") --std -o "$W/tw$1" > /dev/null
}
frame_us() { "$W/tw$1" "$2" 0 500 0 0 0 0 0 0 0 "$3" | grep '^frame_us' | cut -d' ' -f2; }
for pd in 20 10 4; do build $pd; done
# the frame time is the loop steps per pixel times a constant (32,260 us per step, 64 x 64 with trace and retrace): halving the steps halves the time
for prof in "1 0" "2 30"; do
    set -- $prof
    a=$(frame_us 20 "$1" "$2"); b=$(frame_us 10 "$1" "$2"); c=$(frame_us 4 "$1" "$2")
    [ "$a" = 645200 ] && [ "$b" = 322600 ] && [ "$c" = 129040 ] || { echo "FAILED: frame times for profile $1: $a $b $c (expected 645200 322600 129040)"; exit 1; }
done
echo "frame time follows the loop steps per pixel (profiles 1 and 2): ok"
# an air cantilever (Q 100): the tune sweep's 12.7 kHz step misses a 5 kHz line, so the run is refused with 21 (no resonance), not scanned
"$W/tw20" 1 0 500 0 0 0 0 0 0 0 1000 | head -n 1 | grep -qF 'failure code 21,' || { echo "FAILED: Q 100 was not refused with code 21 (docs/high-speed.md, HS1, is out of date)"; "$W/tw20" 1 0 500 0 0 0 0 0 0 0 1000 | head -n 1; exit 1; }
# the same profile at Q 5 (the twin's default) completes
"$W/tw20" 1 0 500 0 | head -n 1 | grep -qF 'failure code 0,' || { echo "FAILED: the default profile 1 no longer completes"; exit 1; }
echo "air Q 100 refused with code 21, default completes: ok"
echo "hs rate: passed"
