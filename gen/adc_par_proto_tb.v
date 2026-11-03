`timescale 1ns/100ps
// The generated interface against a Verilog model of the AD9226 written from its datasheet (Rev. Pr A): the input is sampled on the rising edge of CLK, the output for that sample appears 7 edges
// later and `TOD` ns after the edge (the worst case in that revision, 10 ns), clock period at least 15.38 ns, pulses at least 3 ns. The i-th report must be the analog value of sample i; and the data
// must have settled at least `MARGIN` ns before the capture. Two clock rates: half = 1 (13.5 MS/s) and half = 3 (4.5 MS/s), from a 27 MHz FPGA clock.
module adc_par_proto_tb;
  parameter TOD = 10.0;
  reg clk = 0, rst = 1, en = 0;
  reg [7:0] half = 1; reg [11:0] d_pins = 0; reg otr_pin = 0;
  wire adc_clk, done, otr; wire [11:0] code;
  adc_par dut(clk, rst, en, half, d_pins, otr_pin, adc_clk, done, code, otr);
  always #18.5 clk = ~clk;      // 27 MHz

  // the chip
  reg [11:0] pipe [0:6]; integer k, i;
  function [11:0] analog(input integer j); analog = (j * 37 + 11) % 4096; endfunction
  real t_rise, t_fall, t_chg, min_margin, min_period, min_hi, min_lo, last_rise;
  integer bad, got, sec, nrep;
  initial begin for (i = 0; i < 7; i = i + 1) pipe[i] = 0; k = 0; min_margin = 1e9; min_period = 1e9; min_hi = 1e9; min_lo = 1e9; last_rise = -1; t_fall = -1; end
  always @(posedge adc_clk) begin
    for (i = 6; i > 0; i = i - 1) pipe[i] <= pipe[i-1];
    pipe[0] <= analog(k); k = k + 1;
    d_pins <= #(TOD) pipe[6]; otr_pin <= #(TOD) 1'b0;
    t_rise = $realtime; t_chg = t_rise + TOD;
    if (last_rise >= 0 && t_rise - last_rise < min_period) min_period = t_rise - last_rise;
    if (t_fall >= 0 && t_rise - t_fall < min_lo) min_lo = t_rise - t_fall;
    last_rise = t_rise;
  end
  always @(negedge adc_clk) begin t_fall = $realtime; if (t_fall - t_rise < min_hi) min_hi = t_fall - t_rise; end
  // the margin from the chip's data change to the edge that captures it (the interface's own capture condition, read before the registers update)
  always @(posedge clk) if (!rst && en && dut.cc && dut.pp == dut.hh - 1) begin
    if ($realtime - t_chg < min_margin) min_margin = $realtime - t_chg;
  end
  always @(posedge clk) begin #0.1; if (done) begin
    if (code !== analog(got)) begin bad = bad + 1; if (bad < 4) $display("WRONG report %0d: got %0d want %0d", got, code, analog(got)); end
    got = got + 1; nrep = nrep + 1;
  end end

  task run_rate(input [7:0] h);
    begin
      en = 0; rst = 1; repeat (3) @(negedge clk); rst = 0; k = 0; got = 0;
      for (i = 0; i < 7; i = i + 1) pipe[i] = 0;
      half = h; en = 1; repeat (4000) @(posedge clk);
      en = 0; @(posedge clk);
    end
  endtask
  initial begin
    bad = 0; got = 0; nrep = 0;
    repeat (4) @(negedge clk);
    run_rate(1); $display("half 1: %0d reports", got);
    run_rate(3); $display("half 3: %0d reports", got);
    $display("adc_par protocol: %0d reports, %0d wrong; adc clock period min %0.1f ns (chip needs 15.38), high %0.1f ns, low %0.1f ns (chip needs 3; the shortest high pulse is one cut by a reset); data settled %0.1f ns before capture at worst (output delay %0.1f ns)", nrep, bad, min_period, min_hi, min_lo, min_margin, TOD);
    $finish;
  end
endmodule
