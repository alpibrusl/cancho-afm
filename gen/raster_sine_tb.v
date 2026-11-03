// Lockstep: the generated sinusoidal raster against sim/raster_sine.cho on every clock of raster_sine_trace.txt.
module rsine_tb;
  reg clk = 0, rst = 1, tick = 0, hold = 0; reg [31:0] pstep = 9000, amp = 3000;
  wire [31:0] x_out, y_out, line_out; wire [15:0] phase; wire trace, done;
  raster_sine dut(clk, rst, tick, hold, 32'd3, 32'd2000, 32'd250, 32'd1000, amp, pstep, x_out, y_out, phase, line_out, trace, done);
  always #5 clk = ~clk;
  integer f, r, n, bad, max_x, min_x;
  reg signed [63:0] rs, ti, ho, ps, am, ex, ey, ep, el, et, ed;
  initial begin
    bad = 0; n = 0; max_x = 0; min_x = 1000000;
    repeat (3) @(negedge clk); rst = 0;
    f = $fopen("raster_sine_trace.txt", "r");
    while (!$feof(f)) begin
      r = $fscanf(f, "%d %d %d %d %d %d %d %d %d %d %d\n", rs, ti, ho, ps, am, ex, ey, ep, el, et, ed);
      if (r == 11) begin
        @(negedge clk); rst = rs[0]; tick = ti[0]; hold = ho[0]; pstep = ps[31:0]; amp = am[31:0];
        @(posedge clk); #1; n = n + 1;
        if (x_out !== ex[31:0] || y_out !== ey[31:0] || phase !== ep[15:0] || line_out !== el[31:0] || trace !== et[0] || done !== ed[0]) begin
          bad = bad + 1;
          if (bad < 4) $display("RSINE MISMATCH row %0d: x=%0d y=%0d phase=%0d line=%0d trace=%b done=%b want %0d %0d %0d %0d %0d %0d", n, x_out, y_out, phase, line_out, trace, done, ex, ey, ep, el, et, ed);
        end
        if (x_out > max_x) max_x = x_out; if (x_out < min_x) min_x = x_out;
      end
    end
    $display("raster_sine lockstep: %0d clocks, %0d mismatches, x from %0d to %0d, done=%b", n, bad, min_x, max_x, done);
    $finish;
  end
endmodule
