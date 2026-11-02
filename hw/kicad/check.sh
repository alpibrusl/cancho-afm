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
