# FPGA boards: licence check and alternatives

> Checked 2026-11-01 from the vendors' and OSHWA's public pages and the GitHub licence API. Prices and stock were **not** checked.
> Since the owner relaxed the policy (bought parts need not be open), this is for information and for a fallback board.

## The Tang Nano 20K (the board we have)

* Sipeed's wiki lists a datasheet, **schematic**, BOM and 3D file for download (dl.sipeed.com), and says **no licence** for them;
  the page's only rights text is a copyright line. Example code is on GitHub (sipeed/TangNano-20K-example; no licence found by
  the API). So: **schematics published, licence none stated**. Not open hardware by the OSHWA definition; **acceptable under the
  current policy** (cheap, easy to buy, about USD 25 in 2023 per the CNX Software review).
* No ADC or DAC on the board; the open toolchain (Yosys, nextpnr-himbaechel, Apycula, openFPGALoader) is what `cancho-hdl` already uses.
* Gowin's vendor IDE is proprietary; we do not need it.

## Boards that are open hardware (if we ever want one)

| Board | FPGA | Hardware licence | Source |
|---|---|---|---|
| ULX4M | Lattice ECP5 | **CERN-OHL-S-2.0**, docs CC BY-SA | OSHWA HR000013, Nov 2021; repo github.com/intergalaktik/ulx4m (last push Apr 2025; GitHub API shows a LICENSE.md it cannot classify) |
| OrangeCrab | Lattice ECP5 | **CERN-OHL-1.2** (hardware), MIT (software) | OSHWA AU000015, Sep 2023; repo github.com/gregdavill/OrangeCrab (last push Nov 2024) |
| ULX3S | Lattice ECP5 | OSHWA lists "Other"; repo has a LICENSE.md the API cannot classify (read it before relying) | OSHWA HR000011, Oct 2021; github.com/emard/ulx3s (last push Apr 2025) |
| Icey | iCE40 (family not confirmed in the results) | CERN-OHL-P-2.0 | OSHWA CA000078, listed Aug 2026 |
| iCEBreaker | iCE40 | not found | no OSHWA record found in the results |

Not checked: price, stock, converter content, and whether any fits the loop (the PID needs few LUTs; a small ECP5 or iCE40 would).
A board with on-board converters is a convenience only: the DAC needs 16 bits or better and the ADC a rate from the cantilever's
resonance, so separate converter modules are expected either way.
Search-result claims that the ULX3S has an on-board ADC and DAC, and that a "GammaPi Zero" board has a 12-bit ADC and DAC, are from
secondary pages and **unverified**.
