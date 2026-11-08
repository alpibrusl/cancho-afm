# Phase 2: a version that works in water (epic S9): design note

> Written 2026-11-08, **a plan; nothing here is built, simulated or measured.** Tags: **[repo]** read from this repository; **[general]** general AFM knowledge, not checked
> here and to be confirmed by a search before it becomes a number; **[unknown]** not known. This is a draft of the epic and its issues: nothing is filed on GitHub yet.
> It builds on `docs/high-speed.md` (the cantilever and optical stage, which `docs/high-speed.md` already scopes and which is where the liquid work starts) and on the first image in air (S6).

## Why it is a different instrument

* The tuning fork of the first prototype is a stiff sensor (a spring constant in the thousands of N/m **[general]**); soft samples are imaged with levers of about 0.1 to 1 N/m
  (`docs/hs-order.md` lists a 0.15 N/m lever "mainly designed for high-speed AFM in liquid" **[repo]**). So biology means the **cantilever and optical-lever head** of `docs/high-speed.md`, not the fork.
* In liquid the lever's Q falls to about 2 to 10 (against 100 or more in air) **[repo, from a search]**. The loop was tuned for a sharp resonance.
* Liquid and biological samples are **explicitly out of scope until air works** (`docs/high-speed.md`, "Sample") **[repo]**. This epic is what lifts that, so it starts only after S6 and S8.

## What stays, what changes

| Part | Verdict | Why |
|---|---|---|
| Lock-in, PID, raster, motor, deadman, safety limits (generated from cancho) | **stay** | the lock-in's window and drive frequency are registers; `docs/high-speed.md` H3 ran it at 16 to 35 samples |
| Register table | **grows** | there is no DC deflection or photodiode-sum register today (`ADC0`/`ADC1` are raw conversions) **[repo]**; alignment and contact-mode-like control need them |
| `host/session.cho` tune / approach / choose | **changes** | written for a fork and one clean peak (`docs/high-speed.md`, risk 5) **[repo]**; liquid adds a low Q and, with acoustic drive, a "forest" of peaks **[general]** |
| The twin (`sim/plant.cho`, `sim/board.cho`) | **changes** | the tip is `gap / free` with no force and no sample; no photodiode noise; no liquid damping (`docs/high-speed.md`, "What the twin can and cannot say") **[repo]** |
| Hardware | **new** | optical head, fluid cell, an isolated and sealed scanner, a fast Z amplifier |

## What the twin must learn (and must keep saying it does not know)

1. **Liquid profile.** Q 2 to 10, a lower f0 than in air, a settle time of microseconds; drive by acoustic coupling shows several peaks, not one **[general]**. The twin's single Lorentzian cannot show that, so the tune failure modes (`tune.analyse` reasons 1 to 4) must be tested against a multi-peak response.
2. **Force.** The sample is soft, so the question changes from "did the image follow" to "how hard did the tip hit". The twin needs the lever's stiffness, the amplitude and setpoint, and a **tapping-force estimate per pixel** with a damage threshold as a parameter, plus a compliant sample. The threshold for a given sample is **[unknown]**; the twin reports force against it, it does not claim a safe value.
3. **Optical detection.** Photodiode and laser noise, pointing drift, a DC offset that wanders as the liquid warms (the current ADC noise of 2 counts is not that) **[general]**, and the sum signal that tells whether the lever is lit.
4. **Slow, large drift** in liquid (temperature, evaporation), far above the twin's present drift parameter.

## What the software must learn

