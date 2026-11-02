// Timing harness only (see timing_top.v): z_loop behind one input pin and one output pin. All ten config/data words and the three
// control bits come from a serial shift register, so nothing is constant-folded away; the outputs are XOR-reduced to one bit.
module timing_loop_top(input clk, input din, output dout);
  reg [322:0] sh;
  always @(posedge clk) sh <= {sh[321:0], din};
  reg signed [31:0] w0,w1,w2,w3,w4,w5,w6,w7,w8; reg [31:0] w9; reg rst, start, kick;
  always @(posedge clk) begin
    w0<=sh[31:0]; w1<=sh[63:32]; w2<=sh[95:64]; w3<=sh[127:96]; w4<=sh[159:128]; w5<=sh[191:160];
    w6<=sh[223:192]; w7<=sh[255:224]; w8<=sh[287:256]; w9<=sh[319:288]; rst<=sh[320]; start<=sh[321]; kick<=sh[322];
  end
  wire signed [31:0] z_out; wire busy, fault;
  z_loop dut(clk, rst, start, kick, w0,w1,w2,w3,w4,w5,w6,w7,w8, w9, z_out, busy, fault);
  reg q;
  always @(posedge clk) q <= ^{z_out, busy, fault};
  assign dout = q;
endmodule
