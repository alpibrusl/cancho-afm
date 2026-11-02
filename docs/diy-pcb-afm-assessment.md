# Assessment: Wang et al. 2025, "A do-it-yourself AFM using printed circuit board framework"

> Written 2026-11-01. The paper is Wang et al., Meas. Sci. Technol. 36, 097003 (2025), doi:10.1088/1361-6501/ae08d1 (the DTU Orbit copy, peer-reviewed version, was read locally; **it is
> not in this repository: its notice says it may not be further distributed**, so read it from the DOI). Everything below about the instrument is **the authors' report, not reproduced here**.
> The web results behind the "gaps" are from one search session; nothing was opened beyond search summaries.

## What the paper gives

Optical pickup unit (DVD, Topray Top1300s) as the cantilever sensor; five piezo **disk buzzers** as the scanner, driven at
about +-10 V (30 x 30 um XY, about 1 um Z); an 11-piece **PCB** frame (optional suspension, 20.7 Hz mode); a **RMS-DC converter**
for the tapping amplitude; PID and the XY raster (triangle, or sine on the fast axis) on the controller's FPGA; 12-bit DAC
(0.24 nm per step in Z, 7.3 nm in XY, which they blame for their 0.48 nm step reading 0.34 nm); 40 lines/s clean, drift 6.2 nm/min.

## Would it work for us?

| Point | Fit |
|---|---|
| Piezo drive at +-10 V from a DAC and a **current amplifier** | **Helps a lot.** It removes the high-voltage amplifier that `design.md` section 5 names as the riskiest part. |
| PID and raster in an FPGA, sine fast axis | Same architecture as ours; the sine option is a feature for S8. |
| 12-bit DAC limits Z to 0.24 nm | Confirms we need **16-bit or better** converters (S3). 16 bits over 1 um is 0.015 nm per step. |
| Analog RMS-DC amplitude detector | We should do amplitude detection **in the FPGA** instead (digital), which needs an ADC fast enough for the cantilever: a 300 kHz cantilever wants well over 1 MS/s. This is new input to the S1/S3 converter question. |
| Controller is a **National Instruments myRIO** with LabVIEW | **Breaks the open-hardware policy.** Replaced by our Tang Nano plus converters. |
| OPU sensor | Fits the "upgrade path" in the shopping list, not the first build. Needs a commercial **closed cantilever** (Tap300-G, about 300 kHz, 40 N/m) and a home-made OPU signal amplifier. |
| **No design files in this paper**: no PCB outlines, buzzer layout, OPU amplifier or RMS-DC schematic, bill of materials | **The gap.** The paper cites its earlier work for these. |

Verdict: **the architecture and the scanner idea fit and are worth adopting; the paper alone is not enough to build from.** What we
cannot take from it: any schematic or frame file. What we can: the scanner concept, the drive range, the numbers to beat.

## The OSF files of the 2022 open controller (opened 2026-11-01)

Project https://osf.io/wgx4p/ (read through OSF's public API and the paper's PubMed Central page,
https://pmc.ncbi.nlm.nih.gov/articles/PMC9352456/). Liao et al., HardwareX 12, e00341 (2022).

| Folder | Contents | Use to us |
|---|---|---|
| Figures | 6 TIFFs | none |
| LabView source code and exe | source zip 16 MB, exe zip 357 MB | LabVIEW, needs NI tools. At most a **reference for the algorithm** (PID, sine raster); not read, not downloaded. |
| Circuit design | "Buffer circuit Ver 1.0" (schematic PDF, PCB PDF) and "Ver 2.0" (a zip, 282 KB) | a **buffer between the myRIO's analog pins and the scanner axes**. Downloaded and read only the Ver 1.0 schematic (one page, dated 2021-08-31): an AD8397 op-amp stage, +-12 V rails, a myRIO connector (MTP220), outputs named for fast and slow axes. It is for **their** scanner (the Stromlingo AFM), not for the buzzer scanner. The Ver 1.0 PCB PDF was refused by OSF (HTTP 403), and Ver 2.0 not downloaded. |
| Videos | 6 mp4 | none |

**Licence: the sources disagree, and the policy needs the real one.**

* The paper's own "Design file summary" and "Specification table" say **CC BY-SA 4.0** for the design files, the buffer circuits and the LabVIEW code.
* OSF's metadata for the project says **CC-By Attribution 4.0 International** (copyright holder blank, year 2022), and the press write-up also said CC BY 4.0.
* The two differ on **ShareAlike**. Until the authors clarify, treat it as the stricter, **CC BY-SA 4.0**: anything we derive from those files must be shared under the same licence.
* Both are Creative Commons licences, which the OSHWA definition accepts as covering the files but which say nothing about patents; the policy asks for "a licence that lets anyone build, study, change and sell", and CC BY / BY-SA do. This is a reading, not legal advice.
* The **Stromlingo AFM** the controller was built for is a **commercial product** (stromlinet-nano.org, listed at 2,999 USD with controller plus 199 USD for a table), and the paper states **no licence for it**. No repository was found. Treat it as **not open** until shown otherwise.
* The AD8397 and the other parts are commodity chips; nothing about them is a licence question.

**What this means:** the 2022 files give us one reference circuit and an algorithm reference, under a licence we can live with; they do not give us a scanner, a frame or an OPU amplifier. The missing-files gap stands.

Elsewhere in the search results: the 2015 Spanish-language paper on the buzzer scanner and astigmatic detection
(https://rmf.smf.mx/ojs/index.php/rmf/article/view/4146) has no schematic in its summary; no 2026 repository with a PCB frame,
buzzer-scanner design or OPU amplifier was found in any result.

## Next

1. Ask the authors (Liao, Hwu) which licence applies (BY or BY-SA) and whether the buzzer-scanner, PCB-frame and OPU-amplifier files exist anywhere; read the Ver 2.0 buffer circuit if we want it.
2. Treat the buzzer scanner as the first scanner candidate to test in S4; its +-10 V drive may let S5 (amplifier) shrink to a low-voltage current driver.
3. Fix the S3 converter spec from the cantilever: DAC at least 16 bits; ADC rate from the resonance frequency.
