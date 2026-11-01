# Tutorial: build an automatic AFM, step by step

> **Status: draft, written before anything was built.** Every step is a plan based on published hobby and academic work (see
> `../references.md` and `../shopping-list.md`). **No step has been carried out by this project.** Each part ends with a *Check*
> (a measurement and a pass criterion) and a *Verified by* line that says "nobody yet" until a person has done it. If a Check
> fails, stop and write down what happened, in an issue; do not push on.

For a person with basic electronics and no AFM experience. Time and cost are not claimed. Danger first: read
[`../manual/00-safety-and-tools.md`](../manual/00-safety-and-tools.md).

## Part 0. What you are building

A very sharp tip is held a few nanometres from a surface and moved across it. A feedback loop keeps the tip at a fixed distance
by moving it up and down; the up-and-down record is the picture. Here the "cantilever" is a **quartz tuning fork** vibrating at
32.768 kHz with a tungsten tip glued to one prong. As the tip nears the surface, the fork's vibration amplitude drops; the
controller keeps that amplitude at a chosen fraction. A computer program written in cancho does the rest automatically.

Check: you can say in your own words what the loop holds constant and what the picture is. *Verified by: nobody yet.*

## Part 1. Run the control loop in simulation (no hardware, start here)

1. Install the cancho compiler (https://github.com/alpibrusl/cancho).
2. In this repository run `cancho test tests/loop_test.cho sim/loop.cho --std`.
3. Read `sim/loop.cho`: the model, the amplitude law and the one-line control step.
4. Change the gain (`gain_shift`) in a test and watch how capture time and tracking lag change.

Check: all six tests pass; you can explain why a stronger gain captures faster but can ring. *Verified by: one run of this
project's author, 2026-11-01 (the six tests pass on a local compiler); the "explain" part is yours.*

## Part 2. Buy the parts

Use [`../shopping-list.md`](../shopping-list.md). Buy only rows 1 to 4, 9 and 10 now (a board, tuning forks, tungsten wire,
tools, a grating). Do not buy the amplifier or the motor until their chapters exist. Check: parts list ticked, each part's class
written down. *Verified by: nobody yet.*

## Part 3. Bring up the controller on the bench

1. Load the cancho-hdl "hello" design on the board (see cancho-hdl's `boards/tang-nano-20k/`), to prove the toolchain works.
2. Add your ADC and DAC modules; wire per their datasheets. *No tip, no scanner yet.*
3. Generate a ramp on the DAC and read it back on the ADC.

Check: the ramp read back matches the ramp written within the converters' stated error; write the error down. *Verified by:
nobody yet.*

## Part 4. Read the tuning fork

1. Mount one fork on a small PCB (the leads are fragile; a board is the hobbyist advice).
2. Drive it with a small sine from the DAC near 32.768 kHz and read its current through a transimpedance amplifier into the ADC.
3. Sweep the frequency and plot amplitude against frequency.

Check: a sharp resonance near 32.768 kHz is visible; write down its frequency and width. *Verified by: nobody yet.*

## Part 5. Make a tip

1. Etch tungsten wire to a point in a sodium-hydroxide bath with a small voltage (an etching jig is used by hobbyists). **Wear
   eye protection and gloves; follow chemical-safety practice.**
2. Look at it under a microscope or loupe: a smooth point, no bend.
3. Glue it to one prong of the fork. Re-measure the resonance (part 4).

Check: the resonance is still there, lower in frequency and width by an amount you write down. *Verified by: nobody yet.*

## Part 6. Mechanics, scanner and amplifier

Follow chapters 02 and 04 of the manual once their designs are written. Until then this part is blank on purpose: building a
high-voltage amplifier from a draft is not safe. Check (when written): the scanner moves the stated distance for the stated
voltage, measured with the grating later. *Verified by: nobody yet.*

## Part 7. First approach and first image

1. With the tip well away, run the **hardware limit and deadman test** (manual chapter 06). Do not continue if it fails.
2. Start the automatic approach from the cancho program with you watching and a hand on the power switch.
3. When the loop reports contact, scan the calibration grating, large and slow.

Check: the grating's period measured from the image agrees with its stated period; write the difference. *Verified by: nobody yet.*

## Part 8. Unattended runs and the record

Run a scan from the interface (slice S7); read the record file that lists every setting and every automatic decision.

## When something goes wrong

Retract first (the deadman does this on its own if the host goes quiet), then write down what you saw, with numbers, in an issue.
