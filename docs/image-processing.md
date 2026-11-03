# Image processing: design note

> Written 2026-11-03, **before any of it is built**. Numbers marked **[A]** are assumptions; what the sibling libraries do is from their GitHub descriptions and the READMEs I read (`cancho-table`, `cancho-opt`, `cancho-gpu`); `cancho-ml` and `cancho-stats` I did not read beyond their one-line descriptions.
> Today the project turns a scan into an image (an array of Z values in pm) and stops: `host/session.cho` has one crude analysis (`period_of`, the grating period in pixels). This note says what an AFM image needs, where each part should come from, and how to check it.

## What an AFM image needs

| Step | What | Done by |
|---|---|---|
| **Levelling** | remove the sample tilt (a plane, least squares) and line-to-line offsets (subtract each line's median or mean; a line polynomial); a raw image is mostly tilt | our own code: closed-form least squares on a 3 x 3 system, a median per line |
| **Metrics** | roughness Ra, Rq, Rz; the height of a step (two-level histogram or an edge fit); the pitch and height of a grating | our own code for the plain statistics (they are sums and sorts, exact and small); a fit where it is not closed-form |
| **Features** | find particles or pits: threshold the levelled image, label connected regions, report count, height, area, centre | our own code (labelling is a short loop); the **table** of them is the output |
| **Corrections** | drift between trace and retrace or frames (cross-correlation); creep and hysteresis (the scanner's, H2); periodic noise (a notch in the Fourier transform) | our own code first; models need a measured scanner |
| **Tip effects** | a tip of finite radius widens features; blind reconstruction estimates the tip from the image | an optimisation problem, later |
| **Display** | the levelled image, line profiles, the table | `cancho-ui` has charts but no image element (found in the first console work): either add one there (separate repo) or write the image as a file the page loads |

## What each of the libraries you named is for here

* **`cancho-table`** (built, a deterministic CLI for CSV, TSV and JSON lines: select, filter, group and aggregate, exact decimals, bounded memory, refusals with repairs). **Yes, for the output side**: the particle list and the per-scan metrics are small tables (`particles.csv`: x, y, height, area), and `table` can summarise a campaign of scans (mean height by sample, count by threshold) without us writing a query engine. A real fit; low risk. Its interface I have only read in the README.
* **`cancho-opt`** (a local clone: numerical optimisation as a JSON command line, the `scipy.optimize` subset: minimize with Nelder-Mead, BFGS and others). **Later, for the fits that are not closed-form**: a grating's sinusoid-plus-harmonics, a step edge (an error-function profile), drift parameters, and the tip in blind reconstruction. It is a command line, so it would run as a separate process on the host, not inside the instrument's loop; fine for analysis, not for control. I have read its README only.
* **`cancho-stats`** (a design-phase project as described on GitHub: exact sums, tests, intervals, resampling, regression inference). **Wanted, not usable yet**: a confidence interval for the plane fit or a test that trace and retrace differ would come from it. Until it exists, the mean and rms are written here directly (they are a few lines and exact). Revisit when it ships.
* **`cancho-ml`** (planned, per its description). **Not now**: classifying features (particle against artefact) or spotting a failed tune needs labelled real images, which do not exist; the twin's are invented. Worth a look when there is a library of real scans.
* **`cancho-gpu`** (a real compiler for typed GPU tile kernels, to Metal and CUDA). **Not now**: a 256 x 256 frame is 65,000 pixels; at ten frames a second that is 650,000 pixels a second, which a CPU does in milliseconds for levelling, a Fourier transform or labelling, and the Pi has no GPU target. It would matter for a blind-reconstruction over many frames or a 1,024 x 1,024 live display; revisit if profiling shows a need, not before.

## Where it runs, and how it is checked

* **Host side**, after the session returns an image: a new `host/image.cho` (and `sim`-free: it only reads arrays), in the plain cancho used everywhere, small arrays in regions, no dependency. Every file stays under 2,000 lines.
* **Checked against the twin's ground truth.** The twin knows its sample exactly (`sim/board.cho` `surface`): a 100 pm grating of 12 pixels' pitch (1,200 X codes at 100 codes a pixel), a 150 pm terrace edge at line 26, three raised-cosine particles of 600, 450 and 600 pm at known places. So each routine is scored against **the truth**, something the real instrument will never offer: e.g. the terrace measured within 10% of 150 pm, the grating pitch within 2% of 12 pixels, three particles found with heights within 20% and centres within one pixel, a deliberately added tilt removed to under the noise (28 to 30 pm).
* **What that proves, and what it does not.** It proves the code does what it says on an idealised image with known noise. It does **not** prove the methods suit real images (real tilt, creep, tip shape, dirt): the first real scan will change some of these. A routine is called validated only on a real image.

## Slices, acceptance first

| Slice | What | Acceptance |
|---|---|---|
| I1 | Levelling: plane and line | a tilt added to a twin image (known to the pm) is recovered and removed to under 35 pm rms; a line offset added to every line is removed; tests, twin fork and HS images. **Done 2026-11-03, see "What I1 found"** |
| I2 | Metrics: Ra, Rq, Rz, step height, grating pitch and height | terrace within 10%, pitch within 2%, grating height within 20%, on both profiles; Ra and Rq against a direct computation on the truth. **Done 2026-11-03, see "What I2 found"** |
| I3 | Particle finder and its table | the twin's three particles found, heights within 20%, centres within a pixel, no false ones at the twin's noise; `particles.csv` read by `table` in a test of the flow. **Done 2026-11-03, see "What I3 found"** |
| I4 | Drift: trace against retrace by cross-correlation | a drift set in the twin (`fl[8]`, pm per window) is estimated within 20%; then removed. **Done for x and height drift on the high-speed profile above a floor, see "What I4 found"** |
| I5 | A page for it: levelled image, profile, table in `cancho-ui` (an image element is a change in that repo) | the live console shows the levelled image and the metrics of the last scan |
| I6 | Fits with `cancho-opt` (grating, step, tip) | decided after I2: only if the closed-form metrics are not enough |

## What I1 found (`host/image.cho`, `tests/image_test.cho`, `./scan_twin <profile> 0 0 1`; twin, 2026-11-03)

`image.plane_fit` (least squares with a mask, Cramer's rule), `image.plane_robust` (fit, drop pixels beyond 2.5 residual rms, refit, three rounds), `image.subtract_tilt`, `image.level_lines` (each line's median against the median of the medians within 4 lines).
Images up to 256 x 256 (a region holds 64 KiB; the mask is bytes).

* **Particles pull a plain plane; the robust one is not pulled.** On a flat 32 x 32 image with a tilt of 2.0 and -1.5 pm per pixel and three particles (450 to 600 pm), the plain fit gives bx = 0.77 (error 1.2 pm per pixel, 60%), the robust fit 2.006 and -1.505 (error under 0.01).
* **On the twin's 64 x 64 scan with a tilt of 2.0 and -1.5 added and line offsets of +-40 pm (rms 23 pm):** the tilt estimate is off by 0.009 and 0.04 to 0.05 pm per pixel; after levelling the plane the rms difference from the truth is 23.4 pm (the offsets, untouched), after the lines **11.9 pm for the fork's image, 10.5 pm for the HS profile's**, under the image's own noise of 28 to 30 pm. The acceptance (under 35 pm) is met.
* **A plane flattens real slopes.** The twin's own sample has a 150 pm terrace across the lines; the robust plane fit reads it as a slope of 3.3 pm per pixel along y (210 pm over the image, more than the step: the particles and the two levels pull it). Levelling a plane **before** measuring a step or a slope **removes it**: I2 must measure heights on the image before the plane is taken out (or take the plane from a region without structure).
* **Line levelling cannot tell a line offset from a step across the lines.** The version here keeps a step (a test: a 150 pm step at line 16 of 32 stays within 50 pm after levelling while +-40 pm offsets go), but within 4 lines of a step the lines are pulled toward their neighbours'; and a feature spanning fewer than 5 lines is treated as an offset. The 11 to 12 pm residual on the twin is mostly that edge and the particles.
* **Not done:** a polynomial surface (a bow) beyond the plane; scan lines that are not straight; real data. The twin's image has no bow, creep or drift yet.

## What I2 found (`host/metrics.cho`, `tests/metrics_test.cho`, `./scan_twin <profile> <scanner> <kHz> 2`; twin, 2026-11-03)

**Method, chosen as the best estimator rather than the quickest.** Roughness is the plain sums (nothing better exists). The **step** is an exhaustive search of the edge line with a least-squares fit of two levels *and a common slope along y* to the line medians (exact maximum likelihood once the edge is placed; the median keeps the grating and the particles out, the slope keeps a tilt from being read as part of the step; it is run **before** any plane is taken out, which was I1's finding). The **grating** is a joint least-squares sinusoid over all lines, one frequency, one amplitude and phase, a free offset per line (variable projection: amplitudes and offsets solved exactly for each trial frequency, only the frequency searched, coarse grid then golden section), refitted twice without the pixels beyond 3 residual rms so the particles do not pull it. A Fourier-peak estimate or a zero-crossing count (what `session.period_of` does) is biased by the particles, the line offsets and the finite window; this is not. It is one 2-parameter linear solve per trial frequency, no optimiser library needed, so it is written in `metrics.cho`.

* **Library question, answered.** `cancho-opt` is a separate process and its fits (Nelder-Mead and others) are general; these three are closed-form or one-dimensional, so a subprocess would be slower and less exact. `cancho-stats` (design phase) would be the home of the confidence intervals these lack: today the fits return a residual rms, not an interval. The right extension is **an interval for each metric from `cancho-stats` once it ships**, and `cancho-opt` for the fits that are not like these (tip reconstruction, I6).
* **Checks with known answers** (tests): a square wave gives Ra = Rq = 30 and Rz = 60 exactly; a sine of amplitude 50 gives Rq 35.36 and Ra 31.42 (16 samples a period; 31.83 for a continuous one); a step of 150 on a tilt of 2 pm per line with noise and two particles: edge line 18, height within 6, slope 2 +- 0.3; a grating of pitch 11.7 pixels and 100 pm peak to peak under +-40 pm line offsets, +-25 pm noise and three particles: pitch within 0.5%, height within 5.
* **On the twin's 64 x 64 scan, measured against the same numbers read off the sample's true surface at the pixels** (true values: pitch 12 pixels = 11.999 sampled, grating 99.9 pm peak to peak, terrace nominally 150 pm, 155.1 pm as the median fit reads the truth image, because the particles raise the medians of the lines they sit on):

| image | Ra, Rq, Rz (pm) | step line, height (pm) | pitch (pixels) | grating height (pm) |
|---|---|---|---|---|
| truth | 72.9, 89.2, 182.5 | 25, 155.1 | 11.999 | 99.9 |
| fork | 73.8, 92.3, 194.4 | 25, 149.0 | 12.005 | 93.1 (fit rms 10.3) |
| HS 300 kHz | 72.9, 89.1, 190.3 | 25, 155.5 | 11.998 | 98.3 |
| HS 500 kHz | 72.9, 89.3, 189.6 | 25, 155.5 | 11.997 | 99.8 |
| HS 600 kHz | 73.6, 90.0, 189.2 | 25, 155.2 | 11.998 | 100.9 |
| HS 500 kHz, Z stack 100 kHz | 72.9, 89.3, 190.9 | 25, 153.1 | 11.996 | 100.4 |

  Acceptance (terrace within 10%, pitch within 2%, grating height within 20%) is met by a wide margin on both profiles: the pitch is within 0.05%, the step within 4% of the truth image, the grating height within 7% (fork) and 1 to 2% (HS).
* **The fork's grating comes out 7% low and its fit residual is 10 pm** against 4 pm for the HS images: a likely cause is that the fork's slow loop does not follow the 12-pixel grating completely (the image is the loop's, not the surface's); I did not test that, for instance by scanning slower. Heights read from a slow scan are lower bounds on a fine grating; that is a property of the scan, not a defect of the fit.
* **Rz is 4 to 7% above the truth's** (190 against 182 pm): noise raises the extremes of every line (Rz is a peak-to-valley, the most noise-sensitive of the three). Ra and Rq are within 1 to 3% (HS 0.1 to 1%). The excess of Rq^2 over the truth's is far below the 28 to 30 pm noise variance (e.g. 7 pm^2 for HS 500 kHz), so the image's noise does not simply add in quadrature to the structure: most of the structure's variance is the sample and the loop's tracking, which is shared with the truth.
* **The stepped, particle-covered sample is a bad roughness sample** (Rq 89 pm is the sample's structure, not roughness). The numbers prove the code matches a direct computation; a roughness of a flat region needs a flat sample or a mask, which the caller chooses.
* **Not done:** areal parameters of ISO 25178 beyond Rq as the areal rms; a cut-off filter (a Gaussian) for waviness; an interval for any metric; grating harmonics (a non-sinusoidal profile: the sine amplitude then understates the height); a step edge that is not straight or not along a scan line; real data.

## What I3 found (`host/features.cho`, `tests/features_test.cho`, `./scan_twin <profile> <scanner> <kHz> 3`; twin, 2026-11-03)

**Method.** The background under each pixel is the median of the 15 x 15 window about it (wider than the grating's 12-pixel pitch, more than twice a particle's 8-pixel diameter), so it follows a tilt, a terrace and a grating without a model of any of them. The threshold is the larger of a minimum height the caller gives and 5 x the residual's robust noise (1.4826 x the median absolute deviation). High pixels are grouped by 8-connectivity; a group of at least 4 pixels is a particle (a group over 2,048 pixels is a feature of the surface and is dropped). Height is the group's largest residual; area is the pixels at or above half that height; the centre is the residual-weighted centroid of those pixels (sub-pixel). Output is `x,y,height_pm,area_px` per particle, the CSV that `table` is meant to read.

* **Tests.** A 64 x 64 image with a grating, a 150 pm terrace, a tilt, 30 pm noise and three particles of 600, 450 and 600 pm: all three found, centres within 1 pixel, heights within 20%. Images without particles at 30 and 60 pm noise: none found, **with the minimum height set to 0 so only the automatic 5 sigma threshold is in force**. A mutant with the factor 5 changed to 0.5 fails both tests, so they do discriminate.
* **On the twin's scan** (true particles at (12, 13), (32, 18), (23, 33) pixels, 600, 450 and 600 pm; minimum height 0):

| profile | centres found (pixels) | heights found (pm) | areas |
|---|---|---|---|
| fork | (12.22, 13.00) (31.99, 17.99) (23.18, 33.00) | 594, 508, 599 | 10, 9, 10 |
| HS 300 kHz | (12.17, 13.00) (31.70, 17.99) (23.00, 33.00) | 523, 429, 509 | 10, 7, 9 |
| HS 500 kHz | (12.02, 13.00) (31.70, 17.98) (23.00, 33.00) | 516, 428, 510 | 9, 7, 9 |
| HS 600 kHz | (12.02, 13.00) (31.70, 17.98) (22.99, 33.00) | 526, 434, 518 | 9, 7, 9 |

  Three found, no false ones, centres within 0.3 pixel (acceptance: a pixel), on all four. Heights are within 20% everywhere: the fork's are 1% low, 13% high (the second particle) and 0.2% low; the HS images' 600 pm particles are **12 to 13% low** (509 to 526) and the 450 pm one 4 to 5% low (428 to 434). Why the HS particles are low I did not test; the tracking of a 8-pixel bump by a 250 kHz loop with a Z stack is the suspect, and a guess, not measured.
* **Heights are above the local median, not above the lowest surface:** a particle on the terrace reads its height above the terrace (the third particle's 600 pm is measured from the 150 pm level, which is what is wanted), and a particle on a grating reads above the grating's median, so it carries up to +-50 pm of the grating's phase (the fork's 508 for 450 is probably that).
* **The `table` flow** (`tests/particles_flow.sh`, run by `test_all.sh` when `TABLE` names a built `table`; otherwise it prints that it was skipped). It builds `scan_twin`, writes the HS 500 kHz scan's `particles.csv` and has `table` (cancho-table 0.3.0, built here from a clone with the local compiler and `--ignore-compiler-rev`, because it pins a compiler 173 commits older than the one I use) answer: three rows; `--agg count,max:height_pm:dec(2)` gives 3 and a maximum of 505 to 530 pm; `--where "height_pm:dec(2) > 450"` keeps 2 rows (above 550 it keeps none); and a decimal column **not** declared `:dec(2)` is refused with the rule `value.not-integer` rather than read as a number, which is the behaviour I wanted from it. Not run in CI here; I did not run `table`'s own tests under the newer compiler, so "works with a newer compiler" is shown only by this flow.
* **Not done:** the pixel size is not known to the finder, so the area is in pixels and the heights and centres are not in nm and nm (the caller scales); overlapping particles are one group; touching the image edge is not flagged; a tilt steeper than the window can follow, and a tip of finite radius (the twin's tip is a point), are not handled.

## What I4 found (`host/drift.cho`, `tests/drift_test.cho`, `./scan_twin <profile> <scanner> <kHz> 4 <x> <z>`; twin, 2026-11-03)

**What the twin gained.** The sample drifts under the tip: `fl[20]` X DAC codes and `fl[8]` pm per detector window while a scan runs (`fl[22]` counts the windows; it is zero outside a scan, so the approach is unaffected). `scan_twin` takes the drift in milli-pixels per tick (a tick is one pixel of the raster) along x and milli-pm per tick in height, and now records the **retrace** as well as the trace: the raster already reports the tick (`pixline` runs 0 to 125 on a 64-pixel line), the retrace is ticks 64 to 125 and visits x = 62 down to 1.

**Method.** The scan goes out and back along the same line, so point x is seen at tick x and at tick 2 (63 - x) + x: a lag of D(x) = 2 (63 - x) ticks. A drift of v pixels per tick along x makes the retrace see the surface shifted by v D(x) against the trace; a height drift of w pm per tick adds w D(x); and the feedback loop's own lag (the image trails the tip) adds a constant shift s. The model R(x) = T(x + s + v D(x)) + w D(x) + c(line) (c a free offset per line) is fitted by least squares over every pixel of every line: for a given (s, v) the height drift and the offsets are solved exactly, so only (s, v) are searched (a 25 x 25 grid, then a golden section along each in turn, four rounds). Not a plain cross-correlation: a cross-correlation gives one shift per window and cannot separate a drift (which grows along the line) from the loop's lag (which does not).
* **Interpolation bias, found and fixed.** The first version compared the retrace with a cubic interpolation of the noisy trace. Interpolating noisy pixels at a fractional place averages their noise down by an amount that depends on the fraction, and the fit then preferred the shifts that average most: with 20 pm noise the model's own parameters scored 16.4 pm rms and a wrong shift 15.0, and v came out at 0.0004 for 0.006. Both images are now smoothed by the same kernel (1 4 6 4 1 / 16) before they are compared, and v is 0.006 within 10%.
* **Correction** (`drift.correct`): each line's trace and retrace are put where they really were (relative to the middle of the line's time), the height drift taken off, and the two averaged. Drift **between** lines is not seen by a trace/retrace comparison and is not removed.

**Tests with known answers** (`tests/drift_test.cho`, 64 x 32 images of a grating, a terrace and three bumps, 20 pm noise): drift 0.006 px per tick, lag 0.8 px, height drift 0.5 pm per tick recovered to 0.0006, 0.1 and 0.05; the same with all three negative; none set: all three under the floor; the correction brings the image within 10 pm of the surface (noise-free) where the raw trace is not.

**On the twin's 64 x 64 scan** (HS profile, 500 kHz cantilever, ideal Z scanner unless stated; "set" and "found" in milli-pixels per tick along x, milli-pm per tick in height; the error is the rms difference from the true surface at the middle of each line's time, with the Z baseline removed, pm):

| set x, z | found x, z | raw trace error | corrected error |
|---|---|---|---|
| 0, 0 | 1.4, 3 | 3.8 | 2.2 |
| 3, 0 | 4.0, 1 | 4.4 | 2.7 |
| 5, 0 | 5.9, 0 | 5.4 | 2.6 |
| 8, 0 | 7.1, -3 | 6.5 | 2.3 |
| 16, 500 | 15.0, 490 | 12.5 | 1.9 |
| 30, 0 | 27.2, 0 | 18.1 | 2.2 |
| 8, 0 at 300 kHz | 7.9, 1 | 7.4 | 2.6 |
| 8, 0 at 600 kHz | 8.2, -5 | 6.3 | 2.5 |
| 20, 500 on the fork | 20.0, 492 | 31.1 | 7.3 |

* **Acceptance (within 20%) holds from 5 milli-pixels per tick** (0.6 pixel over a line), on the 300 to 600 kHz cantilevers and on the fork. The height drift is within 2% wherever the loop keeps the surface.
* **The floor is a bias of about 1.4 milli-pixels per tick on the 500 and 600 kHz images with no drift set** (0.0 at 300 kHz). It grows with the loop's lag and is the same sign as the drift: the model takes the lag as one shift, and the loop's response to a grating, a particle and a step is not one shift. So a drift below about 5 milli-pixels per tick (under 0.6 pixel between the two ends of a line) cannot be told from the loop's asymmetry. I did not try to model the lag better (a lag per feature size is a candidate); the cost is a floor, not a wrong answer.
* **Where it fails.** A height drift of 1 pm per tick (126 pm per line, 8 nm per frame) makes the twin lose the surface (the scan is garbage; this is the loop, not the estimator; the cause I did not look into: the contact range or the Z limit); 0.5 is fine. The x search is limited to shifts of 3 pixels at the far end of a line (a quarter of the grating's period).
* **The error after correction (about 2 pm) is the image's own noise floor** on the HS profile; the fork's remains 7 pm, because its lag is 2 pixels and the pixel-to-pixel structure the model cannot follow is larger.
* **What is not tested:** a real drift is not linear in time (it relaxes after a move); y drift (between lines) is not estimated; the zero of the drift clock (a few ticks) is taken as the scan start in the scoring.

## Open questions

1. **Real data.** Everything above is checked on the twin; the invented sample is not an AFM's. The first real image decides what is wrong.
2. **Where the image comes from for a fast scan**: the HS profile's image has 28 to 30 pm noise in the twin; with a real photodiode it will be more. Denoising (a median or Gaussian filter) is deliberately not in the list until the noise is seen.
3. **The tip**: the twin's tip is a point; tip deconvolution needs a tip model in the twin first.
