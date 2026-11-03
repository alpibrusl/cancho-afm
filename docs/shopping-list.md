# Shopping list

> **Status: draft, nothing bought.** Links are ones found in search results on 2026-11-01. **Prices are from those results, may be
> stale or in different currencies, and shipping, tax and import duty are not included.** Where no link is given, the row says
> what to search for; no product page was invented. Before buying, read `open-hardware-policy.md` (revised 2026-11-01: cheap, easy-to-buy parts; open hardware not required for bought parts).

## Route chosen for the first build: a quartz tuning-fork AFM

It needs no laser and no optical alignment, which removes the hardest and riskiest part for a first build. The route is
documented by hobbyists (https://hackaday.io/project/206429-a-working-diy-quartz-tuning-fork-afm , self-reported, unverified).
The optical-pickup route (below) is the upgrade path. **Whether either route works for you has not been tried by this project.**

| # | Part | Class | Where | Reported price | Notes |
|---|---|---|---|---|---|
| 1 | Controller board, option A: **Sipeed Tang Nano 20K** | UNCONFIRMED (licence not read) | docs: https://wiki.sipeed.com/hardware/en/tang/tang-nano-20k/nano-20k.html ; sold on Sipeed's AliExpress store and by retailers | about USD 25 in 2023 (Hackster), current price unchecked | no ADC/DAC on board; works with cancho-hdl today |
| 1 | ~~Controller board, option B: Red Pitaya STEMlab 125-14~~ | **dropped 2026-11-01**: price (USD 490 in the results); not needed | | | |
| 2 | ADC and DAC modules (only with option A): **candidates in `converter-candidates.md`**: first bench **1 x Pmod AD1** and **4 x Pmod DA3** | commodity, schematics published by Digilent (not an open licence) | **DigiKey France**: https://www.digikey.fr/en/products/detail/digilent-inc/410-064/3902823 , https://www.digikey.fr/en/products/detail/digilent-inc/410-241/4090066 | **EUR 28.41 and 32.36 each, excluding VAT, in stock, 4-week lead time** (seen 2026-11-01); about EUR 189 for the five with French VAT. TME and Farnell Ireland show them withdrawn or not stocked, so buy all five together | before buying, read the AD1 filter corner and the AD5541A's settling time; prices for everything else are in `cost.md` |
| 3 | **Quartz tuning forks, 32.768 kHz** (bag of ten or more) | commodity | search "32.768 kHz tuning fork crystal cylinder"; the company Mad City Labs is reported to sell them for AFM use (no link checked) | a few USD, unchecked | handle gently: the leads are fragile |
| 4 | **Tungsten wire**, about 0.1 to 0.25 mm, for tips | commodity | search "tungsten wire 0.1 mm" at a lab-supply shop | unchecked | tips are etched electrochemically (tutorial part 5) |
| 5 | Sample stage piezo (a plate, tube or a flexure) | commodity | search "piezo tube scanner" or "piezo stack actuator" | unchecked | sets the scan range and the voltage |
| 6 | Piezo amplifier parts (high-voltage op-amps, a DC-DC supply, enclosure, fuse) | commodity parts, **our design** | search per the chapter 04 design once it exists | n/a | not yet designed; do not buy before |
| 7 | Coarse approach motor and screw (stepper plus fine-pitch screw) | commodity | search "NEMA 8 stepper lead screw" | unchecked | |
| 8 | 3D printer or printed parts, M2 to M3 screws, nuts | commodity | any | n/a | the frame design is not finished |
| 9 | Lab tools: multimeter, soldering station, fine tweezers, a stereo microscope or a 10x to 30x loupe | commodity | any | n/a | |
| 10 | **Calibration grating** (a stated period, for example 1 to 10 micrometres) | commodity | search "AFM calibration grating TGZ" at an AFM-probe supplier such as https://www.nanoandmore.com | unchecked | the grating's stated period is the reference |
| 11 | **AFM cantilevers** (second stage; buy a handful) | closed, allowed by the owner 2026-11-01 | https://www.nanoandmore.com/AFM-Probe-Tap190Al-G | box of 10: USD 210 on that page; some pages say they do not ship to every country | Tap190 is 190 kHz, 48 N/m. The 2025 paper used a 300 kHz, 40 N/m tapping cantilever for images and a 10 kHz, 0.03 N/m soft one for the speed test. **Needs a deflection sensor (row 12); the tuning fork does not.** |
| 12 | Deflection sensor for cantilevers: a **DVD optical pickup** salvaged from a drive, or a laser diode and a photodiode | commodity / salvage | any old DVD drive; the paper used a Topray Top1300s | n/a | the pickup avoids aligning a laser by eye; its signal amplifier is not published and would be ours |

## The cantilever route: second stage (allowed 2026-11-01)

A cantilever plus a DVD optical pickup, piezo disk buzzers as the scanner and a circuit-board frame is what Wang et al., 2025,
report (`diy-pcb-afm-assessment.md`): 40 lines per second clean and 6.2 nm/min drift (their numbers, not reproduced). It is the
route to a faster instrument than the tuning fork can be (the fork's response time is about a tenth of a second at best). It adds
rows 11 and 12 and an amplifier for the pickup that is not designed. Buzzer disks that scan at low voltage is a claim to test.

## What this list does not cover

Vibration isolation, a draught enclosure, an electrical-noise shield, a laser (optical route), and the amplifier's final parts.
Each waits for its design.
