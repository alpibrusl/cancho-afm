# Measuring with cancho while building

> Written 2026-11-04. **Mostly a design.** The only measuring program that has run on the board is `host/bringup.cho` (17 of 17 on 2026-11-02, nothing wired). `host/bench.cho` (`adc`, `dac`, `ramp`) is written, compiles,
> and was run against a throwaway fake of the board on a pseudo-terminal (it checks the arguments, the register traffic and the arithmetic); **it has never touched a real board**. Everything below
> marked *to write* is a plan built on the register table (`registers-table.md`) and the byte protocol (`host/proto.cho`); none of it has been run. The point: after every step of the
> tutorial, the instrument itself takes a second, independent reading next to the meter, because the one time that happened (`first-hardware.md`) it found a bug the whole simulation had missed.

## What the host can see and drive

* **Drive, with the loop off** (`CTRL` MANUAL bit): the four DACs directly, as codes: `MAN_Z`, `MAN_X`, `MAN_Y`, `MAN_D`. The fork drive's size and middle: `DRIVE_AMP`, `DRIVE_OFFS`; its frequency: `TUNING`.
* **Read:** the latest raw ADC conversion on each channel (`ADC0`, `ADC1`); how many conversions and detector windows have run (`NSAMP`, `NWIN`); the detector's I and Q sums and its amplitude figure (`I`, `Q`, `AMP`); the Z, X and Y the DACs are told (`ZOUT`, `XOUT`, `YOUT`); the raster's line and pixel; `STATUS` (fault, overflow, scan done); the motor's position and refusals.
* **A safety finding:** in MANUAL mode the DAC codes go straight to the outputs and **bypass `ZMIN` and `ZMAX`** (`gen/glue.cho`: `code_z = manual ? man_z : z_out`). Anything that uses `MAN_*` with an amplifier and a piezo attached can put the full range on the piezo, so `host/bench.cho` refuses unless told `bare`.
* **Protocol:** a read is 5 bytes out and 5 back, a write 9 out and 1 back, at 115200 baud (`host/proto.cho`).

## The limit that shapes everything: about a thousand readings a second

A read moves 10 bytes; 115200 baud is about 11.5 kB/s, so **at most about 1,100 reads a second, and fewer with the poll delay** *(an estimate from the byte count, not measured)*. A register holds only the *latest* value. So the host sees
**slow values and statistics, not waveforms**:

| It can | It cannot |
|---|---|
| a DC level, a mean, a noise figure (many reads of a quiet signal), a drift over minutes | a 50 us step edge: about 1 sample or none across it |
| the detector's amplitude at each drive frequency (the FPGA reduces the 32.768 kHz wave to I, Q and AMP, so the slow link is enough) | the 32.768 kHz wave itself |
| the settled DAC-to-ADC relation, point by point | a piezo's capacitance or any absolute voltage (that is the meter) |

