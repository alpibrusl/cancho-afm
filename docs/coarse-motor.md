# The coarse approach motor from the parts on the desk (a design, nothing built)

> Written 2026-11-03. **Nothing here is measured.** Every number is tagged **[nominal]** (a maker's or a commonly quoted figure, not checked on this
> motor), **[derived]** (arithmetic on other numbers here) or **[unmeasured]**. Section 5 is the bench test that replaces them with measurements.

## 1. The question

`docs/cost.md` budgets EUR 27 to 60 for a NEMA 8 stepper with a screw and EUR 7 to 9.50 for an A4988 driver (five-pack) for the coarse approach. The bench already
has a **28BYJ-48 geared stepper with four ULN2003 driver boards** (unipolar, 5 V). Can that do the job, and what does it cost the design?

## 2. The rule it must meet

`docs/tune-approach.md`: `check` refuses an approach whose **coarse step is larger than the Z range less the free amplitude**. `docs/cost.md` takes the Z range
as about **1 um** (the 2025 paper's Z buzzer, 0 to 10 V; their figure, not ours). So the step must be below `1000 nm - A`, where A is the free amplitude of the fork
in the air [unmeasured; tens of nm is the expectation, not a measurement].

## 3. The numbers

| Quantity | Value | Tag |
|---|---|---|
| Gear ratio of the 28BYJ-48 | 1:64 nominal; teardowns give 63.68:1 | [nominal] |
| Full steps per output turn | 2,038 (2,048 at exactly 64:1) | [derived] |
| Half steps per output turn | 4,076 (4,096) | [derived] |
| Screw: kit M3, pitch | 0.5 mm | [nominal] |
| Travel per full step, M3 | 0.5 mm / 2,038 = **245 nm** | [derived] |
| Travel per half step, M3 | **123 nm** | [derived] |
| Room left in the 1 um range at a full step | 755 nm for the amplitude A | [derived] |
| Speed at 500 steps per second | 125 um/s; 1 mm in 8.2 s | [derived] |
| `MOTOR_RATE` for 500 steps per second | 27,000,000 / 500 = **54,000** clocks (the default 27,000 is 1 kHz) | [derived] |
| Pull-in rate of the motor under load | about 500 to 1,000 steps per second at 5 V, unloaded | [nominal] |
| Backlash of the plastic gearbox | present and noticeable, size unknown | [unmeasured] |

So on paper the step passes at full step with about 3x margin and at half step with about 8x. The two things that can break it are **the real Z range** (if the
scanner moves 0.3 um and not 1 um, a full step fails) and **backlash**, which does not affect the step but affects the retract: after a reversal the first steps move
nothing. The approach goes one way, so only retracting by the motor needs an overshoot rule (not designed here).

## 4. The interface: what the FPGA drives

Today the design has `motor_step`, `motor_dir` and `motor_en_n` (pins 77, 49 and 85 in `gen/afm_top.cst`), the A4988 convention, and **every header pin is used**
(`docs/hs-order.md`). The ULN2003 board wants its coils directly. Two ways:

| | Pins | Step | What it needs |
|---|---|---|---|
| **A. four phases, half step** | 4 (one more than today) | 123 nm | a phase sequencer in the FPGA (8-state table, direction, enable = all off); **one pin found from somewhere** |
| **B. two pins, full step** | 2 (one fewer than today) | 245 nm | a 2-bit Gray counter in the FPGA; the other two phases are the complements, so **two inverters** outside (the kit's two MOSFETs and resistors, or any 74HC04) |

Option B works because the full-step two-phase-on sequence 1100, 0110, 0011, 1001 is (a, b, not a, not b) with (a, b) stepping 11, 01, 00, 10. Enable becomes
"hold the pins low" (the coils off). Recommendation: **B first**, because it frees a pin and the 3x margin is enough to start; A only if the bench test shows the
Z range is smaller than assumed. Neither is written; the module would be a small `motor_phase` in the generated top, between the existing step/dir driver and the pins.

**What stays in the FPGA either way** (the safety contract, unchanged): `MOTOR_MAX` (the longest command accepted), the refusal while the deadman has fired,
`MOTOR_POS` read back, and the rate register. The motor is **not** moved to a host GPIO: that would put the one actuator that can drive the tip into the sample
outside the hardware limit.

**Supply:** the motor is 5 V at about 240 mA [nominal]. It does not come from the FPGA board's 3.3 V; a separate 5 V supply with a common ground is needed, and the
Z piezo amplifier's supplies are not to be shared with it (the stepper's switching would couple into the ADC) [design intent, untested].

## 5. The bench test (Pi 4 on the desk, no FPGA needed)

The Pi 4's 3.3 V GPIO can drive the ULN2003 board directly, so the mechanics are settled before any gateware is written. Fixture: the motor, an M3 screw and nut in
a printed holder, a dial gauge or calipers, and the head's weight on it.

| Measure | Method | Pass |
|---|---|---|
| **Step size** | run 2,000 full steps, read the travel, divide; repeat 5 times, both directions | at or below 400 nm (a third of the 1 um budget less margin) |
| **Backlash** | run 500 steps one way, reverse, count the steps before the travel resumes | recorded; the approach rule (a retract overshoot) is written from it |
| **Maximum rate** | raise the step rate until steps are lost (travel against count) with the head's weight | at least 300 steps per second without loss |
| **Heating** | hold a coil energised for 10 minutes | the case under 50 C (it will sit near the fork) |

The numbers go into the table in section 3 in place of the tags. If the step is over 400 nm the plan switches to option A or to a finer screw (M2, 0.4 mm, gives
196 nm per full step [derived]).

## 5a. The circuit, and how to build it on the half-size breadboard

Two output pins, a and b, go to IN1 and IN2 of the ULN2003 board. Each also goes through an inverter to IN3 and IN4 (not a, not b). On the bench the pins are Pi 4
GPIO 17 (pin 11, a) and GPIO 27 (pin 13, b); in the instrument they are two FPGA pins. The kit has no 74HC04, so each inverter is **one MOSFET and one 10 kohm
pull-up**: the gate takes the signal, the source goes to ground, the drain is the output and is pulled to 5 V through the resistor.

| Breadboard row (columns a to e of a row are one node) | What is in it |
|---|---|
| 2 | MOSFET A gate (column c); wire from the Pi pin 11; wire to IN1 |
| 3 | MOSFET A drain (column c); 10 k resistor (column b, to row 6); wire to IN3 |
| 4 | MOSFET A source (column c); wire to the ground rail |
| 6 | the resistor's other leg; wire to the +5 V rail |
| 9, 10, 11, 13 | the same for MOSFET B, with Pi pin 13, IN2 and IN4 |

Rails: Pi pin 6 (ground) and the ULN2003 board's minus to the ground rail; Pi pin 2 (5 V) and the board's plus to the +5 V rail. **Two things to check before power:** the
MOSFET's leg order (read its marking and its datasheet; the table assumes gate, drain, source down the rows, and a different order means swapping which row each wire goes to),
and its gate threshold against 3.3 V (a part that needs more will not switch fully; a 74HC04 powered at 3.3 V is the fallback). The Pi's 5 V pin is fine for the bench test
(about 240 mA); the instrument uses its own supply (section 4). The Pi and board pins are male, so the wires that meet them need female ends; the kit's solid wires stay on the breadboard.

## 6. What this does not decide

* The real Z range and free amplitude (the first bench run on the scanner decides them).
* Whether the head's weight is within the motor's torque [unmeasured].
* The overshoot rule for retracting by the motor.
* Whether to keep the A4988 and the NEMA 8 in `cost.md`: **it stays listed until section 5 passes**. If it passes, the line saves EUR 34 to 70.
