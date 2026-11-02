# The amplifier: design and simulation

> Written 2026-11-02. **A design checked in a circuit simulator (ngspice) with a behavioural op-amp model. Nothing is built or measured.** Every value
> marked *assumed* is a guess that the bench must replace. Netlists and how to run them: [`hw/amp/`](../hw/amp/README.md).

## What it has to do

| Job | From | To | Why |
|---|---|---|---|
| **Z drive** | a DA3 output, 0 to 2.5 V | 0 to +10 V on the Z piezo | the 2025 paper's Z buzzer moved about 1 um for 0 to 10 V (their figure) |
| **X and Y drive** | 0 to 2.5 V (mid-scale 1.25 V) | -10 to +10 V on the scan piezos | the paper scanned 30 x 30 um with +-10 V |
| **Fork drive** | the fourth DA3, 1.25 V mid-scale plus a sine | a few tens of mV at the fork | a fork needs millivolts |
| **Fork receive** | the fork's current, nanoamps | 0 to 3.3 V on the AD1, centred on 1.65 V | the AD1's input range |

The DAC's 1 LSB (2.5 V / 65536 = 38 uV) becomes 153 uV on the Z piezo, **15 pm at 1 um per 10 V**: what the register map and the twin assume (16 pm per code).

## The piezo drivers (`xy_amp_b.cir`, `z_amp.cir`)

```
 DA3 out ---Rdac(6.25k, assumed)---+----------\          Riso 47          to piezo (Cp, assumed 30 nF)
                                   |  + OPA2134 >---oa---/\/\/\---+--------+----> Vout
                  Vref 1.43 V ---Rg 10k---+- (-)   /      |       |       === Cp
                                          |        \      |       Rf      ===
                                          +--- Cf 330p ---+       69.8k      |
                                          +--------------------------------+---- (feedback from the LOAD side)
```
**X/Y:** `Vout = (1 + Rf/Rg) Vin - (Rf/Rg) Vref` with Rg = 10 kohm (the inverting input returns to a reference, not ground), Rf = 69.8 kohm, Vref = 1.43 V from a
2.5 V shunt reference (LM4040) through a divider and a 1 kohm trimmer: **gain 7.98, 0 V out at mid-code, -9.98 V to +9.97 V over the DAC's range**.
**Z:** Rg from the inverting input to ground, Rf = 30.1 kohm: **gain 4.01, 0 to 10.0 V**, Cf = 680 pF.

**Why the Cf path** (a design change the simulation forced): with the feedback taken before the isolation resistor I had expected the load's capacitance to be out of the
loop. It is not: the op-amp's own output resistance drives the load through the isolation resistor and puts a pole inside the loop. With an output resistance of 100 ohm,
a 30 nF load made the output **overshoot by 2.4 V on a 12 V step** (it was clean at 10 to 25 ohm). The real part's output resistance at these frequencies is not known to me, so the
design is made insensitive to it: DC feedback from the load side (exact, since the load draws no current), and a small capacitor Cf from the op-amp's own output
to the inverting input that closes the loop at high frequency without the load.

| Results (simulated, op-amp output resistance 10, 25 and 100 ohm all behave the same) | X/Y, Cf = 330 pF | Z, Cf = 680 pF |
|---|---|---|
| gain at low frequency | 18.04 dB = 7.98 | 12.06 dB = 4.01 |
| output at mid-code | -6 mV (before the trimmer) | 5.012 V |
| -3 dB bandwidth, 30 nF load | 7.4 kHz | 8.9 kHz |
| 10 to 90% rise, 30 nF | 51 us | 39 us |
| overshoot, 10 to 100 nF load | none | none |
| **overshoot, 1 uF load** | 3.0 V (fails) | not run |
| a smaller Cf (100 pF; Z with 330 pF) | overshoots at 100 nF and up | 0.23 V at 100 nF |
| a larger Cf (1 nF, X/Y) | 2.3 kHz, slow | |

**What this means.** The bandwidth is far above what a scan needs (40 lines per second is a fundamental of tens of hertz) and above the Z loop's update rate of 4 kHz. **It is valid for a piezo up to
about 100 nF; a bigger one (a stack of microfarads) needs Cf raised and re-simulated.** The piezo disk's capacitance was *assumed* (30 nF); it is on the bench list to measure.

## The fork's front end (`fork_fe.cir`, `tia_chain.cir`)

