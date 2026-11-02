// The generated masters against behavioural models of the two chips, written from the Digilent manuals (not from the chips' datasheets):
// the AD1 loads {4 zeros, 12 bits} on each data line when CS falls and shifts on each falling edge of SCK; the DA3 shifts DIN in on
// each rising edge of SCLK while CS is low and, if exactly 16 bits came and ~LDAC is low, loads its output register when CS rises.
module ad7476_model(input cs, input sck, input [11:0] v0, input [11:0] v1, output d0, output d1, output reg [4:0] falls);
  reg [15:0] sr0, sr1;
  assign d0 = sr0[15];
  assign d1 = sr1[15];
  always @(negedge cs) begin sr0 <= {4'b0, v0}; sr1 <= {4'b0, v1}; falls <= 0; end
  always @(negedge sck) if (!cs) begin sr0 <= {sr0[14:0], 1'b0}; sr1 <= {sr1[14:0], 1'b0}; falls <= falls + 1; end
endmodule

module ad5541_model(input cs, input sclk, input din, input ldac, output reg [15:0] dac, output reg [31:0] bad);
  reg [15:0] sr; reg [5:0] n; reg armed;
  initial begin dac = 0; bad = 0; n = 0; sr = 0; armed = 0; end
  always @(negedge cs) begin n = 0; armed = 1; end
  always @(posedge sclk) if (!cs) begin sr <= {sr[14:0], din}; n = n + 1; end
  always @(posedge cs) if (armed) begin
    if (n == 16 && !ldac) dac <= sr; else bad <= bad + 1;
  end
endmodule

module spi_proto_tb;
  reg clk = 0, rst = 1, start = 0, write = 0;
  reg [7:0] half = 2; reg [15:0] data = 0; reg [11:0] v0 = 0, v1 = 0;
  wire a_cs, a_sck, a_busy, a_done, d0, d1; wire [11:0] s0, s1; wire [4:0] falls;
  wire d_cs, d_sclk, d_din, d_ldac, d_busy, d_done; wire [15:0] dac_out; wire [31:0] dac_bad;
  spi_adc adc(clk, rst, start, half, d0, d1, a_cs, a_sck, a_busy, a_done, s0, s1);
  ad7476_model chip_a(a_cs, a_sck, v0, v1, d0, d1, falls);
  spi_dac dac(clk, rst, write, data, half, d_cs, d_sclk, d_din, d_ldac, d_busy, d_done);
  ad5541_model chip_d(d_cs, d_sclk, d_din, d_ldac, dac_out, dac_bad);
  always #5 clk = ~clk;
  integer i, bad_a, bad_d, bad_clk, hh, seed;
  initial begin
    bad_a = 0; bad_d = 0; bad_clk = 0; seed = 7;
    repeat (3) @(negedge clk); rst = 0;
    for (hh = 1; hh <= 4; hh = hh + 1) begin
      half = hh;
      for (i = 0; i < 60; i = i + 1) begin
        v0 = $random(seed); v1 = $random(seed);
        if (i == 0) begin v0 = 12'h000; v1 = 12'hfff; end
        if (i == 1) begin v0 = 12'hfff; v1 = 12'h000; end
        @(negedge clk); start = 1; @(negedge clk); start = 0;
        while (a_busy) @(negedge clk);
        if (s0 !== v0 || s1 !== v1) begin bad_a = bad_a + 1; if (bad_a < 4) $display("ADC: read %0h %0h, chip had %0h %0h (half %0d)", s0, s1, v0, v1, hh); end
        if (falls !== 5'd16) bad_clk = bad_clk + 1;
      end
      for (i = 0; i < 60; i = i + 1) begin
        data = $random(seed);
        if (i == 0) data = 16'h0000;
        if (i == 1) data = 16'hffff;
        if (i == 2) data = 16'h8000;
        if (i == 3) data = 16'h0001;
        @(negedge clk); write = 1; @(negedge clk); write = 0;
        while (d_busy) @(negedge clk);
        if (dac_out !== data) begin bad_d = bad_d + 1; if (bad_d < 4) $display("DAC: wrote %0h, chip holds %0h (half %0d)", data, dac_out, hh); end
      end
    end
    $display("spi protocol: adc %0d wrong reads, %0d frames without 16 clocks; dac %0d wrong values, %0d bad frames", bad_a, bad_clk, bad_d, dac_bad);
    $finish;
  end
endmodule
