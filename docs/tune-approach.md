# Tune and approach (S2): written and tested against a model

> Written 2026-11-01. `sim/plant.cho`, `sim/tune.cho`, `sim/approach.cho`, tests in `tests/tune_test.cho` and `tests/approach_test.cho`.
> **Everything here is checked against a model of a resonator and a surface that the author wrote, not against any real fork or
> cantilever.** The model is a Lorentzian resonance, a first-order lag of tau = Q / (pi f0), and the tip law of `sim/loop.cho`. Whether
> the algorithms survive a real sensor is the main risk named in `design.md` section 3 and is untested.

## Tune (`sim/tune.cho`)

* `analyse(freqs, readings, n)`: finds the peak, its frequency (a parabola through the peak and its two neighbours) and Q (the
  half-power width by linear interpolation), and **refuses with a reason**: 1 the peak is at an edge of the sweep, 2 no contrast
  against the floor (peak under 5x), 3 the half-power points are not inside the sweep, 4 degenerate peak (flat top).
* On the model, a 32,768 Hz fork with Q 5,000 swept +-50 Hz in 1 Hz steps: f0 within 0.1 Hz, Q within 3%; with the resonance off-centre
  and +-300 counts of noise on a 32,000-count peak: f0 within 0.5 Hz, Q within 8%. In the end-to-end test, Q came out 1.4% low.
* `choose(t, k, window_s, frac)`: the drive frequency, the setpoint (a fraction of the free reading), Q8 gains for the PID. The loop
  gain is aimed at alpha / 2, where alpha = window / tau is the fraction of a step the plant answers per detector window.

### Two things the simulation found, both fixed in the rule

1. **Q8 gains are too coarse for a slow plant.** With 16 counts per pm the smallest loop gain is 16/256 = 0.06; a tuning fork needs
   about 0.01. The host therefore shifts the detector figure right (`shift`, the smallest that gives kp of at least 8) before the loop.
2. **The integral term destabilised the loop.** With ki = kp / 8 (an integral time of 8 samples) against a plant lag of about 40
   samples, the loop swung between the Z limits (gap from -1000 to +8700 pm in the model). The integral time must be well over
   the loop's own time, so ki = round(kp * alpha / 8), which is **0** (proportional only) at these gains. A P-only loop has no steady
   offset against a fixed surface and follows a moving one with a lag of slope / G: about 16 pm for the test's surface. A slow integral
   at any kp needs a finer gain format (16-bit gains over 65536) in `gen/pid_ir.cho`; not done.

## Approach (`sim/approach.cho`)

A state machine with no I/O: a detector reading in, the next command out (Z target, motor step, contact, or fault). Z starts retracted
and is lowered in steps of dz with a dwell after each so the lagging amplitude can follow; at the bottom of its range with no contact,
Z retracts, the coarse motor steps, and it begins again. Contact is the reading below `contact_pct` of the free reading.

**Refused before anything moves** (`check`): the coarse step larger than the Z range less the free amplitude; dz over a tenth of the
free amplitude; a dwell under one sample; and a lag distance dz / (dwell x alpha) over half the free amplitude. **Faults that retract
at once:** no surface within `max_motor` steps; the reading under half the free one; the free reading gone at full retract.

On the model (free amplitude 2,000 pm, Z range 10,000 pm, 6,000 pm coarse steps, 100 pm Z steps, 150-sample dwell): from 40,000 pm away
it stops after 3 to 6 motor steps with a gap of 1,000 to 1,800 pm and **never touches** (gap above zero at every sample); with no
surface in range it gives up with fault 1 and Z fully retracted; and a dwell of 1 is refused by `check` (the reading would be 48
samples behind a tip moving 100 pm per sample).

## The whole chain, on the model (`test_tune_approach_and_track`)

Sweep a fork it knows nothing about (f0 32,781.4 Hz, Q 4,200), find it, choose gains (kp 13, ki 0, shift 6, setpoint 397), approach
from 33,000 pm (4 motor steps, stops at a 1,700 pm gap, no touch), hand over to `sim/pid.cho` (the arithmetic of the generated hardware)
and follow a surface moving +-300 pm every 6,000 samples: the gap stays between 1,510 and 1,670 pm against a 1,600 pm target and never
reaches zero.

## Not done

Real sensors; the sweep driver that sets the drive and reads the detector (the host side of the register contract, not written);
a step that picks the drive slightly off resonance for tapping; drift and temperature; a PID with a finer gain format; and the same
checks with noise on the approach (the tune tests have noise, the approach tests do not).
