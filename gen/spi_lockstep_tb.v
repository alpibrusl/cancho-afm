// Drives both generated SPI masters with the cancho traces, one clock per row, and compares every output after every clock.
module spi_lock_tb;
  reg clk = 0, rst = 1;
  reg start = 0, d0 = 0, d1 = 0, write = 0; reg [7:0] half_a = 2, half_d = 2; reg [15:0] data = 0;
  wire a_cs, a_sck, a_busy, a_done; wire [11:0] s0, s1;
  wire d_cs, d_sclk, d_din, d_ldac, d_busy, d_done;
  spi_adc adc(clk, rst, start, half_a, d0, d1, a_cs, a_sck, a_busy, a_done, s0, s1);
  spi_dac dac(clk, rst, write, data, half_d, d_cs, d_sclk, d_din, d_ldac, d_busy, d_done);
  always #5 clk = ~clk;
  integer f, r, n, bad_a, bad_d, ldac_bad, conv_a, conv_d;
  reg signed [63:0] h, st, a, b, eb, ec, es, ed, e0, e1, w, dw, edin;
  initial begin
    bad_a = 0; bad_d = 0; ldac_bad = 0; conv_a = 0; conv_d = 0; n = 0;
    repeat (3) @(negedge clk);
    rst = 0;
    f = $fopen("spi_adc_trace.txt", "r");
    while (!$feof(f)) begin
      r = $fscanf(f, "%d %d %d %d %d %d %d %d %d %d\n", h, st, a, b, eb, ec, es, ed, e0, e1);
      if (r == 10) begin
        @(negedge clk); half_a = h; start = st; d0 = a; d1 = b;
        @(posedge clk); #1; n = n + 1;
        if (a_busy !== eb[0] || a_cs !== ec[0] || a_sck !== es[0] || a_done !== ed[0] || s0 !== e0[11:0] || s1 !== e1[11:0]) begin
          bad_a = bad_a + 1;
          if (bad_a < 4) $display("ADC MISMATCH row %0d: got busy=%b cs=%b sck=%b done=%b s0=%0d s1=%0d want %0d %0d %0d %0d %0d %0d", n, a_busy, a_cs, a_sck, a_done, s0, s1, eb, ec, es, ed, e0, e1);
        end
        if (a_done) conv_a = conv_a + 1;
      end
    end
    start = 0;
    rst = 1; @(negedge clk); @(negedge clk); rst = 0;
    n = 0;
    f = $fopen("spi_dac_trace.txt", "r");
    while (!$feof(f)) begin
      r = $fscanf(f, "%d %d %d %d %d %d %d %d\n", h, w, dw, eb, ec, es, edin, ed);
      if (r == 8) begin
        @(negedge clk); half_d = h; write = w; data = dw;
        @(posedge clk); #1; n = n + 1;
        if (d_busy !== eb[0] || d_cs !== ec[0] || d_sclk !== es[0] || d_din !== edin[0] || d_done !== ed[0]) begin
          bad_d = bad_d + 1;
          if (bad_d < 4) $display("DAC MISMATCH row %0d: got busy=%b cs=%b sclk=%b din=%b done=%b want %0d %0d %0d %0d %0d", n, d_busy, d_cs, d_sclk, d_din, d_done, eb, ec, es, edin, ed);
        end
        if (d_ldac !== 1'b0) ldac_bad = ldac_bad + 1;
        if (d_done) conv_d = conv_d + 1;
      end
    end
    $display("spi lockstep: adc %0d conversions, %0d mismatches; dac %0d writes, %0d mismatches; ldac low always: %0d violations", conv_a, bad_a, conv_d, bad_d, ldac_bad);
    $finish;
  end
endmodule
