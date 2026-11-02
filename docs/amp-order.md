# Order list for the piezo driver board

> Written 2026-11-02. The parts of the **board** in [`hw/kicad/`](../hw/kicad/README.md), 69 parts on 28 lines, generated from the schematic (`hw/kicad/amp_bom.csv`, by `gen_bom.py`: it cannot drift from the schematic; `check.sh` compares it).
> **No prices are given and none were checked.** A search for these parts on Reichelt found nothing I could cite (it returned DigiKey, Buerklin and Murata/TDK/KEMET pages), so the lines below say what to buy and where a part was *seen*, and the shop's own page is the
> price. [`shopping-list.md`](shopping-list.md) has the rest of the instrument (the FPGA board, the converters, the motor, the supply) with prices seen on 2026-11-02; the OPA2134 there is the same part.

## What the board needs (from `amp_bom.csv`)

| Qty | Part | Notes |
|---:|---|---|
| 4 (+1 spare) | OPA2134PA, DIP-8 | the simulation's reference part; see `shopping-list.md` for the shop seen |
| 1 (+1) | LM4040 2.5 V shunt reference, SOT-23, B grade or better | seen: [Diodes LM4040B25FTA, DigiKey ES](https://www.digikey.es/en/products/detail/diodes-incorporated/LM4040B25FTA/4249963) (0.2 %, 15 mA) |
| 1 (+1) | BAT54S, SOT-23 | dual series Schottky: the ADC input clamp |
| 2 (+1) | 1N5819, DO-41 | across the supply rails, reversed |
| 2 (+1) | fuse or resettable PTC 500 mA, 1206 | one in each supply line |
| 1 (+1) | trimmer 1 k, Bourns 3296W style | sets VREF to 1.43 V |
| 1 (+1) | **trimmer capacitor 1.5 to 5 pF**, through hole | cancels the fork's parallel capacitance. Seen: [Vishay BFC280823508, DigiKey UK](https://www.digikey.co.uk/en/products/detail/vishay-beyschlag-draloric-bc-components/BFC280823508/5371511) (1.5-5 pF, 150 V; 995 in stock, 11-week standard lead time). **Its pitch is not in the board's footprint (a placeholder): read the datasheet and fix the footprint before ordering boards** |
| 8 (+2) | **10 uF X7R radial multilayer ceramic, 25 V or more, 5 mm pitch, not polarised** | supply bypass. Seen: [Murata RCER71E106K3M1H03A, DigiKey UK](https://www.digikey.co.uk/en/products/detail/murata-electronics/RCER71E106K3M1H03A/4277128) (0.197 in lead spacing = 5.0 mm, body 5.5 x 4.0 mm; the footprint is 6.0 x 4.4 mm, which holds it). A 10 uF *film* capacitor does not exist at this size, and an electrolytic would be backwards on the -12 V rail |
| 8 (+2) | 100 nF X7R ceramic, 50 V, 5 mm pitch | decoupling |
| 2 (+1) | 100 nF film, 63 V or more, 5 mm pitch | signal coupling in the fork path |
| 2 (+1) | 330 pF C0G/NP0, 50 V | X and Y compensation (C0G: they set the stability) |
| 1 (+1) | 680 pF C0G/NP0, 50 V | Z compensation |
| 1 (+1) | 1 pF C0G/NP0, +-0.25 pF or better | across the 1 Mohm |
| 1 (+1) | 10 pF C0G/NP0 | gain stage |
| 6 / 4 / 3 / 2 / 1 each (+1 of each) | resistors 0207 metal film 1 %: 10 k x6, 100 k x4, 47 R x3, 69.8 k x2, 1 k x2, and one each of 1 M, 49.9 k, 30.1 k, 9.53 k, 2.7 k, 2.2 k | **69.8 k, 30.1 k, 49.9 k and 9.53 k are E96 values**: a shop that sells only E24 will not have them. The simulation's gains (7.98 and 4.01) depend on 69.8 k and 30.1 k; if you cannot buy them, say so and I will redesign with E24 values and re-simulate, which changes the schematic |
| 10 (+2), 1 | pin header 2.54 mm, 2 pins; 3 pins | the DAC and piezo leads, the supply |

**The board itself:** a fab (JLCPCB, PCBWay, Eurocircuits and others) takes the Gerbers that KiCad exports from `hw/kicad/amp.kicad_pcb`. I have not exported them, not checked a fab's rules against the board (minimum track and clearance, drill and annular ring, board size and price), and not asked for a quote. Do that before ordering; it is the next piece of work.

## Problems this list found in the design (fixed or open)

* **Fixed:** the 10 uF capacitors were drawn with a *film* footprint (7.2 x 3.0 mm), which cannot hold 10 uF; now a 6.0 x 4.4 mm radial ceramic footprint. The board was regenerated and rerouted (still every net routed, DRC clean).
* **Open:** the trimmer capacitor's footprint is a placeholder (above).
* **Open, from before:** the supply. Eight op-amps may draw about 32 mA per rail, too close to a 1 W, +-42 mA DC/DC module (`amplifier.md`): take a 2 W module or a separate supply.
* **Open:** the piezo's capacitance and rating are assumed (30 nF, and the 10 V the board's rails allow); read the piezo's datasheet before connecting one.
