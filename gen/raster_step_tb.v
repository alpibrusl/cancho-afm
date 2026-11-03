// raster_step is combinational (latency 0): apply each vector from raster_vectors.txt, wait, compare the five outputs with the cancho answer.
module rs_tb;
  reg clk = 0;
  reg signed [31:0] i0,i1,i2,i3,i4,i5,i6,i7,i8,i9;
  wire signed [31:0] o0,o1,o2,o3,o4;
  raster_step dut(clk, i0,i1,i2,i3,i4,i5,i6,i7,i8,i9, o0,o1,o2,o3,o4);
  reg signed [63:0] v0,v1,v2,v3,v4,v5,v6,v7,v8,v9,e0,e1,e2,e3,e4;
  integer f, n, bad, r;
  initial begin
    f = $fopen("raster_vectors.txt", "r"); n = 0; bad = 0;
    while (!$feof(f)) begin
      r = $fscanf(f, "%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d\n", v0,v1,v2,v3,v4,v5,v6,v7,v8,v9,e0,e1,e2,e3,e4);
      if (r == 15) begin
        i0=v0; i1=v1; i2=v2; i3=v3; i4=v4; i5=v5; i6=v6; i7=v7; i8=v8; i9=v9; #1;
        n = n + 1;
        if (o0 !== e0 || o1 !== e1 || o2 !== e2 || o3 !== e3 || o4 !== e4) begin
          bad = bad + 1;
          if (bad < 5) $display("MISMATCH case %0d: got %0d %0d %0d %0d %0d want %0d %0d %0d %0d %0d", n, o0,o1,o2,o3,o4, e0,e1,e2,e3,e4);
        end
      end
    end
    $display("%0d cases, latency %0d, %0d mismatches", n, dut.LATENCY, bad);
    $finish;
  end
endmodule
