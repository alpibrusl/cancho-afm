# First measured image in water: the runbook (S9.11 of `docs/liquid.md`)

> Written 2026-11-09. **A plan. Nothing here has been run on hardware, and the instrument it needs does not exist yet.** The acceptance of S9.11 (#43): "an image taken by the instrument, with the measured Q, f0 and force reported against the twin's prediction; where they differ, the twin's document is corrected." This page fixes what is compared, in what order the run goes and when it must stop, so that the numbers are written down before they are seen. Tags: **[repo]**, **[twin]** (a prediction of this software, not a measurement), **[proposal]**.

## Do not start until all of these are true

| # | Condition | State today |
|---|---|---|
| 1 | A named reader has signed `docs/liquid-safety.md` (laser class, electrical arrangement, biosafety line) | **no** (review table empty) |
| 2 | The leak test (`docs/liquid-leak-checklist.md`) has been run and passed, all four runs | **no** (not run) |
| 3 | The head is built: laser, window, quadrant photodiode, lever holder, droplet cell | **no** (a plan, `docs/liquid-optics.md`, `docs/liquid-cell.md`) |
| 4 | The bench steps of `docs/bench.md` for the electronics (ADC noise, DAC loop-back, Z limit, deadman) have a number written down | **no** (the programs have never touched a board) |
| 5 | The coarse motor's retract rule is decided (the deadman retracts Z, not the motor) | **no** (open in `docs/liquid-safety.md`) |

If any row is "no", the run does not start. The mica sample comes first, the 20 nm grating after the Z range allows it (S9.1).

## The run, in order

1. Dry run in air with the same head: alignment (`host/align.cho`), tune, approach, a scan. Nothing wet. Write down the sum signal and the deflection offset.
2. Droplet on, no scan: watch the sum signal for 10 minutes. A fall of more than 5% means the light refusal (code 82) would trigger; find the cause before going on.
3. Tune in water: record f0 and Q from the sweep.
4. Approach, then a scan of 64 x 64 on freshly cleaved mica at the twin's default pixel rate. Record the contact Z, the setpoint and the faults.
5. Report the force with the lever's stiffness from its data sheet **[to confirm: the real value is not known until measured]**.
6. Stop at any refusal code (22, 25, 43, 81, 82, 83), any leak sensor trip, or any wet scanner side. Write the code and what was seen; do not retry the same way.

## What is compared

The twin column is the run behind the video of 2026-11-09 (`scan_twin`, profile 2, lever Q set to 3.0, stiffness 0.15 N/m, a 500 kHz cantilever). It is a prediction of the software on a made-up sample; **the Q the twin printed (4) is rounded from the input 3.0, so the twin's Q is something it was told, not something it found.**

| Quantity | Twin **[twin]** | Measured | Differs by | Twin document corrected? |
|---|---|---|---|---|
| f0 | 509,927 Hz | **not run** | | |
| Q | about 3 to 4 | **not run** | | |
| Contact Z (approach) | 2,704 pm | **not run** | | |
| Largest tapping force | 32 pN | **not run** | | |
| Height noise (Rq on mica) | not predicted for mica | **not run** | | |
| Faults | 0 | **not run** | | |

**A difference counts when it is more than 20% on f0, Q or force, or any fault code appears that the twin did not give [proposal].** For every such difference the document that made the claim is corrected in place (`docs/liquid.md`, or `docs/high-speed.md` for the twin's plant), with the measurement beside the old claim, as the project rules ask.

## What would make the result worthless

* A force from a stiffness that was not measured: report it as an estimate and say so.
* An image with the loop's Z pinned at an end of its range (nothing judges it today, `docs/liquid.md`).
* A comparison on a different pixel rate or lever than the twin run.

## Open

* The twin's sample is made up; the measured one is mica. The comparison of heights is meaningless except the step of the terrace and the noise; the loop quantities (f0, Q, contact, force) are the ones that carry over.
* Who runs it and where is not decided; S9.12 waits for a wet-lab collaborator.
