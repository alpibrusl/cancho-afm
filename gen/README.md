# gen: SystemVerilog generated from cancho

`pid_ir.cho` writes the PID step once as a dataflow graph (`ir.cho`). From that one graph:

* `ir.eval` computes it in cancho (64-bit integers; the reference);
* `ir.ranges` finds the value range of every node from the declared input ranges (`pid_ir.input_ranges`), and `ir.width` the fewest bits for it;
* `ir.stages` / `ir.delays` place a register after each multiply and clamp and balance every other path;
* `main.cho` + `sv.cho` print the pipelined, narrow-width module `pid_step` (clock, ten 32-bit input words, three 32-bit outputs,
  `LATENCY` cycles, one new input set per cycle, no reset: the state lives outside).

`sv.cho` also emits `z_loop`, the closed loop around it: the state (integral, previous error, Z) in registers, one sample at a time (`start` + `err`, then `LATENCY + 1` = 4 clocks), a hardware clamp of the output to the host's `[zmin, zmax]`, and a deadman (no `kick` for `timeout` clocks latches `fault`; Z then goes to the clamped `zretract`; new samples are refused until `rst`).

`sim/pid.cho` is an independent hand-written copy of the same step, kept as a cross-check.

    sh gen/check.sh        # generate, simulate in Icarus Verilog, compare; needs iverilog

The input contract is a **choice**, in `pid_ir.input_ranges`: err and prev signed 16-bit; gains 12-bit unsigned Q8 (up to 16.0);
integral and its limit 17-bit; z and its limits 20-bit unsigned (up to 1,048,575 pm). Inputs outside it are not covered.

## Measured (2026-11-01; Icarus 13.0, Yosys 0.70 `synth_gowin`)

* `cancho test`: the graph equals `sim/pid.cho` on 400 spread inputs; on all 4,024 contract cases every node stays inside its computed range.
* **Generated Verilog equals `ir.eval`: 0 mismatches on 4,024 cases** (all 1,024 combinations of each input at its minimum or maximum, plus 3,000 spread over the ranges), latency 3, one case per clock. Three deliberate breaks of the Verilog (a multiplier output one bit narrower, a delay stage dropped, the divisor changed) gave 87, 3,515 and 691 mismatches, so the check can fail.
* **Synthesis, narrow and pipelined: 726 cells** (185 ALU, 402 flip-flops, 225 LUT/mux, **3 MULT18X18**) against **4,349 cells and 9 MULT36X36** for the first 64-bit combinational version. The 321 input and 96 output buffers are the ports and would not exist inside a real design.

## The closed loop (2026-11-01)

