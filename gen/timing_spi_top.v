// Timing harness only (see timing_top.v): both SPI masters behind one input and one output pin.
module timing_spi_top(input clk, input din, output dout);
  reg [31:0] sh;
  always @(posedge clk) sh <= {sh[30:0], din};
  reg start, write, rst, d0, d1; reg [7:0] half; reg [15:0] data;
  always @(posedge clk) begin start<=sh[0]; write<=sh[1]; rst<=sh[2]; d0<=sh[3]; d1<=sh[4]; half<=sh[12:5]; data<=sh[28:13]; end
  wire a_cs, a_sck, a_busy, a_done, d_cs, d_sclk, d_din, d_ldac, d_busy, d_done; wire [11:0] s0, s1;
  spi_adc adc(clk, rst, start, half, d0, d1, a_cs, a_sck, a_busy, a_done, s0, s1);
  spi_dac dac(clk, rst, write, data, half, d_cs, d_sclk, d_din, d_ldac, d_busy, d_done);
  reg q;
  always @(posedge clk) q <= ^{a_cs, a_sck, a_busy, a_done, s0, s1, d_cs, d_sclk, d_din, d_ldac, d_busy, d_done};
  assign dout = q;
endmodule
