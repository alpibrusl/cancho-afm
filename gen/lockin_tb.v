// Feeds the synthetic ADC stream (lockin_trace.txt) to the generated detector one sample per clock and checks that every window's
// I, Q and amplitude figure arrive, in order, exactly as sim/lockin.cho computed them (the delay itself is not timed here).
// Then: a full-scale stream must raise `overflow`, and `valid` low must freeze the accumulators.
module li_tb;
  reg clk = 0, rst = 1, valid = 0;
  reg signed [15:0] x_in = 0; reg [31:0] tuning; reg [31:0] window;
  wire [31:0] amp; wire amp_valid, overflow; wire signed [31:0] i_out, q_out; wire [31:0] phase_out;
  lockin dut(clk, rst, valid, x_in, tuning, window, amp, amp_valid, overflow, i_out, q_out, phase_out);
  always #5 clk = ~clk;

  reg signed [63:0] ex [0:4095]; reg signed [63:0] eq [0:4095]; reg signed [63:0] ea [0:4095];
  reg signed [63:0] c0, c1, rx, rd, ri, rq, ra;
  integer f, r, n, nexp, got, bad, fails, since, gap, k, lat, pulses;
  initial begin
    bad = 0; fails = 0; n = 0; nexp = 0; got = 0; gap = -1; since = -1; lat = dut.L;
    f = $fopen("lockin_trace.txt", "r");
    r = $fscanf(f, "%d %d\n", c0, c1);
    tuning = c0; window = c1;
    repeat (3) @(negedge clk);
    rst = 0; @(negedge clk);
    while (!$feof(f)) begin
      r = $fscanf(f, "%d %d %d %d %d\n", rx, rd, ri, rq, ra);
      if (r == 5) begin
        x_in = rx; valid = 1;
        if (rd == 1) begin ex[nexp] = ri; eq[nexp] = rq; ea[nexp] = ra; nexp = nexp + 1; since = 0; end
        @(posedge clk); #1;
        if (since >= 0) since = since + 1;
        if (amp_valid) begin
          if (amp !== ea[got][31:0] || i_out !== ex[got][31:0] || q_out !== eq[got][31:0]) begin
            bad = bad + 1; $display("MISMATCH window %0d: amp=%0d i=%0d q=%0d want %0d %0d %0d", got, amp, i_out, q_out, ea[got], ex[got], eq[got]);
          end
          got = got + 1;
        end
        @(negedge clk);
        n = n + 1;
      end
    end
    // let the last window finish
    repeat (lat + 4) begin @(posedge clk); #1; if (amp_valid) begin
        if (amp !== ea[got][31:0] || i_out !== ex[got][31:0] || q_out !== eq[got][31:0]) begin bad = bad + 1; $display("MISMATCH window %0d", got); end
        got = got + 1; end end
    $display("lockin: %0d samples, %0d windows expected, %0d seen, %0d mismatches, latency %0d, overflow=%0d", n, nexp, got, bad, lat, overflow);
    if (got != nexp) fails = fails + 1;
    if (overflow !== 1'b0) begin fails = fails + 1; $display("FAIL overflow raised on a normal stream"); end

    // valid low freezes everything
    rst = 1; @(negedge clk); rst = 0; valid = 1; x_in = 1000;
    repeat (10) @(negedge clk);
    valid = 0; pulses = 0;
    repeat (500) begin @(posedge clk); #1; if (amp_valid) pulses = pulses + 1; @(negedge clk); end
    if (pulses != 0) begin fails = fails + 1; $display("FAIL window closed with valid low (%0d pulses)", pulses); end
    // full scale: a window of 300 samples of +-32767 in phase with the reference sums to more than 2^23 = 8,388,608
    rst = 1; @(negedge clk); rst = 0; tuning = 32'd536870912; window = 300; valid = 1;
    for (k = 0; k < 300; k = k + 1) begin
      x_in = ((k % 8) < 4) ? 16'sd32767 : -16'sd32767;
      @(negedge clk);
    end
    repeat (lat + 4) @(negedge clk);
    if (overflow !== 1'b1) begin fails = fails + 1; $display("FAIL overflow not raised at full scale"); end
    $display("freeze and overflow: %0d failures", fails);
    $finish;
  end
endmodule
