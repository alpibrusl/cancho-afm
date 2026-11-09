# Safety for the water version: liquid, electronics, laser and biology (S9.10 of `docs/liquid.md`)

> Written 2026-11-08 by the project's AI assistant. **A draft. No person has read it yet, so it does not meet its own acceptance** (below). It is not a biosafety, laser-safety or electrical-safety assessment by a competent person, and it does not replace the rules of the place where the instrument is used, which are **[unknown]** here. Nothing in it was tested on hardware. Tags: **[repo]** read in this repository; **[general]** general knowledge, not checked; **[unknown]**.

**Gate.** S9.11 (the first image in water) and anything that puts liquid on the instrument **must not start** until the review table at the end has a named reader other than the author, a date and a result.

## The hazards

| Hazard | Where it comes from | Worst case |
|---|---|---|
| **Liquid on electronics** | the fluid cell, a spill, a leak at the seal or the O-ring (S9.9) | a short on the amplifier board or the FPGA board; corrosion; with mains-derived supplies, a shock **[general]** |
| **Voltage** | the dry amplifier's rails are **+-12 V** [repo, `docs/amplifier.md`]; the fast Z stack of `docs/hs-order.md` is a **150 V** part (PiezoDrive SA050510, 0 to 150 V) and its amplifier is **not designed** [repo] | 150 V next to a conductive liquid |
| **Laser** | a 650 nm, 5 mW module (`docs/liquid-optics.md`) | eye damage from the beam or a reflection from the window, the lever or the lens **[general]**; the class of the real module is **[unchecked]** |
| **Biological material** | the soft test sample (S9.12) | depends entirely on what is used: see the biosafety section |
| **Chemicals** | buffers, cleaning agents, and, if a lipid film is prepared from a solvent, an organic solvent **[general]** | irritation, fumes, flammability |
| **Mechanical** | the coarse motor driving the lever toward the sample; a brittle lever chip; glass cover slips | a crashed lever (damage to the instrument, not a person); cuts from glass or sharp tips **[general]** |

## The interlock list

"Exists" means it is in this repository and was tested where the row says. A software refusal is **not** an interlock: it protects the image, not a person or the hardware, and it stops working when the software does.

| # | Interlock | Where it lives | State |
|---|---|---|---|
| 1 | **Z limits** `ZMIN`, `ZMAX`, set by the host and read back; Z never leaves them while the loop runs | FPGA (`gen/`) | **exists**, tested in simulation (`tests/board_test.cho`) and in the Verilog check. **Caveat: in MANUAL mode the DAC codes bypass `ZMIN` and `ZMAX`** (`docs/bench.md`): anything that uses `MAN_*` with an amplifier and a piezo attached can put the full range on the piezo |
| 2 | **Deadman**: `TIMEOUT` clocks without a `KICK` latch a fault and Z goes to the retract value | FPGA | **exists**, tested in simulation (`tests/board_test.cho`); a power-off or a host crash retracts Z, **not the coarse motor** |
| 3 | **Fail-closed defaults**: after power-on `CTRL` is 0 and every limit and the retract Z are 0 | FPGA | **exists** [repo, `docs/registers.md`] |
| 4 | **Light refusals** 81, 82, 83 (no light, faded, deflection out of range) | host, `session` profile 2 | **exists, software only**: protects the image |
| 5 | **Leak detection** that cuts the supplies to the scanner amplifier and the laser **in hardware**, independent of the FPGA and the host | analogue: a conductivity or wetness sensor in a drip tray under the cell, a comparator with a latch, a relay or a switch in the supply lines | **not built, not designed**. A requirement: the cut must work with the FPGA and the host dead. A software-read status bit for it could be added to the register table, but a bit is a report, not an interlock |
| 6 | **Current limits and fuses** in each supply line (the 500 mA resettable PTC of `docs/amp-order.md`) | amplifier board | **in the parts list** [repo], not built |
| 7 | **Dry/wet separation by construction**: the laser, lens, photodiode, amplifiers and conditioning are above the window; only the lever chip, holder and sample are wet; the scanner's electrodes and wiring are insulated and sealed away from the liquid | the mechanics | **drawn** (`docs/liquid-optics.svg`), **not designed**; this is S9.9's job, with a leak test using plain water and **no electronics powered** |
| 8 | **A drip tray** under the cell, deep enough for the whole cell volume, and **a small cell volume** (a proposal: about 1 mL or less) | the mechanics | **proposal**, not designed |
| 9 | **A physical stop switch** that removes the amplifier and laser supplies by hand | supply | **not built** |
| 10 | **Laser rules**: goggles for 650 nm, the beam path enclosed or at least below eye level, power at the lowest value that shows, a rule to switch it off before touching the head | procedure | **proposal**; class and required measures **[unknown]**, to be fixed by whoever signs the review |

