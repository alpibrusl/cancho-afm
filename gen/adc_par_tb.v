// Drives the generated parallel-ADC interface with the cancho trace, one clock per row, and compares every output after every clock.
module adc_par_lock_tb;
  reg clk = 0, rst = 1;
  reg en = 0, otr_in = 0; reg [7:0] half = 3; reg [11:0] d = 0;
  wire adc_clk, done, otr; wire [11:0] code;
  adc_par dut(clk, rst, en, half, d, otr_in, adc_clk, done, code, otr);
  always #5 clk = ~clk;
  integer f, r, n, bad, reports;
  reg signed [63:0] h, e, dd, o, ek, ed, ec, eo;
  initial begin
    bad = 0; reports = 0; n = 0;
    repeat (3) @(negedge clk);
    rst = 0;
    f = $fopen("adc_par_trace.txt", "r");
    while (!$feof(f)) begin
      r = $fscanf(f, "%d %d %d %d %d %d %d %d\n", h, e, dd, o, ek, ed, ec, eo);
      if (r == 8) begin
        @(negedge clk); half = h; en = e; d = dd; otr_in = o;
        @(posedge clk); #1; n = n + 1;
        if (adc_clk !== ek[0] || done !== ed[0] || code !== ec[11:0] || otr !== eo[0]) begin
          bad = bad + 1;
          if (bad < 4) $display("MISMATCH row %0d: got ck=%b done=%b code=%0d otr=%b want %0d %0d %0d %0d", n, adc_clk, done, code, otr, ek, ed, ec, eo);
        end
        if (done) reports = reports + 1;
      end
    end
    $display("adc_par lockstep: %0d clocks, %0d reports, %0d mismatches", n, reports, bad);
    $finish;
  end
endmodule
