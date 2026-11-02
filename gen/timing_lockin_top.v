// Timing harness only (see timing_top.v): the amplitude detector behind one input pin and one output pin; the sample, tuning word,
// window and the two control bits come from a serial shift register, the outputs are XOR-reduced to one bit.
module timing_lockin_top(input clk, input din, output dout);
  reg [81:0] sh;
  always @(posedge clk) sh <= {sh[80:0], din};
  reg signed [15:0] x; reg [31:0] tuning; reg [31:0] window; reg rst, valid;
  always @(posedge clk) begin x<=sh[15:0]; tuning<=sh[47:16]; window<=sh[79:48]; rst<=sh[80]; valid<=sh[81]; end
  wire [31:0] amp; wire amp_valid, overflow; wire signed [31:0] i_out, q_out; wire [31:0] ph;
  lockin dut(clk, rst, valid, x, tuning, window, amp, amp_valid, overflow, i_out, q_out, ph);
  reg q;
  always @(posedge clk) q <= ^{amp, amp_valid, overflow, i_out, q_out, ph};
  assign dout = q;
endmodule
