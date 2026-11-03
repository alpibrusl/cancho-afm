# Converter candidates (ADC and DAC)

> Written 2026-11-01 to meet the needs derived in [`converters.md`](converters.md). **Prices are from search results of that day, in USD
> unless marked, before shipping, tax and import duty, and are not checked against live shop pages.** Anything marked **[manual]** was
> read from the vendor's own reference manual (the Digilent PDFs, mirrored at store.comet.bg because digilent.com refuses automated
> fetches); **[search]** is from search-result summaries only; **[unverified]** is from memory or inference and must be checked.

## What we need (from converters.md)

* **ADC, first build (tuning fork):** at least 262 kS/s, 12 to 16 bits, one signal channel. **Second stage (cantilever, 300 kHz to 1 MHz):**
  2.4 to 8 MS/s or more, 12 bits.
* **DAC:** 16 bits or better, four outputs: Z, X, Y and the drive (a 32.768 kHz sine, so about 262 kS/s of updates).
* The FPGA board (Tang Nano 20K) has no Pmod sockets: a 6-pin SPI Pmod is wired to the board's header pins with jumper wires.

## ADC

| | **Pmod AD1** (Digilent 410-064) | **AD9226 module** (unbranded, 12-bit parallel) |
|---|---|---|
| Fits | the first build, the fork | the second stage, a cantilever signal at MS/s |
| Chip | Analog Devices AD7476A **[manual]** | Analog Devices AD9226, 65 MS/s, 12 bits **[search]** |
| Channels, rate | two channels converted at once, up to 1 MS/s each **[manual]**; 12 bits | one channel, 12-bit parallel bus **[search]** |
| Interface | 6-pin Pmod: CS, D0, D1, SCK; a read is 16 clocks, 4 leading zeros then 12 bits MSB first **[manual]** | 12 data lines plus a clock; about 14 FPGA pins **[unverified]** |
| Supply | 2.35 to 5.25 V; 3.3 V works **[manual]** | 5 V **[search]** |
| Filter | two 2-pole Sallen-Key anti-alias filters, **cutoff not stated in the manual [manual]** | none known |
| Documentation | manual and schematic published by Digilent **[manual, search]**; **not an open-hardware licence** | the chip's datasheet; **no module schematic found [search]** |
| Price | 29.99 to 32.00 **[search]** (one listing at 72, an outlier) | 35.95 to 64.00 **[search]**, stock varies |
| Fit to need | 262 kS/s: yes. 12 bits: yes. 1 MS/s ceiling: **too slow for the 300 kHz cantilever (needs 2.4 MS/s)** | far faster than needed; overkill but cheap, and the 12-bit parallel bus suits an FPGA |
| Caveats | the filter's corner must be read from the schematic before relying on a 32.768 kHz signal passing it **[to check]**; the output is offset-binary (0 to 4095), so subtract 2048 for the detector's signed input | the module's input stage and clock quality vary by seller; the input range and impedance must be read from the datasheet before wiring a sensor to it |

**Pick:** the Pmod AD1 for the first build. A 16-bit ADC is not needed (converters.md); the 16-bit 1 MS/s AD7980 has an evaluation
board but no price or schematic was found **[search]**, and 12 bits is enough.

## DAC

