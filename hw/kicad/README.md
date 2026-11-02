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

## The board (`amp.kicad_pcb`): placement only

`gen_pcb.py` (Python, standard library only: `python3 -I hw/kicad/gen_pcb.py NETLIST FOOTPRINT_DIR > hw/kicad/amp.kicad_pcb`) reads the netlist exported from the schematic, copies each footprint named in it from KiCad's own libraries, puts it on
its nets, places the 69 parts in rows by function (a row per drive channel, the reference, the supply, the fork front end), draws a 141 x 121 mm outline and a ground pour on both layers. **There are no tracks**: KiCad's DRC reports
**94 unrouted connections**, and nothing else (no overlap, no clearance finding, **0 schematic-parity errors**, which also settles the footprints' pad numbering against the symbols' pins: a footprint whose pads disagreed would be reported).
Breaking one pad's net in a copy raises the parity errors from 0 to 15, so the check can fail.

Not done: the routing (an autorouter such as Freerouting needs downloading; by hand, in the board editor), the placement is a first arrangement and not an optimised one (the 1 Mohm node's guard, the short loop of each
op-amp's decoupling, the piezo outputs away from the fork input), mounting holes, silkscreen text, a fabrication check. The library warnings of the DRC are the machine's configuration and are ignored by `check.sh`.
