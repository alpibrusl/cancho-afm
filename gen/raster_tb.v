// Runs the generated raster through a whole frame and past its end, one tick at a time, and compares x, y, tick, line, trace and done
// with the cancho trace (raster_trace.txt) at every tick. Also: `hold` freezes it, `done` is final, `rst` restarts it.
module r_tb;
  reg clk = 0, rst = 1, tick = 0, hold = 0;
  reg signed [31:0] npix, nlines, x0, y0, dx, dy;
  wire signed [31:0] x_out, y_out, pix, line_out; wire trace, done;
  raster dut(clk, rst, tick, hold, npix, nlines, x0, y0, dx, dy, x_out, y_out, pix, line_out, trace, done);
  always #5 clk = ~clk;
  integer f, r, n, bad, fails;
  reg signed [63:0] c0,c1,c2,c3,c4,c5, ex, ey, et, el, etr, ed;
  initial begin
    bad = 0; n = 0; fails = 0;
    f = $fopen("raster_trace.txt", "r");
    r = $fscanf(f, "%d %d %d %d %d %d\n", c0,c1,c2,c3,c4,c5);
    npix=c0; nlines=c1; x0=c2; y0=c3; dx=c4; dy=c5;
    repeat (3) @(negedge clk);
    rst = 0; @(negedge clk);
    while (!$feof(f)) begin
      r = $fscanf(f, "%d %d %d %d %d %d\n", ex, ey, et, el, etr, ed);
      if (r == 6) begin
        if (x_out !== ex[31:0] || y_out !== ey[31:0] || pix !== et[31:0] || line_out !== el[31:0] || trace !== etr[0] || done !== ed[0]) begin
          bad = bad + 1;
          if (bad < 5) $display("MISMATCH tick %0d: x=%0d y=%0d t=%0d line=%0d trace=%0d done=%0d want %0d %0d %0d %0d %0d %0d",
                                 n, x_out, y_out, pix, line_out, trace, done, ex, ey, et, el, etr, ed);
        end
        if (n == 20) begin  // hold: ticks with hold set change nothing
          hold = 1; tick = 1; repeat (3) @(negedge clk); tick = 0; hold = 0;
          if (x_out !== ex[31:0] || pix !== et[31:0]) begin fails = fails + 1; $display("FAIL hold: state moved"); end
        end
        tick = 1; @(negedge clk); tick = 0; @(negedge clk);
        n = n + 1;
      end
    end
    $display("raster: %0d ticks, %0d mismatches, done=%0d", n, bad, done);
    tick = 1; repeat (4) @(negedge clk); tick = 0;
    if (done !== 1'b1) begin fails = fails + 1; $display("FAIL done not final"); end
    rst = 1; @(negedge clk); rst = 0; #1;
    if (x_out !== x0 || y_out !== y0 || pix !== 0 || line_out !== 0 || done !== 1'b0) begin fails = fails + 1; $display("FAIL rst"); end
    $display("hold, done, reset: %0d failures", fails);
    $finish;
  end
endmodule
