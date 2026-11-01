# Building the device: manual (draft)

> **Status: draft. No step in this manual has been carried out.** Every step ends with a *Verified by* line; it says "nobody yet"
> until a person has done the step on real hardware and written what happened, including what went wrong. A step with that line
> unchanged is a plan, not instructions you can rely on. No dimension, tolerance or voltage below is a measured value of this
> design unless the step says **[measured]** and names the run.

Read first: [`../open-hardware-policy.md`](../open-hardware-policy.md) (what "open" means here) and [`../design.md`](../design.md).

| # | Chapter | Builds |
|---|---|---|
| 00 | [Safety and tools](00-safety-and-tools.md) | the rules before any power, and the bench you need |
| 01 | [Parts](01-parts.md) | the list, each part marked open, commodity or closed, and where its files are |
| 02 | [Frame, stage and approach](02-frame-stage-approach.md) | the mechanics that hold tip and sample |
| 03 | [Sensor](03-sensor.md) | how the tip's motion becomes a signal |
| 04 | [Scanner and amplifier](04-scanner-and-amplifier.md) | the piezo and the high-voltage drive |
| 05 | [Controller](05-controller.md) | the FPGA, converters and the hardware limit |
| 06 | [First power-up and checks](06-first-power-up.md) | the tests before a tip meets a surface |
| 07 | [First image and calibration](07-first-image.md) | a grating, and what to compare it to |

## How a chapter is written

*Goal*, *Parts*, *Steps*, *Check* (a measurement with a pass criterion written before the step is done), *If it fails*,
*Verified by*. A chapter with no Check is not finished.
