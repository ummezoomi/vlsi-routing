`timescale 1ns/1ps

module umer_verify;
    reg clk;
    reg rst;
    wire [15:0] result; // Connects to probe_val

    // Instantiate with the probe connected
    umer_grid uut (
        .clk(clk), 
        .rst(rst), 
        .probe_val(result)
    );

    always #5 clk = ~clk;

    initial begin
        // Dump waves
        $dumpfile("umer_verify.vcd");
        $dumpvars(0, umer_verify);

        clk = 0; rst = 1;
        $display("[TEST] Resetting...");
        #20; rst = 0;
        $display("[TEST] Running...");

        // Wait for the result to settle (become valid)
        // We assume valid when it's not Infinity (FFFF)
        wait (result !== 16'hFFFF);

        // Record time
        $display("[TEST] Wavefront hit target at %0t ns", $time);
        
        // Allow 1 clock cycle for data to latch cleanly
        #10;

        if (result === 6) 
            $display("SUCCESS: Logic Verified. Distance = 6.");
        else 
            $display("FAILURE: Expected 6, Got %d", result);

        $finish;
    end
endmodule