# The host program

> Written 2026-11-02. `host/*.cho`. The session and its codec run against the twin (`docs/simulator.md`); the serial runner `host/tty_run.cho`
> has been **compile-checked on the Raspberry Pi and never run** against any board.

| File | What |
|---|---|
| `host/regs.cho` | the register table: the one place indexes, names, access kinds, reset values and bit fields are written; the host and the twin use its names, and it generates the contract, the C header, the doc table and a Verilog check (`docs/registers.md`) |
| `host/proto.cho` | the byte protocol: build a write or read request, read the answer. Tested against the bytes the Verilog bridge expects. |
| `host/script.cho` | a script is a list of register operations (write, read, wait, motor) |
| `host/session.cho` | the automatic run: builds a script for each stage and decides from the answers what comes next; no I/O of its own |
| `host/twin_link.cho`, `host/run_twin.cho` | the serial bridge in software, and a runner that executes a script against the twin through the real bytes |
| `host/tty_run.cho` | the runner for the real board over `/dev/ttyUSB1` at 115200 baud; edition 8 (the Tty capability), so it needs the newer compiler |
| `host/bringup.cho` | first contact with the real board: reads the identifier, checks the defaults and refusals and that the motor fails closed; run on the Pi, 17 of 17 passed (`docs/first-hardware.md`) |
| `host/demo_twin.cho` | runs the whole procedure on the twin and prints the run record and the image |

**What `tty_run.cho` can and cannot do.** Its declared authority (from `cancho authority`) is `poll`, `tty_open("/dev")`, `tty_read` and `tty_write`: no network,
no files, no other programs, no foreign code. Before it writes anything it reads the identifier register and exits if it is not `afm_top`'s
(0xAF500001), so pointing it at another design on the same serial port (the robot project's, for one) changes nothing. The approach drives the coarse motor through the board's motor registers (MOTOR_MAX is set first, and the board refuses longer commands).

**First use on a board** belongs on the bench with no tip, no scanner and the amplifier unpowered (tutorial Parts 5 and 10); the DA3 outputs
can be read on a meter. The session writes the limits first and reads them back; the board fails closed until they are set.
