// Bring-up test of the serial bridge alone: a register file of 4 words behind it; host side in the testbench.
`timescale 1ns/100ps
module uart_tb;
  reg clk = 0; reg rst = 1;
  always #18.5 clk = ~clk;
  reg rx = 1; wire tx;
  wire [7:0] rd; wire rv; wire [7:0] td; wire ts, tb_;
  uart_rx urx(clk, rst, rx, rd, rv);
  uart_tx utx(clk, rst, td, ts, tx, tb_);
  wire [31:0] a, w, r; wire we, re; reg [31:0] mem [0:3];
  wire ok = (a[31:4] == 28'h4000000) && (a[1:0] == 0);
  assign r = ok ? mem[a[3:2]] : 32'h0;
  afm_bridge br(clk, rst, rd, rv, td, ts, tb_, a, w, we, re, r, !ok);
  always @(posedge clk) if (we && ok) mem[a[3:2]] <= w;
  task send(input [7:0] b); integer i; begin
    rx = 0; repeat (234) @(posedge clk);
    for (i = 0; i < 8; i = i + 1) begin rx = b[i]; repeat (234) @(posedge clk); end
    rx = 1; repeat (234) @(posedge clk);
  end endtask
  // background receiver: every byte the board sends goes into a FIFO
  reg [7:0] fifo [0:255]; integer wp = 0, rpn = 0;
  reg [7:0] cur; integer k;
  initial begin
    forever begin
      @(negedge tx); repeat (117) @(posedge clk);
      for (k = 0; k < 8; k = k + 1) begin repeat (234) @(posedge clk); cur[k] = tx; end
      repeat (234) @(posedge clk);
      fifo[wp[7:0]] = cur; wp = wp + 1;
    end
  end
  task recv(output [7:0] b); begin
    while (rpn == wp) @(posedge clk);
    b = fifo[rpn[7:0]]; rpn = rpn + 1;
  end endtask
  task wr(input [31:0] ad, input [31:0] d, output [7:0] resp); begin
    send(8'h57); send(ad[31:24]); send(ad[23:16]); send(ad[15:8]); send(ad[7:0]);
    send(d[31:24]); send(d[23:16]); send(d[15:8]); send(d[7:0]); recv(resp);
  end endtask
  task rdr(input [31:0] ad, output [31:0] d, output [7:0] resp); reg [7:0] b0,b1,b2,b3; begin
    send(8'h52); send(ad[31:24]); send(ad[23:16]); send(ad[15:8]); send(ad[7:0]);
    recv(resp); recv(b0); recv(b1); recv(b2); recv(b3); d = {b0,b1,b2,b3};
  end endtask
  reg [7:0] rp; reg [31:0] dd; integer fails;
  initial begin #60000000; $display("WATCHDOG: testbench stuck at %0t", $time); $finish; end
  initial begin
    fails = 0; mem[0] = 0; mem[1] = 0; mem[2] = 0; mem[3] = 0;
    repeat (10) @(posedge clk); rst = 0; repeat (10) @(posedge clk);
    wr(32'h40000004, 32'hdeadbeef, rp); if (rp !== 8'h00) begin fails = fails + 1; $display("FAIL write resp %h", rp); end
    rdr(32'h40000004, dd, rp); if (rp !== 8'h00 || dd !== 32'hdeadbeef) begin fails = fails + 1; $display("FAIL read %h resp %h", dd, rp); end
    wr(32'h40000100, 32'h1, rp); if (rp !== 8'h02) begin fails = fails + 1; $display("FAIL bad addr write resp %h", rp); end
    rdr(32'h40000100, dd, rp); if (rp !== 8'h02) begin fails = fails + 1; $display("FAIL bad addr read resp %h", rp); end
    send(8'h41); send(8'h00);
    wr(32'h40000008, 32'h01020304, rp); rdr(32'h40000008, dd, rp);
    if (dd !== 32'h01020304) begin fails = fails + 1; $display("FAIL after noise %h", dd); end
    $display("uart bridge: %0d failures", fails); $finish;
  end
endmodule
