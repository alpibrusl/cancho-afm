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
# HS4 (docs/high-speed.md): is the lock-in window what limits the frame rate? At 10.3 frames/s (3 loop steps per pixel), Q 100 damped to Q 5 (gain 19), 1,000 pm step.
# (a) the gains the tune chooses are far too low for an ideal Z scanner: doubling them cuts the lag from about 310 pm to about 50 pm
build 3
g() { "$W/tw3" 1 "$1" 500 0 0 0 0 0 0 0 1000 0 0 0 0 0 0 100 0 0 1000 190 0 "$2"; }   # $1 Z scanner (0 ideal, 5 = 50 kHz Q 3), $2 gain scale in percent
a1=$(lag_rms g 0 100); a2=$(lag_rms g 0 200)
awk -v a="$a1" -v b="$a2" 'BEGIN { exit !(a > 200 && b < 100) }' || { echo "FAILED: gain scale 100 -> 200 gave $a1 -> $a2 pm with an ideal scanner (HS4 is out of date)"; exit 1; }
# (b) with a 50 kHz scanner the same doubling makes it worse: the Z scanner, not the gain rule, sets the limit
s1=$(lag_rms g 5 100); s2=$(lag_rms g 5 200)
awk -v a="$s1" -v b="$s2" 'BEGIN { exit !(b > a) }' || { echo "FAILED: with a 50 kHz scanner gain scale 100 -> 200 gave $s1 -> $s2 pm, expected worse (HS4 is out of date)"; exit 1; }
# (c) a one-cycle window (9 samples) at the same frame time (6 loop steps per pixel) is not better than the 18-sample one, each at its best of two gain scales (lag 50 and 56 pm in the table)
sed 's/var n = 16;/var n = 8;/; s/if m < 2 { m = 2; }/if m < 1 { m = 1; }/' sim/lockin.cho > "$W/lockin_m1.cho"
grep -q 'var n = 8;' "$W/lockin_m1.cho" && grep -q 'if m < 1' "$W/lockin_m1.cho" || { echo "FAILED: the one-cycle lockin variant was not made"; exit 1; }
sed "s/if fast(p) == 1 { return 20; } return 60;/if fast(p) == 1 { return 6; } return 60;/" host/session.cho > "$W/s6.cho"
"$CANCHO" build host/scan_twin.cho $(echo "$MODS" | sed "s#SESSION#$W/s6.cho#; s#sim/lockin.cho#$W/lockin_m1.cho#") --std -o "$W/tw6m1" > /dev/null
w9a=$("$W/tw6m1" 1 0 500 0 0 0 0 0 0 0 1000 0 0 0 0 0 0 100 0 0 1000 190 0 150 | head -n 1 | grep -o 'window [0-9]*')
[ "$w9a" = "window 9" ] || { echo "FAILED: the one-cycle variant did not pick a window of 9 (got: $w9a)"; exit 1; }
b18=$(for s in 150 200; do lag_rms g 0 $s; done | sort -n | head -n 1)
b9=$(for s in 150 200; do lag_rms "$W/tw6m1" 1 0 500 0 0 0 0 0 0 0 1000 0 0 0 0 0 0 100 0 0 1000 190 0 $s; done | sort -n | head -n 1)
awk -v a="$b18" -v b="$b9" 'BEGIN { exit !(b > 0.8 * a) }' || { echo "FAILED: a 9-sample window reached $b9 pm against $a pm for 18 (HS4 is out of date: the window may be the limit after all)"; exit 1; }
echo "HS4: doubling the gains cuts the lag $a1 -> $a2 pm (ideal scanner) but $s1 -> $s2 pm with a 50 kHz one; a 9-sample window ($b9 pm) is no better than 18 ($b18 pm): ok"
# HS7 (docs/high-speed.md): a gain rule that knows the Z scanner. Q 100 damped to Q 5, 1,000 pm step; the last argument tells the host the twin's scanner resonance (1) or not (0).
h() { "$1" 1 "$2" 500 0 0 0 0 0 0 0 1000 0 0 0 0 0 0 100 0 0 1000 190 0 0 "$3"; }   # $1 binary, $2 Z scanner (4 = 30 kHz, 1 = 100 kHz), $3 known
# (a) a 30 kHz scanner at 10 steps per pixel: the chosen gains ring (lag about 920 pm); the scaled ones do not
k0=$(lag_rms h "$W/tw10" 4 0); k1=$(lag_rms h "$W/tw10" 4 1)
awk -v a="$k0" -v b="$k1" 'BEGIN { exit !(b < 0.5 * a) }' || { echo "FAILED: a 30 kHz scanner: known $k1 pm against not known $k0 pm (HS7 is out of date)"; exit 1; }
# (b) a 100 kHz scanner at 3 steps per pixel: the chosen gains are timid (about 300 pm); the scaled ones are not
f0=$(lag_rms h "$W/tw3" 1 0); f1=$(lag_rms h "$W/tw3" 1 1)
awk -v a="$f0" -v b="$f1" 'BEGIN { exit !(b < 0.5 * a) }' || { echo "FAILED: a 100 kHz scanner: known $f1 pm against not known $f0 pm (HS7 is out of date)"; exit 1; }
# (c) an ideal scanner is not known to the host either way: the same scan
[ "$(lag_rms h "$W/tw3" 0 0)" = "$(lag_rms h "$W/tw3" 0 1)" ] || { echo "FAILED: telling the host about an ideal scanner changed the scan"; exit 1; }
# (d) a pixel shorter than 0.7 of a 30 kHz scanner's period (3 steps) is refused with 36 before the approach
h "$W/tw3" 4 1 | head -n 1 | grep -qF 'failure code 36,' || { echo "FAILED: 3 steps per pixel with a 30 kHz scanner was not refused with 36"; h "$W/tw3" 4 1 | head -n 1; exit 1; }
h "$W/tw3" 4 0 | head -n 1 | grep -qF 'failure code 0,' || { echo "FAILED: refused although the scanner was not known"; exit 1; }
echo "HS7: a known scanner cuts the lag $k0 -> $k1 pm (30 kHz) and $f0 -> $f1 pm (100 kHz); 3 steps with 30 kHz refused with 36: ok"
echo "hs rate: passed"
