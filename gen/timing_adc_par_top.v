// Timing harness only (see timing_top.v): the parallel ADC interface behind one input and one output pin.
module timing_adc_par_top(input clk, input din, output dout);
  reg [31:0] sh;
  always @(posedge clk) sh <= {sh[30:0], din};
  reg en, rst, otr_in; reg [7:0] half; reg [11:0] d;
  always @(posedge clk) begin en<=sh[0]; rst<=sh[1]; otr_in<=sh[2]; half<=sh[10:3]; d<=sh[22:11]; end
  wire adc_clk, done, otr; wire [11:0] code;
  adc_par dut(clk, rst, en, half, d, otr_in, adc_clk, done, code, otr);
  reg q;
  always @(posedge clk) q <= ^{adc_clk, done, code, otr};
  assign dout = q;
endmodule
