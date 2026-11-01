# 05 Controller

> Draft, unverified. Nothing here has been built or measured.

**Goal.** The FPGA with converters, the feedback loop, the XY raster and the hardware limit and deadman.

**Parts.** See [01-parts.md](01-parts.md).

**Steps.** To be written when the design question for this chapter is settled. Notes so far: The loop is the cancho-hdl design verified in simulation against the cancho model (design.md S1). The limit and deadman follow cancho-robot's hardware gate.

**Check.** A test circuit stands in for the cantilever: the loop holds its setpoint, the limit refuses an out-of-range Z, and the deadman retracts when the host stops. (pass criterion to be written before the step is done.)

**If it fails.** Not yet known.

Verified by: nobody yet.
