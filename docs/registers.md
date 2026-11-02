# Register map of `afm_top`

> Written 2026-11-01. Defined by `gen/glue.cho` (the register file, in `emit_top`) and exercised by `gen/afm_top_tb.v`. **Simulated only; not run
> on a board.** This is a hand-written map, not yet a `.chw` contract of cancho-hdl; turning it into one (so the host code, the C header and
> the test all come from one file) is the next step for it.

**Wire protocol** (the same as cancho-hdl's board bridge, so its host programs such as `boards/tang-nano-20k/host/probe.cho` work): 115200 baud,
8N1, over the board's second USB serial port (on the Pi, `/dev/ttyUSB1`). The host sends `W a3 a2 a1 a0 d3 d2 d1 d0` and gets one byte, or
`R a3 a2 a1 a0` and gets one byte and then `d3 d2 d1 d0`. Big-endian. The first byte is `00` (OKAY) or `02` (SLVERR: an address with no register,
a write to a read-only register, an address that is not `0x400000xx` or not word-aligned). Bytes between commands are ignored.

**Address** = `0x40000000 + 4 * index`.

**Safe defaults after power-on:** `CTRL` = 0 (nothing runs) and every limit and the initial and retract Z = 0, so the Z output sits at 0 until the
host sets limits ("fails closed"). The host reads the limits back to confirm them.

**The table of registers is generated:** [`registers-table.md`](registers-table.md), from `host/regs.cho` (the one place indexes, names, access kinds, reset values and bit fields are written).
From the same table: the cancho-hdl contract [`hw/afm.chw`](../hw/afm.chw) (checked by `chw check`) and the C header [`hw/afm.h`](../hw/afm.h) made from it, a Verilog check of the real
register file (`gen/regs_tb.cho`), and a test of the twin (`tests/contract_test.cho`); `sh test_all.sh` fails if a generated file is stale. What the bits and values mean:

* **CTRL:** bit 0 RUN (the loop), 1 DRIVE_EN, 2 SCAN (the raster, needs RUN), 3 MANUAL (the DACs follow MAN_Z/X/Y/D), 4 ADC_RUN (sampling and the detector), 5 MOTOR_EN (the STEP/DIR/EN pins; EN is active low and inactive at power-on).
* **STATUS:** bit 0 FAULT (the deadman latched), 1 LOOP_BUSY, 2 OVERFLOW (the detector's sums left +-8,388,607; sticky, steps are skipped while it is set), 3 SCAN_DONE, 4 ADC_BUSY.
* **Units:** Z, ZMIN, ZMAX, ZINIT, ZRETRACT and ZOUT are picometres (the Z DAC code is Z / 16); X, Y, X0, Y0, DX, DY and the DRIVE and MAN registers are DAC codes; TIMEOUT and MOTOR_RATE are FPGA clocks (27 MHz); gains are Q16 (65536 = 1.0).
* **TUNING** is 2^32 x f / fs (536870912 = 8 samples per period); **SHIFT** shifts the detector figure right before the loop; **SETPOINT** is a signed 32-bit word.
* **Fail closed:** after power-on every limit and the motor's MOTOR_MAX are 0 and CTRL is 0, so nothing moves or runs until the host sets them.
* **KICK** (any write) restarts the deadman; **MOTOR_CMD** takes a signed number of microsteps, positive toward the sample, refused if longer than MOTOR_MAX, ignored if the driver is disabled, held by a fault, busy, or the number is 0.
* **Not registers:** PIXLINE is the raster's pixel (bits 31:16) and line (15:0); MOTOR_STATUS bit 0 BUSY, 1 ENABLED, 2 REFUSED (the last command was too long).

**Data flow, as built:** a conversion every SAMPLE_DIV clocks -> the detector (the AD1's offset-binary value minus 2048) -> one window figure ->
`(figure >> SHIFT) - SETPOINT` -> one loop step -> Z -> the Z DAC (`Z / 16`, so 1 LSB is 16 pm); every PIXDIV-th loop step advances the raster one pixel
(X and Y go to their DACs as codes). The drive is `DRIVE_OFFS + DRIVE_AMP x sin(phase)` at the detector's own phase, written to the fourth DAC once
per conversion.
