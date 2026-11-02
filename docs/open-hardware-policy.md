# Policy: what we build from, and what we publish

> **Status: decided by the owner on 2026-11-01**, revised the same day: the first version asked for strictly open boards; the owner
> then said **open hardware is not required for bought parts, only that they are cheap and easy to buy.** The licences in the table
> are *proposed* from "use an EU licence" and still to be confirmed by the owner.

## The rule

1. **Buy cheap, common parts.** A part is acceptable if anyone can buy it easily and cheaply: development boards, converter modules,
   op-amps, piezo disks, quartz tuning forks, tungsten wire, stepper motors, screws, PCBs from any fab. It does **not** have to be
   open hardware. A board such as the Sipeed Tang Nano 20K (about USD 25) is acceptable even though its design files carry no
   licence (checked 2026-11-01, see `fpga-boards.md`).
2. **Avoid what is expensive or hard to get.** Out, for that reason and not for being closed: the National Instruments myRIO and
   LabVIEW, the Red Pitaya (USD 490 in the results) and ready-made AFM kits. **AFM cantilevers are allowed** (the owner, 2026-11-01:
   "we can buy the cantilevers"): a closed part, about USD 21 each in the results, bought in small numbers; a cantilever needs a
   deflection sensor, so a DVD optical pickup (salvaged from a drive) or a laser and photodiode comes back with it, for the
   second-stage build. The first build still uses a quartz tuning fork with a tungsten tip, which needs neither.
3. **What we make is open.** Our software, gateware, schematics, PCB layouts, CAD and docs are published in this repository under
   the licences below, so anyone can rebuild the instrument from our files and cheap parts.
4. **Don't copy others' files into our designs** unless their licence is read and compatible; we read published work and design our own.

## Licences **(proposed; owner to confirm)**

| What | Licence |
|---|---|
| Software and generated gateware (cancho programs, SystemVerilog, host tools) | **EUPL-1.2** |
| Hardware we design (schematics, PCB, mechanical CAD) | **CERN-OHL-S-2.0** (or **CERN-OHL-W-2.0** if weaker is preferred) |
| Documentation | **CC BY 4.0** |

No licence file has been added to the repository yet. This is not legal advice.

## What this means for the build

* Controller: Tang Nano 20K (owned already), plus cheap SPI ADC and DAC modules, 16 bits or better for the DAC. The gateware is
  generated from cancho, so moving to another board later (see `fpga-boards.md`) changes pin files and the board glue, not the loop.
* Scanner: piezo disks or a plate, driven by an amplifier we design; the 2025 paper reports about +-10 V is enough for buzzer
  disks (their figure, unverified here).
* Sensor: tuning fork, read by our own amplifier and the FPGA's digital detector.
