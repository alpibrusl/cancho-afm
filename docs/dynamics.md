# Physical dynamics for lipid membranes and proteins: design note

> Written 2026-11-09, **before the first slice is built**, and corrected the same day after the sources were read (see "What reading the sources changed"). Numbers are tagged: **[read]** read in the full text of the source named; **[snippet]** seen only in a search result; **[A]** computed here from stated assumptions (the arithmetic is reproducible: the numbers below come from a short script and from `tests/dynamics_test.cho` once D1 exists); **[recalled]** from general knowledge and **not verified**; **[unknown]**.
> Nothing here ran on an instrument. Every twin result this note asks for is a prediction. This note grows `docs/high-speed.md` (the twin's instrument model) and `docs/liquid.md` (S9.12, the first biological image) with a model of the *sample*.
> Asked for: viscosity and "dispersion" (read here as the spreading of particles by diffusion; if optical dispersion or something else was meant, say so), for lipid membranes and protein analysis, with the maths checked against the literature, compared with experiments, and with force curves analysed to determine dynamics. Issues: #77 (D1) to #82 (D6).

## What the twin has, and what it does not

The twin's sample is a made-up surface (`sim/board.cho`): a grating, a terrace step, three particles that do not move, and, since the dynamic sample (#76), four things on prescribed paths. **What it has none of:** a motion that comes from physics (a diffusion coefficient, a viscosity), a membrane, a lateral size tied to a tip, any effect of the fluid on the lever, a force curve. All are needed before a twin result says anything about a lipid membrane or a protein.

There are two separate physics here:

| | What changes | Why it matters |
|---|---|---|
| **the sample** | molecules move, bind, grow; a membrane is 4 to 5 nm thick, soft and fluid | what the movie shows, and whether it can be tracked at all |
| **the instrument in the fluid** | the lever's Q and drag depend on the fluid's viscosity | the frame rate the instrument can reach (HS3: tau = Q / (pi f0)) |

## What reading the sources changed

The first version of this note was written from search snippets. Reading the sources (full text where the table below says so) **corrected two claims and one proposal**:

| First version said | The sources say | Now |
|---|---|---|
| D depends on a protein's size only through a logarithm | That is the Saffman-Delbrueck prediction; Gambin et al. 2006 measured peptides and proteins of 5 to 30 nm radius with a Stokes-like 1/a dependence instead, and Weiss et al. 2013 found agreement with Saffman-Delbrueck in black lipid membranes; Wikipedia calls the experiments "controversial" **[read: Wikipedia and Demery & Lacoste, citing both]** | stated as a model prediction that experiments contest; the twin offers both laws as a parameter |
| A free protein in a fluid bilayer (about 1 um^2/s) is what HS-AFM would see | HS-AFM on mica-supported bilayers measures D mostly **below 0.001 um^2/s**, three orders under that, with the mica named as the main limitation **[read: Sullivan et al. 2020]** | the biological cases are hindered proteins, and the tracking table below is read against 0.001, not 1 |
| Tracking needs displacement per frame under about one particle diameter | The published detection limit is different and weaker: Casuso et al. 2009 take `<r^2> = 4 D t` and call the fastest observable D at 100 ms **0.025 um^2/s (2.5e4 nm^2/s)**, a displacement of 100 nm, equal to their field **[read]**. Linking several particles needs a stricter rule that depends on density | two criteria, below |

## Verification of the maths and what it was compared with

| Item | Result | Source and status |
|---|---|---|
| Saffman-Delbrueck translational D | `D = kT / (4 pi eta_m h) * [ln(l / a) - gamma]`, `l = eta_m h / eta` (the 2D membrane viscosity over the bulk's), `gamma = 0.5772`; no-slip at the membrane/fluid boundary (zero tangential stress adds a factor 1/2 inside the bracket); applies for `a` below the Saffman-Delbrueck length `L_sd = h eta_m / (2 eta_f) = l / 2` | **[read]** Demery & Lacoste, arXiv 1810.09910, Eq. 1; the Wikipedia article gives the same formula as `ln(2 L_sd / a) - gamma` **[read]** |
| Two forms agree | `ln(2 L_sd / a) = ln(l / a)` since `2 L_sd = l` | **[A]** |
| Weak size dependence | with `L_sd` = 1 um, `a` from 1 nm to 10 nm lowers D by 30% (the article); the formula gives **32.8%** | **[read]** and **[A]** |
| A value to compare with | `eta_m / eta` = 100, `h` = 5 nm, `eta` = 0.96 mPa s, 295 K, `a` = 5 nm gives `l` = 500 nm (the review: "about 500 nm") and **D = 2.72 um^2/s**; the review quotes 2.5 um^2/s for a KvAP-sized inclusion. 9% apart. **This compares the formula with the same model's quoted value, not with an experiment.** | **[A]** against **[read]** |
| Petrov-Schwille interpolation (valid between the small- and large-inclusion limits) | formula with `eps = a / L_sd`, constants `c1` = 0.73761, `b1` = 2.74819, `c2` = 0.52119 and **`b2` = 0.61465 as printed in the 2008 paper, 0.51465 as the Wikipedia article gives it after a correction** | **[read]** both; the 2012 correction itself not read. The two `b2` give the same reduced mobility to 5 digits for eps up to 1 and differ by 3% at eps = 10 **[A]**, so for a protein (eps well under 1) the choice does not matter. Not implemented in D1 |
| 2D mean-square displacement | `<r^2> = 4 D t` | used by Casuso et al. and by every source here; the HS-AFM porin paper does not write it out **[read]** |
| Experiment: detection limit | D = 0.025 um^2/s at a 100 ms frame in a 100 nm field (Casuso et al. 2009). `sqrt(4 D t)` = 100.0 nm **[A]** | **[read]** |
| Experiment: proteins on mica by HS-AFM | porin D mostly below 0.001 um^2/s, over three orders of magnitude, log-normal; fit of the first third of each trajectory; 128 x 128 pixels over 200 x 200 nm (1.56 nm per pixel), 0.2 to 0.5 s per frame, tip radius under 10 nm; the porin appears as a 2.9 +- 0.4 nm bump (a 1.5 nm nanotube, 5.5 nm long). Their molecular dynamics (unsupported bilayer) gave 3.1 to 21.7 um^2/s, three to four orders higher, **which they say cannot be compared directly** | **[read]** Sullivan et al., Sci. Rep. 2020, PMC7368039 |
| Experiment: other proteins | free cell membranes 0.005 to 0.35 um^2/s; rhodopsin 0.4; ATP synthase rotors in POPC on mica 1e-5; fibronectin 1e-4; Casuso quotes CFTR 0.005, GPI-anchored 0.0035 to 0.08, transferrin receptor 0.005, macrophage glycoproteins 0.003 | **[read]** (both papers, as quoted there; the primary measurements not read) |
| Instrument in the experiments | Casuso: a 0.1 to 0.2 N/m lever of 0.8 to 1.2 MHz and **Q about 2 in solution**, forces about 50 pN, 100 ms per frame, 200 x 200 pixels over 66 nm; Sullivan: free amplitude about 2 nm, setpoint 90%, a 0.15 N/m lever | **[read]** both. The twin's liquid lever (0.15 N/m, Q 3, 0.5 MHz, 2 nm, 90%) is of this kind |
| Not obtained | the 2017 porin HS-AFM paper (PMC5483525, an access check blocked the read); the Springer page of the 2020 paper (login), read through PMC instead | **[unknown]** |

## The first result is a limit, computed before any code

A molecule diffusing in two dimensions moves by a root-mean-square `sqrt(4 D dt)` in one frame `dt` **[A]**, for the frame times the twin reaches (nm):

| D (um^2/s) | 40 ms | 100 ms | 200 ms | 500 ms | 645 ms |
|---|---|---|---|---|---|
| 1 | 400 | 632 | 894 | 1,414 | 1,606 |
| 0.1 | 126 | 200 | 283 | 447 | 508 |
| 0.025 | 63 | **100** | 141 | 224 | 254 |
| 0.01 | 40 | 63 | 89 | 141 | 161 |
| 0.001 | 13 | 20 | 28 | 45 | 51 |
| 0.0001 | 4.0 | 6.3 | 8.9 | 14 | 16 |

**Two criteria, not one:**

* **It stays in the frame:** the displacement per frame is under the field. Casuso's own limit: 0.025 um^2/s at 100 ms for a 100 nm field **[read]**. The twin tests `sqrt(4 D dt) < field`.
* **It can be linked from frame to frame among others:** the displacement per frame is under **half the nearest-neighbour distance**, a standard rule in particle tracking **[recalled: from the single-particle-tracking literature (Crocker and Grier), not read here]**. This depends on density: at one particle per 50 nm square it asks for under 25 nm, which `D` = 0.001 um^2/s meets at 100 ms (20 nm) and does not at 200 ms (28 nm). The porin work tracked its particles with TrackMate and **by hand for the fast ones** **[read]**, which is this criterion failing.

**What it says about the biology:** a free membrane protein (D of about 1 um^2/s in the formula's range) moves 630 nm per 100 ms frame, over six times the field of Casuso's experiment, and cannot be followed. What is followed is hindered: mica-supported (D below 0.001), tethered, crystal-edge. **This agrees with Sullivan, who measured exactly that range.**

## What viscosity does, and does not, do

**To the sample.** With the formula above, at 25 degrees C (`kT` = 4.11e-21 J), bulk viscosity 0.89 mPa s **[A]**:

| `eta_m h` (Pa s m) | a = 1 nm | a = 2.5 nm | a = 5 nm |
|---|---|---|---|
| 3e-10 | 5.7 | 4.7 | 4.0 |
| 1e-9 | 2.1 | 1.8 | 1.6 |
| 3e-9 | 0.8 | 0.7 | 0.65 |

(um^2/s.) The `eta_m h` are chosen to land D near the range of the formula's experiments; they are **[unknown]**, not read from a measurement (the review gives only `eta_m / eta` of about 100 and `h` of 4 to 5 nm).

* **Bulk viscosity barely slows a membrane protein by this formula:** from 0.89 to 6 mPa s (a glycerol or sucrose mixture; the 6 is **[recalled]**) D falls from 1.8 to 1.2 um^2/s **[A]**. If the experiments' 1/a law holds instead, the bulk matters more (the Stokes-like regime); the sources disagree. What slows a membrane protein by orders of magnitude, in the measurements read, is **the support and the lipid**: mica, and more DMPC (a higher-melting lipid, the paper's explanation: a more viscous bilayer).
* **To the instrument.** For a conventional submerged cantilever the quality factor always degrades with increasing viscosity (Burg, Sader and Manalis) **[snippet]**. The closed form (Sader's hydrodynamic function) was not obtained. Until it is read, the twin may assume `Q proportional to 1 / sqrt(eta)` between the inertial and viscous limits as a labelled placeholder **[unknown]**. Casuso's Q of about 2 in water for a 0.8 to 1.2 MHz lever is the check.

## The design: six layers, each with its acceptance written first

**D1 (#77). Diffusion with viscosity, and the tracking criteria.** Particles that move by a random walk with a stated `D` (or `D` from Saffman-Delbrueck), on a stated pixel scale: **64 pixels over 100 nm (1.5625 nm per pixel)**, which is Sullivan's pixel size and inside Casuso's field. The twin asks the surface for its height at every sample, so the walk must be evaluable at any time with no state: a sum of sinusoids with fixed random phases, amplitudes `a_k^2 = 4 D ln(r) / (pi w_k)` per axis on log-spaced frequencies `w_k` (ratio `r`), derived so the increment variance is `2 D tau` per axis for `tau` within the band (`<(x(t+tau) - x(t))^2> = sum a_k^2 (1 - cos w_k tau)`, equal to `(2/pi) integral S(w)(1 - cos w tau) dw` with `S = 2 D / w^2`, which is `2 D tau`).
*Acceptance:* the mean-square displacement is `4 D tau` within 35% for lags from 10 ms to 2 s (an ensemble of a few particles and many start times: a wide tolerance because the ensemble is small); Saffman-Delbrueck reproduces the cross-checks above (2.72 um^2/s; the 32.8% size dependence); the two criteria are tested functions that reproduce the table above and Casuso's 0.025 at 100 ms; a movie at three frame rates.

**D2 (#78). The instrument in a viscous fluid.** A viscosity input that sets the lever's Q (placeholder above) and a drag on the lever while it scans.
*Acceptance:* the tune finds the resonance at the Q the law gives, from water to a glycerol mixture, and refuses with a tag when Q falls below what the sweep can resolve (HS3 found Q 100 needed a longer settle; a Q near 1 has no resonance to find); a lever of Casuso's kind (Q about 2) reproduced; the law labelled an assumption in the output.

**D3 (#79). A lipid membrane as a sample.** A bilayer of 4 to 5 nm (Demery & Lacoste: "generally assumed to be of the order of 4 to 5 nm" **[read]**; Sullivan's bilayer 4.1 nm **[read]**), an Lo/Ld height difference (about 1 nm **[recalled]**), a hole, a bilayer patch whose edge advances; all soft (the S9.3 force and damage threshold apply).
*Acceptance:* a 4.5 nm bilayer edge imaged with the step SNR of `docs/spec.md` (20); a 1 nm domain detected or not at stated noise; a growing edge followed at the model's rate; the 100 pN threshold exceeded or not, stated.

**D4 (#80). Protein image formation.** The image is the sample dilated by a tip of stated radius. Apparent height, width and volume against the truth; a mass from the volume by the empirical calibration (Schneider et al.: molecular weight against AFM volume, correlation 0.994 for 38 to 900 kDa on mica **[snippet]**), against a 2016 Ultramicroscopy study arguing the method is unsuitable because broadening and force push the volume opposite ways **[snippet]**. A case to compare: Sullivan's porin, a 1.5 nm tube imaged as a 2.9 +- 0.4 nm bump with a tip under 10 nm **[read]**.
*Acceptance:* the twin quantifies the bias for a stated tip radius; a tip radius at which a 40 kDa monomer and a dimer can be told apart, or the statement that none exists.

**D5 (#81). Analysis in cancho on the twin's movies.** Detection, linking, the mean-square-displacement fit for `D`, counting of oligomers. The fit follows Sullivan: **the first third of each trajectory** **[read]**.
*Acceptance:* from a synthetic movie with known `D`, the fitted `D` within 30% when both criteria hold, a refusal with a tag when they do not, monomers and dimers counted right on a stated fraction. First real use needs an instrument (#69) and a sample (#44).

**D6 (#82). Force curves: elasticity, viscoelastic relaxation and bond kinetics.** A force curve is a slow Z ramp, approach then retract, with the deflection read from the optical lever the twin already has. What it determines:

* **Elasticity:** a Hertz fit of the approach for the modulus (Sneddon for a cone). Hertz assumes a purely elastic half-space; it is the first step, not the last **[snippet: the viscoelastic AFM literature, Soft Matter 2019 review; arXiv 1711.09024]**. The indentation is the Z travel less the lever's own deflection.
* **Viscoelastic dynamics:** the hysteresis between approach and retract is the evidence of a viscous part; Kelvin-Voigt does not describe stress relaxation and Maxwell does not describe creep, so the standard linear solid (or a Kelvin-Voigt-Maxwell form, validated on simulated indentation by Abuhattum et al. 2022) is used for **relaxation times** from a hold at fixed indentation **[snippet]**.
* **Hydrodynamic drag:** negligible at AFM speeds in water for a sharp tip: Stokes drag `6 pi eta a v` is **0.00017 pN** for a 10 nm tip at 1 um/s and **0.42 pN** for a 2.5 um colloidal sphere at 10 um/s **[A]**, far under the pN-to-nN forces of interest; a correction is for fast ramps and large probes.
* **Bond kinetics (dynamic force spectroscopy):** the most probable rupture force depends on the loading rate `r`: `F* = (kT / x_b) ln(r x_b / (k_off kT))` (Evans), linear in `ln r`; the slope gives the barrier distance `x_b`, the intercept the off-rate `k_off`. For `x_b` = 0.5 nm, `k_off` = 1/s: F* is 20, 39, 58 and 77 pN at `r` = 1e2, 1e3, 1e4, 1e5 pN/s **[A]**. Its limits: a fixed barrier position (deviations at wide loading-rate ranges; Dudko, Hummer and Szabo invert the lifetime from the rupture-force histograms; Bullerjahn, Sturm and Kroy give closed forms for slow and fast loading) **[snippet]**.

*Acceptance:* from synthetic noisy curves with known parameters, the modulus, the relaxation time, `x_b` and `k_off` recovered within stated errors; a refusal with a tag when a curve is too short or too noisy to fit; a comparison with published values for a named system (a supported bilayer's breakthrough force; a soft sample's modulus), **with the sources read in full text**, not snippets. **This layer needs a contact model the twin does not have** (the twin's tip-sample law is the linear amplitude law of tapping), so it is a new mode and a new design, not an extension of D1.

## What D1 found (twin, 2026-11-09; predictions, not measurements)

Issue #77. Built: `sim/membrane.cho` (Saffman-Delbrueck, the two tracking criteria, the stateless walk), `board.set_diffusion` (the three particles of the static sample diffuse; refreshed once per detector window), `scan_twin` arguments 27 = 2 (diffusing particles), 28 (the frame's start, ms), 29 (also print the true surface at mid-frame), 30 (D in units of 1e-5 um^2/s); the scan is 64 pixels over 100 nm (1.5625 nm per pixel). The board's float array grew from 48 to 64 slots in `scan_twin`.

**Checks, each a test (`tests/dynamics_test.cho`, `tests/board_test.cho`):**

| Check | Result |
|---|---|
| Saffman-Delbrueck with the review's parameters | 2.72 um^2/s against the review's quoted 2.5 (9% apart; the same model, not an experiment) |
| size dependence at `L_sd` = 1 um, 1 nm to 10 nm | 32.8% lower, against the article's "30%" |
| bulk viscosity 0.89 to 6 mPa s at `eta_m h` = 1e-9, a = 2.5 nm | D 1.81 to 1.18 um^2/s |
| outside validity (`a` above `L_sd`, non-positive input) | no coefficient (0), so the caller refuses |
| Casuso's limit | `sqrt(4 D dt)` at 0.025 um^2/s and 100 ms is 100.0 nm, their field |
| the walk's mean-square increment against `2 D tau` per axis, 12 walks, starts over 20 s | 0.98, 1.01, 0.97, 0.90 and **0.81** at tau = 10, 50, 200, 800 and 2,000 ms (per walk, at 2 s: 0.56 to 1.00) |

* **The walk under-diffuses at long lags by 10 to 19%** (0.8 s and 2 s), because its lowest frequency is 0.05 Hz; it is within 3% up to 0.2 s. The acceptance was 35%. A lower cutoff would fix it; not done.
* **A fault found by the board test:** the walk was not zero at t = 0 (each component started at its own random phase), so particles did not start where they were placed: about 50 nm off at D = 0.001 um^2/s, more than the particle spacing. Each component is now measured from its value at t = 0. The increments, which the mean-square displacement is made of, did not change.
* **The particles move as asked:** at D = 1e-5 um^2/s they moved 5 to 7 pixels in 2 s (the expected rms is about 5.7); at D = 1 um^2/s they are outside the 100 nm field by the middle of the first frame, which is the criterion above, seen in the twin's own image.

**End to end, through the twin's imaging path** (liquid lever, a scan every frame, particles found in the images, linked by the nearest assignment, D from `<r^2> / (4 dt)`; one run each, no repeat):

| Imager | Frame | Input D | Frame pairs used (lost) | Predicted rms displacement | D recovered |
|---|---|---|---|---|---|
| 10.3 frames/s (gains x3, ideal scanner) | 0.097 s | 3.0e-5 um^2/s | 25 (4 lost), 75 displacements | 3.4 nm | **2.70e-5 (0.90)** |
| 1.55 frames/s | 0.645 s | 3.0e-5 um^2/s | **3 (4 lost)**, 9 displacements | 8.8 nm | 1.58e-5 (0.53) |

* **The fast imager recovers D within 10%.** The statistical error of an estimate from 75 squared displacements is about 12% (relative `1 / sqrt(n)`), so 0.90 is within one standard error; it says the twin's imaging and the formula agree, not more.
* **The slow imager's 0.53 is not a result:** with 9 displacements the standard error is about a third, and 4 of its 7 pairs were lost (a particle left the field or merged), which biases the survivors towards the ones that moved less. I did not show that this is the whole cause.
* **A first attempt at D = 3e-4 um^2/s failed** (27 of 29 pairs lost): the particles started 20 to 30 nm from the frame's edge and left a 100 nm field within a few frames. That is the "stays in the frame" criterion, found the hard way, and why the run above uses a hindered coefficient.

**Compared with experiment, in what sense:** the twin's regime matches Sullivan's: D mostly below 0.001 um^2/s at 0.2 to 0.5 s per frame is at most a 45 nm displacement per frame in a 200 nm field, tracked by TrackMate and by hand for the fast ones **[read]**. The twin reproduces Casuso's detection limit because it is the same formula, **not as an independent result**. **No experimental result has been reproduced by the twin.** What would be one: a measured D of a named protein on a named support, imaged at a stated frame rate, run through the twin at the same settings; that needs data we do not have.

**Not done from the acceptance:** the movie at three frame rates (the table above is the measurement it would illustrate); the Petrov-Schwille interpolation (not needed for `a` of a few nm and `L_sd` of 0.1 to 10 um); anomalous diffusion, obstacles, particle-particle interaction, reflecting edges (a particle walks out of the field and stays out).

## What D6 found, first slice: the port from nanoindent (2026-11-09; predictions, not measurements)

Issue #82. The instrument's software stays in cancho, and the force-curve analysis already exists as validated Python in `nanoindent` (github.com/alpibrusl/afm-finite-elements, commit c04820a; the repository beside this one). So this slice is a **port, with nanoindent as the oracle** (not a dependency): `sim/forcecurve.cho` and `tests/forcecurve_test.cho`, whose "oracle" numbers were computed by nanoindent's Python on the same inputs and recorded with its commit.

**Ported:** the contact laws (Hertz; Dimitriadis 2002 bonded, general nu; Garcia & Garcia 2018; Chadwick 2002; Das/Connell 2010 for a fluid bilayer; Sneddon cone), the calibration of a raw curve (baseline from the first 10%, noise, contact point as the first sustained rise above max(5 sigma, 1% of the range), force and indentation with the cantilever-compliance correction), the closed-form modulus fit with the 40-point contact-point scan, and the supported-bilayer analysis of one curve (breakthrough force, step height, modulus per model, area compressibility). **Not ported:** the instrument file readers (JPK, Bruker, Asylum), the free-film Dimitriadis form (published for nu = 1/2 only), force maps, the finite-element solver, the viscoelastic and video modules. A curve is passed in acquisition order as one monotonic segment (the Python sorts it).

**Parity with the oracle** (ten tests pass; relative tolerance 1e-9 for the laws, 1e-6 for the pipelines):

| Quantity | Oracle | cancho |
|---|---|---|
| Hertz, Dimitriadis, Garcia, Chadwick, Connell, Sneddon at four indentations (R = 17 nm, E = 130 MPa, nu = 0.3, h = 7 nm) | analytics.py | equal to 1e-9 |
| modulus from a synthetic raw curve (E = 130, Dimitriadis, no noise, baseline 2 nm): Hertz / Dimitriadis / Garcia / Chadwick | 398.16 / 133.01 / 64.07 / 172.66 MPa | equal to 1e-6, contact points too |
| a deterministic 4.5 nm bilayer curve: breakthrough force, step height, four moduli, area compressibility | 5,088.3 pN, 4.5 nm, 118.3 / 10.99 / 5.92 / 21.18 MPa, 211.26 mN/m | equal to 1e-6 |

* **A discrepancy the oracle caught:** the first port gave a different area compressibility (18.8 against 211.3 mN/m). nanoindent, with no capacitive height channel, **falls back to the piezo Z** to compute the contact-to-substrate height (its definition A) and then uses that height, not the film thickness given, as the bilayer's 2d in the Das/Connell fit. I had left that out, believing it needed a capacitive channel. It is now ported and tested. **That fallback is a weak point of the oracle itself:** the piezo Z includes the cantilever's deflection, so on the test curve (a bilayer built 4.5 nm thick) it returns **7.77 nm**, and the area compressibility is fitted with a thickness that is wrong by 70%. Reproduced for parity, not endorsed; a measured-height channel, or the film thickness, should be preferred.
* **What the pipeline's accuracy is, on noiseless data:** the right model (Dimitriadis, for a curve built with it) recovers 133.0 MPa for a true 130 (2.3% high), because the contact point is found from the deflection by a threshold; naive Hertz reads **398 MPa, three times too stiff**, and the other two finite-thickness models read 64 and 173. The same fit, on real data, would also carry the cantilever calibration, the tip radius and the contact-point noise, none of which is in this test.
* **Refusals (each tagged, none traps):** 1 too few points; 2 not one monotonic segment; 3 no contact found; 4 no breakthrough (no force drop of the minimum size); 5 too few points in the elastic branch; 6 no valid fit.

**Compared with an experiment:** nanoindent's README reports, on **a real gel-phase supported-bilayer map of 400 curves**, a breakthrough force of about 22 nN, a height of about 2.6 nm, an apparent Hertz modulus of about 48 MPa and a bottom-effect-corrected 4 to 14 MPa. **The curves themselves are not in either repository, so this port was not run on them**; the comparison is the reported summary, and the port reproduces nanoindent's code, not its data. The README's lipid atlas (LipidHub) predictions are tagged heuristic and headgroup-blind there.

**Dynamic force spectroscopy is now implemented** (`sim/dfs.cho`, `tests/dfs_test.cho`, eight tests; see "What reading the papers added"): Bell's law, the Bell-Evans peak (derived and checked against the maximum of the rupture-force density), the Dudko-Hummer-Szabo lifetime, and the fit that recovers the barrier distance and the off-rate from the most probable force against the loading rate, refusing with tags (1 too few points, 2 the force does not rise with the rate, 3 the rates span under a decade). It reproduces its own formulas and the DHS Bell limit; **it has not been run on any rupture data**, and the loading rates of ddFLN4 in the tests ignore the linker's stiffness that DHS correct for. **Still design only: viscoelastic relaxation.** The source for the standard linear solid (the RSC review: HTTP 403) was not in the downloaded folder; the arXiv paper on dynamic AFM viscoelasticity that was read uses a different model (a moving-surface piecewise-linear one) and gives no Kelvin-Voigt or Zener equations.

## What D5 found, first slice: the tracking port from nanoindent (2026-11-09; predictions, not measurements)

Issue #81. Same method as D6: a port with nanoindent as the oracle (`nanoindent.video`, commit c04820a): `sim/tracking.cho`, `tests/tracking_test.cho`.

**Ported:** particle detection (a threshold of mean + standard deviation of the frame, 4-connected components, the intensity-weighted centroid of each component of at least `min_size` pixels), greedy nearest-neighbour linking with a largest per-frame displacement, the mean-square displacement at lags 1 to 4 frames and its straight-line fit (`MSD = 4 D t`), and the ensemble mean over tracks of at least five points. **Not ported:** the file readers (.asd, TIFF, JPK), drift correction (an FFT phase correlation), the height time series and event detection, playback. **Streaming by design:** a cancho region holds 64 KiB, so a movie does not fit; a frame is pushed as it arrives and only the tracks are kept, which is also how a live instrument would run the analysis.

**New, not in nanoindent:** `tracking.check` applies the two criteria of this note to an estimate (the particles stay in the field; the displacement per frame is under half the nearest-neighbour distance) and refuses with a tag: 3 they move farther than the field in a frame, 4 they move more than half the nearest-neighbour distance. Other tags: 1 no track long enough, 2 the track store overflowed.

**Parity with the oracle** (five tests):

| Check | Oracle | cancho |
|---|---|---|
| a deterministic movie of four particles, 40 frames: first-frame centroids and their raster order | (20, 20), (30, 50), (50, 25), (50, 50) px | equal to 1e-4 |
| tracks and per-track D | 4 tracks of 40 points; 30.564, 29.772, 28.035, 30.515 nm^2/s | equal to 1e-6 |
| mean D | 29.7213 nm^2/s | equal to 1e-6 |
| the D1 movie (six particles diffusing with D = 30 nm^2/s, 60 frames of 0.0968 s) | 30.36 nm^2/s from 7 tracks of at least 5 points | within 0.01 |

* **D recovered from the D1 movie: 30.36 against 30 put in (1.2% high)**, by both the oracle and the port. One movie, one realisation: the statistical error of such an estimate is of the order of 10 to 15%, so this says the chain (walk, rendering, detection, linking, fit) is consistent, not that it is accurate to 1%. The acceptance was 30%.
* **Six particles gave eleven tracks** (lengths 60, 50, 60, 11, 60, 60, 36 and four of one point): nanoindent's linking ends a track at a missed detection and starts another, and tracks under five points are not used. Why the detections were missed was not investigated. Seven tracks were used.
* **The oracle's own weakness, from its README:** on its synthetic movie it recovers D = 170 against 200 nm^2/s, and says centroid tracking of overlapping blobs biases D low. The port inherits that, and the new check does not catch overlap (it catches speed, not blob size).
* **Refusals are tested with tags**, not by tracking real failure: `check` refuses D = 0.1 um^2/s at 0.1 s in a 128 nm field (3), and D = 0.005 um^2/s against a 40 nm nearest-neighbour distance (4); and trusts the same D for a single particle, where linking is not in question.

**Experimental data found for the lipid side (read in full text, not implemented):** Khadka, Timsina, Rowe, O'Dell, Mainali, *Mechanical properties of the high cholesterol-containing membrane: An AFM study*, BBA Biomembranes 1863:183625 (2021), PMC8154731. **This is not Redondo-Morata's work** (a search had listed it next to hers). Supported POPC/cholesterol bilayers on mica, room temperature, a DNP-S10 lever of 0.35 N/m, a tip of about 32 nm radius measured on titanium, 200 nm/s, 10 x 10 force curves per 5 x 5 um region:

| Chol/POPC (mol%) | breakthrough force (nN) | K_A (mN/m) | bilayer thickness by imaging (nm) |
|---|---|---|---|
| 0 | 5.26 +- 0.28 | 272 +- 69 | 6.24 +- 0.13 |
| 1 (50) | 9.25 +- 0.57 | 524 +- 104 | 6.64 +- 0.19 |
| 1.5 (60) | 4.30 +- 0.60 and 11.13 +- 0.77 (two punctures) | 631 +- 116 | 6.71 +- 0.23 |
| 2.5 (about 71, my arithmetic) | 4.37 +- 0.24 and 11.55 +- 0.95 | 492 +- 76 | 7.68 +- 0.44 |
| 3.0 (75) | 6.34 +- 1.20 and 12.74 +- 1.23 | 393 +- 138 | 8.81 +- 0.25 |

Their model for K_A is the same law as the Das/Connell form ported in D6 (`F = pi K_A R ((D - s) / s)^2` with `s` the tip-mica separation and `D` the bilayer plus water-layer thickness, which equals `pi K_A R z0^2 / (D - z0)^2` for `z0 = D - s`), fitted over the elastic region up to 80% of the breakthrough force, for the first puncture only. That makes this table a **target for D3 and D6** (a twin that produces bilayers whose analysis returns these K_A and breakthrough forces), and an experiment the ported `slb_curve` could be run against if the curves were available. Not in the paper: Young's modulus, a loading rate in N/s, any temperature dependence. Their thickness from force curves includes the water layer (5.8 to 10.6 nm), unlike the imaging one.

**Not obtained:** Redondo-Morata's own papers. The HAL record (hal-02198128) and the Langmuir 2012 article were blocked or not retrievable; nothing of hers is in this note as a result.

## What reading the papers added (2026-11-09; the PDFs were downloaded into a folder outside this repository and are not committed)

Nine PDFs were read after the search-snippet and blocked-fetch rounds above. **None is by Redondo-Morata**: the HAL record (`hal-02198128`) is Et-Thakafy, Guyomarc'h and Lopez (INRAE), and the PMC one was Khadka et al. Of the nine, these were read in the parts that matter here (some only their first pages or abstract, as stated); Bullerjahn et al. (Nat. Commun. 2014) and Bjornham & Andersson (arXiv 1607.00209) were read afterwards, in their abstract, introduction and theory sections (see the next section).

* **The Saffman-Delbrueck formula is the same in four primary sources** once the notation is matched: `D = kT / (4 pi eta_m h) [ln(eta_m h / (eta a)) - gamma]` (Gambin Eq. 1 and Weiss Eq. 1 in their own symbols; Petrov & Schwille as `ln(2 / eps) - gamma` with `eps = a / L_sd`; Demery & Lacoste Eq. 1). `sim/membrane.cho` implements exactly this.
* **Its validity is stricter than I had written.** Petrov & Schwille show Saffman-Delbrueck is a good approximation only for `eps = a / L_sd` below about 0.1; against their fit of the exact (Hughes-Pailthorpe-White) model it is 0.3% low at 0.01, 4.4% at 0.1 and 35% at 0.5 **[A, from their interpolation formula]**. Their own example: for a 100 nm inclusion in a membrane of 4e-10 Pa s m surface viscosity in water, eps is 0.5 and Saffman-Delbrueck would give a radius 1.5 times too small. I had taken `a < L_sd` from the Wikipedia article. **`sd_valid` now stops at 0.1 L_sd** (tested).
* **The size-dependence dispute is real, and now documented from the papers.** Gambin et al. measured peptides and bacteriorhodopsin in bilayers of tunable thickness (nonionic surfactant and dodecane, and giant vesicles) and report that D is "strongly linked to the protein dimensions" with a heuristic Stokes-like `D ~ 1/R`; bacteriorhodopsin (`R` = 18 A) diffused 3.8 times slower than a single helix (D = 0.08 against 0.31 um^2/s). Weiss et al., on black lipid membranes with two-focus fluorescence correlation spectroscopy, conclude that the Saffman-Delbrueck model "is able to describe protein diffusion extremely well and a Stokes-Einstein-like behavior can be ruled out". They used different membranes (free-standing lipid bilayers against vesicles and swollen sponge phases); **I cannot settle it from these two papers, and the twin keeps the size dependence as a choice.**
* **Force spectroscopy theory, read:** Dudko, Hummer & Szabo (PNAS 105:15755) state Bell's law `tau(F) = tau0 exp(-beta F x)`, that the most probable rupture force is linear in the logarithm of the loading rate, that Bell's formula is a lower bound on the lifetime, and give their Kramers-theory generalisation (Eq. 5, with `nu` = 1/2 or 2/3; `nu` = 1 is Bell's formula). The explicit Evans peak formula is not printed there; it is derived in `sim/dfs.cho` and checked against the numerical maximum of the rupture-force density. Named systems with fitted parameters: DNA hairpin unzipping in a nanopore (`tau0` = 14.3 s, `dG` = 11.9 kT for `nu` = 1/2) and the unfolding of the filamin domain ddFLN4 by AFM at 200 to 4,000 nm/s (`tau0` = 120 s, `x` = 1.1 nm, `dG` = 15.0 kT for `nu` = 1/2, 14.7 kT for `nu` = 2/3; Schlierf & Rief's own Bell fit gave 120 s, 1.1 nm and about 19 kT).
* **A real Young's-modulus experiment, with its method** (Et-Thakafy, Guyomarc'h & Lopez 2019): supported bilayers of milk polar lipids on mica, classical Hertz `F = (4/3) E delta^1.5 sqrt(R) / (1 - nu^2)` with a tip radius of 20 nm and `nu` = 0.5, an MLCT lever of about 0.03 N/m, force up to 200 pN at 2 um/s. At 20 C, **gel-phase domains 10 +- 4 MPa and the surrounding fluid phase 6 +- 1 MPa** (a difference of 4.6 +- 0.9 MPa within one image, the gel domain 0.77 +- 0.07 nm taller); at 50 C, above the melting of milk sphingomyelin (34.3 C) the membrane is homogeneous at 4 +- 2 MPa; with 50:50 mol% cholesterol the liquid-ordered phase is a few MPa at 20 and 50 C. They cite 19 and 28 MPa for the fluid and gel phase of a DOPC/DPPC bilayer (Picas et al.) and note that absolute values depend on the probe and the contact model.
* **What the ported analysis says about that experiment, as a model and not a verdict** (`tests/forcecurve_test.cho`, oracle: nanoindent's Dimitriadis and Hertz on the same grid): if such a bilayer behaved as an elastic film **bonded to a rigid substrate** (Dimitriadis 2002), a half-space Hertz fit to 200 pN would **over-read its modulus by 3 to 7 times**: a 4.5 nm film of 2 MPa reads 10.3 MPa; the paper's 6 MPa (fluid) corresponds to a film of 0.86 MPa and its 10 MPa (gel) to 1.91 MPa (1.37 and 2.88 MPa for a 6 nm film). The film model is a poor description of a hydrated bilayer on a water layer, so this says what the correction *would* be, not that the published values are wrong; it agrees in direction with nanoindent's own real gel-phase map (apparent Hertz 48 MPa against 4 to 14 MPa corrected). It also widens the contrast between phases (gel over fluid 1.7 as read, 2.2 corrected).
* **HS-AFM diffusion of carbon-nanotube porins** (Zhang, Tunuguntla, Choi & Noy 2017): HS-AFM in supported lipid bilayers on mica shows "directed" diffusion, a log-normal distribution of coefficients, and values "roughly 10 times lower than the values obtained for membrane proteins in previous studies", for DOPC:DPPC 70:30 (DPPC's Tm is 41 C, DOPC's -17 C), with the authors suggesting the added order slows diffusion; (read: the introduction, conclusion and references; not the results section in detail).
* **Not changed by these papers:** the D1 tracking criteria, which come from Casuso et al. and Sullivan et al. read earlier.

## What the twin bilayer and the live analysis found (2026-11-09; predictions, not measurements)

**Two more papers read**, in their first pages: Bjornham & Andersson (2016) give the Evans peak force as `F* = (kT / x_b) ln(r x_b / (k_off kT))` (their Eq. 3), which is what `sim/dfs.cho` derived and checked, and restrict the linear theory to a constant loading rate, extending it to nonlinear loading (a polymer tether, a worm-like chain) with Monte Carlo checks. Bullerjahn, Sturm & Kroy (2014) give the same rupture-force density (their Eq. 1), say the Bell model keeps the reaction distance fixed under force, and derive closed forms for slow and fast loading; the deterministic regime begins at forces above `2 E / x_b`. Neither was read past the theory section.

**Built:** `sim/bilayer.cho` (the twin's supported bilayer as a force-curve sample), `sim/livecurve.cho` (the analysis while the curve is acquired), `host/curve_twin.cho` (the producer), `ui/curve.cui`, `curve.html`, `curve.js` (the live page), and, in `sim/forcecurve.cho`, `fit_modulus_from_contact` and `slb_curve_nb`.

**The twin's bilayer.** A quasi-static contact (the deflection solves `k d = F(delta)`, `delta = travel - d`), a sample law (a half-space, or a film bonded to a substrate), and a thermally activated breakthrough with the Dudko-Hummer-Szabo lifetime (`nu` = 2/3): the hazard `1 / tau(F)` is integrated in time and the bilayer ruptures when it passes `-ln U` (U a fixed hash of the seed), so a seed always gives the same curve and many seeds give the theoretical distribution. After rupture the tip falls through `t_step` = 4 nm and meets a stiff wall. **Stand-in parameters, all free:** `dG` = 20 kT; per phase, the barrier distance `x` and zero-force lifetime `tau0` that put the most probable breakthrough force at 70,000 pN/s (a 0.35 N/m lever at 200 nm/s) at 5.3 nN (fluid: Khadka et al. give 5.26 nN for POPC under those conditions), 13.25 nN (gel: a stand-in 2.5 times the fluid) and 4.0 nN (melted: a stand-in). The distances come out at 0.006 to 0.02 nm and the lifetimes at 3e4 to 1e5 s: **no structural meaning**, the whole bilayer breaking, not a bond. The moduli are Et-Thakafy et al.'s apparent Hertz values (10 gel, 6 fluid, 4 melted MPa, at 20 C and above the 34.3 C melting of milk sphingomyelin) for the half-space law, and for the bonded-film law (4.5 nm) the film moduli that read as those under a Hertz fit with the contact fixed (1.906, 0.858, 0.445 MPa).

**Checked (`tests/bilayer_test.cho`, 7 tests):**

| Check | Result |
|---|---|
| a seed gives the same curve; another seed another one | yes |
| the whole-curve analysis finds the breakthrough force the generator recorded | equal to 1e-6; the step is 3.5 to 6.5 nm (the 4 nm film plus the wall's give under the lever's stored force) |
| half-space law read back under the lever of Et-Thakafy et al. (0.03 N/m, 20 nm tip, to 200 pN) | **6.0, 9.8 and 4.0 MPa for 6, 10 and 4 built**: within 2% |
| the bonded-film law read back by the same pipeline | 9.5 to 10, 11.5 to 12, 7.5 to 8 MPa, **not** the 6, 10 and 4 of a Hertz fit with the contact fixed at the truth: for a curve that stiffens faster than Hertz the scan of the contact point picks a later contact and a larger modulus, so the reading depends on the analysis choice by up to 2 times |
| median breakthrough force of 41 seeds, fluid, at five speeds (loading rates k v of 7,000 to 700,000 pN/s) | from 4.0 to 6.4 nN, within about 8% of the numerical median of the same hazard at a constant loading rate (4.22, 4.66, 5.18, 5.69, 6.34 nN); slightly below it at low rates, as expected when the sample yields under the lever |
| the Bell-Evans fit of `sim/dfs.cho` on those medians | an effective barrier distance of **0.009 to 0.010 nm**, against 0.0096 from the constant-rate theory and the model's own `x` of 0.0155 nm: the fit gives an effective distance, smaller than the Kramers one, and the nonlinear loading changes it little here |

**A limitation of nanoindent's whole-curve analysis, found with these curves.** Its baseline is the first 30% of the curve. The twin's approach is about 25% of a curve that ends at the breakthrough, so that window holds the start of the indentation, the noise estimate and with it the contact threshold grow, the contact point comes late and the modulus is over-read: **a gel built at 10 MPa read 150 MPa or more.** With the baseline given as the 40 points that are surely before contact (`slb_curve_nb`) it reads 15 to 18 MPa. The remaining 50 to 80% (the fluid reads 9 to 11 for 6 built) is consistent with the 0.3 nm floor of the contact threshold, 105 pN for this 0.35 N/m lever against 9 pN for the 0.03 N/m lever whose curves read within 2%; that was not isolated. A second limitation, same source: the contact-point scan of `fit_modulus` assumes the curve starts near contact (it ran 0.5 to 2 MPa for a 6 MPa half-space on a curve with 10 nm of approach); `fit_modulus_from_contact` starts it at the detected contact. Both are new functions; the ported ones keep parity with the oracle.

**The live analysis** (`sim/livecurve.cho`): one point at a time, it finds the baseline (a fixed number of points), the contact (three points in a row above the threshold), the force and indentation of each point, the modulus fit by each model over the points so far (the same closed-form sums, updated incrementally), the largest force, and the breakthrough (the first single-step drop of at least 400 pN). **Parity with the whole-curve analysis, on the oracle's bilayer curve:** the contact point, the breakthrough index and force (5,088.3 pN) and all four running modulus fits at the breakthrough are equal to 1e-6, and `finish` returns nanoindent's numbers. It differs from the batch analysis in three stated ways (the baseline window is a count, the breakthrough is the first drop not the largest, the film thickness must be given). The running modulus **starts wild** (860 to 1,900 MPa from the first three points in contact) and settles within about 20 points; that is what the page shows.

**The page, seen working in a browser** (a gel session of four curves, paced at 0.12 s a line): the force sits at the baseline, rises as the tip indents, the status line changes to "broken through the bilayer" with the breakthrough force (13,603 pN for curve 4), the indentation jumps from 25 to 33 nm, and the per-curve charts fill in (breakthrough 12.0 and 11.7 nN, Hertz modulus 16.8 and 16.9 MPa for a 10 MPa gel: the over-reading above). **Running it found two bugs**, both fixed and tested: the previous curve's largest force and running sums leaked into the next (the page showed "largest force 4,688 pN" while the force was 200), and the whole-curve analysis at the end of the curve used the oracle's 30% baseline while the live fit used a clean one, so the page showed two different moduli.

**Not done, and not claimed:** no measured curve was run through any of this; the rupture kinetics are free stand-ins; the temperature enters only as a switch between three phases (a transition width, and domains of gel in fluid as in the real membranes, are not modelled); the loading-rate effect of the nonlinear sample was tested only through the fit above, not against Bjornham & Andersson's nonlinear theory; Redondo-Morata's papers are not in this note (they are to be added).

## Force-volume map of a mixed gel and fluid bilayer (design written 2026-11-10, before the code)

**Ask.** Image scanning and curve analysis side by side. **What is honest to build:** one experiment on one sample, a force-volume map: the tip is ramped into the bilayer at every pixel of a grid, each curve is analysed as it is acquired (`sim/livecurve.cho`), and the maps (contact-point height, Hertz modulus, breakthrough force) fill in pixel by pixel next to the live curve of the pixel being measured. It is NOT the tapping-mode `scan_twin` image: that program and the curve twin do not share a sample, and showing a tapping image beside curves from a different sample would imply an agreement nobody checked.

**Sample** (`sim/domains.cho`): a 32 by 32 grid over 200 nm (6.25 nm a pixel), fluid matrix with gel disks (the mixed-phase case of Et-Thakafy et al. 2019 at 20 C). Each pixel is gel if its centre is inside a disk, else fluid; the edge is one pixel wide, not a measured line tension. The gel surface stands `dz` = 1.0 nm higher than the fluid: a STAND-IN (not taken from a paper that has been read; the maps show it only so that the contact-point image has something to find).

**Acceptance, written first:** (1) the analysis recovers the phase of the pixel: a gel pixel reads a larger modulus and a larger breakthrough force than a fluid pixel, for every pixel of the map; (2) the contact-point image shows the 1.0 nm step (CORRECTED after the run: it reads 1.42 nm, see the finding below; the first version of this line claimed the step would be reproduced to within the noise); (3) a pixel is classified by a threshold on the modulus and the classification matches the true map except at most on the disk edge; (4) the whole map is reproducible (fixed seeds); (5) every refused curve is counted and tagged, none is silently dropped.

**Built:** `sim/domains.cho`, `host/fv_twin.cho`, `tests/domains_test.cho`, `tests/fvmap.sh`.

**Found** (32 by 32 = 1,024 curves, law 0, Khadka lever; predictions, not measurements; `tests/fvmap.sh`):

* Cost: a whole 32 by 32 map runs in about a second (16 by 16: 0.08 s). The curves are not the limit.
* No curve was refused (0 of 1,024); 339 pixels are gel, 685 fluid. Two runs are identical.
* The breakthrough force separates the phases with no error: the threshold 8 nN misclassifies 0 pixels (medians 4.88 nN fluid, 12.55 nN gel; these medians are the stand-in kinetics reading back, not a finding about membranes). The modulus misclassifies 1 pixel at 14 MPa: a fluid pixel that broke through at 0.44 nN, far below the rest (the thermal hazard's early tail), so the fit was made on too short a ramp and read 23.5 MPa. That pixel is a real feature of the stochastic model, not a bug; it is why the breakthrough force is the better classifier here.
* The modulus is the closed-form fit of the 32 nm tip of the Khadka lever on a half-space: 11.4 MPa fluid and 16.8 MPa gel, not the 6 and 10 MPa the stand-in table was set to for the 20 nm tip of Et-Thakafy et al. What matters on the map is the ratio (1.47; 1.67 put in).
* **The contact-point image does not give the 1.0 nm step; it gives 1.42 nm.** The analysis finds contact when the deflection is above the threshold (the 0.3 nm floor), and a softer pixel must be pushed further to reach it, so the fluid contact is found about 1.86 nm late and the gel's 0.43 nm late. A topography built from contact points mixes the real height with the stiffness. That is a known confound of force-volume imaging, and the twin shows it.
* **Histograms** (`sim/histogram.cho`, printed by `host/fv_twin.cho` as its last line, 32 bins, no value dropped; checked by `tests/fvmap.sh` and `tests/histogram_test.cho`): the breakthrough force is two separate peaks, fluid at 4.5 to 5.0 nN and gel at 13.0 to 13.5 nN (the gel one wide, about 8 to 15 nN), and the modulus is two narrow peaks at about 11 and 17 MPa; the counts add up to the 1,024 pixels. The fluid peak is below the 5.3 nN its kinetics were set for at 70,000 pN/s; the likely cause is the loading being slower than k v as the sample yields (the nonlinear loading of the papers read), but that was not isolated. The fluid and gel colouring of the histograms is the twin's knowledge of the true phase, which a real map does not have.
* The map is a made-up pattern with a one-pixel edge; nothing here was compared with a measured map (nanoindent's 400-curve gel map is not in either repository).
## D7: nucleation and growth of objects, imaged at high speed (design written 2026-11-10, before any code)

**Ask.** An HS-AFM experiment where objects (bilayer patches, vesicles adsorbing and rupturing) appear over time: how are they analysed, and what does the twin say about what the analysis can recover? This section is a design; nothing here is built, and the analysis recipe is the standard one from general knowledge, not from papers read for this document (reading the HS-AFM vesicle literature is the first task of the slice, and this section is corrected in place by what it finds).

**The analysis, per movie:** flatten each frame; segment by height above the support; label connected objects; track them (`sim/tracking.cho`); per object measure height, footprint area and volume against time; call an event the first frame in which an object above a size threshold exists; then the **nucleation rate** is the number of events per area and time, the **waiting-time histogram** (time from the start to each first appearance) should be exponential for a single barrier at a constant rate, and **growth** is footprint area, or edge speed, against time.

**What the twin will model, slice 1 (patches only; no vesicles, no tip force):**

* Nuclei appear as a Poisson process of rate J (per um^2 per s) over an L by L field, uniform in space; each grows as a disc, radius r(t) = r0 + v (t - t0) at constant speed v, to a height h above the support. Times and places come from a fixed hash of the seed, as in `sim/membrane.cho`, so a movie is reproducible. STAND-IN values: none are taken from an experiment.
* The imaging: frame time Tf, pixel size, height noise sigma, and the analysis's thresholds (smallest visible radius r_min, smallest visible height).

**Closed forms the acceptance is written against** (stated before the code; each is to be verified by simulation, not assumed):

1. With no growth and no overlap, the number of events in a window T over area A = L^2 is Poisson with mean J A T, and the waiting times are exponential with mean 1/(J A). The estimate J_hat = N/(A T) has relative error 1/sqrt(N).
2. Detection lag: an object is first visible when r(t) = r_min, a time (r_min - r0)/v after birth, and is first seen at the next frame boundary, a further delay uniform on [0, Tf] (mean Tf/2). So the observed waiting-time histogram is the true exponential shifted by a constant (r_min - r0)/v + Tf/2 on average; fitting an exponential without the shift over-reads the mean waiting time, i.e. under-reads the rate when the window is short.
3. Crowding: when discs overlap they merge into one object, so counts fall below J A T. For constant J and v the covered fraction is the Kolmogorov-Johnson-Mehl-Avrami result in two dimensions, X(t) = 1 - exp(-pi J v^2 t^3 / 3). The analysis's undercount should follow X; rates must be read from the early frames, or corrected.
4. Objects below the threshold are missed and counted as missed: the report says how many were born and how many were seen.

**Acceptance, written first:** (a) at low coverage the recovered J is within 3 / sqrt(N) of the injected J; (b) the waiting-time histogram has the exponential's mean within the same bound, after the shift of (2) is removed; (c) the measured shift matches (2) to within one frame time; (d) the coverage at time t matches (3) within the Poisson scatter; (e) every refusal has a tag (no objects, field too crowded to separate objects, a frame time longer than the mean waiting time per field); (f) reproducible.

**Slice 2, after slice 1 is read and found sound:** an adsorbed vesicle as a spherical cap that ruptures into a flat disc, with the area and volume relations derived and checked in this document first; and the tip's force on a soft object (it flattens or bursts a vesicle), which needs a model of that force beyond the current force proxy and is therefore the largest unknown.

**Out of scope for slice 1:** vesicle fusion and budding, anything with a curvature energy, diffusion of the objects (D1 covers mobile particles), and any comparison with measured movies (none is available).

## What stays out of scope, and why

* **Real molecular dynamics, hydrodynamic interactions between molecules, crowding, and anything that depends on a force field.** The twin's particles are shapes that move.
* **The tip moving the sample.** In real HS-AFM the tip's force changes what is imaged. The twin's force is a proxy that follows the loop (S9.3, HS5). A model of it is a later design, and D6's contact model is its first step.
* **Anything about the optics in a viscous medium** (refractive index, the light path).

## Order of work, and why

D1 first: it is self-contained, testable against a closed-form result (`4 D tau`) and against published numbers, and it produces the criteria that tell which proteins can be imaged at all. D2 next, because it decides the frame rate in a given fluid. D3 and D4 each build a sample and an image-formation model. D5 needs D1 and D4. D6 is the largest and needs its own design of the contact model first.

## Sources

* Demery V, Lacoste D. *Mechanical factors affecting the mobility of membrane proteins*, arXiv 1810.09910 (HTML version) **[read]**.
* Saffman-Delbrueck model, Wikipedia, revision of 3 Oct 2025 (formula, validity, Petrov-Schwille constants, the size-dependence dispute) **[read]**.
* Casuso I, Kodera N, Le Grimellec C, Ando T, Scheuring S. Contact-mode high-resolution high-speed AFM movies of the purple membrane. Biophys J 97:1354 (2009), PMC2749746 **[read]**.
* Sullivan K, Zhang Y, Lopez AC, Lowe M, Noy A. Carbon nanotube porin diffusion in mixed composition supported lipid bilayers. Sci Rep 10:11908 (2020), PMC7368039 **[read]**.
* Gambin et al., *Lateral mobility of proteins in liquid membranes revisited*, PNAS 103:2098 (2006) and Weiss et al., *Quantifying the diffusion of membrane proteins and peptides in black lipid membranes with 2-focus FCS*, Biophys J 105:455 (2013): **read from the PDFs (first pages and abstracts; see "What reading the papers added")**.
* Petrov and Schwille, *Translational diffusion in lipid membranes beyond the Saffman-Delbrueck approximation*, Biophys J 94:L41 (2008): **read in full**; its 2012 correction (Biophys J 103:375): **not read**.
* Burg, Sader, Manalis PRL 2009; Sader and Burg J Fluid Mech 2010; Sader 1998 **[snippet; closed form not read]**.
* Viscoelastic AFM: Soft Matter 2019 review (pubs.rsc.org c9sm01020c), arXiv 1711.09024, PMC8931349, Abuhattum et al. iScience 2022 **[snippet]**. Dynamic force spectroscopy: Evans; Dudko, Hummer, Szabo (PMC2572921); Bullerjahn, Sturm, Kroy (PMC4124868) **[snippet]**.
* Schneider et al. 1998 and the 2016 Ultramicroscopy study on tip broadening **[snippet]**.