* `gen/loop_trace.cho` runs the loop in cancho (`sim/pid.cho` against `sim/loop.cho`'s tip-and-surface model, a triangle surface, 1,500 steps, from 40,000 pm down to the surface); `gen/z_loop_tb.v` closes the same loop around `z_loop` with a Verilog copy of the plant and compares Z after every step: **0 mismatches in 1,500, 4 clocks per sample**.
* Deadman and limit: after the last `kick` the fault latched, Z went to the retract value, a new sample was refused, a host `zmax` below the retract request clamped the output, and `rst` cleared the fault: 0 failures. Four deliberate breaks (fault never latches, no output clamp, state updated a cycle early, samples accepted while faulted) were each caught.
* Choices, not measurements: the retract direction is *up* (larger Z is farther from the surface), taken from `sim/loop.cho`; the plant is the simple clamp law, not a cantilever.

## The XY raster (2026-11-01)

`raster_ir.cho` writes one raster tick as a graph (the IR gained a less-than and a select for it); `sv.cho` prints it as `raster_step` (combinational, no multiplier: positions are accumulated) and wraps it as `raster`: state in registers, one step per `tick` unless `hold` or `done`, `trace` high on the recorded pixels, `rst` restarts. The fast axis is a triangle (`npix` points out, `npix`-2 back, so a line is `2*npix-2` ticks and the next starts exactly at `x0`); the slow axis steps `dy` at the end of each line; after `nlines` lines `done` latches. `sim/raster.cho` is the independent hand-written reference.

* `cancho test`: a 4 x 3 frame visits each pixel once at the right place, takes 3 x 6 ticks and stops; the graph equals `sim/raster.cho` after every tick for 12 sizes through to `done`; every node stays inside its computed range over 4,024 cases.
* Icarus: `raster_step` equals the cancho graph on **4,024 cases, 0 mismatches**; the `raster` wrapper over a 16 x 8 frame and 6 ticks past its end matches the trace of `sim/raster.cho` on x, y, tick, line, trace and done at **all 246 ticks, 0 mismatches**; `hold` froze it, `done` stayed final, `rst` restored `x0`, `y0`. Four deliberate breaks (ticks accepted after done, `hold` ignored, trace flag off by one, reset not restoring y) were each caught.
* Place and route (Pi, as below, harness `gen/timing_raster_top.v`): **Fmax 107.87 MHz, PASS at 27 MHz**; no multipliers.
* Contract, not checked by the hardware: `npix >= 2`, up to 1024 x 1024 pixels, positions and steps are 16-bit DAC words, and the scan must fit the DAC (`x0 + (npix-1)*dx` and `y0 + (nlines-1)*dy` at most 65535). Limits on X and Y are the amplifier's job; there is no clamp on them yet. The fast axis is a triangle only; the sine trajectory the 2025 paper uses for speed is not written.

## The amplitude detector (2026-11-01)

`sim/lockin.cho` (reference) and `gen/lockin_ir.cho` + `gen/sv.cho` (generated): a quadrature lock-in on the ADC samples with a square-wave reference (no multiplier in the mixing), accumulated over a window, then `floor(sqrt(I^2 + Q^2))` by the digit-by-digit square root unrolled into a 13-stage pipeline (the IR gained a constant divisor and an explicit register). Wrapper `lockin`: `valid`, `x_in` (16-bit), `tuning`, `window`; outputs `amp`, `amp_valid`, `overflow`, I and Q. What the converters must therefore provide is worked out in [`docs/converters.md`](../docs/converters.md).

* `cancho test`: 6 tests of the model (phase independence, proportionality, noise, two pinned weaknesses) and one that the unrolled square-root graph equals `isqrt` on 3,000 cases with every node inside its computed range.
* Icarus: a synthetic ADC stream of 3,072 samples (12 windows, amplitudes from 100 to 30,000 counts, a third harmonic and noise in some): **all 12 windows give I, Q and the amplitude figure exactly as the cancho model, 0 mismatches**, arriving in order (the 13-stage latency plus the latch; the clock count itself is not timed by the testbench); no window closes while `valid` is low; a full-scale window raises `overflow`. Deliberate breaks (cos or sin sign inverted, window one too long, `valid` delayed one stage early, overflow never raised) were caught; breaking `valid` handling is caught by the stream test, not by the freeze test (which only checks that no window closes while `valid` is low).
* Place and route (Pi, harness `gen/timing_lockin_top.v`): **Fmax 83.30 MHz, PASS at 27 MHz**; 1,777 LUT4 (8%), 1,059 flip-flops (6%), 996 ALU (6%), 2 of 12 MULT36X36 (the two squares).
* Limits: I and Q within +-8,388,607; the amplitude figure is `2/pi * A * window` times a constant that depends on samples per period (2.6% high at 8 per period); a third harmonic raises it (a band-pass or sine references would fix that); no ADC interface, no frequency sweep or resonance finder yet.

## The SPI masters for the Pmod AD1 and DA3 (2026-11-01)

`sim/spi.cho` has a cycle-accurate model of each master (one call per FPGA clock); `gen/sv.cho` prints `spi_adc` and `spi_dac` as text
(sequential blocks, not dataflow graphs). `half` (clocks per half SCK period, 1 to 255) is read at the start of a frame and held. At 27 MHz
and half = 2 an SCK of 6.75 MHz gives a conversion or write in about 70 clocks, 0.38 M per second; whether the chips accept that clock is in
their datasheets, unchecked.

* The AD1 master: SCK idles high, CS falls, 16 clocks, each bit read on the last clock of SCK's high phase (just before the falling edge that brings the next one), two lines, 12 bits each after four leading zeros; then `done` with both samples (offset-binary, 0 to 4095: the detector wants signed, so subtract 2048 in the glue, not written).
* The DA3 master: SCLK idles low (mode 0), CS falls, 16 bits MSB first, CS held low `half` clocks after the last bit then raised (that loads the DAC because ~LDAC is held low), `done` after `half` clocks high.
* `cancho test` (`tests/spi_test.cho`): each model against a behavioural chip written in cancho from the manuals: 60 AD1 conversions (half 1 to 5), 60 DA3 writes, the extremes, and a write offered while busy is ignored.
* Icarus, **lockstep**: every output of both generated masters equals the model after each of 21,000 clocks (226 conversions, 202 writes), with starts, writes and half all varying: **0 mismatches**. **Protocol**: against Verilog models of the two chips (again from the manuals), 240 AD1 conversions read back exactly with 16 clocks each, 240 DA3 words land exactly, half 1 to 4, 0 errors.
* Eight deliberate breaks were caught, each by at least one of the two tests (a late sample, the AD1's bit order, a swapped channel, the DA3's clock polarity inverted, DA3 LSB first, a wrong bit order after the first bit, no CS hold, `half` read every clock). Two weak spots of the tests themselves were found and fixed: the lockstep's random data used the low bit of a generator that alternates, so the AD1's bit-order break passed; and a test chip's "bad frame" counter counted the power-up edge.
* **A real bug found by the lockstep and fixed:** reading `half` every clock let a change in the middle of a frame strand the counter past its match; it ran 512 clocks until it wrapped. `half` is now latched at the start of each frame.
* Place and route (Pi, harness `gen/timing_spi_top.v`): both masters **155.6 MHz, PASS at 27 MHz**; 352 LUT4 (1%), 150 flip-flops, 80 ALU.
* **The chip behaviour is as the Digilent manuals describe it, not from the AD7476A or AD5541A datasheets.** Not checked there: the SCLK limit, the data-valid delay after the SCK edge (the master reads just before the next falling edge, with `half` clocks of margin), the minimum CS-high time, and the DA3's settling and update rate.
* Not written: the glue that turns an AD1 `done` into the detector's `valid` and `x_in`, and that sends the loop's Z to a DA3 when the loop has a new value; the Tang Nano's pin assignments for the six or so wires per module.

## The interface to a parallel ADC, for the AD9226 module (2026-11-03, H3b of `docs/high-speed.md`)

`sim/adc_par.cho` is a one-clock-at-a-time model; `gen/sv.cho` prints `adc_par` as text (`gen/main_adc_par.cho`). The block drives the ADC's clock itself (low `half` FPGA clocks, high `half`;
`half` 1 to 255 read when `en` rises: 13.5 MS/s for 1, 4.5 MS/s for 3 at 27 MHz), captures the 12 data bits and OTR on the last clock of the high phase, drops the first **7** captures (the pipeline filling) and then pulses `done`
with the code of the sample of 7 edges earlier. `en` low holds the clock low.