1. A `liquid` profile in `host/session.cho` (profile 2 next to fork 0 and hs 1): sweep range, a settle time that is not 20 ms, setpoint fraction and gains chosen for a low Q.
2. **Tune** that finds the lever in a forest and refuses (with a tagged reason) when it cannot decide which peak is the lever. Every refusal has a rule tag.
3. **Approach** that does not trust a small amplitude contrast alone; it also watches the new deflection and sum registers.
4. An **alignment** stage: read the photodiode sum and the quadrant difference, step a mirror or screw, tell the operator when the spot is on the lever.
5. A **force and damage report** per image (from the twin's model, then from the measured setpoint), next to the height image, in `host/report.cho`.
6. Bench programs for the new head, as `host/bench.cho` does for the first board: read `ID` first, restore what they write, print measured against expected.

## The epic and its issues (draft; to file as S9 and S9.1 to S9.12)

**Epic S9: a version that works in water (liquid, then biological samples).** Done when a measured image of a hard test sample is taken in water by the instrument, then one of a soft biological sample, with
the tapping force reported. Depends on S6 (first image in air) and S8 (a small fast cantilever and its optical head, measured). Each issue below states its acceptance first; a claim that turns out false is corrected in the document that made it.

| # | Title | Depends on | Acceptance |
|---|---|---|---|
| S9.1 | Scope and acceptance: define "works in water", choose the two test samples | S6 | a section of this note naming a hard sample (a calibration grating or freshly cleaved mica) and a soft one, the instrument's target force, and what is out of scope; every number tagged |
| S9.2 | Twin: a liquid profile | S9.1 | the twin runs tune, approach and scan with Q 2 to 10 and a multi-peak response; existing tests unchanged; a test where `tune.analyse` refuses with a tagged reason on an ambiguous forest |
| S9.3 | Twin: tip-sample force and a compliant sample | S9.1 | a per-pixel tapping-force figure and a damage flag against a stated threshold; a test that a higher setpoint ratio gives a higher force; the doc says the threshold is a parameter, not a finding |
| S9.4 | Twin: optical-lever noise, DC wander and sum signal | S9.1 | deflection and sum channels with a noise figure and a drift rate as parameters; a scan with drift still finishes or refuses with a tagged reason |
| S9.5 | Register table and gateware: deflection and sum readout | S9.4 | new registers in `docs/registers-table.md`, regenerated, lockstep against the cancho model and under Icarus, the byte-for-byte rule of S1; a second ADC channel or a multiplexer chosen and justified |
| S9.6 | Software: the liquid profile in tune, approach and choose | S9.2, S9.5 | the whole procedure runs against the twin with no operator input in profile 2 and refuses cleanly otherwise; a refusal on every untrusted result |
| S9.7 | Software: alignment stage and the force and damage report | S9.3, S9.5 | the twin run prints alignment steps; the report has the force next to the image; tests for both |
| S9.8 | Hardware: optical head parts list and design | S8 | a list in the style of `docs/hs-order.md` with each price tagged read, snippet or unchecked; the item `docs/hs-order.md` calls the largest unsolved (optics, mount, alignment) has a drawing and a method |
| S9.9 | Hardware: cantilever holder, fluid cell, seal, electrical isolation | S9.8 | a drawing and a leak test with plain water and no electronics powered; the piezo electrodes and the +-12 V amplifier cannot touch the liquid by design; the test and its result written down |
| S9.10 | Safety: liquid, electronics and biology | S9.9 | a written interlock list (leak, limits, deadman already in the gateware), a power-off procedure, and a biosafety note naming what the project will and will not handle; a person other than the author has read it |
| S9.11 | First measured image in water of the hard sample | S9.6, S9.9, S9.10 | an image taken by the instrument, with the measured Q, f0 and force reported against the twin's prediction; where they differ, the twin's document is corrected |
| S9.12 | First biological image | S9.11 | a protocol for sample preparation, an image with its force figure, and an honest statement of what was and was not resolved |

An optional cheap check before S9.8: a fork with a long tip dipped into a drop, over a hard sample, with the fork kept dry **[general]**. It would show whether the loop survives damping, it is not
a route to biology, and it needs a tip and a holder that are not designed **[unknown]**. If wanted it becomes S9.0.

## Risks

1. **The optical head** is the schedule risk already named in `docs/high-speed.md` and it is still the same risk.
2. **Force**: with a soft sample the instrument may damage it before it images it; the twin can only say so under a threshold nobody here has measured.
3. **Wet lab and biosafety** are not electronics and not in the author's stated scope; S9.12 may need a collaborator.
4. **Electrical safety** next to a conductive liquid: the present amplifier is built for a dry piezo.
5. **Overlap with S8**: the optical head and the fast Z scanner belong to S8; S9 must not redo them, only extend them for liquid.

## What S9.2 found (twin, 2026-11-08; predictions, not measurements)

Built: `plant.forest` and `board.set_forest` (fl 28 to 31), tune refusal tag 5 (a second, separate peak at 0.7 of the highest or more), `scan_twin` arguments 11 to 13 (Q in tenths, forest height in percent, spacing in kHz), `tests/liquid_test.cho` (8 tests). The gate passed (all cancho tests, `gen/check.sh`, the register checks).

* A 400 kHz lever of **Q 3** with a forest (nearest peak 20% of the lever's, 70 kHz apart, Q 15) goes through the whole procedure in the twin (tune, approach, scan, 36 of 36 pixels), with the tuned f0 within 5% of 400 kHz.
* The forest does not fall when the tip touches: the lever's part goes to zero, the forest's stays, so contrast against the free amplitude is smaller than in air. That is by construction (the forest is the cell's motion), the assumption to test in S9.11.
* With a forest as tall as the lever (nearest peak 90%, 140 kHz apart) the run **refuses with failure code 25** (20 + tag 5) and writes nothing to the scanner.
* **A finding that corrected my first version:** the forest raises the sweep's floor, so `analyse` first said "no resonance" (tag 2, peak under 5 times the floor) for it, which is the wrong reason. The ambiguity test now runs first when the peak is at least 2 times the floor; a flat or noise-only sweep is still tag 2.
* **Not found:** whether tag 5 is the right threshold for a real cell. It is 0.7 because that is minus 3 dB, not because anything was measured. The 1/k fall-off and the spacings are guesses. Q 2 (the bottom of the stated range) was not run through the whole procedure, only Q 3.
* `scan_twin` keeps going after a refused session and prints a scan of nothing (all 10000 pm); it reports the failure code on its first line. Left as it was.
