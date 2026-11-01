# References

> Read on 2026-11-01 from web search summaries, **not from the papers and not checked against their repositories**. Treat every line
> as a pointer to read, not as a fact this project relies on.

* **An open-source and low-cost AFM controller for high-speed imaging** (HardwareX; dataset on Mendeley:
  https://data.mendeley.com/datasets/kz3rx67cgw). Reported: under about USD 4,000 in total, a 512x512 image in 9.3 s, 55 lines/s.
  Reported build: a National Instruments myRIO-1900, an open buffer circuit, an Arduino-based controller, a simplified stage.
  **The myRIO is proprietary hardware**, so this design's "open" covers its files, not its parts list. Press summary:
  https://hackster.io/news/this-4-000-open-source-high-speed-atomic-force-microscope-is-a-nanoscale-imaging-marvel-69e5786fd824
* **Gwyscope** (HardwareX, July 2023, Valtr et al.): an open-hardware SPM DSP on a Red Pitaya (Zynq: feedback loop in Verilog in the
  FPGA, Linux and C on the ARM side, Ethernet to a workstation), custom Eurocard PCBs, under about USD 1,500. Summary:
  https://hackaday.com/2024/01/31/low-cost-dsp-for-scanning-probe-microscopy . The Red Pitaya has two 125 MS/s 14-bit analog
  inputs and outputs (https://redpitaya.readthedocs.io/en/latest/intro.html).
* **GXSM** (GPLv2): scanning-probe acquisition and visualisation software for STM, contact AFM and NC-AFM; it runs against a
  commercial DSP. https://github.com/pyzahl/Gxsm3 , https://gxsm.sourceforge.net/
* **CO-AFM** (Hackaday.io, 2014): a 3D-printed, CD-ROM-drive-based low-cost AFM; whether its files were ever fully released was not
  confirmed. https://hackaday.io/project/2169-co-afm-cheap-open-source-atomic-force-microscope
* **OpenAFM / LEGO2NANO** (Institute of Making): a DVD optical pickup as the sensor, an Arduino Nano, a 3D-printable stage; current
  status not found. https://www.instituteofmaking.org.uk/blog/lego2nano-is-now-openafm
* A 3D-printed scanner head on MakerWorld (mechanics only): https://makerworld.com/models/1264272