For a step response there are two ways: an oscilloscope, or **a capture buffer in the gateware** (a block RAM filled at the ADC rate and read out afterwards over the same link). That second one is not designed, not in the register table, and is only an option.
*(An earlier version of the tutorial said the AD1 could capture the amplifier's step through a divider; with a latest-value register and this link it cannot, and the tutorial now says so.)*

## The measurements, by stage

"Exists" means a program in `host/` ran it. Every row ends with a number written down, next to the one in the tutorial's table.

| Part | Measurement | What the program does | Registers | Result it prints | State |
|---|---|---|---|---|---|
| 4 | the link and the registers | reads the identifier before any write; checks defaults, read-back and refusals | `ID`, defaults, `SETPOINT`, `MOTOR_MAX` | PASS or FAIL per check; exit code | **exists, run on the board** (`host/bringup.cho`) |
| 5 | a DAC code to a voltage | MANUAL on; sets a code; the operator reads the meter and types it back | `CTRL`, `MAN_*` | the code, the volts it should give; the operator reads the meter | *written 2026-11-04, `host/bench.cho`; run only against a fake serial port, never on a board* (`dac CH CODE bare`) |
| 5 | the ADC's offset, gain and noise | ADC run on; reads `ADC0` and `ADC1` N times with the input at GND, at 3V3 and at a divider | `CTRL`, `ADC0`, `ADC1`, `NSAMP` | mean, standard deviation, smallest and largest, in counts and in mV | *written 2026-11-04, `host/bench.cho`; run only against a fake serial port, never on a board* (`adc N`) |
| 5 | the DAC to ADC loop-back | writes a code, waits, reads the ADC, repeats over the range (a ramp) | `MAN_*`, `ADC0` | the error against code; the largest error; a straight-line fit's gain and offset | *written 2026-11-04, `host/bench.cho`; run only against a fake serial port, never on a board* (`ramp CH STEPS bare`) |
| 5 | noise floor and drift of the electronics | many reads of a quiet input over seconds, then minutes | `ADC0` | rms in counts (one AD1 step is 806 uV); drift per minute | the rms is in `adc N`; the drift over minutes is *to write* |
| 6 | the fork's resonance | for each frequency: sets `TUNING`, waits for the fork to settle and `NWIN` to advance, reads `AMP`, `I`, `Q` | `TUNING`, `DRIVE_AMP`, `NWIN`, `AMP`, `I`, `Q` | amplitude against frequency; the peak, its width, the Q (peak frequency over full width at half the peak power) | *to write* |
| 6 | the baseline and the C0 trimmer | the same sweep, repeated while the trimmer is turned; reports the peak-to-baseline ratio | as above | the ratio (design: about 84 matched, 6.8 with no trimmer, assumed fork) | *to write* |
| 6 | the drive reaching the fork | steps `DRIVE_AMP`, reads `AMP` at resonance | `DRIVE_AMP`, `AMP` | amplitude per drive step; where it saturates | *to write* |
| 8 | the three piezo drivers' DC points | MANUAL on; sets named codes (0, mid, full) for Z, X and Y and tells the operator what the meter should show | `MAN_Z/X/Y` | the expected number, a place for the read one | *to write*: `dac` as written refuses unless `bare` (nothing but a meter on the DAC); with the amplifier connected it needs a cap on the code |
| 8 | an amplifier's step response | not by the host (see above) | none | a scope reading, or a capture buffer | **not possible today** |
| 9 | the coarse motor | enables it; commands steps; reads where it thinks it is; the operator confirms the mark | `MOTOR_MAX`, `MOTOR_CMD`, `MOTOR_POS`, `MOTOR_STATUS` | steps asked, position read, refused flag | the register checks exist; the turn test is *to write* |
| 10 | the Z limit | sets `ZMIN` and `ZMAX`, asks for a Z past them, reads `ZOUT` | `ZMIN`, `ZMAX`, `ZOUT` | the Z it reports against the limit; the operator checks the meter too | the behaviour is tested in simulation (`tests/board_test.cho`); the host program that measures it on the board is *to write* |
| 10 | the deadman | sets `TIMEOUT`, stops writing `KICK`, reads `STATUS` and `ZOUT` | `TIMEOUT`, `KICK`, `STATUS`, `ZOUT` | the time to the fault; Z at the retract value | the behaviour is tested in simulation (`tests/board_test.cho`); the host program is *to write* |
| 11 | the approach | steps the motor, reads `AMP` after each step, stops at the setpoint | `MOTOR_CMD`, `AMP`, `SETPOINT` | amplitude against step | exists against the twin (`host/session.cho`); `host/tty_run.cho` was compile-checked only |
| 11 | the first image | runs the raster and reads `ZOUT` per pixel; the report program levels it and measures the period | `NPIX`, `NLINES`, `PIXLINE`, `ZOUT` | the image; the grating's period | exists against the twin; never on the board |

## How a measurement should be written

* **A bench program refuses to start on the wrong board**, as `bringup.cho` does: it reads `ID` first and stops if it is not `0xAF500001`.
* **It writes only what the step needs**, and restores it. Anything that moves a piezo or the motor needs the limits set and read back first (tutorial Part 10).
* **It prints the number and the expected number side by side**, and exits non-zero on a FAIL, so the same program is a check on the bench and in `test_all.sh`.
* **The twin runs the same program first.** A bench program that passes against the twin and then fails on the board has told you something about the board, which is the point.

## What the tutorial's tables should say

A row that needs the host to set a code or read the ADC says so, and says *to write* until the program exists. A row that needs the meter or a scope says that. No row claims a reading the instrument cannot yet take.

## Open

1. Whether to add a capture buffer to the gateware for step responses, or to buy a cheap USB oscilloscope; a capture buffer would also help to look at the fork's ring-down.
2. The real read rate over the serial link, measured with a program that reads `NSAMP` in a loop.
3. Whether `TUNING` has fine enough steps for a fork of Q several thousand: at 262,136 samples per second (27 MHz / 103) one hertz is about 16,384 counts, so the register is fine enough; the settling time is the limit (about Q / (pi f0), roughly 50 ms for a Q of 5,000, so wait a few times that at every point).