## The power-off procedure (not yet rehearsed on any hardware)

Normal shutdown, in this order:
1. Stop the scan and the loop: write `CTRL` = 0 (the end of `session`, stage 7). Read `STATUS` and `ZOUT` back.
2. **Retract the lever from the sample** with the coarse motor by a distance longer than the approach used, with the **backlash overshoot rule, proposed in `docs/motor-retract.md` (not built; it needs the measured backlash)**: until it is, the retract must be checked by eye or by the readings, not assumed.
3. Switch the **laser** off.
4. Switch the **amplifier supplies** off at the stop switch.
5. Only then unplug the USB of the FPGA board.
6. Only with everything off, handle the liquid: remove the sample, empty the cell, wipe the tray.

**If liquid is where it should not be:** (a) the stop switch, (b) unplug the supplies, (c) do not touch the wet parts until it is dry and unplugged, (d) mop up, (e) do not power the instrument until the parts are dry and the cause is found. **The drill must be rehearsed once** with plain water and nothing powered, as part of S9.9's leak test, and the result written down: **not done**.

## What the project will and will not handle (biosafety; a proposal)

**Will handle (in S9.11 and S9.12, in a place that allows it):**
* mica, plain water and ordinary buffers (for example a Tris or phosphate buffer **[general]**);
* **commercially supplied lipid vesicles or liposomes, already in water**, prepared as a supported bilayer on mica: a non-living, non-infectious material **[general; to be confirmed against the supplier's safety data sheet for the chosen product]**.

**Will not handle (without a named collaborator whose institution approves it):**
* any living cell, fixed cell or tissue; bacteria, viruses, or any material that could carry them;
* anything of human or animal origin (blood, serum, tissue, cell lysate);
* any recombinant organism, any toxin, and any biological agent that needs a biosafety level above the plain minimum or any approval;
* **organic solvents that need a fume hood**: a lipid film made from a solvent such as chloroform is **not** prepared here; if used, it is prepared elsewhere by someone equipped for it;
* radioactive or unknown-hazard materials, including unknown nanoparticles.

**Waste and spills:** liquid from the cell and the sample are treated as the supplier's safety data sheet and the local rules say **[unknown here]**; lever chips and cover slips go in a sharps container **[general]**; surfaces are wiped after use. Whether the owner's site needs any approval for the above is **[unknown]**.

**S9.12 waits for a named wet-lab collaborator** (decision recorded in `docs/liquid.md`, S9.1); this note is what the project promises to do until there is one.

## Review

| Reader (not the author) | Role | Date | Read all of it? | Result and changes asked |
|---|---|---|---|---|
| *not yet named* | | | | **NOT REVIEWED** |

Questions to put to the reader: the laser class and what it needs; whether the electrical arrangement (low-voltage supplies, no mains-powered part near the liquid) is acceptable and what the 150 V stack changes; whether the biosafety list is the right line for the site; what the site requires for waste; whether a leak interlock like #5 is enough or a different design is required.

## What this note does not claim

No measure in it was tested; the power-off is a sequence on paper; the leak interlock does not exist; the laser's class was not looked up; and no person has read it.
