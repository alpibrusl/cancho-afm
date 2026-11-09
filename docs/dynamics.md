# Physical dynamics for lipid membranes and proteins: design note

> Written 2026-11-09, **before anything is built**. Numbers are tagged: **[search]** read in a search result (not the paper itself, unless said), **[A]** computed here from stated assumptions, **[recalled]** from general knowledge and **not verified**, **[unknown]**.
> Nothing here ran on an instrument. Every twin result this note asks for is a prediction. This note grows `docs/high-speed.md` (the twin's instrument model) and `docs/liquid.md` (S9.12, the first biological image) with a model of the *sample*.
> Asked for: viscosity and "dispersion" (read here as the spreading of particles by diffusion; if optical dispersion or something else was meant, say so) for lipid membranes and protein analysis.

## What the twin has, and what it does not

The twin's sample is a made-up surface (`sim/board.cho`): a grating, a terrace step, three particles that do not move, and, since the dynamic sample, four things on prescribed paths. Its particles are raised cosines. **What it has none of:** a motion that comes from physics (a diffusion coefficient, a viscosity), a membrane, a lateral size tied to a tip, any effect of the fluid on the lever. All three are needed before a twin movie says anything about a lipid membrane or a protein.

There are two separate physics here, and the order of work follows from it:

| | What changes | Why it matters |
|---|---|---|
| **the sample** | molecules move, bind, grow; a membrane is 4 to 5 nm thick, soft and fluid | what the movie shows, and whether it can be tracked at all |
| **the instrument in the fluid** | the lever's Q and drag depend on the fluid's viscosity | the frame rate the instrument can reach (HS3: tau = Q / (pi f0)) |

## The first result is a limit, computed before any code

A molecule diffusing in two dimensions with coefficient `D` moves by a root-mean-square `sqrt(4 D dt)` in one frame `dt` **[A]**. Reliable tracking from frame to frame needs that to be under about one particle diameter (**a proposal, not a derived rule**; 5 nm for a small protein). In nanometres, for the frame times the twin reaches:

| D (um^2/s) | 40 ms (25 frames/s) | 100 ms (10 frames/s) | 645 ms (1.55 frames/s) |
|---|---|---|---|
| 1 | 400 | 632 | 1,606 |
| 0.1 | 127 | 200 | 508 |
| 0.01 | 40 | 63 | 161 |
| 0.001 | 13 | 20 | 51 |
| 0.0001 | 4.0 | **6.3** | 16 |
| 0.00001 | 1.3 | 2.0 | 5.1 |

* **A free protein in a fluid bilayer (D of about 1 um^2/s) moves 630 nm in one 100 ms frame, which is several times a typical HS-AFM frame (100 to 200 nm).** A review-style source says the same: single membrane proteins in such bilayers have a mobility of about 1 um^2/s, far beyond what HS-AFM can follow **[search]** (the sources are in the list below; read in snippet form only).
* **What HS-AFM does follow is slow:** influenza M2 in a DPPC bilayer on mica, by contact-mode AFM, D = 4.4e-14 cm^2/s (4.4e-6 um^2/s by my conversion) **[search]**; bacteriorhodopsin at the edges of purple-membrane crystals, at 100 ms per frame and 40 ms per image in the Ando group's work **[search]**; carbon-nanotube porins in DOPC/DMPC bilayers on mica, tracked by HS-AFM, with the mica slowing diffusion **[search, numbers not read]**. So the biological use cases are proteins that are **hindered** (crystal edges, support friction, gel-phase lipid, tethers), not free diffusion.
* **Pixel size and frame:** the twin's 64 x 64 frame is unitless today. A frame of 128 nm at 2 nm per pixel (as HS-AFM frames of single proteins are: **[recalled]**, about 100 to 200 nm) makes a 400-code particle radius 8 nm, protein-sized. This note proposes that scale for the biological samples (a parameter `nm_per_pixel`, default 2).

## What viscosity does, and does not, do

**To the sample.** For a protein in a membrane the standard Saffman-Delbrueck form is `D = kT / (4 pi eta_m h) * (ln(eta_m h / (eta a)) - gamma)` **[recalled; the search confirmed the model and its weak dependence on size but did not return the formula text; check it, and the Petrov-Schwille correction for large inclusions, against the primary sources before using it]**, with `eta_m` the membrane's viscosity, `h` its thickness, `a` the inclusion's radius, `eta` the bulk viscosity, `gamma` Euler's constant. Evaluated at 25 degrees C (`kT` = 4.11e-21 J) **[A]**:

| `eta_m h` (Pa s m) | a = 1 nm | a = 2.5 nm | a = 5 nm |
|---|---|---|---|
| 3e-10 | 5.7 | 4.7 | 4.0 |
| 1e-9 | 2.1 | 1.8 | 1.6 |
| 3e-9 | 0.8 | 0.7 | 0.65 |

(um^2/s, bulk viscosity 0.89 mPa s). The `eta_m h` values are chosen to land D in the observed range of about 1 um^2/s; they are **[unknown]**, not read from a measurement.

* **D depends on the protein's size only through a logarithm** (1 nm to 5 nm lowers D by about a third here), which is the opposite of the Stokes-Einstein law for a particle in bulk **[search for the weak size dependence; A for the numbers]**.
* **Bulk viscosity barely slows a membrane protein:** raising it from 0.89 to 6 mPa s (a glycerol or sucrose mixture; the 6 is **[recalled]**) lowers D from 1.8 to 1.2 um^2/s, by a third **[A]**. **Adding glycerol to the buffer is not a way to slow a membrane protein enough to image it.** What slows it is the membrane's own viscosity (lipid chain order, cholesterol, temperature, gel phase) and the support (mica).
* **To the instrument.** The lever's Q falls as the fluid's viscosity rises: for a conventional submerged cantilever the quality factor always degrades with viscosity (Burg, Sader and Manalis, from the abstract) **[search]**. The closed form (Sader's hydrodynamic function) was **not** retrieved. Until it is read, the twin may assume `Q proportional to 1 / sqrt(eta)` between the inertial and the viscous limits as a labelled placeholder **[unknown: an assumption, not a result]**. The consequence is the same as HS3's: a lower Q means a faster response, and a lever that drops to Q 1 or below has no resonance for the tune to find.

## The design: four layers, each with its acceptance written first

**D1. Diffusion with viscosity, and the tracking criterion.** Particles that move by a random walk whose coefficient is `D` (given directly, or from Saffman-Delbrueck with `eta_m h`, `a` and `eta`), on a stated pixel scale. A random walk the twin can evaluate at any time with no state (the board asks the surface for its height at every sample): the sum of sinusoids with random phases and amplitudes `a_k^2 = 4 D ln(r) / (pi w_k)` on log-spaced frequencies `w_k`, whose mean-square displacement is `4 D tau` for `tau` within the band.
*Acceptance:* a test that the mean-square displacement of the twin's particles is `4 D tau` within 35% over lags from 10 ms to 2 s (an ensemble of a few particles and many start times; the tolerance is wide because the ensemble is small); a table of the tracking criterion above reproduced by the twin; a movie at three frame rates showing the particles linkable at the slow `D` and not at the fast one; the viscosity table above reproduced by a function with a test.

**D2. The instrument in a viscous fluid.** A viscosity input that sets the lever's Q (placeholder law above, replaced by Sader's when read), and a drag on the lever while it scans.
*Acceptance:* the twin's tune finds the resonance at the Q the law gives, from water to a mixture, and **refuses with a tag** when Q falls below what the sweep can resolve; the frame rate the HS1 table gives for that Q; the law marked as an assumption in the output.

**D3. A lipid membrane as a sample.** A bilayer of 4 to 5 nm (the spec's figure), an Lo/Ld height difference (about 1 nm **[recalled]**), a hole or defect, a bilayer patch whose edge advances (supported-bilayer formation), all soft (the twin's soft-sample force and damage threshold of S9.3 apply).
*Acceptance:* the twin images a 4.5 nm bilayer edge with the step SNR of `docs/spec.md` (20 on a lipid bilayer); a domain with a 1 nm offset is detected or not at stated noise; a growing edge is followed at the rate the model sets; the damage threshold (100 pN) is exceeded or not, stated.

**D4. Protein image formation and what it costs.** The tip has a radius, so the image is the sample dilated by the tip. A protein is a spherical cap or a stack of them. The image's height, width and volume are measured and compared with the truth, and a mass is estimated from the volume by the empirical calibration of Schneider and others (molecular weight against AFM volume, correlation 0.994 for 38 to 900 kDa on mica **[search]**).
*Acceptance:* the twin quantifies the bias for a given tip radius (apparent width and volume above the truth, apparent height below it), **against a source's finding that the method is unreliable in general** (a 2016 Ultramicroscopy study argues that tip broadening and force push the volume in opposite directions and make the molecular-weight method unsuitable **[search]**); a stated tip radius at which a 40 kDa monomer and a dimer can be told apart, or the statement that none exists.

**D5. Analysis in cancho on the twin's movies.** Particle detection, linking from frame to frame, the mean-square-displacement fit for `D`, counting of oligomers by volume.
*Acceptance:* from a synthetic movie of D1 with known `D`, the fitted `D` within 30% when the criterion holds; a refusal with a tag when it does not (the particles move farther than a diameter per frame); a count of monomers and dimers right on a stated fraction of the particles. The first real use needs an instrument (#69) and a sample (#44).

## What stays out of scope, and why

* **Real molecular dynamics, hydrodynamic interactions between molecules, crowding, and anything that depends on a force field.** The twin's particles are shapes that move.
* **The tip moving the sample.** In real HS-AFM the tip's force changes what is imaged (and can move or damage the sample). The twin's force is a proxy that follows the loop (S9.3, HS5). A model of it is a later design.
* **Anything about the optics in a viscous medium** (refractive index, the light path). Not asked for, not modelled.

## Order of work, and why

D1 first: it is self-contained, testable against a closed-form result (`4 D tau`), and it produces the criterion that tells which proteins can be imaged at all. D2 next because it decides the frame rate in a given fluid. D3 and D4 each build a sample and an image-formation model and can go in either order. D5 needs D1 and D4.

## Sources

* Review-style source on membrane protein mobility (about 1 um^2/s, beyond HS-AFM): found in a search; not identified to a paper here.
* M2 in DPPC on mica, 4.4e-14 cm^2/s: `umimpact.umt.edu`, "AFM visualization of mobile influenza A M2 molecules in planar bilayers" **[search, abstract snippet]**.
* Carbon-nanotube porins in DOPC/DMPC on mica by HS-AFM, `link.springer.com/10.1038/s41598-020-68059-2` (Sci. Rep. 2020) **[search; numbers not read]**.
* Casuso et al. 2009 (bacteriorhodopsin, 100 ms per frame) and Yamashita et al. 2009 (40 ms per image): `pmc.ncbi.nlm.nih.gov/articles/PMC2749746` and the Ando-group records **[search, abstracts]**.
* Saffman-Delbrueck model: `en.wikipedia.org/wiki/Saffman-Delbr%C3%BCck_model`, and `arxiv.org/pdf/1810.09910` for its limits **[search; formula not retrieved]**.
* Burg, Sader and Manalis (PRL 2009) and Sader and Burg (J. Fluid Mech. 2010) on viscosity and Q **[search; closed form not retrieved]**.
* Schneider et al. 1998 (molecular weight against AFM volume) and the 2016 Ultramicroscopy paper on tip broadening: `wp.icmm.csic.es/forcetool/.../UltramicroscopyPaper-2016.pdf` **[search]**.
