# hw/kicad: the piezo driver board

`amp.kicad_sch` is the schematic of the X, Y and Z piezo drivers, the 1.43 V reference, the supply and the fork's front end (drive divider, C0 trimmer, transimpedance stage, gain about 1.65 V, ADC clamp) of [`docs/amplifier.md`](../../docs/amplifier.md), **generated** by `gen_sch.cho`
(`cancho run hw/kicad/gen_sch.cho --std > hw/kicad/amp.kicad_sch`). It is written like a netlist: every pin ends in a net label, so the nets are the names in the generator and nothing depends on
placement. The symbols are the generator's own (library `cancho`, embedded in the file); the footprints are the parts to buy, **not checked against their pad numbering**.

`sh hw/kicad/check.sh` (with `CANCHO` and, for the KiCad part, `KICAD_CLI`) checks: the file equals the generator's output; KiCad's ERC (10.0.7) has no finding except the library
configuration of the machine; and `check_nets.py` reads the exported netlist and confirms, for X, Y and Z, that Rf is taken from the load side, Cf from the op-amp output, Riso in series, the
op-amp pins, the values **equal those of `hw/amp/xy_amp_b.cir` and `z_amp.cir`**, the reference divider can hold 1.43 V, and the decoupling is there.

The 48 checks include the fork front end's values against `hw/amp/fork_fe.cir`, and each of three deliberate breaks (a wrong value, swapped op-amp inputs, a clamp to the wrong rail) is caught. **Not done:** no board layout; the front end is on the same ±12 V rails as the drivers (the ADC clamp, not the rail, protects the converter); no layout guard around the 1 Mohm node; part values are those
of the simulation (the piezo's capacitance and the op-amp's output resistance are still assumptions). The first check found a real error: `z_amp.cir` carried Cf = 330 pF while the design and
the document's table use 680 pF; the file is corrected.

## The board (`amp.kicad_pcb`): placed and routed, in cancho

`sh hw/kicad/make_pcb.sh > hw/kicad/amp.kicad_pcb` (with `CANCHO` and `KICAD_CLI`) makes the board end to end:

1. `gen_pcb.py` (Python, standard library only) reads the netlist exported from the schematic, copies each footprint it names from KiCad's own libraries, puts the 69 parts in rows by function, draws a 141 x 121 mm outline and a ground
   pour (solid connections) on both layers, and writes the pads to `/tmp/amprouter/pads.txt`;
2. **`route.cho` routes it, in cancho; no Java, no Freerouting.** A 127 um grid on two layers; each net grows as a tree, one pad at a time, by a shortest-path search (Dijkstra with a penalty for going against a layer's preferred
   direction and for a via) to the nearest pad it has not joined; routed copper and pads become keep-out disks for the other nets (track 0.25 mm, clearance 0.2 mm, via 0.8 mm / 0.4 mm drill, plus a cell for the snapping of
   centres to the grid). Ground is not routed: the pour joins it. No rip-up: a blocked net is reported (`F n`) and left, so the answer is a partial routing, never a short. It runs in about 3 seconds;
3. `gen_pcb.py` adds the tracks and vias to the board.

**Result (KiCad 10.0.7 DRC, with refilled zones):** every net routed (572 track segments, 55 vias), **0 unconnected, 0 clearance, 0 shorting findings, 0 schematic-parity errors**; the only findings are 69 about the machine's library
configuration, ignored by `check.sh`. A deliberate short added to a copy is reported (5 shorting items), and a wrong pad net raises the parity errors, so the check can fail. Two first runs showed what the router's model got wrong,
and the fixes are in the source: pad keep-outs ignored the snapping of centres to the grid (clearance 0.17 mm against 0.2 mm), and a square pad reaches its corner, not its half-width.

**Not done, and not claimed:** the placement is a first arrangement, not an optimised one (55 vias is a lot; the 1 Mohm node has no guard; the op-amps' decoupling loops are not short by design; the piezo outputs are not kept away
from the fork input); the tracks are all 0.25 mm and 90 degrees (no wider power tracks, no 45-degree corners); no mounting holes or silkscreen text; no fabrication check (a fab's own rules, the stack-up, annular ring, drill sizes); and the
board has never been built or measured.
