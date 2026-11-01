# Shopping list

> **Status: draft, nothing bought.** Links are ones found in search results on 2026-11-01. **Prices are from those results, may be
> stale or in different currencies, and shipping, tax and import duty are not included.** Where no link is given, the row says
> what to search for; no product page was invented. Before buying, read `open-hardware-policy.md`: each row says whether the part
> is open, commodity or closed.

## Route chosen for the first build: a quartz tuning-fork AFM

It needs no laser and no optical alignment, which removes the hardest and riskiest part for a first build. The route is
documented by hobbyists (https://hackaday.io/project/206429-a-working-diy-quartz-tuning-fork-afm , self-reported, unverified).
The optical-pickup route (below) is the upgrade path. **Whether either route works for you has not been tried by this project.**

| # | Part | Class | Where | Reported price | Notes |
|---|---|---|---|---|---|
| 1 | Controller board, option A: **Sipeed Tang Nano 20K** | UNCONFIRMED (licence not read) | docs: https://wiki.sipeed.com/hardware/en/tang/tang-nano-20k/nano-20k.html ; sold on Sipeed's AliExpress store and by retailers | about USD 25 in 2023 (Hackster), current price unchecked | no ADC/DAC on board; works with cancho-hdl today |
| 1 | Controller board, option B: **Red Pitaya STEMlab 125-14** | UNCONFIRMED | https://redpitaya.com/shop/ | starter kit USD 490 on the official shop in the results | has two 14-bit 125 MS/s inputs and outputs, so no extra converters; a different FPGA toolchain from cancho-hdl's |
| 2 | ADC and DAC modules (only with option A) | open, to be chosen | none chosen: search for a 16-bit SPI ADC and a 16-bit SPI DAC module with published schematics | n/a | speed and resolution come from slice S1 |
| 3 | **Quartz tuning forks, 32.768 kHz** (bag of ten or more) | commodity | search "32.768 kHz tuning fork crystal cylinder"; Mad City Labs sells them for AFM use (https://madcitylabs.com) | a few USD, unchecked | handle gently: the leads are fragile |
| 4 | **Tungsten wire**, about 0.1 to 0.25 mm, for tips | commodity | search "tungsten wire 0.1 mm" at a lab-supply shop | unchecked | tips are etched electrochemically (tutorial part 5) |
| 5 | Sample stage piezo (a plate, tube or a flexure) | commodity | search "piezo tube scanner" or "piezo stack actuator" | unchecked | sets the scan range and the voltage |
| 6 | Piezo amplifier parts (high-voltage op-amps, a DC-DC supply, enclosure, fuse) | commodity parts, **our design** | search per the chapter 04 design once it exists | n/a | not yet designed; do not buy before |
| 7 | Coarse approach motor and screw (stepper plus fine-pitch screw) | commodity | search "NEMA 8 stepper lead screw" | unchecked | |
| 8 | 3D printer or printed parts, M2 to M3 screws, nuts | commodity | any | n/a | the frame design is not finished |
| 9 | Lab tools: multimeter, soldering station, fine tweezers, a stereo microscope or a 10x to 30x loupe | commodity | any | n/a | |
| 10 | **Calibration grating** (a stated period, for example 1 to 10 micrometres) | commodity | search "AFM calibration grating TGZ" at an AFM-probe supplier such as https://www.nanoandmore.com | unchecked | the grating's stated period is the reference |
| 11 | Optional: AFM cantilevers (only for the optical route): **closed, unavoidable** | closed | https://www.nanoandmore.com/AFM-Probe-Tap190Al-G | box of 10: USD 210 on that page; some pages say they do not ship to every country | Tap190 is 190 kHz, 48 N/m |

## The optical-pickup route (upgrade, from published work)

A 2025 paper reports a do-it-yourself AFM built from consumer-electronics parts: an **optical pickup unit (OPU) from a DVD drive** as
the cantilever sensor, **piezo disk buzzers** as the scanner, a printed-circuit-board frame, 40 lines per second and 6.2 nm per
minute thermal drift (Wang et al., *Measurement Science and Technology* 36, 2025; abstract at
https://orbit.dtu.dk/en/publications/a-do-it-yourself-atomic-force-microscope-using-printed-circuit-bo/ , results self-reported).
An older guide by the same group's design lineage costs USD 500 to 1,000 without a controller
(https://www.instructables.com/id/A-Low-Cost-Atomic-Force-Microscope-低成本原子力顯微鏡/). Their open controller (CC BY 4.0, uses
a proprietary National Instruments myRIO, so it breaks this project's rule) is at
https://data.mendeley.com/datasets/kz3rx67cgw . This project would replace the myRIO with the controller of slice S3.

## What this list does not cover

Vibration isolation, a draught enclosure, an electrical-noise shield, a laser (optical route), and the amplifier's final parts.
Each waits for its design.
