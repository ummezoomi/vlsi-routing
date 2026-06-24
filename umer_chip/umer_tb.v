`timescale 1ns/1ps

module umer_tb;
    reg clk;
    reg rst;

    // Instantiate the Grid
    umer_grid uut (.clk(clk), .rst(rst));

    // Generate Clock (10ns cycle = 100MHz)
    always #5 clk = ~clk;

    initial begin
        // 1. Setup Simulation File
        $dumpfile("umer_wave.vcd");
        $dumpvars(0, umer_tb);

        // 2. Start Logic
        clk = 0;
        rst = 1; // Hold Reset
        #20;
        rst = 0; // Release Reset (Start!)

        // 3. Watch it run for 200ns
        #200;
        $finish;
    end
endmodule