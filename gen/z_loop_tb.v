// Closes the loop around z_loop with a model of the tip and surface (amplitude = clamp(z - h, 0, 10000), error = amplitude - 8000, as
// sim/loop.cho) and compares Z after every sample with the trace sim/pid.cho produced (loop_trace.txt). Then tests the deadman.
module zl_tb;
  reg clk = 0, rst = 1, start = 0, kick = 0;
  reg signed [31:0] err, kp, ki, kd, ilim, zmin, zmax, zinit, zretract;
  reg [31:0] timeout;
  wire signed [31:0] z_out; wire busy, fault;
  z_loop dut(clk, rst, start, kick, err, kp, ki, kd, ilim, zmin, zmax, zinit, zretract, timeout, z_out, busy, fault);
  always #5 clk = ~clk;

  function signed [31:0] plant(input signed [31:0] z, input signed [31:0] h);
    reg signed [31:0] g;
    begin g = z - h; if (g < 0) g = 0; if (g > 10000) g = 10000; plant = g - 8000; end
  endfunction

  integer f, r, n, bad, cyc, period, maxz, i, fails;
  reg signed [63:0] a0,a1,a2,a3,a4,a5,a6,a7, h, ez;
  initial begin
    bad = 0; n = 0; fails = 0; period = 0;
    f = $fopen("loop_trace.txt", "r");
    r = $fscanf(f, "%d %d %d %d %d %d %d %d\n", a0,a1,a2,a3,a4,a5,a6,a7);
    kp=a0; ki=a1; kd=a2; ilim=a3; zmin=a4; zmax=a5; zinit=a6; zretract=a7; timeout=1000; err=0;
    repeat (3) @(negedge clk);
    rst = 0;
    @(negedge clk);
    while (!$feof(f)) begin
      r = $fscanf(f, "%d %d\n", h, ez);
      if (r == 2) begin
        err = plant(z_out, h[31:0]);
        start = 1; kick = 1;
        @(negedge clk); start = 0; kick = 0; cyc = 1;
        while (busy) begin @(negedge clk); cyc = cyc + 1; end
        period = cyc;
        n = n + 1;
        if (z_out !== ez[31:0]) begin bad = bad + 1; if (bad < 5) $display("MISMATCH step %0d: z=%0d want %0d", n, z_out, ez); end
      end
    end
    $display("closed loop: %0d steps, %0d clocks per sample, %0d mismatches", n, period, bad);

    // deadman: stop kicking; the fault must latch, Z must go to the clamped retract value, and samples must be refused
    timeout = 50;
    repeat (70) @(negedge clk);
    if (fault !== 1'b1) begin fails = fails + 1; $display("FAIL deadman: fault not latched"); end
    if (z_out !== zmax) begin fails = fails + 1; $display("FAIL deadman: z_out=%0d, want retract %0d", z_out, zmax); end
    err = 5000; start = 1; @(negedge clk); start = 0; @(negedge clk);
    if (busy) begin fails = fails + 1; $display("FAIL deadman: a sample was accepted after the fault"); end
    // the host's limit also bounds the output: lower zmax below the retract request
    zmax = 45000; #1;
    if (z_out !== 45000) begin fails = fails + 1; $display("FAIL limit: z_out=%0d, want 45000", z_out); end
    rst = 1; @(negedge clk); rst = 0; kick = 1; @(negedge clk);
    if (fault !== 1'b0 || z_out !== zinit) begin fails = fails + 1; $display("FAIL reset: fault=%0d z_out=%0d", fault, z_out); end
    $display("deadman and limit: %0d failures", fails);
    $finish;
  end
endmodule
