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
| I1 | Levelling: plane and line | a tilt added to a twin image (known to the pm) is recovered and removed to under 35 pm rms; a line offset added to every line is removed; tests, twin fork and HS images |
| I2 | Metrics: Ra, Rq, Rz, step height, grating pitch and height | terrace within 10%, pitch within 2%, grating height within 20%, on both profiles; Ra and Rq against a direct computation on the truth |
| I3 | Particle finder and its table | the twin's three particles found, heights within 20%, centres within a pixel, no false ones at the twin's noise; `particles.csv` read by `table` in a test of the flow |
| I4 | Drift: trace against retrace by cross-correlation | a drift set in the twin (`fl[8]`, pm per window) is estimated within 20%; then removed |
| I5 | A page for it: levelled image, profile, table in `cancho-ui` (an image element is a change in that repo) | the live console shows the levelled image and the metrics of the last scan |
| I6 | Fits with `cancho-opt` (grating, step, tip) | decided after I2: only if the closed-form metrics are not enough |

## Open questions

1. **Real data.** Everything above is checked on the twin; the invented sample is not an AFM's. The first real image decides what is wrong.
2. **Where the image comes from for a fast scan**: the HS profile's image has 28 to 30 pm noise in the twin; with a real photodiode it will be more. Denoising (a median or Gaussian filter) is deliberately not in the list until the noise is seen.
3. **The tip**: the twin's tip is a point; tip deconvolution needs a tip model in the twin first.
