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
