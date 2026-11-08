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
| S9.3 | Twin: tip-sample force and a compliant sample | S9.1 | a per-pixel tapping-force figure and a damage flag against a stated threshold; a test that a lower setpoint ratio (a harder tap) gives a higher force; the doc says the threshold is a parameter, not a finding |
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

## What S9.3 found (twin, 2026-11-08; predictions, not measurements)

Built: `board.set_soft` (fl 32 to 38), `tune.force_estimate`, `scan_twin` arguments 14 to 16 and a `force_pn_max` line, `tests/force_test.cho` (5 tests). The twin's force is a **proxy**: the lever's stiffness (N/m) times the amplitude it has lost to the surface (pm), which is in pN. The soft sample is indented by force over its stiffness, only where the surface is raised (a soft layer on a rigid substrate), eased in over a few samples so the loop through the gap stays stable.

* **A correction in the acceptance text:** the issue first said "a higher setpoint ratio gives a higher force". That is backwards: a *lower* setpoint ratio (a harder tap) gives the higher force. The table above and issue #35 now say so.
* 400 kHz, Q 3 lever, 0.15 N/m, rigid sample, setpoint 0.8 of free: the setpoint asks for 60 pN (`force_estimate`); the twin's largest window over the scan reached **88 pN**, the loop's own swing at the terrace edge and the particles. Against the twin the estimate is a check of the arithmetic, not of the physics (same formula).
* The same scan with a 0.6 N/m lever: **354 pN**, about 4 times, as the stiffness says.
* A soft sample of 1.0 N/m: the raised parts are pressed in by **59 pm**, so a 100 pm grating looks flatter (test: 20 pm or more lower than the rigid one); 0.2 N/m: **303 pm**, more than the grating's height, so the twin shows an image of a sample that has been squashed.
* The damage flag counts detector windows over a threshold. At a 30 pN threshold every window of the scan counted (the setpoint alone asks for 60 pN); at 1,000 pN none did. **Which threshold is safe for a given sample is [unknown]**: the twin reports against the number it is given and says nothing about biology.
* **Not modelled:** the real tip-sample force curve (the proxy has no adhesion, no Q and no dissipation), indentation that depends on the tip radius, a soft sample that recovers slowly, and the lever's stiffness changing in liquid.
* **The per-pixel map (closes #35), 2026-11-08:** `host/force.cho` works out a force for every pixel from what the host can read: the stiffness it is told, the free amplitude figure and the `AMP` register read at the pixel (`scan_twin` packs it above the heights; arguments 14 to 16 turn it on and it prints `force_map_max` and `pixels_over_threshold`). Same 400 kHz, Q 3 lever and 0.15 N/m: the host's largest pixel is **62 pN** against the 60 pN the setpoint asks for; with 0.6 N/m, **247 pN**.
* **A finding:** the host's per-pixel figure is **lower than the twin's own largest window** (62 against 88 pN; 247 against 354 pN). The loop is near its setpoint when the pixel is read, and the larger forces are transients at the terrace edge and the particles, which a figure taken once per pixel misses. With a 70 pN threshold the twin counts 116 windows over it and the host's map flags no pixel. So a pixel-sampled force is a figure of the *typical* tap, not the peak; a damage claim needs the peak. How to measure that on a real board (a faster read, or a peak-hold in the gateware) is not designed.
* The proxy also **understates** force when a forest is present (`host/force.cho`): the free figure includes the part that does not fall at contact.

## What S9.4 found (twin, 2026-11-08; predictions, not measurements)

Built: `board.set_optics` (fl 39 to 43), `board.light`, `board.sum_now` and `board.deflection_now` (what S9.5 will make registers), `scan_twin` arguments 17 to 20, `tests/optics_test.cho` (7 tests). The optical lever is a guess at the shape: a sum signal at best alignment, the share of light reaching the photodiode (alignment), optical noise scaled by the light, a deflection level that wanders by a fixed number of counts per detector window, and light lost at a fixed fraction per window. Off by default: every earlier result is unchanged.

400 kHz, Q 3 lever, full procedure in the twin (`scan_twin 1 0 400 ...`):

| Optics | Result |
|---|---|
| noise 3, 10 or 30 counts | runs to code 0 (the image was not checked beyond that) |
| 50% of the light | runs, the free figure halves (7,064 against 14,136) |
| 2% of the light | runs, free figure 287 (the detector still finds the lever) |
| no light (dark) | **refused, code 22 (no resonance)** |
| baseline wander up to 0.05 counts per window | runs |
| wander of 0.1 or 0.2 | **refused, code 43** (see below) |
| light loss 2 ppm per window | runs |
| light loss 10 ppm per window | **runs to code 0, but finishes with Z pinned at 0 pm (a silent wrong result)** |
| light loss 20 ppm per window | refused, code 43 |
| light loss 200 ppm per window | **runs with code 0, contact at 8,080 pm, Z pinned at 0: garbage** |

Things the twin found that were wrong in the software, now fixed:

* **A dark photodiode was accepted as a resonance.** The "no resonance" test was a peak 5 times the floor with the floor clamped to 1, so noise of a few counts passed; the approach then faulted later (code 43). `tune.analyse` now also needs a peak of at least **100 counts of figure** (a free figure is thousands, so this is under 1%; an absolute guard, not a derived one) and a dark sweep is code 22.
* **My own S9.2 test called a dark sweep "ambiguous"** (tag 5) because its gate was on the sweep's minimum; the claim two sections up ("a flat or noise-only sweep is still tag 2") was untested and false until this change. The ambiguity test now needs the same 100-count guard; a test covers a noise-only sweep.
* **"Contact" at Z fully retracted** (the reading dropped by itself, nothing moved) was accepted and the run scanned nothing with code 0. `approach.next` now refuses it as fault 3 (code 43).

**Not fixed, left for S9.6 (#38):** a slow loss of light that makes the loop drive Z to the bottom of its range still ends with code 0 and a wrong image. Nothing the host reads now says the light is fading; the sum signal does (`board.sum_now`), but there is no register for it until S9.5 and no check on it until S9.6. Until then, a run with code 0 under a fading beam is not to be trusted. Also not modelled: pointing noise, a deflection offset that clips against the photodiode's own limits, thermal drift of the lever, and the real noise of any photodiode and amplifier.

## What S9.5 found (generated Verilog, twin and register table, 2026-11-08)

**The choice: no second converter.** The Pmod AD1 is two 12-bit channels and is already in the order; in the parallel-ADC mode the high-speed stage uses (`docs/high-speed.md`) it sat idle. So the optical lever's two *slow* outputs, the deflection's DC level and the photodiode sum, are wired to the AD1, and the fast oscillation signal stays on the AD9226. The alternatives (a multiplexer on the fast ADC, or a third converter) cost parts or bandwidth for no gain at the rates involved: the host reads a latest-value register about a thousand times a second at most (`docs/bench.md`), and one AD1 conversion takes about 100 FPGA clocks at HALF 3 (an estimate from 16 SCK periods, not simulated alone).

**What changed:** `CTRL` bit 8 `OPT_RUN` (runs the AD1 beside the parallel ADC; **off by default**, so nothing earlier behaves differently), `OPT_DEFL` (50) and `OPT_SUM` (51), read-only, the latest AD1 conversions in either mode (equal to `ADC0`/`ADC1` in the SPI mode). Register count 50 to 52. `host/regs.cho` is the source: `docs/registers-table.md` and `hw/afm.chw` are regenerated, and `hw/afm.h` regenerated with a `chw` built from `../cancho-hdl` (`chw check` accepts the contract). The twin has the same two registers: in the parallel mode with `OPT_RUN` they carry `board.deflection_now` (2,048 plus the wander) and `board.sum_now`; in the SPI mode they equal ADC0 and ADC1.

**How it was checked, honestly:** there is **no new generated block**, so no new trace to run in lockstep; the SPI converter is the one already in lockstep (`spi_adc_trace`, 226 conversions, 0 mismatches). What is new is a gate on its start and two capture registers, checked by:
* `gen/afm_top_tb.v` phase 9 (unchanged assertions, plus both registers read 0 without `OPT_RUN`) and **phase 10**: with `OPT_RUN` the parallel ADC still reads its exact code and OTR and one sample per 6 clocks (to 0.5%), the SPI converter runs, `OPT_SUM` reads the AD1 model's channel 1 (1234) and `OPT_DEFL` a 12-bit code, and both clear with `ADC_RUN` off;
* the contract test (`gen/regs_tb.cho`: 52 registers, reset values, read-only refusal, unmapped refusal);
* `tests/optics_test.cho`: the twin's two registers in each mode, read-only, cleared.
It is **not** a code-for-code comparison of the twin's `OPT_DEFL` with the Verilog's (the AD1 model in the testbench is a fork, not an optical lever), and the twin updates the two registers every fast sample while the hardware updates them at the AD1's rate.

**Not known, not built:** the AD1 inputs take 0 to 3.3 V, so the photodiode amplifier's sum and deflection outputs must be conditioned to that range and a mid-scale DC level for the deflection **[unknown, part of S9.8]**; the SPI clock running beside the 4.5 MS/s fast ADC may add noise to it, **not measured** (a reason `OPT_RUN` is off by default and S9.11 should compare the fast channel's noise with it on and off); no host program reads the two registers yet (S9.6, #38).

## What S9.6 found (software, against the twin, 2026-11-08; predictions, not measurements)

**Profile 2, `liquid`, in `host/session.cho`.** It shares the whole fast-cantilever setup of profile 1 (parallel ADC, 6 clocks a sample, the swept 100 to 899 kHz range, the snapped window; a new function `fast(p)` replaces the old `p == 1` tests). What differs, all in functions of the profile so profiles 0 and 1 are unchanged:
* it turns the optical lever on (`CTRL` bit 8, `adc_bit(2)` is 384) at the end of stage 0 and **reads `OPT_SUM` and `OPT_DEFL` at the end of every stage** (so every other read keeps its place);
* a gentler tap: setpoint 90% of the free figure (80% before) and contact declared at 94% (90% before). These two numbers are **choices, not findings**: nothing here says what a soft sample tolerates (S9.3: the threshold is a parameter), and the force is not reported until S9.7;
* refusals on the light, checked after every stage before anything else in it is believed: **81** the sum signal at the start under 400 counts of the AD1's 4,095 (no optical lever, or an unlit one); **82** the sum signal fell under 95% of its starting value; **83** the deflection's DC level left the 2,048 +- 1,000 range. They sit next to the ones that already existed: 22 (dark sweep), 25 (ambiguous forest, S9.2), 43 (contact at full retract, S9.4). The limits (`sum_min`, `sum_floor_pct`, `defl_span`) are **assumed**; the twin's sum has no noise, so none of them has met a real photodiode.

**The fading beam (handed over by S9.4) is now refused**, with one correction to my own first version: I set the floor at 70% and the twin showed the approach faulting first (43), because the amplitude follows the light and the approach declares contact at 94% of the free figure, so a 6% fade is already a "contact" at full retract. A 5% floor is what the setpoint margin justifies (the loop taps with a 10% margin under the setpoint; a 5% fade halves it), so it is 95%. The run now ends with 82 and a state where `ss[24]` (the lowest sum seen) says why. A very slow fade (2e-8 per window) still runs.

**Tested (`tests/liquid_session_test.cho`, 8 tests):** the whole run with no operator (36 pixels, f0 and Q found, the light read the whole way); no optical lever (81); a lever with a tenth of the light (81, nothing moves); a fading beam (82); a very slow fade (runs); a wandering deflection (83); an ambiguous forest (25); the profile's own constants. `host/scan_twin.cho` takes profile 2 (the optical lever always on, defaults a sum of 2,000 and no noise): a default run finishes with code 0, a half-aligned one with half the free figure (6,198 against 12,394 counts), a fading one with 82.

**Not done, said plainly:**
* the last stage turns the ADC off (which clears the optical registers), so the final light check is the last pixel read, not a reading after the scan;
* no check on the loop's Z being pinned at an end of its range (the hand-off reads Z, nothing judges it);
* the limits above were chosen from the twin's own numbers; the real photodiode's noise and the lever's real approach are the places they will move;
* the force is not computed in the session: S9.7 puts it next to the image.

## What S9.7 found (software, against the twin, 2026-11-08; predictions, not measurements)

**Alignment (`host/align.cho`, `host/align_twin.cho`).** A state machine with no I/O that finds where the spot sits on the lever from `OPT_SUM` alone: the operator moves a screw (or mirror) to each of n positions and the program keeps the best, goes back to it for a second reading and says "aligned, leave it at position p", or refuses: **1** no light at any position (best under 400 counts), **2** the best is at an end of the range (the peak may be beyond; widen it), **3** the second reading is under 90% of the first (not repeatable). `host/align_twin.cho` runs it against the twin through the registers and prints every step ("step 7: move the screw to position 6, sum 2000"); the twin's screw is a Lorentzian hump of half-width 2 positions, **a guess at a shape and not a head**. Against it: a hump at 6 of 11 is found in 12 steps; a hump with 5% of the light is refused with 1; one past the range with 2.
**Not done:** the quadrant difference. Centring across the screw's axis needs a second deflection axis the register table does not have (one deflection, `OPT_DEFL`); the sum alone only finds the best along one screw. A real head will need that axis and, probably, a better search than a scan.

**The force next to the image.** The console's `scan.json` (`host/scan_twin.cho`, mode 5) now carries `force_pn_max`, `force_pixels_over`, `force_threshold_pn` and a `force_text` that says what the number is, whenever a stiffness is given (arguments 14 to 16). Profile 2, 0.15 N/m, a rigid sample, threshold 60 pN: largest pixel force **32 pN**, none over 60. It is the S9.3 per-pixel proxy, so it keeps its limits: the twin's own guess, circular against the twin, it misses transient peaks (the twin's largest window was higher than the largest per-pixel value), it understates force under a forest, and **the threshold is a parameter, not a finding**. Without a stiffness no force is printed (the report does not invent one). The stiffness is printed as hundredths of N/m: the first version printed 0.15 as "0.2" through a one-decimal formatter, found when I read the output.

**Tests:** `tests/align_test.cho` (6: synthetic peak, the three refusals, the twin through the registers, the twin refusals) and `tests/liquid_flow.sh` (in `test_all.sh`, needs only the compiler: the printed steps, aligned at 6, reasons 1 and 2 by exit code, the force and threshold in the JSON, pixels over a 1 pN threshold, and no force without a stiffness). Not covered: the console page (`ui/`) does not show the force yet; it is in the JSON only.

## Scope and acceptance (S9.1, 2026-11-08; a proposal for the owner to confirm; nothing here is measured)

Tags as above, plus **[search]**: a number from a web search on 2026-11-08, a listing or a lecture and not a datasheet read here. The two samples and the force are **proposals**: they are the project owner's to confirm or change.

**"Works in water" means, and only means:**
1. The instrument, with the S8 optical head and a cantilever in a sealed fluid cell, finds the lever's resonance in liquid with no operator input (`session` profile 2) and refuses with a tag when it cannot (S9.6) **[repo]**.
2. It forms an image of the **hard sample** below, and the step height it reports is within 10% of the sample's stated height. The 10% is a choice of this project, not a standard, and a gentler number is better once there is a measurement **[unknown]**.
3. It reports a tapping force next to that image (S9.7) and the force is at or under the target below.
4. It does so with the electronics dry: no piezo electrode, amplifier output or mains-powered part touches the liquid (S9.9, S9.10).
5. The **soft sample** image (S9.12) is a separate and later claim, and "works for biology" is **not** claimed by items 1 to 4.

**The hard test sample (proposed): a height-calibration grating of silicon dioxide on silicon, 20 nm step**, such as the BudgetSensors HS-20MG, which its sellers list as a 20 nm calibrated height on a 5 x 5 mm chip with the exact value on the label **[search: [NanoAndMore](https://nanoandmore.com/afm-calibration-standard-BUDGETSENSORS-HS-20MG), [Ted Pella](https://tedpella.proscitech.com.au/products/afm-calibration-standard-step-height-20nm-mounted)]**. It is rigid, stable in water **[general, not checked for this chip]** and has a step that the twin's 100 pm grating does not: 20 nm is 200 times that, so it is the first sample where the twin's number and the real image differ by a lot, and the twin's Z range (10,000 pm) is **less than the step**, so S9.11 must either use a smaller step or extend Z. **That is a real conflict, left open for the owner.** The alternative is **freshly cleaved mica** (layer steps of about 1 nm **[general, unchecked]**, atomically flat, the usual support for soft samples): a better test of noise and of the loop, a worse test of "did the height come out right". A TGZ1-type grating (listed at 18 to 20 nm, 3 um period, with the vendors disagreeing on the figure and a batch spread of up to 10% **[search: [Labtech listing](https://www.labtech.com/?p=29534), a [BAM reference-material record](https://www.nano-refmat.bam.de/en/nano-refmat_media/27_step_grating_1.pdf)]**) is the same kind of sample, with a larger period.

**The soft test sample (proposed): a supported lipid bilayer on mica** (about 4 to 5 nm thick **[general, unchecked]**), prepared from a lipid the lab can buy, imaged in a buffer. It is a sheet and not a cell, it is flat, and its damage shows (holes), so a force that is too high is visible in the image. The alternatives, in rising order of difficulty: DNA on mica (needs a divalent cation and a specific mica treatment **[general]**), a purple membrane (a protein sheet that high-speed AFM groups use, from a specialist source **[general]**), living cells (out of scope, below). Which one is the owner's call together with whoever does the wet lab (see Risks).

**Target force: at or under 100 pN, and the instrument says what it reached.** Non-destructive imaging of soft biological samples in physiological liquid is described as needing forces under about 100 pN **[search: [a lecture deck](https://moodle2.units.it/pluginfile.php/791264/mod_resource/content/0/Lezione7_AFM_Examples1_2025_compressed.pdf); Bruker states the same figure for its own mode, a vendor claim]**; the same sources say force sensitivity falls in liquid because Q is under 10, which is what profile 2 assumes. The twin's profile 2 with a 0.15 N/m lever, 2,000 pm free and a 90% setpoint asks for 30 pN by the S9.3 proxy (the measured largest pixel in a scan was 32 pN **[repo, S9.7]**), so the number is consistent with the twin and **says nothing about a real lever**. The damage threshold of a particular sample is **[unknown]** and is a parameter of the twin, never a finding.

**Out of scope:** living cells and anything that needs temperature control or sterility; any sample that is not the two above until S9.12 is done; imaging faster than about a frame in seconds (S8 reached for more; this epic does not need it); flow, electrochemistry and heated stages; a claim about the force beyond the proxy until a real calibration of the lever's stiffness exists **[unknown: the spring constant of a real lever is calibrated by a method this project has not chosen; the vendor's value can be far off]**; and any measured number: all of the above are plans.

**Decisions for the owner** (S9.1 is done when these are written in):
1. Hard sample: HS-20MG-type 20 nm step (needs the Z range raised or a lower step), or mica first, or both in that order?
2. Soft sample: supported lipid bilayer on mica as proposed, or another?
3. Is 100 pN the target, or something stricter for the first soft image?
4. Is the wet-lab collaborator named, or does S9.12 wait?
