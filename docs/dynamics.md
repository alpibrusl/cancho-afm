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
| Petrov-Schwille interpolation (valid between the small- and large-inclusion limits) | formula with `eps = a / L_sd`, constants `b1` = 2.74819, `b2` = 0.51465 (the corrected value; the original had a typo), `c1` = 0.73761, `c2` = 0.52119 | **[read]** Wikipedia; the original and its correction (Biophys. J. 103:375, 2012) not read. Not implemented in D1: for `a` of a few nm and `L_sd` of 0.1 to 10 um it is not needed |
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

**Still design only (D6, and sources not obtained):** viscoelastic relaxation and dynamic force spectroscopy. The sources for the standard linear solid (the RSC review: HTTP 403) and for the Bell-Evans formula (PMC and the arXiv PDF: not readable by the fetch tool) were **not read**; the formula in this note is from a search result that quotes Evans. The arXiv paper on dynamic AFM viscoelasticity that was read uses a different model (a moving-surface piecewise-linear one) and gives no Kelvin-Voigt or Zener equations.

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
* Gambin et al. PNAS 2006 (PMC1413751) and Weiss et al. Biophys J 2013 (PMC3714877): cited by the above; **not read**.
* Petrov and Schwille, Biophys J 2008, and the correction in Biophys J 103:375 (2012): **not read**.
* Burg, Sader, Manalis PRL 2009; Sader and Burg J Fluid Mech 2010; Sader 1998 **[snippet; closed form not read]**.
* Viscoelastic AFM: Soft Matter 2019 review (pubs.rsc.org c9sm01020c), arXiv 1711.09024, PMC8931349, Abuhattum et al. iScience 2022 **[snippet]**. Dynamic force spectroscopy: Evans; Dudko, Hummer, Szabo (PMC2572921); Bullerjahn, Sturm, Kroy (PMC4124868) **[snippet]**.
* Schneider et al. 1998 and the 2016 Ultramicroscopy study on tip broadening **[snippet]**.
