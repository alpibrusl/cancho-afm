# 00 Safety and tools

> Draft, unverified. These are general hazards of this kind of instrument, not a safety assessment of this design; get one from
> someone qualified before powering it.

* **Laser.** The optical sensor needs a laser diode. Never look into the beam or at its reflection; use the lowest-power module that
  works, block the beam path when aligning, and know your laser's class from its datasheet. An alignment target (card) is used
  instead of the eye.
* **High voltage.** Piezo scanners are driven by an amplifier that can reach tens to over a hundred volts. Fuse it, enclose it,
  discharge it before opening, and never touch the scanner leads powered.
* **Static.** Cantilevers, the photodiode and the FPGA are damaged by static; use a wrist strap.
* **The tip and the sample.** The tip is destroyed by contact at speed. The hardware limit of chapter 05 exists for this and is
  tested **before** a tip is mounted (chapter 06).
* **Never leave it unattended** until chapter 06's checks have passed and the deadman has been seen to retract the Z drive.

## Bench

A multimeter; an oscilloscope (or the FPGA recorder of cancho-hdl, which is not yet a substitute); a soldering station; a 3D
printer (for the printed parts, if the frame is printed); a stable table, and a heavy base on soft support for vibration
isolation (the design of the isolation is an open question, `design.md` §5).

Verified by: nobody yet.
