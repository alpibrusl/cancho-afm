# Parts for the high-speed stage (H5 of `docs/high-speed.md`)

> Written 2026-11-03. **Nothing bought; no shop's basket, shipping, tax or import duty is included.** Each price is tagged: **[read]** = I opened the product page and read it on 2026-11-03; **[snippet]** = seen in a search result, page not read (stale or wrong currency possible);
> **[unchecked]** = no price found. Currencies are as the shop shows them, not converted. Specifications are the makers' nominal values.
> This list is for the **second stage** only. The first (tuning fork) is in `shopping-list.md` and `amp-order.md`.

## The sensor and the cantilever

| Part | Candidate and what was found | Price |
|---|---|---|
| **Cantilever, cheap, to validate the electronics in air** | Tap300-G (BudgetSensors; Nano and More): 300 kHz (200 to 400), 40 N/m, 125 x 30 x 4 um, tip radius under 10 nm, box of 10. Q is not on the page. A stiff tapping lever in air has a Q of hundreds, so its response time is tens to hundreds of microseconds: it tests the detector, the snap, the loop and the optics, **not high speed** | USD 200 per 10 [read] ([Nano and More](https://www.nanoandmore.com/AFM-Probe-Tap300-G)); Tap300Al-G, aluminium-coated (better reflection), USD 210 per 10 [snippet] (Ted Pella) |
| **Cantilever, a real high-speed one** | NanoWorld USC-F1.2-k0.15: 1.2 MHz (0.8 to 1.6), 0.15 N/m, 7 x 2 x 0.08 um, "mainly designed for high-speed AFM in liquid, also usable in air"; NanoWorld says it cannot be used in all commercial AFMs because of its size. A 0.3 MHz, 0.3 N/m model (USC-F0.3-k0.3) was seen at USD 980 per 10 [snippet] | **USD 1,183 per 10** [read] ([Nano and More](https://www.nanoandmore.com/AFM-Probe-USC-F1.2-k0.15)): about USD 118 each, six times the Tap300. Its 7 x 2 um size needs a focused spot of a few microns: **[unknown]** whether a salvaged or cheap lens does it |
| **Quadrant photodiode** | Hamamatsu S4349: four segments, cutoff 20 MHz at 5 V reverse bias, 50 ohm load, 780 nm (datasheet figure, per the search). The 650 nm lasers below are within a silicon photodiode's range; its responsivity there was not looked up | GBP 37.43 ex VAT [snippet] (RS UK; the page itself refused to load). First Sensor / Pacific Silicon QP50-6 and QP5.8 were found too: no bandwidth or price **[unchecked]** |
| **Laser** | Olimex LASER-650nm, 5 mW, 6 mm x 13 mm, 5 cm leads: **a bare diode, no collimating lens, no driver** | EUR 0.50 [read] ([Olimex](https://olimex.com/Products/Components/LEDs/LASER-650nm)). A focusable module (lens, driver) is what is wanted: eBay lists them as 5 x 635 nm, 3 V, brass; Picotronic sells 650 nm focusable modules (LFD650-5-3): price **[unchecked]** |
| **Transimpedance amplifier for the photodiode** | TI OPA657 (1.6 GHz, FET input, aimed at photodiodes) or OPA656 | OPA657UB USD 16.45 (Farnell, 55 in stock) and USD 14.56 (Mouser) [snippet from price aggregators, date unknown]; OPA656U USD 15.86 [snippet] |
| **Optics, mirror, mount, alignment** | A lens to focus the spot on a 2 um wide lever, a mirror, a mount with adjustment, a holder for a 3.4 x 1.6 x 0.3 mm chip | **[unknown]** and the largest unsolved item: not designed, not priced. The salvaged DVD pickup of `shopping-list.md` row 12 combines laser, lens and photodiode, but its bandwidth and focus are **[unknown]** for a 1 MHz lever |

## The converters, the drive, the scanner

| Part | Candidate and what was found | Price |
|---|---|---|
| **ADC, 4.5 to 10 MS/s, 12 bits** | AD9226 module: 12 bits, 65 MS/s, parallel output, SMA input, screw-terminal power, 2 V internal reference; the seller is in Brno and delivers to 21 EU countries (not the Czech Republic, per its own list) | **EUR 20.70 with VAT, 22 in stock** [read] ([Neven](https://www.neven7.eu/p/ad9226-module-12bit-high-speed-adc)). Marketplace copies USD 28 to 64 [snippet]. **Needs a new generated interface block** (H3b) and 13 or more FPGA pins; whether the Tang Nano 20K header has them free is **[unchecked]** |
| **Drive DAC, 4.5 MS/s for a 500 kHz sine** | An **8-bit R-2R ladder on FPGA pins** and an RC low-pass: eight bits of resistors and a capacitor, cents. Nothing to buy beyond what the amplifier board uses. Image frequencies at 4.5 MS/s are filtered by the cantilever's own response. **Not designed or simulated** [A] | cents **[unchecked]**. The alternative is a module: an AD9708-class 8-bit 125 MS/s, about USD 40 for an unbranded eBay board [snippet] |
| **Z scanner for the fast loop** | PiezoDrive SA050510: 5 x 5 x 10 mm stack, 10 um at 0 to 150 V, **630 nF**, force 900 N, in stock; **resonance not listed** | USD 68 [read] ([PiezoDrive](https://www.piezodrive.com/product/150v-5x5x10mm-piezo-stack-actuator-sa050510/)). PI PICMA PL055.31: 5 x 5 x 2 mm, 2.2 um at 100 V, axial resonance **over 600 kHz** per the search result (the page text did not load for me; capacitance **[unchecked]**) USD 68 [snippet]. A 5 x 5 x 9 mm stack with about 140 kHz resonance (Deep Minds BBPXMS-5X5X9) [snippet]: price **[unchecked]** |
| **Fast piezo amplifier** | none chosen; see the calculation below | **[unchecked]** |

## What the stack asks of the amplifier (computed [A], from the figures above)

The earlier slew result (H2: a 20 pm/us amplifier breaks the loop at a 150 pm step) must be read against real numbers. A stack with 10 um per 150 V is 67 nm/V; the 150 pm terrace step is **2.2 mV**. For a 2.2 um per 100 V chip (22 nm/V) it is 6.8 mV. So:

* **Slew:** 20 pm/us on the 67 nm/V stack is 0.3 mV/us: every op-amp is thousands of times faster. **The H2 slew failure will not come from the op-amp's slew rate**; it would come from the current into the capacitance.
* **Current into 630 nF:** a 150 pm step in one 4 us loop update is 0.35 mA. A 1 nm sine at 100 kHz (15 mV peak on that stack) is 6 mA. These are small: an op-amp able to deliver 10 to 20 mA into a capacitive load, with an isolating resistor, suffices **for the fast, small-signal part**.
* **The large range** (the approach, 10 um) is another matter: 150 V swings into 630 nF at even 1 kHz is 0.6 A. It belongs on the slow path (the existing +-15 V amplifier cannot give 150 V). A **two-path design**: a slow high-voltage path for the range and a fast low-voltage path summed in for the nanometre-scale detail, is the usual arrangement, **not designed here**.
* **The stack's own resonance** (not listed for the SA050510) decides how fast the fast path can go; H2 said about 50 kHz and up for a 250 kHz loop. Ask the maker, or measure.

## Totals, honestly

Counted only where a price was **read** on 2026-11-03: Tap300 box USD 200 + AD9226 EUR 20.70 + SA050510 USD 68 + the 0.50 EUR bare laser diode, about **USD 300**, **without** the photodiode (GBP 37, snippet), TIA (USD 15 to 20, snippet), a laser module with lens, any optics or mounting, the fast amplifier, the board, and shipping. With the USC-F1.2 instead of the Tap300, add USD 983. These are **parts**; they make a bench, not an instrument.

## What this changes in the plan

1. **A real HS lever is the expensive line**, ten times a Tap300 per probe at USD 118, and the optics for its 2 um width are unsolved. A sensible order is: Tap300 in air first (the detector, the snap, the loop and the optical path all get tested at a fraction of the cost), the USC only once that works.
2. **Air limits the rate whatever the electronics do** (the Q of a Tap300 in air); `docs/high-speed.md` says why. The first measurement (H6) with a Tap300 will not show a high-speed line rate and must not be reported as one.
3. **Open, in order:** the optics and photodiode mount (nothing designed); the interface block for the AD9226 (H3b); the fast amplifier and the two-path arrangement; the stack's resonance; a focusable laser module and its price.
