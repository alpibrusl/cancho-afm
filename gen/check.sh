#!/bin/sh
# Generate pid_step + z_loop and the cancho references, simulate both in Icarus, compare. Exits non-zero on any failure.
set -e
cd "$(dirname "$0")/.."
CANCHO=${CANCHO:-../cancho/target/release/cancho}
mkdir -p build
$CANCHO run gen/main.cho gen/ir.cho gen/pid_ir.cho gen/sv.cho --std > build/pid_step.sv
$CANCHO run gen/vectors.cho gen/ir.cho gen/pid_ir.cho --std > build/vectors.txt
$CANCHO run gen/loop_trace.cho sim/pid.cho sim/loop.cho --std > build/loop_trace.txt
cd build
iverilog -g2012 -o tb.vvp pid_step.sv ../gen/pid_step_tb.v
vvp tb.vvp | tee tb.log
grep -q " 0 mismatches" tb.log
iverilog -g2012 -o zl.vvp pid_step.sv ../gen/z_loop_tb.v
vvp zl.vvp | tee zl.log
grep -q "closed loop: 1500 steps, 4 clocks per sample, 0 mismatches" zl.log
grep -q "deadman and limit: 0 failures" zl.log
cd ..
$CANCHO run gen/main_raster.cho gen/ir.cho gen/raster_ir.cho gen/sv.cho --std > build/raster.sv
$CANCHO run gen/raster_vectors.cho gen/ir.cho gen/raster_ir.cho --std > build/raster_vectors.txt
$CANCHO run gen/raster_trace.cho sim/raster.cho --std > build/raster_trace.txt
cd build
iverilog -g2012 -o rs.vvp raster.sv ../gen/raster_step_tb.v
vvp rs.vvp | tee rs.log
grep -q " 0 mismatches" rs.log
iverilog -g2012 -o rt.vvp raster.sv ../gen/raster_tb.v
vvp rt.vvp | tee rt.log
grep -q "raster: 246 ticks, 0 mismatches, done=1" rt.log
grep -q "hold, done, reset: 0 failures" rt.log
# the sinusoidal fast axis
cd ..
$CANCHO run gen/raster_sine_trace.cho sim/raster_sine.cho --std > build/raster_sine_trace.txt
$CANCHO run gen/main_glue.cho gen/glue.cho --std > build/afm_glue.sv
cd build
iverilog -g2012 -s rsine_tb -o rsn.vvp afm_glue.sv ../gen/raster_sine_tb.v
vvp rsn.vvp | tee rsn.log
grep -q "raster_sine lockstep: 12000 clocks, 0 mismatches" rsn.log
# the amplitude detector
cd ..
$CANCHO run gen/main_lockin.cho gen/ir.cho gen/lockin_ir.cho gen/sv.cho --std > build/lockin.sv
$CANCHO run gen/lockin_trace.cho sim/lockin.cho --std > build/lockin_trace.txt
cd build
iverilog -g2012 -o li.vvp lockin.sv ../gen/lockin_tb.v
vvp li.vvp | tee li.log
grep -q "lockin: 3072 samples, 12 windows expected, 12 seen, 0 mismatches" li.log
grep -q "freeze and overflow: 0 failures" li.log
# the high-speed detector: the same generated lock-in, one sample every 6 clocks, the windows and drives of lockin.snap (docs/high-speed.md, H3)
cd ..
$CANCHO run gen/lockin_hs_trace.cho sim/lockin.cho --std > build/lockin_hs_trace.txt
cd build
iverilog -g2012 -o lih.vvp lockin.sv ../gen/lockin_hs_tb.v
vvp lih.vvp | tee lih.log
grep -q "lockin hs: 3 sections, 912 samples at 6 clocks each, 36 windows, 0 mismatches, 0 failures" lih.log
# the interface to a parallel ADC (the AD9226 module, docs/hs-order.md), against the model, and against a model of the chip written from its datasheet
cd ..
$CANCHO run gen/main_adc_par.cho gen/ir.cho gen/sv.cho --std > build/adc_par.sv
$CANCHO run gen/adc_par_trace.cho sim/adc_par.cho --std > build/adc_par_trace.txt
cd build
iverilog -g2012 -o ap.vvp adc_par.sv ../gen/adc_par_tb.v
vvp ap.vvp | tee ap.log
grep -q " 0 mismatches" ap.log
iverilog -g2012 -o apx.vvp adc_par.sv ../gen/adc_par_proto_tb.v
vvp apx.vvp | tee apx.log
grep -q "0 wrong" apx.log
# the SPI masters for the Pmod AD1 and DA3
cd ..
$CANCHO run gen/main_spi.cho gen/ir.cho gen/sv.cho --std > build/spi.sv
$CANCHO run gen/spi_adc_trace.cho sim/spi.cho --std > build/spi_adc_trace.txt
$CANCHO run gen/spi_dac_trace.cho sim/spi.cho --std > build/spi_dac_trace.txt
cd build
iverilog -g2012 -o sl.vvp spi.sv ../gen/spi_lockstep_tb.v
vvp sl.vvp | tee sl.log
grep -q "adc 226 conversions, 0 mismatches; dac 202 writes, 0 mismatches; ldac low always: 0 violations" sl.log
iverilog -g2012 -o sp.vvp spi.sv ../gen/spi_proto_tb.v
vvp sp.vvp | tee sp.log
grep -q "adc 0 wrong reads, 0 frames without 16 clocks; dac 0 wrong values, 0 bad frames" sp.log
# the board-level glue: the serial bridge alone, then the whole board against models of the chips and a fork
cd ..
$CANCHO run gen/main_glue.cho gen/glue.cho --std > build/afm_glue.sv
cd build
$CANCHO run ../gen/motor_trace.cho ../sim/motor.cho --std > motor_trace.txt
iverilog -g2012 -s motor_lock_tb -o mo.vvp afm_glue.sv ../gen/motor_tb.v
vvp mo.vvp | tee mo.log
grep -q "motor lockstep: 15000 clocks, 0 mismatches" mo.log
grep -q "forward 7 edges (want 7), dir 1, pos 7" mo.log
grep -q "back 4 edges (want 4), dir 0, pos 3" mo.log
iverilog -g2012 -s uart_tb -o ub.vvp afm_glue.sv ../gen/uart_bridge_tb.v
vvp ub.vvp | tee ub.log
grep -q "uart bridge: 0 failures" ub.log
iverilog -g2012 -s afm_top_tb -o sys.vvp afm_glue.sv pid_step.sv raster.sv lockin.sv spi.sv adc_par.sv ../gen/afm_top_tb.v
vvp sys.vvp | tee sys.log
grep -q "afm_top system test: 0 failures, 0 bad DAC frames" sys.log
grep -q "phase 10 (optical lever slow channels): OPT_SUM 1234 beside the parallel ADC" sys.log
# the register file of afm_top against the register table (host/regs.cho)
cd ..
$CANCHO run gen/regs_tb.cho host/regs.cho --std > build/contract_tb.v
cd build
iverilog -g2012 -s contract_tb -o ct.vvp afm_glue.sv pid_step.sv raster.sv lockin.sv spi.sv adc_par.sv contract_tb.v
vvp ct.vvp | tee ct.log
grep -q "contract check: 52 registers, 0 failures" ct.log
