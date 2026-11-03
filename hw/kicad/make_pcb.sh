#!/bin/sh
# The board, end to end: the netlist of the schematic -> placement and pads (gen_pcb.py) -> routing (route.cho, in cancho) -> the board with its tracks (gen_pcb.py).
#   CANCHO=path KICAD_CLI=path sh hw/kicad/make_pcb.sh > hw/kicad/amp.kicad_pcb        (from the repository root; KICAD_FOOTPRINTS overrides the library directory)
set -e
FP=${KICAD_FOOTPRINTS:-$(dirname "$KICAD_CLI")/../SharedSupport/footprints}
mkdir -p /tmp/amprouter
"$KICAD_CLI" sch export netlist --format kicadsexpr -o /tmp/amp.net hw/kicad/amp.kicad_sch > /dev/null 2>&1
PADS_OUT=/tmp/amprouter/pads.txt python3 -I hw/kicad/gen_pcb.py /tmp/amp.net "$FP" > /dev/null 2>&1
"$CANCHO" run hw/kicad/route.cho --std > /tmp/amprouter/routes.txt
python3 -I hw/kicad/gen_pcb.py /tmp/amp.net "$FP" /tmp/amprouter/routes.txt 2> /tmp/amprouter/gen.err
cat /tmp/amprouter/gen.err >&2
