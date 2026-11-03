# High-speed AFM (HS-AFM): design note

> Written 2026-11-03, **before anything is built**. Numbers are **computed from stated assumptions [A]**, taken from a search **[search]**, or not known **[unknown]**.
> Nothing here has run on a cantilever, a photodiode or a fast scanner. The twin results this note asks for are predictions, not measurements.
> This note grows `docs/design.md` section 6 and slice S7. It is the second stage: the tuning fork route (`docs/first-hardware.md`) comes first.

## What changes, and what does not

The software stays: tune, choose, approach, scan, the register table, the lock-in and PID generated from cancho, the twin. What changes is **hardware and a number of
constants**. In the order of difficulty:

| Part | Fork stage (now) | HS stage | Status |
|---|---|---|---|
| Sensor | quartz fork, current through a 1 MOhm TIA | small cantilever, **laser and quadrant photodiode** (optical beam deflection), bandwidth of several MHz | **[unknown]** which cheap photodiode and TIA; the hardest item |
| Resonance | 32.768 kHz, Q about 500 | **0.5 to 1.5 MHz**; Q 2 to 10 in liquid, 100 or more in air **[search]** (Ando: small cantilevers, 450 to 650 kHz in 2001; 1.2 MHz in later work; a commercial one is listed at 1.5 MHz in air, 0.5 MHz in liquid, 0.1 N/m) | cantilevers may be bought; **[unverified]** price and stock |
| ADC | 262 kS/s, 12 bits (Pmod AD1, AD7476A, 1 MS/s) | **4 to 10 MS/s**, 12 bits: at 8 samples per period (what our lock-in needs for a phase-free figure, `docs/converters.md`) 0.5 MHz is 4 MS/s, 1.2 MHz is 9.6 MS/s | AD7476A is too slow (already rejected); AD9226 (12 bits, parallel) is a candidate `docs/converter-candidates.md` **[search]** |
| Drive | DDS word, DAC about 262 kS/s | the same DDS, a DAC at 8 or more times f0 (4 to 10 MS/s) | **[unknown]** part |
| Detector window | 64 samples, 0.24 ms | **16 to 35 samples (2 to 4 whole cycles)**, microseconds | generated lock-in has the window as a register; lockstep run at 18, 23 and 35 (H3) |
| FPGA clock | 27 MHz, timing met at 65.9 MHz estimated | a PLL to 100 MHz or more is wanted for 10 MS/s; Tang Nano 20K has a PLL **[unverified]** | to check |
| Z scanner | the fork's piezo tube or stack, a 1 MOhm-class amplifier (`docs/amplifier.md`) | **small stack, first resonance above 100 kHz** and an amplifier with the bandwidth and slew rate for it; no ringing at the loop rate | **[unknown]**; the amplifier of `docs/amplifier.md` is far too slow for it |
| Z and XY DAC | 16 bits, SPI | settling well under the loop period; SPI at 50 MHz sets the update rate | datasheet values **[unknown]** |
| Sample | any hard sample, air | **a hard sample in air first** (calibration grating); liquid and biological samples are out of scope until air works | scope |

## The bandwidth budget (computed [A], not measured)

A loop update comes from one detector window of `W` samples at the sampling rate `fs` (8 samples per period). The pixel takes `K` updates (the twin's session uses
**K = 20**, "the loop needs about 20 to follow a feature", `host/session.cho`). The cantilever's own response time is `tau = Q / (pi f0)` (Ando) and an amplitude
change settles in about 3 tau. So the pixel time is at least `max(K W / fs, 3 tau)` and the frame rate for `N x N` pixels (trace only) is `1 / (N^2 pixel)`:

| Cantilever | fs | window | tau | pixel (K = 20) | 3 tau | 64 x 64 frame rate |
|---|---|---|---|---|---|---|
| 0.5 MHz, Q = 2 (liquid) | 4 MS/s | 64 samples, 16 us | 1.3 us | 320 us | 3.8 us | 0.8 /s |
| the same | 4 MS/s | 16 samples, 4 us | 1.3 us | 80 us | 3.8 us | 3.1 /s |
| the same | 4 MS/s | 8 samples, 2 us | 1.3 us | 40 us | 3.8 us | 6.1 /s |
| 1.2 MHz, Q = 100 (air) | 9.6 MS/s | 8 samples, 0.8 us | 26.5 us | 17 us | **80 us** | **3.1 /s** (the cantilever limits, not the detector) |

What this says, plainly:

* **The window is the first lever.** Cutting it from 64 to 8 samples gives 8 times the rate, and costs noise (a lock-in over fewer samples is noisier; see the
  noise paragraph below). It also makes the "8 samples per period" rule bite: a window under 8 samples is under one cycle, and the figure is no longer phase-free.