* **From the datasheet** (Rev. Pr A, 10/22/99, a PDF I could read; a later revision may differ): latency 7 clock cycles; output delay 7 ns typical, 10 ns maximum (a Rev. B table seen in a search says 3.5 to 7 ns); minimum clock period 15.38 ns, pulse widths 3 ns; the input is sampled on the rising edge; straight binary or two's complement by the MODE pin (this block takes straight binary: the module's strap is **unchecked**); the first draft of this design assumed a latency of 3: wrong, caught by reading the sheet.
* `cancho test` (`tests/adc_par_test.cho`): against a behavioural AD9226 written in cancho (a 7-deep pipeline): every report is the sample of 7 edges earlier for `half` 1 to 5; the first report comes at the 8th capture; the clock stops when disabled and the pipeline refills; `half` is held.
* Icarus **lockstep** (`gen/adc_par_tb.v`): all outputs equal the model after each of 21,000 clocks (3,033 reports) with `en` in bursts and `half` changing mid-run: **0 mismatches**.
* Icarus **protocol** (`gen/adc_par_proto_tb.v`): against a Verilog AD9226 with the worst-case 10 ns output delay, at `half` 1 and 3 from a 27 MHz clock: 2,652 reports, **0 wrong**; the ADC clock period is at least 74 ns (the chip needs 15.38), low pulses 37 ns (needs 3); **the data has settled 27 ns before the capture at worst** (37 ns less the 10 ns). That margin leaves out the FPGA's own pin delays, the cable or board and the module's buffers: not measured.
* Five deliberate breaks: a latency of 6, capture in the low phase and `half` read every clock were caught by the lockstep, and the first two by the protocol test as well; clearing the code on disable was caught by the lockstep; an extra clear of the capture counter on disable changed nothing (an equivalent mutant: the counter is masked by the run flag).
* Place and route (Pi, harness `gen/timing_adc_par_top.v`, 2026-11-03): **Fmax 145.96 MHz, PASS at 27 MHz** (it fails a 150 MHz target); 169 LUT4, 61 flip-flops, 26 ALU, harness shift register included.
* **Not done:** the block is not in `afm_top` (that needs a register to choose the SPI or the parallel ADC, so a change to the register table), no pin assignments, no check of the module's MODE strap, and nothing run against a real chip.

## The whole board: serial bridge, registers and glue, in simulation (2026-11-01)

