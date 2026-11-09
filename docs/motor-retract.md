# Retracting by the coarse motor: the rule (design, nothing built)

> Written 2026-11-09. **A design on paper. No code, no test, no measurement.** It closes the item "the overshoot rule for retracting by the motor" left open in `docs/coarse-motor.md` (sections 3 and 6) and in `docs/liquid-safety.md` (interlock 2 and step 2 of the shutdown). Tags: **[repo]** read in this repository, **[derived]** arithmetic on repo figures, **[proposal]** a choice of this design, **[unmeasured]**.

## What exists

* Forward only: `host/session.cho` advances by `coarse_steps()` = 30 microsteps a step and never commands a negative move **[repo]**. Nothing in the host retracts by the motor.
* In the FPGA: `MOTOR_MAX` refuses any single command longer than it (0 after power-on, so nothing moves), `MOTOR_STATUS.REFUSED`, `MOTOR_POS` read back, and no motion while the deadman has fired **[repo: `gen/glue.cho`, `sim/board.cho`, `tests/board_test.cho`]**.
* The deadman retracts **Z** to `ZRETRACT`, not the motor **[repo: `docs/liquid-safety.md`]**.
* Backlash of the gearbox is "present, size unknown" **[repo: `docs/coarse-motor.md`]**; the twin's motor has none.

## Finding: MOTOR_MAX allows a move longer than the Z range

`session.cho` writes `MOTOR_MAX = 2 * coarse_steps()` = 60 microsteps. At the assumed 198 pm per microstep **[repo: `pm_per_step`, "ASSUMED"]** one allowed command is **11.9 nm, which is more than the twin's 10 nm Z range [derived]**. The approach itself uses 5.9 nm a step, which fits, but the *contract* the FPGA enforces is the maximum, not what the host happens to use. The safety argument "Z retract always clears the tip" needs the maximum to fit:

> **Invariant I:** `MOTOR_MAX x nm_per_microstep <= Z range - free amplitude - margin`.

On the twin's numbers that means `MOTOR_MAX` of at most about 30 microsteps (5.9 nm, with the 10 nm range and a few nm of amplitude and margin) **[derived]**. For the 28BYJ-48 plan of `docs/coarse-motor.md` (245 nm per full step, 1 um range) one full step fits and two do too, but the microstep unit of the register has to be matched to that motor first **[the repository holds two motor assumptions, 198 pm and 245 nm, which do not agree]**.

**Proposal:** the host sets `MOTOR_MAX` to one coarse step during the approach and raises it only for a retract (R5 below).

## The rule

A retract by the motor is **never the first thing**: Z comes out first (the loop is opened or the deadman has put Z at `ZRETRACT`), then the motor.

* **R1. Z first.** Do not move the motor while Z is under the loop and in contact. Set the loop off, read `ZOUT` at `ZRETRACT`.
* **R2. How far.** Command `D = A + B + 2 s` microsteps, where
  * `A` = `MOTOR_POS` now minus `MOTOR_POS` when the approach began (read from the register, not remembered by the host),
  * `B` = the **measured backlash** in microsteps (`docs/coarse-motor.md` section 5, "Backlash"),
  * `s` = one coarse step, the margin.
  The first `B` steps after a reversal move nothing, so the tip is clear by `A + 2s` once all of `D` has run.
* **R3. No backlash number, no motor retract.** The host refuses to retract by the motor while `B` is not recorded, with a rule tag, and says to retract by hand. A guessed `B` is not allowed.
* **R4. In pieces, read back.** Send `D` in commands of at most `MOTOR_MAX`, wait for `BUSY` to clear, read `MOTOR_POS` and `MOTOR_STATUS` after each, stop on `REFUSED`, on a position that did not move by what was asked, or on a fault.
* **R5. The limit is raised only for this.** `MOTOR_MAX` goes to the retract chunk size for the retract and is set back to the approach value after, including on every error path. At power-on it is 0.
* **R6. Check by readings, not by assumption.** After the retract, the amplitude (air) must be back at 98% or more of the free figure recorded at the tune (liquid: also the sum signal unchanged within the light checks of S9.6). If not, repeat R2 once with `A` replaced by the extra distance asked for, at most **three** times, then stop and report failure. Never loop without a bound.
* **R7. No retract by the motor while the lever is in a droplet** until the cell design (`docs/liquid-cell.md`) says how far the holder must rise to break the meniscus without dragging the chip through the surface. **[open: not designed]**

## Should the deadman also retract the motor? Proposed: no

A deadman that moves the motor on power loss or a host crash needs the FPGA to move an actuator **without** the host's checks and, on a power loss, without power. It would also move by a distance that cannot be right without `B`. The hardware safe state stays **Z at `ZRETRACT`**, and what makes that safe is Invariant I: no single motor command can have moved the tip further than Z can lift it. **Residual, not examined:** what the Z amplifier's output does on a power loss (whether the piezo relaxes toward retracted or toward extended depends on the mapping, which is not designed) **[unmeasured]**.

## What would test it, when someone writes it (a software slice, not part of this note)

1. A backlash parameter in the twin's motor (`sim/board.cho`) and a `retract` function in the host.
2. Tests: with `B` from 0 to 40 microsteps the rule frees the tip every time; the same retract **without** the `B` term does not for `B > 2s`; no `B` recorded is refused with its tag; `MOTOR_MAX` is back at the approach value after an error mid-retract; a command over `MOTOR_MAX` is refused and stops the retract.
3. A check of Invariant I in the session's setup against the profile's Z range.

## Not decided here

* The measured backlash and the real nm per microstep (the bench test of `docs/coarse-motor.md`, section 5).
* Which motor, and so which unit `MOTOR_MAX` is in.
* The meniscus rule (R7) and the power-loss behaviour of the Z amplifier.