| | **Pmod DA3** (Digilent 410-241), one per output | **Quad-DAC chip on our own board** (AD5686 or DAC8564) |
|---|---|---|
| Fits | the first build: 4 modules for Z, X, Y, drive | later, one open board with all four outputs |
| Chip | Analog Devices AD5541A, 16 bits, **2.5 V reference** **[manual]** | AD5686: quad 16-bit, SPI up to 50 MHz, 3 mm x 3 mm 16-lead LFCSP **[search]**; DAC8564 (Texas Instruments): quad 16-bit **[unverified]** |
| Output | an SMA connector **[manual]**; unbuffered (a listing says so) **[search]**, so it needs a buffer and a level stage before a piezo amplifier; the exact range (presumably 0 to 2.5 V) and output impedance are **not stated [manual]** | 2.5 V or 5 V full scale, selectable **[search]** |
| Interface | 6-pin Pmod: ~CS, DIN, ~LDAC, SCLK; 16 bits in SPI mode 0; the LDAC pin updates the output **[manual]** | SPI **[search]** |
| Supply | 2.7 to 5.5 V; 3.3 V recommended **[manual]** | 2.7 to 5.5 V **[search]** |
| Documentation | manual and schematic published by Digilent **[manual, search]**; not an open-hardware licence | datasheets; an Analog Devices evaluation board for the AD5686 exists (EVAL-AD5686RSDZ, needs an Analog Devices controller board) **[search]**; no open breakout found |
| Price | 29.99 to 35.99 each **[search]**: **about 120 to 145 for four** | a few USD per chip **[unverified]** plus a PCB we design and order |
| Fit to need | 16 bits: yes. Four outputs: four modules and four chip-select pins. **Update rate and settling are not in the manual** | one SPI bus, four outputs, much cheaper per channel |
| Caveats | whether it can update at 262 kS/s for the 32.768 kHz drive is **unverified** (the datasheet of the AD5541A must be read: settling time and clock limit); a single unipolar output means our amplifier supplies the bipolar swing | needs us to design, order and solder a small-package board; the board is hardware we would publish under CERN-OHL-S-2.0 |

**Pick for the first bench: four Pmod DA3**, unless the AD5541A datasheet shows it cannot update at 262 kS/s, in which case the drive is
made differently (see below). **Pick for the open build: our own board with a quad DAC**, once the first bench has shown what the signals
need.

## Considered and rejected

* **Waveshare High-Precision AD/DA board** (about 26 GBP to 48 EUR **[search]**): a Raspberry Pi HAT, so it is wired to the Pi's GPIO, not
  the FPGA, and the loop must live in the FPGA. Its ADC (ADS1256, 24 bits) is about 30 kS/s **[unverified]**, far too slow. The listings
  disagree on its DAC part (DAC8532 or DAC8552 **[search]**).
* **Pmod AD5** (4 channels, 24 bits, 4.8 kHz **[search]**): far too slow. **Pmod DA4** (8 channels, 12 bits **[search]**): not enough bits for Z.

## If the DA3 cannot make the drive

The fork's drive is a single frequency: a sine, or even a square wave filtered by the fork itself (a quartz fork is a very narrow
filter). A one-bit output from the FPGA through a small low-pass filter would drive it, and the lock-in then uses the same phase
accumulator as the reference. This is an idea, not tested; it would remove one DAC.

## Where to buy in Europe (checked 2026-11-01)

DigiKey France lists both Pmods Active and in stock (AD1 EUR 28.41, DA3 EUR 32.36 ex VAT, 4-week manufacturer lead time); TME shows both withdrawn; Farnell Ireland shows the AD1 as no longer stocked. Prices and links: `cost.md`.

## Before buying

1. Read the Pmod AD1 schematic for the anti-alias corner (and the AD7476A datasheet for its SCLK limit and the 1 MS/s timing).
2. Read the AD5541A datasheet for settling time, serial clock limit, output range and output impedance.
3. Check the Tang Nano 20K's header for 3 SPI buses worth of free pins (about 10 for the ADC and 4 chip selects, a shared clock and data for the DACs); its pin numbers are from memory in cancho-hdl and unchecked.
4. Price each against the live shop page.

## What the FPGA provides (written 2026-11-01)

`sim/spi.cho` and `gen/sv.cho`: an SPI master for each module, tested against a cancho model clock by clock and against models of the chips
written from the Digilent manuals (details in `gen/README.md`). At 27 MHz an SCK of 6.75 MHz gives a conversion or a write in about 70
clocks. **Still to write:** the glue from the AD1's `done` to the lock-in's `valid` and `x_in` (subtract 2048 from the 12-bit
offset-binary value), and from the loop's new Z to a DA3 write. **Still to check in the datasheets:** SCLK limits, the data-valid delay,
and the AD5541A's settling time and update rate.
