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
# an air cantilever (Q 100). The tune needs a settle longer than the lever's own time constant and a second, finer pass (docs/high-speed.md, HS3); before that it was refused with code 21.
# lag_rms: the trace-minus-retrace rms over columns 2 to 61, in pm, from the scan records of mode 0 (a figure of the loop's lag, as in HS1)
lag_rms() { "$@" | awk 'NF == 3 && $1 ~ /^[0-9]+$/ { if ($2 < 64) tr[$1 "," $2] = $3; else if ($2 < 126) rt[$1 "," (126 - $2)] = $3 } END { for (k in tr) { split(k, a, ","); if (a[2] >= 2 && a[2] <= 61 && (k in rt)) { d = tr[k] - rt[k]; s += d * d; n++ } } if (n == 0) print "nan"; else printf "%.1f\n", sqrt(s / n) }'; }
air() { "$W/tw20" 1 0 500 0 0 0 0 0 0 0 "$1" 0 0 0 0 0 0 100 0 0 1000 "$2" "$3"; }   # $1 Q in tenths, $2 Q control gain in tenths, $3 its phase error in degrees
air 1000 0 0 | head -n 1 | grep -qF 'failure code 0,' || { echo "FAILED: Q 100 no longer completes"; air 1000 0 0 | head -n 1; exit 1; }
l0=$(lag_rms air 1000 0 0); l9=$(lag_rms air 1000 90 0); lq5=$(lag_rms air 0 0 0)
# without Q control the lag is large (1,014 pm in the table); with a gain of 9 (Q 100 -> 10) it is small (11 pm)
awk -v a="$l0" 'BEGIN { exit !(a > 500) }' || { echo "FAILED: Q 100 without control lags only $l0 pm (HS3 is out of date)"; exit 1; }
awk -v a="$l9" 'BEGIN { exit !(a < 50) }' || { echo "FAILED: a gain of 9 leaves a lag of $l9 pm (HS3 is out of date)"; exit 1; }
# a gain of 19 takes Q 100 to 5, the default profile: the same scan
[ "$(lag_rms air 1000 190 0)" = "$lq5" ] || { echo "FAILED: Q 100 with a gain of 19 is not the Q 5 scan"; exit 1; }
# a phase error past 90 degrees is refused with 85 before anything runs
air 1000 90 100 | head -n 1 | grep -qF 'failure code 85,' || { echo "FAILED: a phase error of 100 degrees was not refused with 85"; exit 1; }
# the default profile 1 still completes
"$W/tw20" 1 0 500 0 | head -n 1 | grep -qF 'failure code 0,' || { echo "FAILED: the default profile 1 no longer completes"; exit 1; }
echo "air Q 100 completes, Q control cuts the lag from $l0 to $l9 pm, 100 degrees refused with 85: ok"
echo "hs rate: passed"
