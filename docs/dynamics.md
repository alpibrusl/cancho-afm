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

**The analysis, per movie:** flatten each frame; segment by height above the support; label connected objects; track them (`sim/tracking.cho`); per object measure height, footprint area and volume against time; call an event the first frame in which an object above a size threshold exists; then the **nucleation rate** is the number of events per area and time, the **waiting-time histogram** (time from the start to each first appearance) should be exponential for a single barrier at a constant rate (CORRECTED 2026-11-10, after reading Plunkett et al.: that holds for slice 1's model, where nuclei are born independently of each other; for bilayer formation from vesicles the literature argues the births are NOT independent, rupture depending on the density of adsorbed vesicles or on the edges of existing patches, so an exponential waiting time cannot be assumed there, and its absence is itself the signal; see slice 2 below), and **growth** is footprint area, or edge speed, against time.

**What the twin will model, slice 1 (patches only; no vesicles, no tip force):**

* Nuclei appear as a Poisson process of rate J (per um^2 per s) over an L by L field, uniform in space; each grows as a disc, radius r(t) = r0 + v (t - t0) at constant speed v, to a height h above the support. Times and places come from a fixed hash of the seed, as in `sim/membrane.cho`, so a movie is reproducible. STAND-IN values: none are taken from an experiment.
* The imaging: frame time Tf, pixel size, height noise sigma, and the analysis's thresholds (smallest visible radius r_min, smallest visible height).

**Closed forms the acceptance is written against** (stated before the code; each is to be verified by simulation, not assumed):

1. With no growth and no overlap, the number of events in a window T over area A = L^2 is Poisson with mean J A T, and the waiting times are exponential with mean 1/(J A). The estimate J_hat = N/(A T) has relative error 1/sqrt(N).
2. Detection lag: an object is first visible when r(t) = r_min, a time (r_min - r0)/v after birth, and is first seen at the next frame boundary, a further delay uniform on [0, Tf] (mean Tf/2). So the observed waiting-time histogram is the true exponential shifted by a constant (r_min - r0)/v + Tf/2 on average; fitting an exponential without the shift over-reads the mean waiting time, i.e. under-reads the rate when the window is short.
3. Crowding: when discs overlap they merge into one object, so counts fall below J A T. For constant J and v the covered fraction is the Kolmogorov-Johnson-Mehl-Avrami result in two dimensions, X(t) = 1 - exp(-pi J v^2 t^3 / 3). The analysis's undercount should follow X; rates must be read from the early frames, or corrected.
4. Objects below the threshold are missed and counted as missed: the report says how many were born and how many were seen.

**Acceptance, written first:** (a) at low coverage the recovered J is within 3 / sqrt(N) of the injected J; (b) the waiting-time histogram has the exponential's mean within the same bound, after the shift of (2) is removed; (c) the measured shift matches (2) to within one frame time; (d) the coverage at time t matches (3) within the Poisson scatter; (e) every refusal has a tag (no objects, field too crowded to separate objects, a frame time longer than the mean waiting time per field); (f) reproducible.

**Built (slice 1, 2026-11-10):** `sim/nucleation.cho` (births, the frame, the analysis, the expected lag and the Avrami law), `tests/nucleation_test.cho` (the four closed forms, each at its stated bound), `host/d7_report.cho` (the table below). Field 72 by 72 pixels, 60 s, 12 movies of about 60 births each; units are pixels and seconds, nothing is from an experiment. The reading of vesicle movies named at the top of this section is **still not done**; slice 1 does not wait on it because it needs only the analysis recipe, but the section is not corrected by any paper yet.

**Found** (`cancho run host/d7_report.cho sim/nucleation.cho --std`; predictions of this software):

| frame time | smallest object | rate, lag removed | rate, naive | lag measured / predicted | seen / born |
|---|---|---|---|---|---|
| 1 s | 6 px | 0.91 | 0.62 | 18.6 / 19.1 s | 448 / 725 |
| 4 s | 6 px | 0.94 | 0.62 | 20.1 / 20.6 s | 444 / 725 |
| 10 s | 6 px | 0.98 | 0.60 | 22.9 / 23.6 s | 429 / 725 |
| 1 s | 3 px | 0.92 | 0.74 | 11.7 / 12.1 s | 531 / 725 |
| 1 s | 12 px | 0.92 | 0.48 | 28.2 / 28.9 s | 343 / 725 |
| 4 s | 12 px | 0.96 | 0.48 | 29.6 / 30.4 s | 342 / 725 |

* The four closed forms hold at the stated bounds: the birth counts are Poisson and the waiting times exponential; the rate is recovered once the lag is removed (within three counting errors); the measured lag is within one frame time of the predicted; the covered fraction follows the Avrami law within 25% (r0 = 0, mean of 12 movies).
* **The lag, not the frame time, is what biases the rate.** A nucleus must grow to the smallest visible size before it is seen, which took 19 s of a 60 s movie here (the object needs 6 pixels, the disc grows 0.058 pixel/s); the frame time adds only half a frame. A rate read naively, as events over the whole window, comes out 26% to 52% too low; with the lag removed it is within 2% to 9% of the rate put in.
* **A small bias is left, not explained:** the lag-corrected rate is 0.91 to 0.98 of the rate put in, low in all six runs, and the measured lag is about 0.5 s below the predicted. The counting error bound (1 / sqrt(N) = 5% at 448 events) allows it, but all six sit low. Candidates, none isolated: nuclei near the field edge are clipped and seen late, and neighbouring discs merge (X is about 0.1 at the end).
* 725 nuclei were born over the 12 movies and 448 seen at the 1 s frame time: the rest were born too late to have grown to the threshold, which is design item 4 (the report says how many were missed).
* Not tested: crowding beyond X of about 0.1, the field edge, anything with noise sigma above 0.1 of the height, and real movies.

**Slice 2: bilayer formation from vesicles. Reading done (2026-11-10), design below; nothing built.**

*What was read.* **Read in full:** Plunkett P, Camley B, Weirich K, Israelachvili J, Fygenson D, Atzberger PJ, *Simulation of edge facilitated deposition and critical concentration induced rupture of vesicle deposition of supported lipid bilayer membranes* (Soft Matter 2013; the author manuscript, fetched as a PDF and read as text): a **simulation** paper, fitted to the fluorescence master curve of Weirich et al. (the experiment, **not read**), not an HS-AFM study. **Snippets only (search results; not read, to be checked before use):** a 2019 HS-AFM protocol for supported bilayers (vesicle fusion or Langmuir-Blodgett on mica), time-lapse AFM on mica describing adsorption, deformation, rupture, patches that coalesce, Reimhult's thesis (edge-induced rupture dominates), a time-resolved study disputing a critical density (it reports edges enhance adhesion and induce rupture), and Morigaki and Tawa on a critical vesicle coverage. **No HS-AFM time-resolved study of vesicle fusion was found by the search**, so there is no HS-AFM number in this design.

*What Plunkett et al. state, and what it changes:*

* The pathway: vesicles adsorb; rupture nucleates bilayer islands; islands grow and merge; vesicles are recruited to island edges; vesicles trapped under a growing island desorb. The rate of deposition accelerates once islands exist.
* **The rupture criterion is contested, and the twin should hold both.** Their model has a vesicle rupture only if enough adsorbed vesicles are within 3 r of it (a critical local density) and says edge-induced rupture must be slow for the overshoot of lipid on the surface to appear; the snippets above say the opposite (edges induce rupture). The two give different movies: critical density gives a delay and then ruptures anywhere the surface is crowded; edge-induced rupture gives events clustered at existing patch edges and a rate that grows with edge length.
* Numbers they use (a simulation's parameters, not measurements): vesicle radius r = 25 nm; a ruptured vesicle becomes a **disc of radius 2 r** (its whole surface area 4 pi r^2 spread out; whether that is the right area for a bilayer that has two leaflets is not argued in the paper and is a question to settle before using it); arrival is a Poisson process whose rate is linear in the bulk concentration; the deposition time scale is inversely proportional to the concentration (their master-curve scaling, t_max proportional to 1/c). Their critical counts are given inconsistently in the text: gamma_d = 2.7 in the model section and 1.8 in Table 2.
* **What the twin must not claim:** that the critical-density model is right. It is the model of one paper, fitted to a fluorescence curve.

*What slice 2 models.* Vesicles arrive at a Poisson rate per area and, on a bare spot, adsorb as domes of a given footprint and height; one that lands on a patch is lost (desorbs). A mechanism switch: (A) critical density: an arriving vesicle with at least gamma_d adsorbed vesicles within 3 r ruptures at once; (B) edge-induced: an adsorbed vesicle within r of a patch edge ruptures at a rate k_e; both can be on. A ruptured vesicle becomes a disc of radius 2 r (the paper's rule, area conserved to the pixel grid); discs that overlap are one patch; a vesicle under a patch desorbs. Imaged as in slice 1, with a second height level so the analysis can tell domes from patches.

*What the analysis recovers, with the closed forms to be checked first:* (1) before the first rupture the number of adsorbed vesicles grows at the arrival rate (a Poisson count, relative error 1/sqrt(N)); (2) the patch area is the number of ruptures times 4 pi r^2, to the pixel grid, until discs overlap; (3) the **fraction of rupture events that occur within one vesicle diameter of an existing patch edge** is the statistic that separates the two mechanisms: under (A) alone it should match the fraction of the free area that lies within that distance of an edge (a number the analysis can compute), under (B) it should be well above it; the acceptance is that the analysis calls the mechanism correctly on movies with each switch on and the other off, at the counts a real movie could give; (4) under (A) the time to the first rupture scales as 1/arrival rate (the master-curve scaling), checked at two arrival rates.

**Built (slice 2, 2026-11-10):** `sim/vesicles.cho` (the history, the frame, the analysis, `study`), `tests/vesicles_test.cho` (the acceptance lines below), `host/d7_vesicles.cho` (the table). Field 40 by 40 pixels (a cancho region is 64 KiB; it is small), vesicle radius 2 px, patch radius 4 px, 0.5 s frames, 60 s, 8 movies a row; the analysis reads rupture events only while the patches cover at most 25% of the field (my choice: beyond it a new patch is mostly overlap). Units are pixels and seconds; every parameter is a stand-in; the edge rate k_e = 0.5 per s and gamma = 3 are mine, not Plunkett et al.'s.

**Found** (`cancho run host/d7_vesicles.cho sim/vesicles.cho sim/nucleation.cho --std`; predictions of this software):

| mechanism | events read | near-edge share | chance level | first event | dome rate / put in |
|---|---|---|---|---|---|
| critical density only (gamma 3), lam 0.003 | 79 | 0.22 | 0.24 | 4.3 s | 0.88 |
| critical density + edge-induced (k_e 0.5) | 72 | 0.57 | 0.20 | 4.3 s | 0.88 |
| critical density only, lam 0.006 | 80 | 0.23 | 0.24 | 2.3 s | 0.90 |
| critical density only, gamma 2 | 74 | 0.23 | 0.24 | 2.8 s | 0.92 |

* **The discriminating statistic works in the twin.** With critical density alone, the share of ruptures next to an existing patch is the chance level (0.22 against 0.24, within three binomial errors); with edge-induced rupture on it is 0.57 against 0.20, more than five binomial errors above it (about 70 events in 8 movies). The analysis therefore names the mechanism correctly on both. It was tested at one k_e and one gamma at first; how it degrades with fewer events, a smaller k_e or noisier images is measured in the section below.
* The time to the first rupture goes as 1 / arrival rate under critical density: 4.3 s at lam 0.003 and 2.3 s at 0.006 (ratio 1.87; the test bound is 1.5 to 2.5), the master-curve scaling of the paper reproduced by a model built on its assumption (which does not test the paper).
* The dome count reads the arrival rate to 0.88 to 0.92 of the rate put in (touching domes are one component).
* The patch area reads 0.76 to 0.86 of ruptures times 4 pi r^2. Random overlap of discs at the 25% cap predicts (1 - e^-x) / x = 0.87 for x = 0.29; the A-only value fits, the A + B value is lower (edge-induced discs overlap their parent by construction). **That formula was checked after the numbers were seen, and the test band 0.75 to 0.95 was set with it, so this line is a consistency check, not a prediction.**
* With the critical density off and only the edge process, no patch ever forms (0 events): edge-induced rupture needs a first patch from somewhere, so in this model it cannot be the only mechanism.
* The events read (about 75 of 8 movies) are far fewer than the true ruptures (298 to 434): the rest happened after the cap. The two are not a like-for-like count and the table does not compare them.
* Not found, and not claimed: which of the two mechanisms real vesicles follow. The twin shows what the analysis can distinguish if either is true.

**How the edge-share statistic degrades (2026-11-10; `cancho run host/d7_degrade.cho sim/vesicles.cho sim/nucleation.cho --std`, about 30 s).** 48 movies per setting (seeds 1 to 48), pooled g at a time into groups; z = (share - chance) / sqrt(chance (1 - chance) / events); a mechanism is called at z > 3. Edge-induced rupture on is B, critical density alone is A. Predictions of this software with stand-in parameters.

| what varies | setting | events per group | B called (z > 3) | A falsely called | mean z of B |
|---|---|---|---|---|---|
| movies pooled | 1 | 9 to 10 | 31% | 0% (0 of 48 groups) | 2.5 |
| | 2 | 19 to 20 | 75% | 0% (0 of 24) | 3.4 |
| | 4 | 38 to 40 | 92% | 0% (0 of 12) | 4.9 |
| | 8 | 76 to 81 | 100% | 0% (0 of 6) | 6.9 |
| image noise (sigma, 8 movies) | 0.1 | 76 | 100% | 0% | 6.9 |
| | 0.2 | 75 | 100% | 0% | 4.8 |
| | 0.3 | 68 | 0% | 0% | 1.8 |
| | 0.4 | 51 | 0% | 0% | 0.7 |
| edge rate k_e per s (8 movies) | 0.5 | 76 | 100% | | 6.9 |
| | 0.2 | 78 | 100% | | 5.0 |
| | 0.1 | 81 | 83% | | 4.0 |
| | 0.05 | 80 | 33% | | 2.9 |

* **About 20 events are needed to call the edge-induced mechanism three times in four, about 40 for nine times in ten** (k_e = 0.5, sigma = 0.1), and ten events (one movie) call it in 31% of cases. The critical-density-only movies were never called edge-induced in any group: 0 false alarms in 90 groups in all, which bounds the false-alarm rate at a few percent at most (0 of 6 groups says little by itself).
* **The statistic weakens as the edge process weakens:** at one tenth of the rate the 76 events still call it 83% of the time, at one tenth of that 33%. Real k_e is unknown, so the size of the effect to be found cannot be assumed.
* **Noise breaks it by a mechanism that is the analysis's weakness, not the physics:** noise flags isolated bare pixels as patch, so every place is "next to a patch" and the chance level climbs (0.22 at sigma 0.1, 0.40 at 0.2, 0.90 at 0.3); the statistic still works at 0.2, where the chance level is already 0.40, and fails at 0.3, where 0.96 against 0.90 leaves no room. A minimum patch size or a median filter before the class test would be the fix and **was not built**.
* **A first version of this sweep was wrong and is corrected:** the image noise was uniform and bounded (at most 1.73 sigma), so nothing changed until sigma reached 0.29 and then everything did, a cliff made by the noise model. It was replaced by Gaussian noise (Box-Muller from two hashes), and the sweep above is the corrected one; the sigma = 0.1 rows are identical in both because no pixel crosses a threshold at that level.
* Not measured: the critical count gamma, the arrival rate, the coverage cap (25%), the frame time, and anything that makes events cluster in time.

*Not in slice 2, stated:* the tip's force on adsorbed vesicles (it can flatten them and may trigger rupture, which would make the imaging itself a cause; this is the largest confound for real HS-AFM and needs its own slice); vesicle-substrate adhesion energies; ionic conditions and calcium (the snippets say they change the behaviour); diffusion of adsorbed vesicles (the paper moves them with the edge); and any comparison with a measured movie.

**Out of scope for slice 1:** vesicle fusion and budding, anything with a curvature energy, diffusion of the objects (D1 covers mobile particles), and any comparison with measured movies (none is available).

## D7, slice 3: the scanning tip as a cause of rupture, and the noise filter (2026-11-10; predictions of this software, stand-in parameters)

**Design note, written with the code because the model is one parameter:** the tip passes over every adsorbed vesicle once per frame and ruptures it with probability `p_touch` (mechanism C in `sim/vesicles.cho`). `p_touch` stands in for the tip's force, which is **not modelled**; no source on the force needed to flatten or burst an adsorbed vesicle has been read. The natural next step is a Bell-type dependence of the hazard on the force (as in `sim/dfs.cho`), with the vesicle's stiffness and rupture force from a source, and a tip that is a real force, not a probability; that needs the reading first. Acceptance: (1) the ruptures per touch equal `p_touch` within binomial error (the tip alone); (2) the edge-share statistic is measured with the tip on, so the contamination is a number.

**Found** (`cancho run host/d7_tip.cho sim/vesicles.cho sim/nucleation.cho --std`, 10 s):

* The tip alone: 0.020 ruptures per touch at p_touch = 0.02 (397 of 19,888; the test bounds it at three binomial errors). That is the code agreeing with its input.
* **The total ruptures do not go as the imaging rate.** With frames every 0.5, 1 and 2 s the movies hold 49.6, 42.6 and 34.5 ruptures, not four times as many at the fastest rate. Probably the field fills with patches and arrivals are lost on them (saturation), so the dose dependence has to be read early in the movie; that was not measured, so this is a guess.
* **The tip contaminates the edge-share statistic quickly.** Critical density plus edge-induced rupture (k_e 0.5), groups of 8 movies (about 75 events), 6 groups each:

| p_touch per frame | share vs chance | mean z | called (z > 3) |
|---|---|---|---|
| 0 | 0.55 vs 0.22 | 6.9 | 6 of 6 |
| 0.005 | 0.49 vs 0.22 | 5.5 | 6 of 6 |
| 0.01 | 0.45 vs 0.23 | 4.7 | 6 of 6 |
| 0.03 | 0.37 vs 0.24 | 2.6 | 2 of 6 |
| 0.1 | 0.29 vs 0.25 | 0.9 | 1 of 6 |

  Tip ruptures happen at random places and dilute the edge preference: at 3% per frame the mechanism is called in two groups of six, at 10% in one. The imaging dose has to be low enough that the tip's own ruptures are a small share of all, or the movies have to be taken at two imaging doses and compared (the tip's share changes with the dose, the intrinsic mechanisms' does not); the second was not built.

**The median filter on the noise problem, measured** (`host/d7_degrade.cho`, same 48 movies per setting): a 3 by 3 median filter before the class test (`filter` 1 in `sim/vesicles.cho`) lowers the chance level that noise inflates (at sigma 0.3: 0.59 against 0.90) **but makes the statistic miscalibrated, not better**: the critical-density-only movies are then called edge-induced in 17% of groups at sigma 0.2, 67% at 0.3 and 83% at 0.4 (z > 3), where without the filter they were never called. The filter changes where events are found and how near-edge is judged (it rounds corners), so the analytic chance level no longer describes the null. Edge-induced rupture is still called 100% of the time at sigma 0.1 to 0.4 with the filter, but a method that also calls the other mechanism is not usable. **The unfiltered statistic is the better calibrated one up to sigma 0.2 (no false call, B called 100%) and fails above; a null made by shuffling the events over the bare area of the same frames, instead of the analytic chance level, is the fix this points to and was not built.** The noise bullet of slice 2 above that said a minimum patch size or a median filter would likely fix it is wrong about the filter and is corrected here.

**The shuffled (implant) null, built and measured (2026-11-10): it did not fix the miscalibration, and what it rules out is the useful part.** `implant_chance` in `sim/vesicles.cho` places a synthetic rupture (a disc of radius 2 r) at a random bare place of the previous frame, finds its newly-patch pixels the way the analysis does, takes their centroid and tests it for a patch within the near distance; it keeps what the analytic chance level leaves out (an overlapping rupture shows only its crescent, whose centroid is not the disc's centre). `host/d7_degrade.cho` now prints z against both nulls. Result: **the two nulls agree to within about 0.02 everywhere** (0.27 against 0.26 at sigma 0.1; 0.59 against 0.59 for the filtered images at sigma 0.3), so the critical-density-only movies are still called edge-induced in 67% of groups at sigma 0.3 with the filter on (z 3.3), exactly as before. The hypothesis "the analytic chance level is wrong because crescent centroids are biased" is therefore **rejected**; the false calls come from the data: something near existing patches produces more events than the null predicts once the images are filtered and noisy. **The cause was not found.** Candidates, none tested: boundary pixels of patches flickering across the class threshold from frame to frame and forming small new components next to a patch; the filter shifting the class of dome pixels beside patches. A direct test is to match each event at sigma 0.3 against the true ruptures and look at the ones that match none, which was not done. The statistic stays usable only unfiltered and up to sigma 0.2. (`tests/vesicles_test.cho` keeps one check: the implant null agrees with the analytic level on clean images.)

## Model adequacy, and the discrepancy matrix (2026-11-10; predictions of this software, stand-in models)

**Idea (the user's):** make data in the twin under one model, analyse or compare it under another, and record the discrepancy; the pattern of which summaries disagree is a **fingerprint** of how the two models differ. It is a known idea (a confusion matrix over models; posterior predictive checks; simulation-based model comparison), done here with the twin's own analysis, so it checks what the analysis can see, not what is true.

**Built:** `sim/adequacy.cho` (a library of six models, seven summaries of a movie read from its images, ensembles over k movies, the discrepancy and the fingerprint), `host/d7_matrix.cho` (the matrix), `host/d7_adequacy.cho` (observed summaries in, a verdict per model out), `tests/adequacy_test.cho`. The summaries: events read, the excess edge share (share minus the null), the first event's time, the dome count's read of the arrival rate, the patch area over the true ruptures' (**uses the truth, so it is ignored on real data**), the covered fraction at 15 s and at 30 s. The discrepancy is the root mean square of the seven differences of means in standard errors; two ensembles of the same model give about 1.

**Found** (`cancho run host/d7_matrix.cho sim/adequacy.cho sim/vesicles.cho sim/nucleation.cho --std`, 12 s; 24 movies per ensemble, data from seeds 1 to 24, predictions from seeds 1001 to 1024). Models: 0 critical density (gamma 3) only; 1 plus edge-induced rupture (k_e 0.5); 2 plus a tip rupturing 3% of vesicles a frame; 3 edge and tip; 4 a weak edge process (0.1); 5 critical density with gamma 2.

| data made under \ predicted by | m0 | m1 | m2 | m3 | m4 | m5 | best |
|---|---|---|---|---|---|---|---|
| m0 | **1.0** | 8.6 | 6.7 | 11.2 | 5.6 | 3.1 | m0 |
| m1 | 10.0 | **0.7** | 6.1 | 4.0 | 4.0 | 6.4 | m1 |
| m2 | 8.1 | 5.0 | **1.2** | 5.3 | 4.3 | 3.9 | m2 |
| m3 | 11.4 | 3.7 | 5.2 | **0.9** | 6.4 | 7.3 | m3 |
| m4 | 5.8 | 3.7 | 4.1 | 6.3 | **0.6** | 3.2 | m4 |
| m5 | 4.7 | 6.4 | 3.1 | 8.2 | 4.0 | **0.9** | m5 |

* **All six are identified:** the diagonal (a model against its own other seeds) is 0.6 to 1.2, as it should be, and every off-diagonal is at least 3.1. The closest pair is m0 and m5 (the same mechanism, a different critical count; 3.1 and 4.7), then m1 and m3 (edge with and without the tip; 3.7 and 4.0).
* **The fingerprints say why, and they differ by kind of change** (z in standard errors, order: events, edge share, first event, dome rate, area, cover 15 s, cover 30 s):
  * *an edge process* (m0 against m1): edge share -6.9, cover 15 s -10.5, cover 30 s -18.3; the first event is unchanged (-0.6), because no edge rupture can happen before a first patch exists;
  * *a tip* (m0 against m2): first event 6.4, cover 15 s -9.6, cover 30 s -13.2, edge share only 1.6: the tip ruptures early and everywhere;
  * *a different critical count* (m0 against m5): edge share 0.0, first event 3.0, covers -5.3 and -5.2: no edge signature at all;
  * *a weaker edge process* (m0 against m4): the same signs as m1 but about half the size.
  So the edge share separates edge-induced rupture from the rest, the first-event time separates the tip, and neither moves when only the critical count changes: a three-way separation the single edge-share statistic of slice 2 could not give.
* **The covered fraction at 15 s and 30 s carries most of the discrimination (z up to 24)**: every mechanism that adds ruptures speeds the coverage. That is also a warning: if the real coverage curve is affected by anything the models omit (adsorption rate, drift, a different vesicle size), every comparison will be dominated by it.

**The adequacy check on pseudo-observed data** (`host/d7_adequacy.cho` with no arguments: 24 movies made under m3, seeds 5001 to 5024, compared with each model's ensemble from seeds 1001 to 1024): m3 reproduces it (discrepancy 0.6, every summary within 1.0 standard error), the closest wrong model m1 is at 3.3, the rest at 5.8 to 11.7. A set of made-up means entered on the command line (`-- 24 9000 -50 4000 900 800 100 400`, in thousandths) gets "no model of the library reproduces the data", the right answer for numbers nobody generated.

**What this does and does not show:**
* It shows that, **within this family of models and with these summaries**, an experiment of 24 movies could tell the six apart, and which summaries to look at. It does not show that real vesicles follow any of them.
* **The models are all one family**: the same arrival process, the same disc rule, the same analysis. Differences outside the family (a different adsorption rate, vesicle size, spatial drift, an imaging artefact) are not in the library, so a real experiment could match none of the six for a reason the matrix cannot name. A model that reproduces the summaries is **not shown to be right**: another could too (m1 and m3 are only 3.7 apart).
* The spread of each summary comes from the twin's 24 movies, not from the data; with real data the observed spread is to be checked separately. Seven summaries chosen by me; a different set gives a different matrix. Twenty-four movies is what the twin could afford (12 s); how the matrix sharpens or blurs with fewer movies was not measured.
* The first use on real data is still to come: nothing real has been through it.

**How the identification blurs as the experiment shrinks** (`cancho run host/d7_blur.cho sim/adequacy.cho sim/vesicles.cho sim/nucleation.cho --std`, 80 s; predictions of this software, stand-in models, one family). Each of the six models is predicted from a reference ensemble of 24 movies; for each experiment size k, six independent experiments of k movies are made under each model (36 per size, seeds not reused) and compared with the six references. "Named" is whether the smallest discrepancy is the right model; "rejected" is a wrong model with discrepancy above 3 (5 per experiment, 180 in all); "kept" is the true model below 3. Two ways of taking the spread of a summary are shown: estimated from the k movies, and the twin's own.

| k movies | named (observed spread) | named (twin's spread) | true kept (twin's) | wrong rejected (twin's) |
|---|---|---|---|---|
| 1 | 25 of 36 (69%) | 25 | 36 of 36 | 17 of 180 (9%) |
| 2 | 29 (81%) | 31 | 36 | 53 (29%) |
| 3 | 33 (92%) | 35 | 36 | 74 (41%) |
| 4 | 35 (97%) | 34 | 36 | 104 (58%) |
| 8 | 36 (100%) | 36 | 36 | 126 (70%) |
| 12 | 36 (100%) | 36 | 36 | 142 (79%) |
| 24 | 36 (100%) | 36 | 36 | 174 (97%) |

* **Naming the closest model takes few movies; ruling the others out takes many.** Four movies (about 40 events) name the right model in 34 to 35 of 36 experiments, eight in all 36; but at four movies only 58% of the wrong models are rejected, at eight 70%, at 24 97%. An experiment that merely picks the best of the library needs about 4 to 8 movies here; one that must say the alternatives do not fit needs about 24.
* At one movie the model is named 69% of the time (the mistakes: m3 taken for m1, m0 for m5, m2 for m3 or m5), and almost nothing is rejected (9%).
* **The observed-spread column has an artefact at k = 2:** the true model is "kept" in 31 of 36 (5 false rejections) and the mean discrepancy to the true model is 1.8, not 1, because a spread estimated from two movies is itself very noisy. Using the twin's spread (the model's own variance) removes it (36 of 36 kept at every k). **So for small experiments the spread should come from the model and be checked separately, not estimated from the few movies.**
* The numbers are for these six stand-in models and seven summaries; thirty-six experiments per size means a percentage is good to about 5 to 15 points; the reference ensemble of 24 has its own noise; nothing real has been through it.

## Model adequacy for force curves (2026-11-10; predictions of this software, stand-in models)

The same check as for vesicle movies, applied to force curves, so that real curves (Lorena Redondo-Morata's, or the nanoindent 400-curve gel map when it is found) can be the first real test. **Built:** `sim/fcmodels.cho` (six models, the summaries of an experiment of n curves read from the curves alone, ensembles), `host/fc_matrix.cho`, `host/fc_blur.cho`, `tests/fcmodels_test.cho`. The comparison is `adequacy.compare2`. Models: 0 fluid bilayer, half-space law, 200 nm/s; 1 gel; 2 melted; 3 fluid with the bonded-film law; 4 fluid at 2,000 nm/s (ten times the loading rate); 5 a mixture of 70% fluid and 30% gel domains (a curve is taken on one or the other). Summaries of an experiment: the mean breakthrough force, the mean Hertz modulus, the mean modulus of the next model of `forcecurve`, the mean film height, the mean area compressibility kappa_A, the spread of the breakthrough force, and the share of curves in which a breakthrough was found. Every curve is analysed as `forcecurve.slb_curve_nb` analyses a measured one.

**Found** (`cancho run host/fc_matrix.cho ...`, 1 s; 24 experiments of 16 curves per model, data from seeds 1 to 24, predictions from seeds 1001 to 1024):

| model | breakthrough nN | Hertz E MPa | height nm | kappa_A mN/m | sd of breakthrough nN |
|---|---|---|---|---|---|
| 0 fluid | 4.84 | 11.6 | 5.05 | 4.8 | 0.50 |
| 1 gel | 12.39 | 17.0 | 7.30 | 7.3 | 1.27 |
| 2 melted | 3.59 | 8.8 | 4.67 | 3.2 | 0.38 |
| 3 fluid, film law | 5.07 | 61.3 | 5.12 | 65.5 | 0.52 |
| 4 fluid, 10x speed | 5.96 | 11.6 | 5.38 | 4.5 | 0.63 |
| 5 mixture | 10.05 | 15.3 | 6.61 | 6.5 | 3.52 |

* **The diagonal of the discrepancy matrix is 0.7 to 1.1 and every off-diagonal is at least 15** (up to 198): the models are far apart in this twin. The pairs closest to each other are the fluid at the two speeds (15 and 17), the gel against the mixture (15 and 17), and the mixture against fluid or gel (26 to 27).
* **The fingerprints separate three causes cleanly.** A tenfold loading rate (m0 against m4) moves the breakthrough force (z = -28) and **not the Hertz modulus (0)**, the signature of a rate effect on the rupture only (the direction dynamic force spectroscopy predicts). A mixture (m0 against m5) is the only one that moves the spread of the breakthrough force by tens of standard errors. Phase (fluid against gel against melted) moves everything together in the order breakthrough, modulus, height, kappa_A.
* **The seven summaries are not independent:** the breakthrough, height and kappa_A move together with the phase, so the discrepancy (a root mean square over the seven) counts one cause several times and is larger than a count of independent differences would be.
* **The bonded-film model reads a Hertz modulus five times the half-space's (61 against 12 MPa) and a kappa_A 14 times larger.** That is not the same membrane read differently: its film moduli (0.858 MPa and the others) were set so that a Hertz fit of a 20 nm tip reads 6 MPa, and here the tip is the 32 nm of Khadka et al. A model with the wrong tip for its stand-in moduli is a different model; a real comparison must fix the tip first.

**How few curves tell the models apart** (`cancho run host/fc_blur.cho ...`, 1.5 s; one experiment of n curves against a reference of 24 experiments of n curves; six experiments per model, 36 per size):

| curves per experiment | named correctly | true model kept (d < 3) | wrong models rejected (of 180) |
|---|---|---|---|
| 1 | 24 of 36 (67%) | 36 | 139 |
| 2 | 28 (78%) | 36 | 137 |
| 4 | 36 (100%) | 36 | 160 |
| 8 | 36 | 36 | 170 |
| 16 | 36 | 36 | 180 |

* One curve names the model in two cases of three; the mistakes are a gel curve taken for the mixture (the mixture contains gel curves), a fluid curve for the mixture or for the faster fluid, and so on. Four curves name it every time; sixteen reject every wrong model.
* **These numbers are far too optimistic for real curves, and the reason is specific:** the twin's curves differ from each other only by the thermal rupture (a hash-driven hazard) and the 0.02 nm deflection noise. A real membrane has heterogeneity, a tip that changes, drift, and the curve-to-curve scatter of the modulus that nanoindent's own 400-curve map shows; the real spread is probably many times larger, and with it the number of curves needed. The twin's spread is the least trustworthy thing in this table, and the first real data should be used to replace it (the spread of each summary across real experiments, not the twin's).
* Not measured: models closer together than these (a gel at 25 against 20 C, a fluid at two tip radii), the effect of a wrong tip radius or stiffness on the verdict, and any real curve.

## Real force curves into the adequacy check: the loader (2026-11-10; NOT TESTED ON ANY REAL FILE)

**Built:** `sim/fcload.cho` (the text reader, the orientation, the cut at the turn-around, the analysis), `host/fc_load.cho` (files in, per-curve analysis and the verdict against the library out), `host/fc_export.cho` (twin curves as text, to try the loader on files whose maker is known), `tests/fcload_test.cho` and `tests/fcload_flow.sh`.

**The format it reads** is the generic two-column text of nanoindent's `read_csv`: z and deflection, comma, tab, semicolon or space separated; lines that are not two numbers (headers, units, blanks) are skipped. Units are given on the command line (nm, m, um). What it does to a file, in order: numbers read whole or the line skipped; to nm; every nth row kept if there are more than 2,600 (the stride is printed: a thinned curve has less detail); **orientation as nanoindent's `to_force_indentation`** (if z and deflection are negatively correlated, z is flipped); the approach is cut at the largest oriented z, **assuming the file starts with the approach** (a retract first would be read as the approach); then the analysis of `forcecurve.slb_curve_nb` with the library's settings (40 baseline points, contact at 8 noise levels, a drop of at least 400 pN, a film of 4.5 nm), so that a real curve and a library curve are read the same way. A file with fewer than 80 approach points is refused with tag 9.

**What the command prints:** one line per file (rows, approach points, then the breakthrough, modulus and height, or the tag of the refusal), the experiment's seven summaries, and the discrepancy to each of the six models with its fingerprint. The library is rebuilt for the same number of curves (up to 200) with the twin's own spread, so 400 curves take about a minute. A lever other than the library's 0.35 N/m and 32 nm prints a warning that the moduli and heights are not comparable.

**Checked on twin files** (`sh tests/fcload_flow.sh`): eight curves exported under the gel model and eight under the melted model are each named correctly (discrepancy 0.6 for the melted ones); sixteen curves of the mixture are named the mixture (2.3) and the others are at 11 to 62; a two-row file is refused with tag 9; a missing file is reported and does not stop the run. The loader recovers the breakthrough force of a written curve to 0.1% (`tests/fcload_test.cho`).

**What it cannot do yet:**
* **Binary formats.** JPK force files (a zip of segments), Asylum `.ibw` and the instrument's own are not read; they would need a reader for each (nanoindent has them in Python: `read_jpk`, `read_ibw`). Export the curves as text from the instrument's software, or say which format you have.
* **Deflection in volts.** The text must be in a length unit; a volts column needs the inverse optical lever sensitivity, which the command does not take.
* **A map.** One file is one curve; a force-volume map exported as one file per pixel works, but the pixel positions are not read, so no image is made.
* **The lever.** The library is built for one lever (0.35 N/m, 32 nm). For another, `sim/bilayer.cho` has the second (`lever_et_thakafy`) and the library would have to be rebuilt for it; it was not.
* **Authority** (`cancho authority host/fc_load.cho ...`): it performs `args`, `file_read`, `fs_read("")`, `heap` and `io_write`, and never touches the network, signals, other programs or foreign code. It reads the files it is given and writes only to its output.
* **The real spread.** The verdict uses the twin's spread of each summary, which is much smaller than a real membrane's (the twin has no heterogeneity or drift); on real data a model will be rejected for the twin's narrowness unless the spread is replaced by the measured one. This is the first thing to check on the first real set. **The measured-spread option below does that, and has a cost.**

### A measured spread (SPREAD = 1), and what it costs (2026-11-10; twin files only)

`fc_load K R ZUNIT DUNIT SPREAD THIN WINDOW file...` (THIN and WINDOW added 2026-11-10, below): SPREAD 0 is the twin's own spread; **SPREAD 1 takes the spread of each summary from the experiment itself**: `fcload.bootstrap` resamples the curves with replacement (400 resamples, a fixed hash), recomputes the seven summaries of each, and the variance of those is added to the library's. It is the sampling variance of the summaries given the set's own heterogeneity. It needs at least 8 analysed curves (up to 200 files) and says so, falling back to the twin's spread, when it has fewer. It says nothing about drift between sessions or a tip that changed, which one set cannot show. `adequacy.compare_var` takes the variance directly. `tests/fcload_test.cho` checks the bootstrap against the closed forms (the variance of a mean of 100 values is their sample variance over the number analysed; of a share, p (1 - p) / n), each within 25%.

**Found** (16 curves each; `fcfiles` made with `host/fc_export.cho`; the verdict lines, discrepancy of the closest and of the others):

| set of files | twin's spread | measured spread |
|---|---|---|
| 16 curves made under the melted model | named m2, 0.9; others 10.9 to 45.0 | named m2, 1.0; others 29.0 to 181.4 |
| 16 curves, a third each of fluid, gel and melted (**not in the library**) | **no model reproduces it** (closest m5, 4.8); sd of breakthrough z = 44 against m0 | **m4 "reproduces" it (2.3), also m0 (2.5), m5 (2.8)**; m1 4.9 and m2 4.0 are rejected, m3 59.9 |

* **On a set made under one model the measured spread agrees with the twin's** (the same model is named, discrepancy 1.0 against 0.9) and the wrong models are rejected harder, because the bootstrap spread of a homogeneous set is small.
* **On a heterogeneous set the measured spread does what it was added to do, and a second thing.** The twin's spread rejects every model, as it should for data no model describes; the measured spread, inflated by the set's own scatter (a third of the curves are gel, so the breakthrough force has a spread of about 4 nN), **accepts three models that are wrong, the fluid at both speeds among them.** The check has become permissive: its power to reject is spent on the heterogeneity. A discrepancy under 3 with a measured spread means "this set cannot rule the model out", not "the model describes it".
* **So both must be read.** If the twin's spread rejects every model and the measured one accepts some, the data are more heterogeneous than the library; the sd of the breakthrough force in the fingerprint says it (still 5.7 to 6.1 standard errors for every model but the mixture, 0.8, which is the one that contains heterogeneity). The fingerprint, not the single number, is the result.
* Not measured: the real spread of a real set, and how the verdict behaves with 400 curves from one real map.

## A force-volume map from files (2026-11-10; NOT TESTED ON ANY REAL MAP)

**Built:** `host/fc_map.cho` (the manifest of curve files in, the maps and a report out), `host/fc_export.cho` gains model 9 (the curve of one pixel of the twin's gel-disk map, so that a map of files with a known truth can be written), `tests/fcmap_flow.sh`.

**Usage** (`./fc_map K R ZUNIT DUNIT NX NY SNAKE MODE THIN WINDOW MANIFEST`, THIN and WINDOW as below; NX and NY at most 512, 262,144 pixels in all): the manifest is a text file with one curve file per line, in the order the instrument took them; the files are two-column text as in `sim/fcload.cho`. **A pixel's position is not read from the files: it is the line's place in the manifest**, row by row from the first, left to right, or with SNAKE 1 left to right on even rows and right to left on odd ones. The wrong order scrambles the map and nothing can detect it, so the order must be known. MODE 0 prints a report, 1, 2 and 3 write the PNG of the breakthrough force, the Hertz modulus or the film height to the output (the colours run from the 2nd to the 98th percentile of the analysed pixels, a pixel with no result is dark grey), 4 prints one JSON line per pixel. The report: how many pixels were analysed, the refusals by tag (7 a file that cannot be read, 8 no file listed, 9 fewer than 80 approach rows, and `forcecurve`'s own tags), each quantity's median and 2% to 98% range, and a two-class split of the breakthrough force by Otsu's threshold on a 64-bin histogram: the threshold, the share of pixels above it and the mean of each side. Whether the two classes are two phases is not something a map says.

**Checked on a 16 by 16 map of twin files whose truth is known** (`sh tests/fcmap_flow.sh`, 2 s):
* all 256 pixels analysed; the two-class split finds **79 pixels above 5.72 nN, exactly the 79 gel pixels of the pattern** (means 12.38 and 4.76 nN); the 8 nN threshold of the twin's own map classifies 0 pixels wrongly, and the loader's values agree with `fv_twin`'s analysis of the same curves to 0.01 nN (the file text keeps three decimals);
* the same map taken in snake order with the manifest reordered is the same report; the three PNGs are valid and show the three gel disks in the breakthrough force, the modulus and the height; a missing file is refused with tag 7 and the other 255 pixels are analysed; a missing manifest and a map over 32 pixels a side are reported.
* **A bug found while building it, in the open:** the first version took line n of the manifest as line n-1 (`bytes.field` counts from 1), so pixel 0 had no file and every other pixel read its neighbour's curve. The Otsu count was still close to the truth by chance of the pattern, and the exact comparison to `fv_twin`'s values is what showed it.

**Limits:**
* The map is at most 512 by 512 pixels (262,144) since 2026-11-10: see "The size limit, lifted" below (it was 32 by 32). Curves are read whole since 2026-11-10: see "Curves read whole, and the catch" below (they were thinned to 1,500 rows).
* **No topography.** The contact point's height (the "zc" of the twin map, which the twin showed to be biased by stiffness) is not mapped; the film height is the analysis's step height.
* **No adequacy verdict for the whole map.** For that, run the same files through `fc_load` (with the measured spread, and read both).
* The map is only as good as the order of the manifest, the curve files' units, and the analysis settings (a 4.5 nm film, a drop of at least 400 pN, 40 baseline points), which were set for the twin's curves and not checked on a real membrane.

### The size limit, lifted (2026-11-10)

The 32 by 32 limit came from two things, both removed: the per-pixel results lived in one 64 KiB region, and the PNG encoder built the whole image in a region (capped near 255 by 255). **Now** the results are on the heap (`box_slice`), the manifest is read with one cursor (looking up line n by scanning from the start would be quadratic), medians and percentiles come from a 4,096-bin histogram instead of a sort (a sort of 262,144 values would not finish; the values are exact to a 4,096th of the range), and `png.indexed_big` writes the IDAT chunk a block of 32,768 bytes at a time with the Adler-32 and the CRC-32 carried along, so an image can be any size its pixels can. The image is scaled up by a whole number to about 512 pixels. The curve was still limited to 1,500 rows in memory when this was written; see the next section. The map is limited to 512 by 512 only to bound the run.

**Checked:** `indexed_big` gives byte for byte what `indexed` gives for a small image (`tests/png_test.cho`), and the right length for a 200 by 200 image of two blocks; **a 512 by 512 PNG was decoded by Pillow, an independent decoder, and the checkerboard it was made from is recovered**; so is a 96 by 96 map scaled to 480 by 480. A 512 by 512 map (262,144 curves read, all analysed) takes **8 s** and finds 131,072 pixels above the threshold, exactly half of the checkerboard; `tests/fcmap_flow.sh` keeps a 128 by 128 version (16,384 pixels, 512 by 512 PNG) and refuses 600 by 600. The test map uses two files repeated, so it tests the machinery, not a map of 262,144 different curves: a real map of that size would also be dominated by reading that many files.

### Curves read whole, and the catch (2026-11-10)

**Done:** `fcload.load_and_analyse` keeps every row of a curve on the heap (up to 4,000,000 rows; more is refused with tag 10), orients, cuts and analyses it, and frees the arrays; `fc_load` and `fc_map` use it. A new argument **THIN** keeps every THIN-th row (0 or 1: all of them): `fc_load K R ZUNIT DUNIT SPREAD THIN file...` and `fc_map K R ZUNIT DUNIT NX NY SNAKE MODE THIN MANIFEST`. Nothing is thinned unless you ask. The analysis itself is linear in the rows, so a long curve costs only time.

**Checked** (`tests/fcload_test.cho`, 7 tests): a twin curve written at **20 times the usual rows** (about 5,000 rows where the library uses 300) is read whole (every row kept), gives **the breakthrough force the generator recorded to 0.2%**, and a Hertz modulus **within 5% of the same curve thinned to every 20th row**. The flow tests of `fc_load` and `fc_map` pass with the new argument.

**The catch, shown by a test and not only argued: reading whole is not always better, because the breakthrough is a single-step rule.** The breakthrough is the largest force drop **between two consecutive rows** of at least 400 pN (nanoindent's rule, ported unchanged). A real detector has a finite bandwidth, so a rupture is spread over several rows; at a dense spacing no single row drops by 400 pN and the rule finds nothing. The twin's rupture is instantaneous at any spacing, so the test smooths the deflection by a boxcar of 20 rows (a detector bandwidth of 20 rows) before writing the file: **read whole, the curve is refused with tag 4 (no breakthrough); thinned to every 20th row it is analysed and its breakthrough is within 20% of the generator's.** So the rule depends on the row spacing, and the spacing at which it works is not a property of the sample. What this means for a real set:
* if the loader refuses many dense curves with tag 4, thin (THIN = the number of rows a rupture is spread over, roughly) and compare; if thinning recovers them, the rule was the problem, not the data;
* the breakthrough force read at different THIN on the same curves should agree if the spread is within the step; if it does not, the value is a function of THIN and has to be reported with it;
* the cleaner fix is a rule that does not depend on the spacing: **built, as an option, in the next section.**
* Not measured: how real detector bandwidth spreads a real rupture, and which THIN a real instrument needs. Both need real curves.

### A spacing-independent breakthrough rule, as an option (2026-11-10)

**Built:** `forcecurve.slb_curve_win` takes a `window_nm`. With **0 it is nanoindent's rule exactly** (the largest drop between two consecutive rows; `slb_curve_nb` is now a call to it with 0, and the eleven golden tests of `tests/forcecurve_test.cho` pass unchanged, as do those of the bilayer, live-curve and model-library tests). With **window_nm > 0** it is the largest force drop between a row i and any later row j whose piezo travel from i is at most window_nm: the breakthrough force is the force at the top of that drop, and the film height and the post-rupture line fit start at its bottom. `fcload.analyse_w` and `load_and_analyse` carry it; `fc_load` and `fc_map` take **WINDOW**, in tenths of a nanometre (0: nanoindent's rule; 10: one nanometre), after THIN. The two rules are alongside each other so that the same curves can be read both ways and compared.

**Checked** (`tests/fcload_test.cho`, 9 tests): on the bandwidth-limited dense curve of the last section (the 20-row boxcar), **a window of 1 nm reads the breakthrough within 3% of the generator's at every row spacing** (all rows, every 5th, every 20th: -0.3%, -0.4% and -0.8% against the generator's 5.378 nN), where the single-step rule is **refused at all rows (tag 4)** and works once thinned (it already works at every 5th row, where a rupture spread over 20 rows still drops about a quarter of its force per kept row). On an instantaneous rupture the two rules agree to 0.5%. Window 0 gives exactly `slb_curve_nb`'s breakthrough, modulus and height; a window of 1 nm on the ordinary twin curve gives the same breakthrough force within 0.5%.

**How the window was chosen, and how much it matters (one curve; not a study):** on that curve the breakthrough read is **the same, 5.360 nN, for windows of 0.3, 1, 3 and 10 nm, and a window of 0.1 nm still finds it**; the rupture is spread over 0.2 nm of travel here, and the film height read is 5.23 nm.

**What it costs and risks:**
* **Time:** the windowed search costs the rows times the rows in a window. A dense curve of 100,000 rows with 10,000 rows to a nanometre is 10^9 comparisons (seconds); a typical 2,000 to 50,000 rows is negligible. A smarter search (a sliding minimum) is possible and was not needed.
* **A larger window can only find larger drops:** it can catch a drop that is not a rupture (a slow relaxation, a tip-sample jump), and 400 pN over a window of nanometres is easier to reach than 400 pN in one row, so the number of curves refused as "no breakthrough" will fall and the number of false breakthroughs may rise. **How many on a real set is not known**, and this is the thing to compare on the first real data: read the same curves with WINDOW 0 and with WINDOW 10, and look at the curves where they disagree.
* **A window of piezo travel is not a window of time.** At a different approach speed the same travel is a different time, and a rupture's smear is set by the detector's bandwidth, which is time; if the speed varies across a set, so does the right window. The twin has one speed in the curve library (two in the 10x model) and does not test this.
* The rule is mine, not nanoindent's: **its number is not the oracle's** where the two differ; the oracle's remains available (window 0).

## Using the twin to design experiments

The twin has answered design questions of three kinds so far; each is a number the twin computed, with the caveat that its parameters are stand-ins unless a paper supplies them:

| question | what the twin says | where |
|---|---|---|
| how fast can I image, and over what height range, without the loop failing? | the frame-rate and Z-range rules (HS1, HS2), the gain rule, the Q-control limits | `docs/high-speed.md` |
| can I follow particles that diffuse, at this frame rate? | no, unless D is low enough that a particle moves under about a pixel a frame; the rms step against D and the tracking criteria | D1, D5 |
| how many force curves, at what speed, to separate two phases or fit a rupture rate? | the breakthrough force separates gel from fluid at no error over 1,024 curves; the speed sets the loading rate | D3, D6, force-volume map |
| how many nucleation events do I need to see, and what biases the rate? | about 20 to call a mechanism three times in four, about 40 nine in ten; the detection lag, not the frame time, biases the rate | D7 slices 1 and 2 |
| does imaging disturb what I measure? | in the twin, a tip that ruptures vesicles at 3% a frame erases the edge signal; the twin cannot yet say what force that is | D7 slice 3 |

What the twin can **not** do for an experiment design: say whether the physics in its stand-ins is right. It can say what an analysis can and cannot recover if the physics is as assumed, which parameters the result is sensitive to (so which to measure first), and how many events or curves are needed. The procedure that follows from it: write the analysis, run it on twin movies with the unknown switched on and off, find the sample size and the imaging dose at which it calls them correctly, then do the real run at or above that, and **replace the twin's stand-in parameters with the first real measurements before trusting its next prediction**.

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