* **In air the cantilever's Q is the limit**, not the electronics: Q = 100 at 1.2 MHz has tau = 26 us. Fast imaging in air needs Q control (active damping) or low-Q
  cantilevers. Q control is not designed here **[unknown]**.
* **10 frames per second** (Ando reports 10 to 25 fps for his instrument **[search]**) at 64 x 64 would need a pixel of 24 us: K = 20 updates of 1.2 us, so a window of
  about 5 samples at 4 MS/s. That is below one cycle and **does not look reachable with a lock-in**. Ando uses an RMS-to-DC converter or peak hold and a
  fast scanner, and attributes the limits to cantilever frequency, the RMS-DC rate and the Z scanner bandwidth **[search]**. Our honest target is **1 to 5 frames per second at 64 x 64**, not 10.
* **The one open published controller** reports 55 lines/s, a 512 x 512 image in 9.3 s, for under USD 4,000, on NI hardware (`docs/references.md`). Our cost goal
  is far below that, and our line rate on this budget is also lower **[A]**; neither is measured here.

Noise, which the table ignores: the lock-in's figure noise falls with window length, roughly as 1/sqrt(samples). A window 8 times shorter is about 2.8 times noisier **in theory**; in the twin (H3) the 18-sample window with a snapped drive gave the fork's 28 pm, because its ADC noise is small, so this is not yet seen.
Whether that leaves a usable setpoint depends on the photodiode's noise, **[unknown]**.

## What the twin can and cannot say

The twin (`sim/board.cho`, `sim/plant.cho`) models the cantilever as a Lorentzian with a first-order lag, applied **per ADC sample** with `alpha = pi f0 / (Q fs)`
(clamped at 1). An earlier version of this note said the lag was per window and clamped; that was wrong (read from a comment, not the code) and is corrected here:
at 4.5 MS/s a 0.5 MHz, Q = 5 cantilever has alpha = 0.07, so the lag is modelled, not clamped away. The first-order lag is still the simplest shape: no overshoot.

* **Can, with changes of constants only (H1):** f0 0.5 to 1.2 MHz, Q, free amplitude, the sample rate (`rf[3]`, the divider of the 27 MHz clock: 6 gives 4.5 MS/s), the
  window, pixel divider, a bigger raster; and report the **frame rate the twin predicts**. The tune stage sweeps 32.52 to 33.02 kHz in 8 Hz steps
  (`host/session.cho`): it must sweep a megahertz-scale range, with a wider step. That is a parameter, not new logic.
* **Can, with a small model (H2):** a Z scanner as a second-order system (resonance, damping), and an amplifier slew limit, in `sim/plant.cho`: it shows ringing and the
  line-rate limit **when the loop is faster than the scanner**. The parameters would be guesses until a scanner is measured.
* **Cannot:** photodiode and laser noise, optical alignment, tip-sample dynamics at speed (tapping with very small amplitudes), liquid damping, the real scanner.
  The twin must say so on every HS result, as it does now.

## Slices, acceptance written first

| Slice | What | Acceptance |
|---|---|---|
| H1 | An `hs` profile in the twin: constants only, a larger raster, the frame rate printed | the full procedure (tune, approach, scan) finds a 0.5 MHz, Q = 5 cantilever and scans 64 x 64; the predicted frame rate is within 10% of the table's formula; existing tests unchanged. **Done 2026-11-03, see "What H1 found"** |
| H2 | Second-order Z scanner and amplifier slew in the twin | with the loop faster than the scanner's resonance the twin shows ringing; with a slower one it does not; a test for both. **Done 2026-11-03, see "What H2 found"** |
| H3 | The generated lock-in at 16 to 35 samples per window and 4.5 MS/s, in Verilog | lockstep with the cancho model at several windows at 6 clocks per sample; timing at the clock that gives 8 or more samples per period. **Done for the detector 2026-11-03, see "What H3 found"; the parallel ADC and the fast DAC are not designed** |
| H4 | A video of a fast scan, labelled as a prediction | the video states the frame rate, the window and what is not modelled. **Done 2026-11-03: `docs/hs-vs-fork.mp4`** (the fork and the HS profile scan the same invented sample in simulated real time over 12 s: the fork completes 10% of a frame, the HS profile 18 frames; `docs/make_hs_video.py`) |
| H5 | Parts: a cantilever, a laser and photodiode, a fast ADC and DAC, a small stack and its amplifier | an order list as in `docs/amp-order.md`, with prices **checked** and sources, and what is still **[unknown]** marked. **Done 2026-11-03: `docs/hs-order.md`** (prices read for four lines, snippet-only for the rest, unchecked for the optics and the amplifier) |
| H6 | A measured line rate on a real small cantilever | the S7 acceptance: measured, not predicted; before this, no claim of speed |

