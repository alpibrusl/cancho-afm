# hw/kicad: the piezo driver board

`amp.kicad_sch` is the schematic of the X, Y and Z piezo drivers, the 1.43 V reference and the supply of [`docs/amplifier.md`](../../docs/amplifier.md), **generated** by `gen_sch.cho`
(`cancho run hw/kicad/gen_sch.cho --std > hw/kicad/amp.kicad_sch`). It is written like a netlist: every pin ends in a net label, so the nets are the names in the generator and nothing depends on
placement. The symbols are the generator's own (library `cancho`, embedded in the file); the footprints are the parts to buy, **not checked against their pad numbering**.

`sh hw/kicad/check.sh` (with `CANCHO` and, for the KiCad part, `KICAD_CLI`) checks: the file equals the generator's output; KiCad's ERC (10.0.7) has no finding except the library
configuration of the machine; and `check_nets.py` reads the exported netlist and confirms, for X, Y and Z, that Rf is taken from the load side, Cf from the op-amp output, Riso in series, the
op-amp pins, the values **equal those of `hw/amp/xy_amp_b.cir` and `z_amp.cir`**, the reference divider can hold 1.43 V, and the decoupling is there.

**Not done:** the fork's front end (drive divider, transimpedance stage, C0 trimmer, receive gain and ADC protection of docs/amplifier.md) is not drawn yet; no board layout; part values are those
of the simulation (the piezo's capacitance and the op-amp's output resistance are still assumptions). The first check found a real error: `z_amp.cir` carried Cf = 330 pF while the design and
the document's table use 680 pF; the file is corrected.
