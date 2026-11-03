# cancho-afm

An atomic force microscope, and a high-speed one as the second goal, that **runs by itself**: the software is written in
[cancho](https://github.com/alpibrusl/cancho), the controller logic in [cancho-hdl](https://github.com/alpibrusl/cancho-hdl), the
operator interface in [cancho-ui](https://github.com/alpibrusl/cancho-ui), and the hardware is built only from open hardware.

> **Status: design. Nothing is built, nothing is measured, no part has been bought.** Everything in `docs/` is a plan or a
> reading of someone else's published work, marked as such. The build manual in `docs/manual/` is a **draft**: no step in it has
> been carried out by anyone yet, and each step says so until someone signs it off.

## What "automatic" means here

1. **Approach**: bring the tip to the surface without crashing it, with no operator at the knobs.
2. **Tune**: find the cantilever's resonance, choose the setpoint and the loop gains, and tell the operator what it chose.
3. **Scan**: raster a requested area, keep the feedback stable, stop and retract on a fault.
4. **Report**: write the image with every setting that made it, so a run can be repeated.

The safety rule of `cancho-robot` carries over: the part that can damage the instrument (the Z drive and the approach motor) sits
behind a limit and a deadman that live in hardware, so a software fault cannot drive the tip into the sample.

## Layout

| Path | What |
|---|---|
| `docs/design.md` | the architecture, what is automatic, the safety model, the slices |
| `docs/open-hardware-policy.md` | what "open hardware only" means for this project and what it excludes |
| `docs/references.md` | the open AFM/SPM projects this builds on, read from search results, not verified |
| `docs/manual/` | how to build the device (draft) |
| `docs/index.html` | the project page and the step-by-step tutorial |
| `docs/simulator.md`, `docs/host.md`, `docs/registers.md` | the software twin, the host program, the board's register map |
| `docs/amplifier.md`, `hw/amp/` | the amplifier design and its ngspice simulations |
| `docs/first-hardware.md`, `bench/` | the first run on the real board |
| `docs/cost.md`, `docs/buy-now.md` | what build one costs for France and Spain, and what to order now |
| `gen/`, `sim/`, `host/`, `tests/` | the generated hardware, the models, the host program and their tests; `sh test_all.sh` runs all of it |

Open questions are issues in this repository.
