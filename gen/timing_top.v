// Timing harness only, not part of the product: puts pid_step behind one input pin and one output pin so place-and-route can
// time it without 400 pins. Ten 32-bit input words are filled by a serial shift register; the three outputs are XOR-reduced
// to one bit so nothing is optimised away.
module timing_top(input clk, input din, output dout);
  reg [319:0] sh;
  always @(posedge clk) sh <= {sh[318:0], din};
  wire signed [31:0] o0, o1, o2;
  reg signed [31:0] i0,i1,i2,i3,i4,i5,i6,i7,i8,i9;
  always @(posedge clk) begin
    i0<=sh[31:0]; i1<=sh[63:32]; i2<=sh[95:64]; i3<=sh[127:96]; i4<=sh[159:128];
    i5<=sh[191:160]; i6<=sh[223:192]; i7<=sh[255:224]; i8<=sh[287:256]; i9<=sh[319:288];
  end
  pid_step dut(clk, i0,i1,i2,i3,i4,i5,i6,i7,i8,i9, o0,o1,o2);
  reg q;
  always @(posedge clk) q <= ^{o0,o1,o2};
  assign dout = q;
endmodule
