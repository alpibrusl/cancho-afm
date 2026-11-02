// System test of afm_top: the board's pins connected to behavioural models of the Pmod AD1 (reading a simulated fork and tip above a surface)
// and four Pmod DA3, and everything driven through the serial port like a host would. Nothing reaches inside the design except to watch.
`timescale 1ns/100ps
module afm_top_tb;
  reg clk = 0;
  always #18.5 clk = ~clk;
  reg rxd = 1; wire txd;
  wire adc_cs, adc_sck, adc_d0, adc_d1;
  wire dz_cs, dz_din, dz_sclk, dx_cs, dx_din, dx_sclk, dy_cs, dy_din, dy_sclk, dd_cs, dd_din, dd_sclk, ldac, motor_step, motor_dir, motor_en_n;
  integer m_edges = 0; always @(posedge motor_step) m_edges = m_edges + 1;
  wire [5:0] led;
  afm_top dut(clk, rxd, txd, adc_cs, adc_sck, adc_d0, adc_d1, dz_cs, dz_din, dz_sclk, dx_cs, dx_din, dx_sclk, dy_cs, dy_din, dy_sclk, dd_cs, dd_din, dd_sclk, ldac, motor_step, motor_dir, motor_en_n, led);

  // ---- DA3 models: shift DIN in on rising SCLK while CS low; load the output when CS rises with exactly 16 bits and LDAC low
  reg [15:0] code_z = 0, code_x = 0, code_y = 0, code_d = 32768;
  integer bad_frames = 0;
  reg [15:0] srz, srx, sry, srd; integer nz = 0, nx = 0, ny = 0, nd = 0; reg armed = 0;
  always @(negedge dz_cs) begin nz = 0; armed = 1; end
  always @(posedge dz_sclk) if (!dz_cs) begin srz <= {srz[14:0], dz_din}; nz = nz + 1; end
  always @(posedge dz_cs) if (armed) begin if (nz == 16 && !ldac) code_z <= srz; else bad_frames = bad_frames + 1; end
  always @(negedge dx_cs) nx = 0;
  always @(posedge dx_sclk) if (!dx_cs) begin srx <= {srx[14:0], dx_din}; nx = nx + 1; end
  always @(posedge dx_cs) if (armed) begin if (nx == 16 && !ldac) code_x <= srx; else bad_frames = bad_frames + 1; end
  always @(negedge dy_cs) ny = 0;
  always @(posedge dy_sclk) if (!dy_cs) begin sry <= {sry[14:0], dy_din}; ny = ny + 1; end
  always @(posedge dy_cs) if (armed) begin if (ny == 16 && !ldac) code_y <= sry; else bad_frames = bad_frames + 1; end
  always @(negedge dd_cs) nd = 0;
  always @(posedge dd_sclk) if (!dd_cs) begin srd <= {srd[14:0], dd_din}; nd = nd + 1; end
  always @(posedge dd_cs) if (armed) begin if (nd == 16 && !ldac) code_d <= srd; else bad_frames = bad_frames + 1; end
  integer drive_min = 65535, drive_max = 0;
  reg [15:0] prev_d = 16'd32768; integer drive_cross = 0, conv_at_start = 0;
  always @(code_d) begin if (prev_d < 16'd32768 && code_d >= 16'd32768) drive_cross = drive_cross + 1; prev_d = code_d; end
  always @(code_d) begin if (code_d < drive_min) drive_min = code_d; if (code_d > drive_max) drive_max = code_d; end

  // ---- the plant: a fork of amplitude A0 pm in free air at 8 samples per period, lagging its target by alpha per sample; a tip that
  // reduces it as gap/free when the gap (Z, 16 pm per DAC code, above a surface at 0) is under free
  real A0 = 2000.0, FREE = 2000.0, ALPHA = 0.0016, amp_pm = 2000.0, gap, target, pi = 3.14159265358979;
  integer nconv = 0; reg [15:0] sr0, sr1; reg [11:0] v0, v1; real sv;
  always @(negedge adc_cs) begin
    gap = code_z * 16.0;
    target = (gap >= FREE) ? A0 : (gap <= 0.0) ? 0.0 : A0 * gap / FREE;
    amp_pm = amp_pm + ALPHA * (target - amp_pm);
    sv = 2048.0 + 0.5 * amp_pm * $sin(2.0 * pi * nconv / 8.0 + 0.5);
    if (sv < 0.0) sv = 0.0; if (sv > 4095.0) sv = 4095.0;
    v0 = $rtoi(sv + 0.5); v1 = 12'd1234;
    sr0 <= {4'b0, v0}; sr1 <= {4'b0, v1}; nconv = nconv + 1;
  end
  always @(negedge adc_sck) if (!adc_cs) begin sr0 <= {sr0[14:0], 1'b0}; sr1 <= {sr1[14:0], 1'b0}; end
  assign adc_d0 = sr0[15];
  assign adc_d1 = sr1[15];

  integer fails = 0;
  // ---- the host: a serial port
  reg [7:0] fifo [0:255]; integer wp = 0, rpn = 0; reg [7:0] cur; integer k;
  initial forever begin
    @(negedge txd); repeat (117) @(posedge clk);
    for (k = 0; k < 8; k = k + 1) begin repeat (234) @(posedge clk); cur[k] = txd; end
    repeat (234) @(posedge clk);
    fifo[wp[7:0]] = cur; wp = wp + 1;
  end
  task recv(output [7:0] b); begin while (rpn == wp) @(posedge clk); b = fifo[rpn[7:0]]; rpn = rpn + 1; end endtask
  task send(input [7:0] b); integer i; begin
    rxd = 0; repeat (234) @(posedge clk);
    for (i = 0; i < 8; i = i + 1) begin rxd = b[i]; repeat (234) @(posedge clk); end
    rxd = 1; repeat (234) @(posedge clk);
  end endtask
  task wr(input [7:0] idx, input [31:0] d, output [7:0] resp); begin
    send(8'h57); send(8'h40); send(8'h00); send(8'h00); send({idx[5:0], 2'b00});
    send(d[31:24]); send(d[23:16]); send(d[15:8]); send(d[7:0]); recv(resp);
  end endtask
  task rd(input [31:0] ad, output [31:0] d, output [7:0] resp); reg [7:0] b0, b1, b2, b3; begin
    send(8'h52); send(ad[31:24]); send(ad[23:16]); send(ad[15:8]); send(ad[7:0]);
    recv(resp); recv(b0); recv(b1); recv(b2); recv(b3); d = {b0, b1, b2, b3};
  end endtask
  task rdi(input [7:0] idx, output [31:0] d); reg [7:0] r; begin rd({24'h400000, idx[5:0], 2'b00}, d, r); if (r !== 8'h00) begin fails = fails + 1; $display("FAIL read of register %0d answered %h", idx, r); end end endtask
  task w(input [7:0] idx, input [31:0] d); reg [7:0] r; begin wr(idx, d, r); if (r !== 8'h00) begin fails = fails + 1; $display("FAIL write of register %0d answered %h", idx, r); end end endtask

  integer i, loop_ok; integer x_max = 0;
  always @(code_x) if (code_x > x_max && code_x < 16'd50000) x_max = code_x;
  reg [31:0] d, free_r, spv; reg [7:0] rp;
  real zf, gapf;
  initial begin #3000000000; $display("WATCHDOG at %0t", $time); $finish; end
  initial begin
    repeat (400) @(posedge clk);
    // ---- phase 1: the register interface, defaults and refusals
    rdi(0, d); if (d !== 32'hAF500001) begin fails = fails + 1; $display("FAIL id %h", d); end
    rdi(1, d); if (d !== 0) begin fails = fails + 1; $display("FAIL ctrl default %h", d); end
    rdi(14, d); if (d !== 0) begin fails = fails + 1; $display("FAIL zmax default %h (must fail closed)", d); end
    w(3, 32'd103); rdi(3, d); if (d !== 103) begin fails = fails + 1; $display("FAIL readback %0d", d); end
    wr(2, 32'h1, rp); if (rp !== 8'h02) begin fails = fails + 1; $display("FAIL write to status answered %h", rp); end
    rd(32'h40000200, d, rp); if (rp !== 8'h02) begin fails = fails + 1; $display("FAIL read of an unmapped address answered %h", rp); end
    rd(32'h00000004, d, rp); if (rp !== 8'h02) begin fails = fails + 1; $display("FAIL read below the base answered %h", rp); end
    $display("phase 1 (registers): %0d failures so far", fails);
    // ---- phase 2: bench, the Part 5 check: the DACs follow what is written, the ADC reads the simulated fork
    w(6, 2); w(3, 103); w(4, 32'd536870912); w(5, 64);
    w(28, 32'd2500); w(29, 32'h1234); w(30, 32'hFEDC); w(31, 32'h0F0F);
    w(1, 32'h18);   // manual + adc_run
    repeat (30000) @(posedge clk);
    if (code_z !== 16'd2500 || code_x !== 16'h1234 || code_y !== 16'hFEDC || code_d !== 16'h0F0F) begin fails = fails + 1; $display("FAIL dacs hold %0d %h %h %h", code_z, code_x, code_y, code_d); end
    w(28, 32'd40000); w(29, 32'd0); w(30, 32'd65535); w(31, 32'd1);
    repeat (30000) @(posedge clk);
    if (code_z !== 16'd40000 || code_x !== 16'd0 || code_y !== 16'd65535 || code_d !== 16'd1) begin fails = fails + 1; $display("FAIL dacs after ramp hold %0d %0d %0d %0d", code_z, code_x, code_y, code_d); end
    w(28, 32'd2500);   // Z at 40,000 pm: far above the surface, amplitude is the free amplitude
    repeat (200000) @(posedge clk);
    rdi(32, free_r); rdi(38, d);
    $display("phase 2 (bench): free figure %0d, adc0 %0d, samples seen, dac bad frames %0d", free_r, d, bad_frames);
    if (free_r < 30000 || free_r > 60000) begin fails = fails + 1; $display("FAIL free figure %0d out of the expected range", free_r); end
    rdi(40, d); if (d < 1000) begin fails = fails + 1; $display("FAIL only %0d samples", d); end
    // ---- phase 3: the loop closes
    w(1, 0); repeat (500) @(posedge clk);
    w(7, 4); w(8, (free_r * 8 / 10) >> 4); w(9, 2304); w(10, 0); w(11, 0); w(12, 65535);
    w(13, 0); w(14, 60000); w(15, 3000); w(16, 60000); w(17, 32'd40000000);
    w(19, 32'd20000); w(20, 32'd32768);
    drive_min = 65535; drive_max = 0; drive_cross = 0; conv_at_start = nconv;
    w(1, 32'h13);   // run + drive + adc_run
    loop_ok = 0;
    for (i = 0; i < 60; i = i + 1) w(18, 0);   // the host's heartbeat
    rdi(33, d); zf = d; gapf = zf;
    $display("phase 3 (loop): z %0d pm (target about 1600), dac z code*16 = %0d, windows %0d, drive swung %0d..%0d", d, code_z * 16, nconv / 64, drive_min, drive_max);
    if (gapf < 1360.0 || gapf > 1840.0) begin fails = fails + 1; $display("FAIL the gap %0d pm is not within 15%% of 1600", d); end
    if (code_z * 16 < d - 16 || code_z * 16 > d + 16) begin fails = fails + 1; $display("FAIL the Z DAC (%0d) does not follow Z (%0d)", code_z * 16, d); end
    if (drive_max < 52000 || drive_max > 53500 || drive_min < 12000 || drive_min > 13500) begin fails = fails + 1; $display("FAIL the drive swung %0d..%0d, wanted about 12768..52768", drive_min, drive_max); end
    // the drive is one sine period per 8 samples (the detector's own phase): upward crossings of mid-scale per conversion about 1/8
    if (drive_cross * 100 < (nconv - conv_at_start) * 11 || drive_cross * 100 > (nconv - conv_at_start) * 14) begin fails = fails + 1; $display("FAIL drive frequency: %0d crossings in %0d conversions, wanted about 1 in 8", drive_cross, nconv - conv_at_start); end
    rdi(2, d); if (d[0] !== 1'b0) begin fails = fails + 1; $display("FAIL fault set while kicking"); end
    // ---- phase 4: the limit, and the deadman
    w(14, 32'd1000); repeat (3000) @(posedge clk);
    rdi(33, d); if (d !== 1000) begin fails = fails + 1; $display("FAIL the limit did not clamp Z: %0d", d); end
    w(14, 32'd60000); w(17, 32'd300000);
    // a heartbeat every ~80,000 clocks keeps a 300,000-clock deadman quiet for 1.2 million clocks
    for (i = 0; i < 15; i = i + 1) begin w(18, 0); repeat (60000) @(posedge clk); end
    rdi(2, d); if (d[0] !== 1'b0) begin fails = fails + 1; $display("FAIL the deadman latched while the host was kicking"); end
    repeat (600000) @(posedge clk);
    rdi(2, d); if (d[0] !== 1'b1) begin fails = fails + 1; $display("FAIL the deadman did not latch"); end
    rdi(33, d); if (d !== 60000) begin fails = fails + 1; $display("FAIL Z did not go to the retract value: %0d", d); end
    if (code_z !== 16'd3750) begin fails = fails + 1; $display("FAIL the Z DAC code is %0d, wanted 3750", code_z); end
    // ---- phase 5: back to rest
    w(1, 0); repeat (30000) @(posedge clk);
    rdi(2, d); if (d[0] !== 1'b0) begin fails = fails + 1; $display("FAIL fault not cleared by run=0"); end
    rdi(33, d); if (d !== 3000) begin fails = fails + 1; $display("FAIL Z is %0d at rest, wanted zinit 3000", d); end
    // ---- phase 6: a small scan, the raster advancing one pixel per 3 loop steps (4 pixels, 2 lines: 12 ticks, 36 windows)
    w(17, 0); w(21, 4); w(22, 2); w(23, 1000); w(24, 2000); w(25, 100); w(26, 250); w(27, 3);
    x_max = 0;
    w(1, 32'h15);   // run + scan + adc_run
    repeat (60000) @(posedge clk);
    rdi(2, d); if (d[3] !== 1'b0) begin fails = fails + 1; $display("FAIL the scan was done after %0d windows; 36 are needed", nconv / 64); end
    repeat (600000) @(posedge clk);
    rdi(2, d); if (d[3] !== 1'b1) begin fails = fails + 1; $display("FAIL the scan did not finish"); end
    if (x_max !== 1300) begin fails = fails + 1; $display("FAIL the X DAC reached %0d, wanted 1300", x_max); end
    if (code_x !== 16'd1000 || code_y !== 16'd2250) begin fails = fails + 1; $display("FAIL after the scan X=%0d Y=%0d, wanted 1000 and 2250", code_x, code_y); end
    $display("phase 6 (scan): x max %0d, final x %0d y %0d", x_max, code_x, code_y);
    // ---- phase 7: the coarse-approach motor. Fails closed: nothing moves until it is enabled and given a maximum.
    w(1, 0);
    if (motor_en_n !== 1'b1) begin fails = fails + 1; $display("FAIL the motor driver is enabled at rest"); end
    rdi(47, d); if (d !== 0) begin fails = fails + 1; $display("FAIL MOTOR_MAX default %0d, must be 0", d); end
    w(44, 40);
    w(1, 32'h20);  // motor enable only
    if (motor_en_n !== 1'b0) begin fails = fails + 1; $display("FAIL the enable pin did not go active"); end
    m_edges = 0; w(43, 1); repeat (2000) @(posedge clk);
    rdi(45, d); if (d[2] !== 1'b1 || m_edges !== 0) begin fails = fails + 1; $display("FAIL a command with MOTOR_MAX = 0 was not refused (status %h, %0d steps)", d, m_edges); end
    w(47, 10);
    m_edges = 0; w(43, 5); repeat (1000) @(posedge clk);
    rdi(45, d); if (d[2:0] !== 3'b010) begin fails = fails + 1; $display("FAIL motor status after 5 steps: %b", d[2:0]); end
    rdi(46, d); if (m_edges !== 5 || motor_dir !== 1'b1 || d !== 32'd5) begin fails = fails + 1; $display("FAIL forward: %0d edges, dir %b, pos %0d (want 5, 1, 5)", m_edges, motor_dir, d); end
    m_edges = 0; w(43, 32'hFFFFFFFD);   // -3
    repeat (1000) @(posedge clk);
    rdi(46, d); if (m_edges !== 3 || motor_dir !== 1'b0 || d !== 32'd2) begin fails = fails + 1; $display("FAIL back: %0d edges, dir %b, pos %0d (want 3, 0, 2)", m_edges, motor_dir, d); end
    m_edges = 0; w(43, 20); repeat (2000) @(posedge clk);   // over the maximum of 10
    rdi(45, d); if (d[2] !== 1'b1 || m_edges !== 0) begin fails = fails + 1; $display("FAIL an oversize command was not refused"); end
    // disabling aborts a move in progress
    w(44, 4000); m_edges = 0; w(43, 8); repeat (6000) @(posedge clk);
    w(1, 0); repeat (200) @(posedge clk);
    rdi(45, d); if (d[0] !== 1'b0 || motor_en_n !== 1'b1 || m_edges >= 8 || m_edges < 1) begin fails = fails + 1; $display("FAIL abort: status %b, %0d of 8 steps", d[1:0], m_edges); end
    $display("phase 7 (motor): ok so far, %0d failures", fails);
    // ---- phase 8: the sinusoidal fast axis (CTRL bit 6): 2 lines of 4 ticks (PSTEP 16384), 3 windows a tick, so 24 windows
    w(1, 0); repeat (1000) @(posedge clk);
    rdi(48, d); if (d !== 0) begin fails = fails + 1; $display("FAIL SINE_AMP default %0d, must be 0", d); end
    w(48, 40000); w(49, 16384); w(21, 4); w(22, 2); w(23, 1000); w(24, 2000); w(26, 250); w(27, 3); w(17, 0);
    x_max = 0;
    w(1, 32'h55);   // run + scan + adc_run + sine
    repeat (60000) @(posedge clk);
    rdi(2, d); if (d[3] !== 1'b0) begin fails = fails + 1; $display("FAIL the sine scan was done after %0d windows; 24 are needed", nconv / 64); end
    repeat (600000) @(posedge clk);
    rdi(2, d); if (d[3] !== 1'b1) begin fails = fails + 1; $display("FAIL the sine scan did not finish"); end
    if (x_max !== 40999) begin fails = fails + 1; $display("FAIL the X DAC reached %0d, wanted 40999", x_max); end
    if (code_x !== 16'd1000 || code_y !== 16'd2250) begin fails = fails + 1; $display("FAIL after the sine scan X=%0d Y=%0d, wanted 1000 and 2250", code_x, code_y); end
    $display("phase 8 (sine scan): x max %0d, final x %0d y %0d", x_max, code_x, code_y);
    $display("afm_top system test: %0d failures, %0d bad DAC frames, %0d conversions", fails, bad_frames, nconv);
    $finish;
  end
endmodule
