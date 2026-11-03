// Timing harness only (see timing_top.v): the raster behind one input pin and one output pin; the six config words and the three control
// bits come from a serial shift register, the outputs are XOR-reduced to one bit.
module timing_raster_top(input clk, input din, output dout);
  reg [194:0] sh;
  always @(posedge clk) sh <= {sh[193:0], din};
  reg signed [31:0] a0,a1,a2,a3,a4,a5; reg rst, tick, hold;
  always @(posedge clk) begin
    a0<=sh[31:0]; a1<=sh[63:32]; a2<=sh[95:64]; a3<=sh[127:96]; a4<=sh[159:128]; a5<=sh[191:160];
    rst<=sh[192]; tick<=sh[193]; hold<=sh[194];
  end
  wire signed [31:0] x_out, y_out, pix, line_out; wire trace, done;
  raster dut(clk, rst, tick, hold, a0,a1,a2,a3,a4,a5, x_out, y_out, pix, line_out, trace, done);
  reg q;
  always @(posedge clk) q <= ^{x_out, y_out, pix, line_out, trace, done};
  assign dout = q;
endmodule
