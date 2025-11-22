`default_nettype none
`timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module tb ();

  // Dump the signals to a FST file. You can view it with gtkwave or surfer.
  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb);
    #1;
  end

  // Wire up the inputs and outputs:
  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  reg [7:0] uio_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;
`ifdef GL_TEST
  wire VPWR = 1'b1;
  wire VGND = 1'b0;
`endif

  reg finished;  // used by cocotb to check end was reached
  reg halfclk;
  reg [4:0] lfsr;

  always @(posedge clk) begin
    halfclk   <= rst_n ? ~halfclk : 1'b0;
    lfsr[4:0] <= rst_n ? { lfsr[3:0], ~(lfsr[4] ^ lfsr[2]) } : 5'd0; 
  end

  // Replace tt_um_example with your module name:
  tt_um_dlmiles_ddr_throughput_test ericsmi_tt_um_ddr_input_test (

      // Include power ports for the Gate Level test:
`ifdef GL_TEST
      .VPWR(VPWR),
      .VGND(VGND),
`endif

      .ui_in  ({8{lfsr[0]}}), // Dedicated inputs
      .uo_out (uo_out),   // Dedicated outputs
      .uio_in (uio_in),   // IOs: Input path
      .uio_out(uio_out),  // IOs: Output path
      .uio_oe (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
      .ena    (ena),      // enable - goes high when design is selected
      .clk    (halfclk),  // clock
      .rst_n  (rst_n)     // not reset
  );

  initial begin
    clk = 1 ; #10 clk = 0 ; 
    forever #10 clk = ~clk ;
  end

  initial begin
    finished = 0;
    ena = 1;
    rst_n = 0;
    uio_in = 8'd0;
    $display ("T\tRn\tL\tUj");
    $display ("------------------------------------------------------");
    @(posedge clk);
    @(posedge clk);
    rst_n = 1;
    $monitor ("%03t\t%d\t%d\t%02x", $time, rst_n, lfsr[0], uo_out[7:0]);
    #200 finished = 1;
    // cocotb needs a window of simtime to detect
    #200 $finish;
  end

endmodule
