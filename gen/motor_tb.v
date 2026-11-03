// Lockstep: the generated stepper driver against sim/motor.cho on every clock of motor_trace.txt, then a protocol check of the pulses it makes.
module motor_lock_tb;
  reg clk = 0, rst = 1, enable = 1, hold = 0, go = 0; reg signed [31:0] steps = 0; reg [31:0] rate = 8;
  wire step, dir, busy; wire signed [31:0] pos;
  motor_drv dut(clk, rst, enable, hold, go, steps, rate, step, dir, busy, pos);
  always #5 clk = ~clk;
  integer f, r, n, bad, edges, k; reg prev;
  reg signed [63:0] en, ho, g, st, ra, eb, es, ed, ep;
  initial begin
    bad = 0; n = 0;
    repeat (3) @(negedge clk); rst = 0;
    f = $fopen("motor_trace.txt", "r");
    while (!$feof(f)) begin
      r = $fscanf(f, "%d %d %d %d %d %d %d %d %d\n", en, ho, g, st, ra, eb, es, ed, ep);
      if (r == 9) begin
        @(negedge clk); enable = en[0]; hold = ho[0]; go = g[0]; steps = st[31:0]; rate = ra[31:0];
        @(posedge clk); #1; n = n + 1;
        if (busy !== eb[0] || step !== es[0] || dir !== ed[0] || pos !== ep[31:0]) begin
          bad = bad + 1;
          if (bad < 4) $display("MOTOR MISMATCH row %0d: busy=%b step=%b dir=%b pos=%0d want %0d %0d %0d %0d", n, busy, step, dir, pos, eb, es, ed, ep);
        end
      end
    end
    // protocol: 7 steps forward then 4 back at a period of 10 clocks: count the rising edges of STEP and the direction pin during each
    rst = 1; enable = 1; hold = 0; go = 0; rate = 10; repeat (2) @(negedge clk); rst = 0; @(negedge clk); steps = 7; go = 1; @(negedge clk); go = 0; edges = 0; prev = 0;
    while (busy) begin @(posedge clk); #1; if (step && !prev) edges = edges + 1; prev = step; end
    $display("motor protocol: forward %0d edges (want 7), dir %b, pos %0d (want 7)", edges, dir, pos);
    k = edges;
    @(negedge clk); steps = -4; go = 1; @(negedge clk); go = 0; edges = 0; prev = 0;
    while (busy) begin @(posedge clk); #1; if (step && !prev) edges = edges + 1; prev = step; end
    $display("motor protocol: back %0d edges (want 4), dir %b, pos %0d (want 3)", edges, dir, pos);
    $display("motor lockstep: %0d clocks, %0d mismatches", n, bad);
    $finish;
  end
endmodule
