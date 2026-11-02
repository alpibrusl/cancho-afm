# First contact with the real board

> 2026-11-02. A Sipeed Tang Nano 20K attached to a Raspberry Pi (Linux, aarch64), loaded with the controller built by `gen/build_fpga.sh` from the SystemVerilog this
> project generates. **The only hardware this project has run on.** Nothing was wired to the board's header pins.

## What was done

1. The OSS CAD Suite 2026-11-01 (Yosys 0.70, nextpnr-himbaechel 0.11.1, Apycula, openFPGALoader 1.2.0) was already installed on the Pi (`~/tools/oss-cad-suite`).
2. `gen/build_fpga.sh` built `afm.fs` there (7.3 MB): 6,000 of 20,736 LUT4 (28%), 3,469 of 15,552 flip-flops (22%), one block RAM, 71.9 MHz estimated against the 27 MHz clock.
3. The board was checked first: `openFPGALoader --detect` saw a Gowin GW2A(R)-18(C) (idcode 0x81b), and no process held its serial ports. The owner had said the robot project
   was not using the board. `openFPGALoader -b tangnano20k afm.fs` loaded it into **SRAM**: a power cycle restores the board to whatever it held.
4. `bench/bringup_serial.py` talked to the board's second USB serial port (`/dev/ttyUSB1`, 115200 baud). It reads the identifier before writing anything and stops if it is not afm_top's.

## Result: 19 of 19 checks passed

The identifier (0xAF500001); CTRL, ZMAX and MOTOR_MAX all 0 at power-on; the SAMPLE_DIV, TUNING and MOTOR_RATE defaults; a write and its read-back; a signed 32-bit word read back
whole; writes to the read-only STATUS and ID refused; a read of an unmapped register refused; with the motor enabled and MOTOR_MAX = 0 a command refused and the position unchanged; the motor disabled
again; STATUS idle and no ADC samples while ADC run is off; and 50 identifier reads in a row with the framing in step.

**What this confirms:** the clock pin (4), the serial pins (69 and 70) and the baud-rate divider (27 MHz / 234) are right; the generated bridge, register file and motor driver's registers behave on
silicon as in simulation; the design fails closed at power-on.

**What it does not:** every pin below (the ADC, the four DACs, the motor driver, the LED mapping) has no wire on it, so none has been checked; the Pmods have not been bought; no analog signal exists.
The loop, the detector and the raster were not run (they need an ADC); the LEDs were not looked at.

## Second run, 2026-11-02: the same checks in cancho, and a bug the hardware found

`host/bringup.cho` repeats the checks as a cancho program over the Tty capability (edition 8, compiled and run on the Pi with the newer compiler): **17 of 17 passed, exit code 0**.
Its declared authority is `heap`, `io_write`, `poll`, `tty_open("/dev")`, `tty_read` and `tty_write`: no files, no network. So the project's own host path, in cancho, works against the board.

**The first run refused the board, correctly and usefully.** The program reads the identifier before writing anything and stops if it is wrong. It stopped, because it compared against
2,941,716,481, which is a wrong decimal copy of 0xAF500001 (the right one is 2,941,255,681). The twin returned the same wrong number, so every test in the repository had passed. The session's
identity check and the serial runner's safety check would have refused the real board. It is now written as the hex literal `0xAF500001` in all of them, and `test_all.sh` checks that the Verilog,
the twin and the host all say the same thing. This is the kind of mistake only a second, independent implementation (the real board) catches.

## Third run: the host code now uses the register table

After the register table (`host/regs.cho`) replaced the bare numbers in the host code, the same `host/bringup.cho` was run on the board again: **17 of 17, exit code 0**.

## Next on the bench

Order the Pmods (`buy-now.md`), wire the AD1 and one DA3 per `gen/afm_top.cst`, and run the tutorial's Part 5 check (a ramp on the DA3 read back by the AD1) with the host program.
