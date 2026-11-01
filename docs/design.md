# Design: an automatic AFM, and what stands in the way of a fast one

> **Status: design, nothing built.** Written 2026-11-01. What is general knowledge about how AFMs work is not marked; what is a
> **[choice]** is a choice; what is **[unknown]** has no number behind it. No measurement has been taken on any instrument.

## 1. What an AFM does, in the parts this project owns

A cantilever with a sharp tip is held near a surface. A laser reflected off the cantilever lands on a four-segment photodiode; the
difference between segments is the cantilever's **deflection**, or, if it is driven at resonance (tapping mode), the **amplitude** of
its oscillation. A **Z scanner** (a piezo) moves tip or sample so that this signal stays at a **setpoint**; a **feedback loop**
computes that Z motion. **XY scanners** move the sample in a raster. The recorded Z needed to hold the setpoint, at each XY point, is
the image. A coarse **approach motor** brings tip and surface from millimetres apart to within the Z scanner's range.

## 2. The split

| Layer | Written in | Does | Timing |
|---|---|---|---|
| **Loop** (FPGA) | cancho-hdl | amplitude detection, feedback (PID), Z output, XY raster, the hardware limit and deadman | microseconds, deterministic |
| **Instrument control** | cancho | approach, tuning, scan sequencing, fault handling, image assembly, run records | milliseconds |
| **Interface** | cancho-ui | live image, controls, the run record; the operator can watch and stop, never needs to turn a knob | human |

**[choice]** The loop is in hardware and is **tested against a cancho model of the same loop**, byte for byte, the way cancho-hdl
tests its other designs. That is the project's own method, and it is why the loop is not written on a general-purpose processor.

## 3. Automatic, one step at a time

1. **Approach.** Step the coarse motor, extend the Z scanner, look for the setpoint to be reached, retract and repeat. Stop on the
   first contact; the **limit** in hardware stops the Z drive from exceeding a safe extension whatever software asks.
2. **Tune.** Sweep the drive frequency, find the cantilever resonance from the amplitude response, set the drive and the setpoint
   as a fraction of the free amplitude, set the gains from a measured loop response. The chosen values are printed. **[unknown]**
   how reliably this works on a real cantilever; it is the main software risk.
3. **Scan.** Raster the requested area at a requested rate. Watch the error signal: if it saturates (the loop cannot keep up) lower
   the speed or stop; if the Z drive reaches its limit, retract.
4. **Retract on any fault**: a lost sensor signal, a timeout, a limit hit, the host going quiet (the deadman).
5. **Record**: image plus every setting and every automatic decision, in a plain file.

## 4. Safety model **[choice]**

The expensive and easily damaged things are the tip and the sample. As in `cancho-robot` (`docs/hardware-gate.md`), software is not
trusted to protect them alone: a **limit on Z extension and a deadman** are in the FPGA, set by the host and read back, and the
host fails closed if it cannot confirm them. This is a second enforcement point, not a proof; the glue is hand-written and
its guarantee is its tests.

## 5. Open questions that decide the build (each an issue)

* **Which controller hardware.** The Tang Nano 20K has no ADC or DAC and is on cancho-hdl's current toolchain. A Red Pitaya has fast
  14-bit converters and a Zynq but would need a different FPGA toolchain. An external open ADC/DAC on the Tang Nano is a third
  option. **[unknown]** which suits; the loop's required converter speed and resolution have not been worked out.
* **Sensor.** Optical beam deflection (a commodity laser and photodiode, plus alignment) or a quartz tuning fork (no optics).
* **Scanner.** A tube or flexure piezo scanner and its high-voltage amplifier: the amplifier is the part with the most risk (high
  voltage, noise) and must be an open design or ours.
* **Vibration and drift.** Nothing here yet.

## 6. High speed

A fast AFM differs from a slow one in the **hardware**, mostly not the software: small, high-frequency cantilevers; a fast, small Z
scanner; a fast low-noise amplitude detector; a controller loop with a high update rate. The loop in the FPGA is what makes the rate
reachable at all, so the design does not close the door. **[unknown]** how fast an all-open build can go; the one published open
high-speed controller found (`docs/references.md`) reports 55 lines per second, which is a number to read and reproduce, not one to
assume.

## 7. Slices, each with its acceptance written first

| | Slice | Done when |
|---|---|---|
| S0 | this repository, the policy, the references | the owner has confirmed the policy |
| S1 | a **software-in-the-loop** model: a cancho model of cantilever and surface, the PID loop, the raster; the same loop in Verilog | the FPGA loop's output equals the model's, byte for byte, in simulation |
| S2 | approach and tune logic against the model | the model's cantilever is found, approached and scanned with no operator input |
| S3 | controller electronics chosen and a first board running (ADC, DAC, limit) | a signal generated and read back, loop closed on a test circuit |
| S4 | mechanics: stage, scanner, motor, sensor | built and measured: noise floor, drift, resonance |
| S5 | first image of a calibration grating | the grating's period measured and compared to its stated value |
| S6 | interface in cancho-ui | an unattended run from the interface, with its record |
| S7 | toward high speed | a measured line rate on a small fast cantilever |

S1 and S2 need no hardware and are where work can start today.
