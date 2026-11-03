#!/bin/sh
# Builds a bitstream for the Tang Nano 20K from the generated SystemVerilog. Needs the YosysHQ OSS CAD Suite on the PATH
# (on the Pi: . ~/tools/oss-cad-suite/environment). It loads NOTHING onto the board unless given --flash, and --flash replaces whatever
# design the board holds, so check that nothing else (for example the robot project) is using the board first.
#   sh gen/build_fpga.sh [DIR] [--flash]      DIR holds afm_glue.sv pid_step.sv raster.sv lockin.sv spi.sv (default: build)
set -e
DIR=build; FLASH=no
for a in "$@"; do case "$a" in --flash) FLASH=yes ;; *) DIR="$a" ;; esac; done
HERE=$(cd "$(dirname "$0")" && pwd)
OUT="$DIR/fpga"; mkdir -p "$OUT"
need() { command -v "$1" >/dev/null 2>&1 || { echo "missing tool: $1"; exit 2; }; }
need yosys; need nextpnr-himbaechel; need gowin_pack
echo "== 1 yosys"
yosys -q -l "$OUT/yosys.log" -p "read_verilog -sv $DIR/afm_glue.sv $DIR/pid_step.sv $DIR/raster.sv $DIR/lockin.sv $DIR/spi.sv; synth_gowin -top afm_top -json $OUT/afm.json"
echo "== 2 nextpnr (27 MHz target)"
nextpnr-himbaechel --json "$OUT/afm.json" --write "$OUT/afm_pnr.json" --device GW2AR-LV18QN88C8/I7 --vopt family=GW2A-18C --vopt cst="$HERE/afm_top.cst" --freq 27 --seed 1 --log "$OUT/pnr.log" > /dev/null
grep -E "Max frequency" "$OUT/pnr.log" | tail -1
echo "== 3 gowin_pack"
gowin_pack -d GW2A-18C -o "$OUT/afm.fs" "$OUT/afm_pnr.json"
echo "bitstream: $OUT/afm.fs"
if [ "$FLASH" = yes ]; then
  need openFPGALoader
  echo "== 4 flashing to SRAM (the board loses it on power-off)"
  openFPGALoader -b tangnano20k "$OUT/afm.fs"
else
  echo "not flashed (pass --flash with the board connected, after checking nothing else uses it)"
fi
