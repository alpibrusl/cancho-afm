# The simulator: a software twin of the instrument

> Written 2026-11-02. `sim/board.cho` (the twin), `host/` (the host program), `tests/board_test.cho`, `tests/host_proto_test.cho`,
> `tests/session_test.cho`. **It predicts what this software would do, not what an instrument would; nothing in it is a measurement.**

## What it is

The same host program that will talk to the real board over a serial port can talk to the twin, with no hardware: every byte of the
protocol is encoded by `host/proto.cho`, answered by `host/twin_link.cho` (the serial bridge in software) in front of `sim/board.cho`, and
decoded again. So when the instrument exists, the first thing to try is the program that has already run against the twin.

`sim/board.cho` has the register interface of `afm_top` (`docs/registers.md`): the same indexes, defaults, read-only and unmapped refusals and
response codes. Behind it are the validated models of this repository wired as the board wires them: the detector (`sim/lockin.cho`), the loop with
its limit and deadman (`sim/pid.cho`), the raster (`sim/raster.cho`), and a model of a fork, a tip and a surface (`sim/plant.cho`): a driven
resonator that follows its target with a lag, a tip whose amplitude falls as it nears the surface, a grating of chosen height and period under it,
a coarse motor that lowers the tip, ADC noise, and the bench wiring of tutorial Part 5 (Z DAC into ADC channel 0).

A whole automatic run (several hundred thousand simulated ADC conversions) takes about a second on the debug build of the compiler.

## How far to trust it

* **Checked against the hardware simulation** (`tests/board_test.cho`): the free figure (41,822 in the Verilog system test; the test requires the twin to be within 0.3%), the
  Z the loop settles at (1,599 pm against 1,600; the twin within 40 pm), the limit, the deadman, the reset, and where a scan ends. Both use the same
  detector arithmetic and the same samples.
* **Not clock-accurate:** a detector window is applied at once, not 13 clocks later; the SPI masters, the serial link and the DAC refresh are not
  modelled (a DAC code is what the loop says); the deadman counts a conversion as 103 clocks.
* **The plant is the simplest model with the right shape** (a Lorentzian resonance, a first-order lag, a linear tip law, a sinusoidal grating):
  not any real fork or cantilever, no drift, no thermal noise, no tip wear, no vibration.

## The automatic run on the twin (`host/session.cho`, `host/demo_twin.cho`)

The session is a host program that has no I/O of its own: for each stage it builds a script of register operations, a runner executes it, and the
session decides from the answers what comes next. Stages: check the board's identity and read the limits back; sweep the drive frequency and find
the resonance; settle there and fix the setpoint; approach with the coarse motor; hand the loop the tip; scan; read the image back; stop.

On the twin's fork (f0 = 32,781.4 Hz, Q = 500, 2,000 pm free amplitude; the program is told only "near 32,768") with the sample 21,000 pm away and a
grating of 100 pm and 6 pixels' period, it ran end to end with no refused write:

* **Tune:** f0 found at 32,781.5 Hz, Q at 495; peak figure 41,672; chosen shift 5, setpoint 1,044, kp 10, ki 0.
* **Approach:** 2 coarse motor steps, contact at Z = 2,704 pm, the loop settled at 2,677 pm (a gap of 1,677 pm against a target of 1,600).
* **Scan:** 36 of 36 pixels read; the grating's period came out at 5.7 to 6.1 pixels (6 true) for 30 to 120 loop steps per pixel.

## What the twin found before any hardware existed

1. **The reference's 16-bit phase was too coarse** (a step of 4 Hz against a fork's 6.5 Hz-wide resonance, so a sweep could not resolve it). It is now
   32 bits (a step of 0.00006 Hz); the model, the generated Verilog, the tests and the register map were changed together.
2. **The raster needed a pixel divider.** It advanced one pixel per loop step, but the loop needs about 20 steps to follow a feature, so a scanned
   grating came out smeared. `PIXDIV` (register 27) is the number of loop steps per pixel; the Verilog system test now scans with it.
3. **The image is only as good as the loop.** At 30 steps per pixel the grating's height came out at about 40% of its true value; at 60 to 120
   steps about 50 to 60%. The loop is proportional-only (an integral term made it unstable, `docs/tune-approach.md`) and the Z DAC steps in 16 pm, so a
   100 pm grating is only about 6 steps high. A real grating of tens of nanometres is far above that floor, and the loop and DAC set the image's
   vertical resolution, not the detector.
4. **No on-board image memory is needed for a fork,** whose response takes tens of milliseconds, but the program reads a pixel by polling over the
   serial port and relies on its timing being aligned with the raster's ticks, which only the twin guarantees; on a real board a pixel-synchronous
   read or a small capture memory is needed.
5. **The board had no coarse-motor interface.** The approach needs motor steps, so the board now has a STEP/DIR/ENABLE driver (`docs/registers.md`, registers 43 to 47) that fails closed
   (a maximum steps per command of zero after power-on); the twin models it and moves the tip by 198 pm per microstep (an assumed 0.635 mm screw at 1/16 microstepping), and the session drives it
   through those registers.

## Run it

```sh
cancho run host/demo_twin.cho host/session.cho host/script.cho host/run_twin.cho host/proto.cho host/twin_link.cho \
  sim/board.cho sim/lockin.cho sim/pid.cho sim/raster.cho sim/plant.cho sim/tune.cho sim/approach.cho --std
sh test_all.sh      # every cancho test, then the generated hardware against the models
```