`gen/glue.cho` prints the board-level parts as text: a UART (115200 baud, 8N1) and a bridge that speaks cancho-hdl's byte protocol, a register file
(`docs/registers.md`), a refresh block per DAC, a sine table computed with `std.math`, and the top level `afm_top`: sample timer, the AD1 master, the
detector, the loop (one step per detector window) with its limit and deadman, the raster (one pixel per loop step), the drive (a sine at the detector's own
phase) and four DA3 masters. Pins: `gen/afm_top.cst` (clock, serial and LEDs are the pins in Sipeed's own examples; the header pins are read from the board's
pin-diagram image; none checked on the board).

* **Bridge alone** (`gen/uart_bridge_tb.v`): writes and reads back a register, answers SLVERR for an unmapped address, ignores stray bytes: 0 failures.
* **Whole board** (`gen/afm_top_tb.v`): the top level's pins connected to a model of the AD1 (reading a simulated fork, 2,000 pm free amplitude, lagging
  its target, over a surface) and four models of the DA3, driven only through the serial port. Phase 1: registers (ID, defaults fail closed, read-back, refusal
  of writes to read-only registers and of bad addresses). Phase 2, the tutorial's Part 5 check: the four DACs follow written codes, the ADC reads the fork
  (free figure 41,822). Phase 3: with the host's settings written and a heartbeat sent, **Z settles at 1,599 pm against a 1,600 pm target**, the Z DAC follows it,
  and the drive swings 12,768 to 52,767 at one period per 8 samples. Phase 4: lowering the limit clamps Z at once; with heartbeats a 300,000-clock deadman stays
  quiet; without them it latches, Z goes to the retract value and the Z DAC to its code. Phase 5: run off clears the fault and Z returns to rest. **0 failures,
  0 bad DAC frames, about 38,000 conversions, 28 seconds.**
* Seven deliberate breaks in the glue were tried: the heartbeat ignored, the error sign inverted, the figure shift ignored, run-off not clearing the fault,
  defaults not failing closed, a read-only register writable, and the drive taken from the wrong phase bits; each was caught by a check (the last two only after
  I added a defaults check and a drive-frequency check; the first version of the test missed the wrong-phase drive).
* **Built on the Pi into a real bitstream** (`sh gen/build_fpga.sh`, nextpnr and gowin_pack from the OSS CAD Suite; **not flashed**): 24% of the LUT4 (5,157),
  20% of the flip-flops, 13% of the ALU, 1 block RAM (the sine), 6 multiplier blocks (2 of 36x36, 4 of 18x18), 26 of 384 IOs. **nextpnr estimates 74.6 MHz,
  passing at 27 MHz.** The bitstream is 7.3 MB.
* **Not done:** a run on a board (the board's header pins, the Pmods and the serial port have never been touched); the host program; the AD1's filter and
  the DA3's speed (still unchecked in the datasheets); noise on the simulated fork.

## Place and route on the Tang Nano's chip (2026-11-01, on the Pi: OSS CAD Suite 2026-11-01, nextpnr-himbaechel 0.11.1, `GW2AR-LV18QN88C8/I7`)

`pid_step` sits behind `gen/timing_top.v` (a timing harness, not part of the product: one input pin feeding a shift register, one output pin
fed by an XOR of the outputs, pins from `gen/timing_top.cst`) so it can be placed without 400 pins. One run, seed 1, no tuning.

* **Fmax 70.74 MHz; PASS at the board's 27 MHz, FAIL at a 100 MHz target.** The critical path is the last stage (add, add, divide by 256, subtract, clamp), not a multiplier.
* `z_loop` (the wrapper, with `gen/timing_loop_top.v`): **Fmax 86.95 MHz, PASS at 27 MHz**; 871 LUT4 (4%), 683 flip-flops (4%), 404 ALU (2%), 3 MULT18X18 (6%), harness shift register included. At 4 clocks per sample that is 6.75 M samples/s at 27 MHz.
* Whole harness: 431 of 20,736 LUT4 (2%), 525 of 15,552 flip-flops (3%), 208 ALU (1%), **3 of 48 MULT18X18 (6%)**; the harness's 320-bit input shift register is included, so the module alone is smaller.
* At 27 MHz that is a new sample every 37 ns with 3 cycles of latency; at 70 MHz it would be 14 ns. These are the loop step's numbers, not an AFM's: no converter, no closed loop, no board has been involved.
* Not claimed: a different seed or tool version may give a different Fmax; the timing model is nextpnr's, not a measurement on silicon.

## Not measured

* Timing on the real board (the figure above is nextpnr's estimate).
* Equality outside the 4,024 cases; inputs outside the contract.
* The XY raster, the ADC/DAC interfaces and the amplitude detector: not written. The host-visible registers (limits, timeout, fault read-back) are plain ports of `z_loop`, not yet a `.chw` contract.
* Anything on a board.
