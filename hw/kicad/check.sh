#!/bin/sh
# The schematic against the generator and the simulated circuits. Needs the cancho compiler (CANCHO) and, for the KiCad part, KICAD_CLI=path of kicad-cli
# (without it only the drift check runs, and the script says so). Run from the repository root: sh hw/kicad/check.sh
set -e
CANCHO=${CANCHO:-../cancho/target/release/cancho}
$CANCHO run hw/kicad/gen_sch.cho --std > /tmp/amp.kicad_sch.new
cmp -s /tmp/amp.kicad_sch.new hw/kicad/amp.kicad_sch || { echo "hw/kicad/amp.kicad_sch is stale: regenerate it with gen_sch.cho"; exit 1; }
echo "amp.kicad_sch equals the generator's output: passed"
if [ -z "${KICAD_CLI:-}" ]; then echo "KICAD_CLI not set: ERC and net checks skipped"; exit 0; fi
cd hw/kicad
"$KICAD_CLI" sch erc --format report --severity-all -o /tmp/amp_erc.rpt amp.kicad_sch > /dev/null 2>&1 || true
# the library warnings are the configuration of the machine (the symbols are embedded; the footprint libraries are not searched here); anything else is a finding
bad=$(grep -E '^\[' /tmp/amp_erc.rpt | grep -v -E '^\[(footprint_link_issues|lib_symbol_issues)\]' || true)
[ -z "$bad" ] || { echo "ERC findings:"; echo "$bad"; exit 1; }
echo "ERC: no findings beyond the library configuration: passed"
"$KICAD_CLI" sch export netlist --format kicadsexpr -o /tmp/amp.net amp.kicad_sch > /dev/null 2>&1
python3 -I check_nets.py /tmp/amp.net | tail -1
python3 -I check_nets.py /tmp/amp.net > /dev/null
echo "netlist against the simulated circuits: passed"
# the board: generated from the netlist and KiCad's footprint libraries (KICAD_FOOTPRINTS, default: next to a macOS kicad-cli), then KiCad's DRC with schematic parity
FP=${KICAD_FOOTPRINTS:-$(dirname "$KICAD_CLI")/../SharedSupport/footprints}
python3 -I gen_pcb.py /tmp/amp.net "$FP" > /tmp/amp.kicad_pcb.new 2> /dev/null
cmp -s /tmp/amp.kicad_pcb.new amp.kicad_pcb || { echo "hw/kicad/amp.kicad_pcb is stale: regenerate it with gen_pcb.py"; exit 1; }
echo "amp.kicad_pcb equals the generator's output: passed"
"$KICAD_CLI" pcb drc --schematic-parity --refill-zones --severity-all --format report -o /tmp/amp_drc.rpt amp.kicad_pcb > /dev/null 2>&1 || true
grep -q "Found 0 Footprint errors" /tmp/amp_drc.rpt || { echo "the board and the schematic disagree:"; grep -A4 "Footprint errors" /tmp/amp_drc.rpt | head; exit 1; }
bad=$(grep -E '^\[' /tmp/amp_drc.rpt | grep -v -E '^\[(lib_footprint_issues|unconnected_items)\]' || true)
[ -z "$bad" ] || { echo "DRC findings:"; echo "$bad"; exit 1; }
echo "DRC: no overlap or clearance finding, schematic parity 0 ($(grep -c '^\[unconnected_items\]' /tmp/amp_drc.rpt) unrouted connections: the board has no tracks yet): passed"
