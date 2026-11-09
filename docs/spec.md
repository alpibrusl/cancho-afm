# Resolution and signal-to-noise: what we ask of the instrument

> Written 2026-11-09. **A proposal. Nothing here has been measured on hardware**; the only noise figures in the repository come from the twin, which is idealised. Phase 1 is the instrument in air (tuning fork first, high-speed cantilever as the upgrade); phase 2 is the instrument in water (S9, `docs/liquid.md`). Tags: **[repo]** a figure from a document here, **[computed]** worked out from repo figures, **[general]** general knowledge, not checked, **[proposal]** a choice of this project. A number is not a result until a measurement row below says so.

## How it is measured

* **Height noise** is the rms height (Rq) of freshly cleaved mica over 1 um x 1 um, after the plane and line levelling of `host/image.cho`. It is quoted with the pixel rate it was taken at, because noise rises with bandwidth.
* **Step SNR** is a calibrated step height divided by that Rq.
* **Height accuracy** is the step height read from the 20 nm calibration grating against its stated value.

## The spec

| | Phase 1: air | Phase 2: water |
|---|---|---|
| Height noise (Rq, mica) | requirement <= 0.3 nm, goal <= 0.1 nm **[proposal]** | requirement <= 0.2 nm, goal <= 0.1 nm **[proposal]** |
| Step SNR | >= 60 on the 20 nm grating; >= 3 on a 1 nm mica step at the requirement, >= 10 at the goal **[computed]** | >= 20 on a 4 to 5 nm lipid bilayer **[general]**; >= 5 on a 1 nm mica step **[computed]** |
| Z step | 15 pm per DAC code **[repo: `docs/amplifier.md`]** | same |
| Lateral pixel | 117 nm at 256 px over 30 um; 4 nm at 256 px over 1 um **[computed]** | 4 nm or finer on 1 um frames **[proposal]** |
| Lateral resolution | set by the tip, about 10 nm **[general]** | same, with a soft lever |
| Height accuracy | within 10% on the grating **[repo: `docs/liquid.md`, S9.1]** | same |
| Force | not applicable | 100 pN or less **[repo: S9.1 decision]** |
| Drift | <= 1 nm/min **[proposal, not derived]** | same |

## Where the numbers come from

* **Phase 1 height noise.** The 2025 DIY AFM paper read a 0.48 nm step as 0.34 nm with a 12-bit DAC **[repo: `docs/diy-pcb-afm-assessment.md`]**. A 16-bit DAC removes that limit. 0.3 nm is what I think a DIY build can reach **[proposal]**. The goal of 0.1 nm is what a 1 nm mica step needs for SNR 10.
* **The electronics are not the first limit, if the signal fills the ADC.** One AD1 step is 806 uV and the amplifier's noise is about 0.04 of a step **[repo: `docs/amplifier.md`]**; a 256-sample window averages noise down about 11 times **[repo: `docs/converters.md`]**.
* **Phase 2 amplitude noise.** The setpoint is 90% of the free amplitude, so the loop holds a 10% dip. With a free amplitude of about 1.5 nm **[assumption]** the dip is 0.15 nm, and the amplitude noise must stay under about 0.03 nm (one fifth of the dip) or the force swings by more than the dip **[computed]**.
* **A front-end requirement that follows:** at least 500 AD9226 counts per nanometre of free amplitude, so one count is about 2 pm **[computed; the gain stage is not designed]**.
* **Thermal floor in water.** A 0.15 N/m lever moves about 0.17 nm rms in total; in a 5 kHz loop band, with Q 3 near 400 kHz, about 8 pm **[computed, unchecked]**. Not the limit.
* **Twin figures, for reference only:** an image floor of 7 pm on the fork and 2 pm on the high-speed profile, with idealised noise **[repo: `docs/image-processing.md`]**. They are not evidence for the spec.

## Conflicts and gaps

* The twin's Z range is 10 nm, so it cannot scan the 20 nm step; the real scanner should give about 1 um **[repo: the paper's buzzers]**.
* Hysteresis and creep of the piezo are not in the table; the grating calibration should absorb them, but there is no number.
* The drift row is a wish: the paper reported 6.2 nm/min **[repo]**, and 1 nm/min is not derived.
* The 1.5 nm free amplitude, the 4 to 5 nm bilayer and the 10 nm tip are not checked.

## Measurements, to fill when they exist

| Spec row | Measured | Where, when, how | Pass? |
|---|---|---|---|
| Height noise, phase 1 | **not run** | | |
| Height noise, phase 2 | **not run** | | |
| Step height, 20 nm grating | **not run** | | |
| Force, phase 2 | **not run** | | |
| Drift | **not run** | | |
