// The high-speed detector (docs/high-speed.md, H3): the generated lock-in fed one sample every GAP = 6 clocks (4.5 MS/s from a 27 MHz clock), the windows and drives of
// lockin.snap, against what sim/lockin.cho says (lockin_hs_trace.txt). Every window's I, Q and amplitude must arrive in order and exactly. (That the figure of a steady
// signal is the same every window is tests/lockin_test.cho's.)
module lih_tb;
  localparam GAP = 6;
  reg clk = 0, rst = 1, valid = 0;
  reg signed [15:0] x_in = 0; reg [31:0] tuning; reg [31:0] window;
  wire [31:0] amp; wire amp_valid, overflow; wire signed [31:0] i_out, q_out; wire [31:0] phase_out;
  lockin dut(clk, rst, valid, x_in, tuning, window, amp, amp_valid, overflow, i_out, q_out, phase_out);
  always #5 clk = ~clk;

  reg signed [63:0] ex [0:63]; reg signed [63:0] eq [0:63]; reg signed [63:0] ea [0:63];
  reg signed [63:0] c0, c1, c2, rx, rd, ri, rq, ra;
  integer f, r, nsec, sec, rows, k, g, nexp, got, bad, fails, lat, total, win_total;
  initial begin
    bad = 0; fails = 0; total = 0; win_total = 0; lat = dut.L;
    f = $fopen("lockin_hs_trace.txt", "r");
    r = $fscanf(f, "%d\n", nsec);
    for (sec = 0; sec < nsec; sec = sec + 1) begin
      r = $fscanf(f, "%d %d %d\n", c0, c1, c2);
      tuning = c0; window = c1; rows = c2;
      rst = 1; valid = 0; repeat (3) @(negedge clk); rst = 0; @(negedge clk);
      nexp = 0; got = 0;
      for (k = 0; k < rows; k = k + 1) begin
        r = $fscanf(f, "%d %d %d %d %d\n", rx, rd, ri, rq, ra);
        if (rd == 1) begin ex[nexp] = ri; eq[nexp] = rq; ea[nexp] = ra; nexp = nexp + 1; end
        x_in = rx; valid = 1;
        @(posedge clk); #1;
        if (amp_valid) begin
          if (amp !== ea[got][31:0] || i_out !== ex[got][31:0] || q_out !== eq[got][31:0]) begin
            bad = bad + 1; $display("MISMATCH section %0d window %0d: amp=%0d i=%0d q=%0d want %0d %0d %0d", sec, got, amp, i_out, q_out, ea[got], ex[got], eq[got]);
          end
          got = got + 1;
        end
        @(negedge clk); valid = 0;
        for (g = 1; g < GAP; g = g + 1) begin
          @(posedge clk); #1;
          if (amp_valid) begin
            if (amp !== ea[got][31:0] || i_out !== ex[got][31:0] || q_out !== eq[got][31:0]) begin bad = bad + 1; $display("MISMATCH section %0d window %0d (idle)", sec, got); end
            got = got + 1;
          end
          @(negedge clk);
        end
      end
      repeat (lat + 4) begin @(posedge clk); #1; if (amp_valid) begin
          if (amp !== ea[got][31:0] || i_out !== ex[got][31:0] || q_out !== eq[got][31:0]) begin bad = bad + 1; $display("MISMATCH section %0d window %0d (tail)", sec, got); end
          got = got + 1; end @(negedge clk); end
      if (got != nexp) begin fails = fails + 1; $display("FAIL section %0d: %0d windows expected, %0d seen", sec, nexp, got); end
      total = total + rows; win_total = win_total + got;
      $display("section %0d: window %0d samples, drive word %0d, %0d windows, latency %0d clocks", sec, c1, c0, got, lat);
    end
    $display("lockin hs: %0d sections, %0d samples at %0d clocks each, %0d windows, %0d mismatches, %0d failures", nsec, total, GAP, win_total, bad, fails);
    $finish;
  end
endmodule
