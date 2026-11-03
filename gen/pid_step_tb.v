// Reads vectors.txt (from gen/vectors.cho), drives the pipelined pid_step one vector per clock, and after LATENCY cycles
// compares each output with the cancho answer. Inputs are applied at the falling edge, outputs read just after the rising edge.
module tb;
  reg clk = 0;
  reg signed [31:0] i0,i1,i2,i3,i4,i5,i6,i7,i8,i9;
  wire signed [31:0] o0,o1,o2;
  pid_step dut(clk, i0,i1,i2,i3,i4,i5,i6,i7,i8,i9, o0,o1,o2);
  always #5 clk = ~clk;

  reg signed [63:0] mem [0:13*5000-1];
  reg signed [63:0] v0,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12;
  integer f, n, bad, r, k, j, lat;
  initial begin
    f = $fopen("vectors.txt", "r"); n = 0; bad = 0;
    while (!$feof(f)) begin
      r = $fscanf(f, "%d %d %d %d %d %d %d %d %d %d %d %d %d\n", v0,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12);
      if (r == 13) begin
        mem[n*13+0]=v0; mem[n*13+1]=v1; mem[n*13+2]=v2; mem[n*13+3]=v3; mem[n*13+4]=v4; mem[n*13+5]=v5; mem[n*13+6]=v6;
        mem[n*13+7]=v7; mem[n*13+8]=v8; mem[n*13+9]=v9; mem[n*13+10]=v10; mem[n*13+11]=v11; mem[n*13+12]=v12;
        n = n + 1;
      end
    end
    lat = dut.LATENCY;
    for (k = 0; k < n + lat; k = k + 1) begin
      @(negedge clk);
      if (k < n) begin
        i0=mem[k*13+0]; i1=mem[k*13+1]; i2=mem[k*13+2]; i3=mem[k*13+3]; i4=mem[k*13+4];
        i5=mem[k*13+5]; i6=mem[k*13+6]; i7=mem[k*13+7]; i8=mem[k*13+8]; i9=mem[k*13+9];
      end
      @(posedge clk); #1;
      j = k - lat + 1;
      if (j >= 0 && j < n) begin
        if (o0 !== mem[j*13+10] || o1 !== mem[j*13+11] || o2 !== mem[j*13+12]) begin
          bad = bad + 1;
          if (bad < 5) $display("MISMATCH case %0d: got %0d %0d %0d want %0d %0d %0d", j, o0,o1,o2, mem[j*13+10],mem[j*13+11],mem[j*13+12]);
        end
      end
    end
    $display("%0d cases, latency %0d, %0d mismatches", n, lat, bad);
    $finish;
  end
endmodule
