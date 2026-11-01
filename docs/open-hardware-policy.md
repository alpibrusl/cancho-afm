# What "open hardware only" means here

> **Status: a proposal for the owner to confirm.** The goal as given is "only open hardware pieces". A microscope cannot be built
> from open designs alone, so the rule needs a boundary. This is the one proposed; change it before any part is bought.

## The rule

A part is **open** when its design files (schematic and layout for a board, CAD for a mechanical part, HDL or source for firmware)
are published under a licence that lets anyone build, study, change and sell it (the OSHWA definition,
https://www.oshwa.org/definition/). The files must be in a public place we can link to and archive here.

Three classes, and every part in `docs/manual/01-parts.md` carries one:

| Class | Meaning | Examples (to be confirmed per part) |
|---|---|---|
| **open** | files published under an open licence, linked | our own PCBs and printed parts; a published controller board |
| **commodity** | a standard component sold by many makers, no single design to open | screws, a laser diode, a photodiode, piezo plates, resistors, connectors |
| **closed, unavoidable** | made by one maker, design not published, and the instrument cannot work without it | **AFM cantilevers** (silicon probes), the FPGA chip itself |

**What this excludes:** a part that is closed *and* has an open alternative. A proprietary DAQ card (for example the National
Instruments myRIO used by one published open AFM controller) is excluded; its job is done by an open board or our own.

## What this means for the build

* The cantilever is the one part that is closed and has no open alternative. The manual says so and does not pretend otherwise. A
  quartz tuning-fork sensor (no optics) is a commodity alternative worth evaluating for a first build; it is a decision in the open
  issues, not a claim.
* **Not confirmed for any specific board** (Tang Nano 20K, Red Pitaya, an ADC/DAC module): whether its design files are published,
  and under what licence. Sipeed and Red Pitaya both publish documentation; **whether that meets the definition above has not been
  checked.** Each is marked UNCONFIRMED in the parts list until someone reads the licence.
* The software is all open: cancho, cancho-hdl, cancho-ui and this repository.