```
 DA3 drive --Cc 100n--Rd1 49.9k--+--- fork ---+--- Rf 1M || Cfb 1p ---+                 +--Cc2 100n--+--- (+) OPA2134 ---Rs 1k---> AD1 A0
  (1.25 V mid)                   |            |                      |                 |            Rb 100k to 1.65 V    (gain 11,
                              Rd2 1k    (the fork's current)   (-)\ TIA >-- tout --------+                                   about 1.65 V)
                                 |                                  /
                                 +-- unity inverter (100k/100k) -- Ctrim 1.5-5 pF (trimmer) -- into the same input
```
* **Drive:** the DA3's AC part through 100 nF and a divider of 1/50.9: 1.25 V peak at the DAC is 24.6 mV peak at the fork.
* **Receive:** a transimpedance stage of 1 Mohm (1 pF across it) then an AC-coupled gain of 11 about Vmid = 1.65 V (a buffered divider from the AD1's 3.3 V). The total is **10.5 Mohm at 32,768 Hz,
  with corners at 15.8 Hz and 98 kHz** (so the 32.768 kHz signal sits well inside the band). Vout sits at 1.650 V when the fork is quiet.
* **The fork's parallel capacitance C0.** A watch crystal in the fork's package has a C0 of order 1 pF, whose current under the drive rivals the tiny motional current and rides under the resonance as a
  baseline. The compensation path feeds the inverted drive through a trimmer into the same input to cancel it.

| Results (the fork *assumed*: C0 = 1.5 pF, Q = 5,000, motional R1 = 485 kohm) | |
|---|---|
| peak at the ADC per volt of DAC drive | 0.42 V/V; the largest drive (1.25 V peak) gives **0.52 V peak = about 650 ADC counts of the AD1's +-2047** |
| baseline off resonance, **no compensation** | 0.063 V/V: the peak is only **6.8x** the baseline, and the peak is shifted 7 Hz |
| baseline off resonance, **trimmer = C0 (1.5 pF)** | 0.005 V/V: **84x** below the peak |
| trimmer off by 0.5 pF | about 20x |
| noise (computed, not simulated) | the 1 Mohm's thermal current noise is 0.13 pA per root hertz, 1.4 uV per root hertz at the ADC, 30 uV rms in a 500 Hz band: **0.04 of an ADC step (806 uV): the converter, not the amplifier, sets the noise** |

## Power and protection

* **Rails: +-12 V.** The ADC input is protected by 1 kohm in series and two Schottky diodes (BAT54S) to 3.3 V and ground, because the op-amp could drive far past the AD1's limit if a fault occurred.
* **The hardware limit still lives in the FPGA** (ZMIN/ZMAX); the rails (+-12 V) bound what the op-amps can deliver at all (+-10.5 V swing), and the piezo's own rating must be read before connecting (not yet looked up).
* A fuse in each supply line and a reverse-polarity diode; ferrite and 10 uF plus 100 nF bypassing on every op-amp; a DC-DC module's switching noise must be filtered (not simulated).
* **Supply current is not budgeted.** Eight op-amps at the OPA2134's quiescent current (read the datasheet; if it is near 4 mA each) would be about 32 mA per rail, which is too close to a 1 W, +-42 mA module: take a 2 W module or a separate supply.

## Parts (Europe; seen 2026-11-02; check the pages before buying)

| Part | Qty | Code | Seen |
|---|---|---|---|
| Dual FET op-amp, OPA2134PA, DIP-8 (the simulation's reference: 8 MHz, 20 V/us) | 4 (8 amplifiers: X, Y, Z, reference buffer, inverter, TIA, gain stage, Vmid buffer) | [Reichelt `OPA 2134 PA`](https://reichelt.com/de/en/2-channel-audio-operational-amplifier-20-v-s-8-mhz-dip-8-opa-2134-pa-p73934.html) ; [DigiKey FR](https://www.digikey.fr/fr/products/detail/texas-instruments/OPA2134PA/254686) | 6.33 incl. 19% German VAT; 7.94 ex VAT at DigiKey FR. **Farnell shows it no longer made** |
| 2.5 V shunt reference, LM4040AIZ-2.5, 0.1%, TO-92 | 1 | [Reichelt `LM 4040 AIZ2,5`](https://reichelt.com/de/en/shunt-voltage-reference-fixed-2-5-v-0-1-to-92-lm-4040-aiz2-5-p109411.html) | about 1.93 |
| DC/DC converter, 5 V in, +-12 V out, 1 W (see the supply note: probably a 2 W part instead) | 1 | [Reichelt, TRACO TMA 0512D](https://www.reichelt.com/de/en/shop/product/dc_dc_converter_tma_series_5_-12_v_dc-120447?r=1) ; [RECOM RB-0512D](https://www.reichelt.com/de/en/shop/product/dc_dc_converter_rb_5_vin_dual_-_12_vout_-_42_ma_sip-7-159017) | about 6 to 7; unregulated, +-40 mA |
| Trimmer capacitor 1.5 to 5 pF | 1 | [Reichelt, Vishay BFC280823508](https://www.reichelt.com/de/en/shop/product/trimmer_capacitor_1_5_-_5_pf_grey-21760) ; Farnell 4143684 | price not seen; Reichelt's page lists the range as "1.2 to 6 pF": read the datasheet |
| Resistors 1%: 10k x 8, 69.8k x 2, 30.1k, 100k x 8, 1M, 49.9k, 1k x 4, 47 x 3; film or C0G capacitors 100 nF x 4, 330 pF x 2, 680 pF, 1 pF, 10 pF; 100 nF and 10 uF bypass; BAT54S; fuses; a 1 kohm trimmer | | any distributor | *guess* EUR 10 to 15 |

**Cost of the amplifier, revised:** about EUR 55 to 80 including enclosure and connectors (the circuit board is counted with the other boards), against the earlier unpriced guess of 30 to 100.

## What the bench must settle

1. Measure the **piezo disk's capacitance** (and read its voltage rating); if it exceeds about 100 nF, raise Cf and re-simulate.
2. Read the **OPA2134 datasheet** for output resistance, quiescent current and noise, and replace `opamp.lib` with the vendor's SPICE model; rerun the sweeps.
3. Read the **DA3's output resistance** (assumed 6.25 kohm; it only has to be small against the op-amp's input impedance, which it is).
4. Measure the **fork's C0, Q and motional resistance** (tutorial Part 6) and set the trimmer for the flattest baseline; the simulation only says where to look.
5. Check the whole chain with a **dummy 30 nF capacitor** and no piezo: mid-code reads 0 V (trim Vref), full-scale 9.97 V, and a step has no overshoot.

**Not done:** a schematic in a schematic-capture tool and a circuit board layout; noise and slew rate in simulation; the supply's switching noise; thermal drift of the gain resistors.