H1 and H2 are cancho and need no hardware. H3 is generated hardware and runs under Icarus. H5 and H6 need money and a bench.

## What H1 found (twin, 2026-11-03; predictions, not measurements)

`host/session.cho` takes a profile (`ss[3]`: 0 fork, 1 hs); `host/scan_twin.cho` scans 64 x 64 over the made-up sample for either (`./scan_twin 1`). Hs profile: 4.5 MS/s
(divider 6 of the 27 MHz clock), an 18-sample window, 20 loop updates per pixel, a sweep of 100 to 899 kHz. The full procedure ran with no operator input and no refused write.

* **Tune found the cantilever:** f0 = 508.3 kHz against the twin's 500 kHz (1.7% high: the sweep step is 12.7 kHz), Q = 6 against 5. Contact at Z = 2704 pm, as for the fork. A first sweep of 376 to 628 kHz was refused (no resonance well above the floor: the edges were only 2.7 times lower than the peak); the sweep must span several line widths.
* **The window must be a whole number of cycles.** With 16 samples (1.8 cycles at 4.5 MS/s) the amplitude figure rippled by 12% from window to window and the approach saw a false contact at the top of the Z range: the scan was all zeros. 18 samples (2.05 cycles) worked. Of the windows tried (9, 14, 15, 16, 18 at dividers 6 and 7) only 18 at divider 6 completed. **H3 below explains this and fixes it.**
* **Frame rate predicted:** 0.65 s per 64 x 64 frame with trace and retrace, 1.5 frames/s; 3.1 frames/s if only the trace were scanned (the formula's 3.05 to 3.4 /s for a 4 to 4.5 MS/s, 16 to 18 sample window). The twin counts the clocks it simulates, so this agrees with the formula by construction; it is not a check of the formula.
* **The loop did not limit the image: something in the detector did.** Over the same sample the hs image had a trace-minus-retrace rms of 87 pm against 28 pm for the fork's, and the same numbers at 20, 40 and 60 updates per pixel. This note first read that as the cost of a shorter window (about 4% of the figure). **That was wrong, corrected by H3:** it was the beating of a drive that did not span a whole number of cycles per window; with the drive snapped (below) the same 18-sample window gives 28 to 31 pm, the fork's own figure.
* **Not found, because not modelled:** photodiode noise, the real scanner (H2), liquid damping.

## What H2 found (twin, 2026-11-03; predictions, not measurements)

`sim/board.cho` has a Z scanner between the DAC and the tip: a second-order system (resonance, Q) behind an amplifier slew limit, sub-stepped so it stays stable; resonance 0 is the old ideal scanner (every earlier result is unchanged). Three tests (`tests/board_test.cho`): a step of Z
rings when the resonance is high-Q (peak over 1.5 times the step), does not when critically damped, and the slew limit bounds the speed. `./scan_twin <profile> <scanner>` scans through it; the figure is `docs/h2-scanner.png`. All of it a guess until a real scanner is measured.

HS profile, 64 x 64, the loop's gains as the session chooses them (it knows nothing of the scanner), one loop update every 4 us (250 kHz):

| Z scanner | trace-minus-retrace rms | image against the ideal scanner's |
|---|---|---|
| ideal | 87 pm | |
| 100 kHz, Q 3 | 88 pm | 0.998 |
| 70 kHz, Q 3 | 89 pm | 0.996 |
| 50 kHz, Q 3 | 94 pm | 0.979 |
| 30 kHz, Q 3 | 544 pm | 0.38: the loop rings, no image |
| 20 kHz, Q 10 | 896 pm | 0.09: the loop runs away |
| 100 kHz with a 20 pm/us amplifier | 5766 pm | 0.11: fine on the flat part, then a limit cycle from the terrace step on |

* **The scanner's resonance must be about a fifth of the loop update rate or more** for these gains: 50 kHz works, 30 kHz does not. The fork profile (a 4 kHz loop) is unaffected even by a 20 kHz, Q = 10 scanner. That is the acceptance: ringing when the loop is faster than the scanner, none when slower.
* **A slew limit breaks the loop at a step**: with 20 pm/us the amplifier cannot follow the 150 pm terrace within a loop update, and the loop oscillates. An amplifier for HS has to be specified in pm per us for the largest step, not only in bandwidth.
* **The session's gain choice (`tune.choose`) ignores the scanner.** Taking its resonance into account, or a slower loop, would widen what works, at the cost of rate. Not done; the table is for the gains as they are.
* **Not shown:** a measured scanner, hysteresis and creep, the amplifier of `docs/amplifier.md` (far too slow: its bandwidth is for the fork).

## What H3 found (generated Verilog and the twin, 2026-11-03)

**The detector.** The generated lock-in (`gen/lockin_ir.cho`, unchanged: the window is a register) was fed one sample every 6 clocks (4.5 MS/s from 27 MHz) over three windows (18, 23, 35 samples, drives at 2, 2 and 4 whole cycles): 36 windows,
**0 mismatches** against `sim/lockin.cho` under Icarus (`gen/lockin_hs_tb.v`, in `gen/check.sh`). The amplitude arrives **13 clocks (0.48 us)** after the window closes. It accepts a sample every clock, and its place and route
gave Fmax 83.3 MHz (`gen/README.md`), so **no PLL is needed for the detector**: 27 MHz allows up to 27 MS/s and the divider (3 for 9 MS/s, 6 for 4.5) is a register. What is not designed: the ADC itself (the Pmod AD1's SPI is 1 MS/s at most; a 12-bit parallel part such as the AD9226 needs a new generated interface block), the fast drive DAC, and the pins.

**Why windows failed in H1, and the fix.** A square-wave lock-in is steady only if each window sees the same sample phases, i.e. m whole cycles in n samples. Spanning "about" a whole number of cycles is not enough: windows of 2.02 cycles still beat by 6% at 400 kHz.
So `lockin.snap` (`sim/lockin.cho`) snaps the drive to `fs m / n` within 1/(8 Q) of the tuned frequency (under 2% of the amplitude lost) and takes the shortest such window; the session uses it for the HS profile after the sweep (window and tuning word, `ss[15]`, `ss[18]`). Tests: the snap picks
n = 18, m = 2 at 508 kHz, Q 6 (500 kHz, 9 samples per period exactly, word 477218588) and n = 23, m = 2 at 395 kHz; a steady sine's figure is identical every window at the snapped drive (spread of at most 1 count) and ripples by more than 1,000 counts at 1.8 cycles in 16 samples.

**In the twin**, a cantilever anywhere from 300 to 600 kHz (Q about 5) now tunes, approaches and scans 64 x 64 with no operator input, where only 500 and 600 kHz worked before:

| f0 | window | frame (trace+retrace) | trace-minus-retrace rms |
|---|---|---|---|
| 300 kHz | 29 | 1.04 s | 28 pm |
| 400 kHz | 23 | 0.82 s | 29 pm |
| 450 kHz | 20 | 0.72 s | 29 pm |
| 500 kHz | 18 | 0.65 s | 30 pm |
| 550 kHz | 16 | 0.57 s | 30 pm |
| 600 kHz | 16 | 0.57 s | 31 pm |

* **Limits**: at 4.5 MS/s a cantilever above fs / 8 = 560 kHz has fewer than 8 samples per period (the profile above 600 kHz was not made to work; it needs the divider 3 or 4, 9 or 6.75 MS/s, chosen from the tuned frequency: not done). The snap assumes the drive can be set to the snapped frequency without losing the cantilever, true for a Q of about 5 and to be checked for the 100 or more of air.
* **Twin, not measured:** the noise numbers are the twin's own (ADC noise of 2 counts, no photodiode), and its sampling is ideal.

Image processing of the result (levelling, roughness, step height, pitch, particles) is designed in `docs/image-processing.md`.

## Risks

1. **Optical detection** is a new subsystem (laser, alignment, quadrant photodiode, a fast TIA); none is designed. It is the schedule risk.
2. **The cantilever's Q in air** (above) limits the rate whatever we do.
3. **The Z scanner** decides the line rate; the cheap small stacks with resonances above 100 kHz are **[unverified]**.
4. **The lock-in's window** must hold a whole number of drive cycles (H3: solved by snapping the drive; the noise of a short window then equals the fork's in the twin, not yet seen with a real photodiode).
5. **The tune stage is written for a fork**: it sweeps a small range, with a long settle (20 ms), neither valid at 1 MHz.

## Sources

* Ando et al., *A high-speed atomic force microscope for studying biological macromolecules*, PNAS 98, 12468 (2001) (450 to 650 kHz cantilevers, scanner resonance-free to 60 kHz) **[search]**.
* Ando, overview of HS-AFM (2011) (10 to 25 fps; tau = Q / (pi f0); the three rate limits) **[search]**; `docs/references.md` for the open controller (HardwareX, Mendeley).
* Olympus ultra-small cantilever listing (1.5 MHz in air, 0.5 MHz in liquid, 0.1 N/m) **[search]**: a listing, not a datasheet read.
