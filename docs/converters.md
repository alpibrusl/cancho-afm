# Converters: what the loop needs from the ADC and DAC

> Written 2026-11-01. **Computed from stated assumptions, not measured on any instrument.** The assumptions are marked **[A]**.
> This is the answer S1 (issue #2) was asked for: the converter speed and resolution the detector and the loop need.

## What the detector measures (sim/lockin.cho, gen/lockin_ir.cho; both tested)

A quadrature lock-in with a square-wave reference: the ADC samples are added or subtracted by the signs of cos and sin of a 16-bit
phase, over a window of `window` samples; the amplitude figure is `R = floor(sqrt(I^2 + Q^2))`. Measured on synthetic signals
(`tests/lockin_test.cho`, deterministic):

* at 8 samples per period the figure does not depend on the signal's phase (identical at 8 phases) and is 2.6% above the ideal
  `2/pi * A * window`; at 16 per period 0.6% above;
* it is proportional to the amplitude (within 1% from 1000 down to 100) and to the window (within 3%);
* uniform noise of +-300 on a 1000-count signal moves it under 2%; a 10-count signal under +-3 noise within 4%;
* **known weaknesses, pinned by tests:** a third harmonic of 20% of the signal leaks in at one third of its size and raises the
  figure about 7%; a reference 0.5% off the signal over a 32-period window costs about 7%. The second is removed by design when the
  drive and the detector share one oscillator (the drive is the detector's reference, so there is no mismatch); the first needs a
  band-pass in front of the ADC, or sine references (multipliers), if the signal's harmonics are strong.

## Sampling rate

The reference needs at least 4 samples per period (a quarter-period phase), 8 is what was tested: **fs >= 8 x f0**.

| Sensor | f0 **[A]** | ADC rate needed | Window of 256 samples lasts |
|---|---|---|---|
| quartz tuning fork | 32.768 kHz | 262 kS/s | 0.98 ms |
| tapping cantilever, the 2025 paper's | about 300 kHz | 2.4 MS/s | 0.11 ms |
| small fast cantilever **[A]** | about 1 MHz | 8 MS/s | 32 us |

The FPGA side is not the limit: the detector takes one sample per clock, so at 27 MHz it keeps up with any of these (the generated
module closes timing at 83 MHz in nextpnr, `gen/README.md`).

## Resolution

* **ADC: 12 bits is enough, 14 to 16 give margin.** A 12-bit full scale is 4096 counts; summing a window of 256 samples averages
  noise down by about sqrt(256/2) = 11, which is about 3.5 more bits. Setpoints of a few percent of the free amplitude are far above
  one count. The sensor's analog front end (gain and filter) matters more than the last bits of the ADC.
* **Detector range, a hard contract:** the sums must stay within +-8,388,607 (24 bits) or `overflow` is raised and the figure is not
  valid: `window x full-scale count <= 8,388,607`. A 12-bit ADC (2047 counts) allows a window up to 4096; a 16-bit ADC (32767 counts), 256.
* **DAC for Z: 16 bits.** The 2025 paper's 12-bit DAC over about 1 um of Z gave 0.24 nm steps and their 0.34 nm atomic step read
  0.48 nm. 16 bits over the same range is 0.015 nm. **[A]** 1 um of Z range.
* **DAC for X and Y: 16 bits.** Over 30 um that is 0.46 nm per step, well under a 256-pixel image's pixel size (117 nm).

## Speed of the loop: what actually limits it

* The cantilever's own response: roughly `tau = Q / (pi f0)`. For a tuning fork **[A: Q of 5,000 to 10,000 in air]** that is 0.05 to
  0.1 s, so the amplitude cannot follow faster than a few hertz: a fork AFM in amplitude mode is for slow scans, and its limit is the
  fork, not the electronics. For a small cantilever **[A: Q = 100, f0 = 1 MHz]** it is about 32 us.
* The detector window (table above) and the loop (4 clocks per sample at 27 MHz is 6.75 MS/s) are both much faster than the fork.
* The Z scanner: a piezo disk or stack responds in the kilohertz range **[A]**; this, not the electronics, caps a fast scan with
  feedback.

So: the electronics proposed here are not what limits an AFM at a few lines per second; for the fork route the physics is. See the
high-speed section of the landing page.

## What to buy (the shopping list rows 2 to 3, derived)

A DAC of 16 bits or better, 3 channels (X, Y, Z) plus one for the drive, settling well under a loop period; an ADC of 12 to 16 bits at
at least 262 kS/s for the fork (2.4 MS/s for a 300 kHz cantilever). Specific parts are not chosen.
