// =========================================================
//  THE U.M.E.R. HARDWARE SUITE (STRICT TYPING VERSION)
// =========================================================
`timescale 1ns/1ps

// --- MODULE 1: THE CELL (The Brain) ---
module umer_cell (
    input clk,
    input rst,
    input is_wall,
    input is_source,
    input [15:0] n_in, 
    input [15:0] s_in,
    input [15:0] e_in,
    input [15:0] w_in,
    output reg [15:0] val
);
    parameter INF = 16'hFFFF;
    
    // 1. COMBINATIONAL LOGIC
    reg [15:0] best;
    always @(*) begin
        best = val; 
        if (n_in != INF && n_in + 1 < best) best = n_in + 1;
        if (s_in != INF && s_in + 1 < best) best = s_in + 1;
        if (e_in != INF && e_in + 1 < best) best = e_in + 1;
        if (w_in != INF && w_in + 1 < best) best = w_in + 1;
    end

    // 2. SEQUENTIAL LOGIC (FIX: Synchronous Reset)
    // Removed "or posedge rst" so the synthesizer can use logic gates for the reset
    always @(posedge clk) begin
        if (rst) begin
            if (is_source) 
                val <= 16'd0;
            else 
                val <= INF;
        end else if (!is_wall && !is_source) begin
            val <= best;
        end
    end
endmodule

// --- MODULE 2: THE GRID (The Body) ---
module umer_grid (
    input clk,
    input rst,
    output [15:0] probe_val
);
    wire [15:0] grid [3:0][3:0];
    wire [15:0] INF = 16'hFFFF;

    assign probe_val = grid[3][3];

    genvar x, y;
    generate
        for (x=0; x<4; x=x+1) begin : COL
            for (y=0; y<4; y=y+1) begin : ROW
                wire [15:0] n, s, e, w;

                assign n = (y == 0) ? INF : grid[x][y>0 ? y-1 : 0];
                assign s = (y == 3) ? INF : grid[x][y<3 ? y+1 : 3];
                assign w = (x == 0) ? INF : grid[x>0 ? x-1 : 0][y];
                assign e = (x == 3) ? INF : grid[x<3 ? x+1 : 3][y];

                wire is_src = (x==0 && y==0);
                wire is_wall = (x==1 && y==1);

                umer_cell pixel (
                    .clk(clk), .rst(rst),
                    .is_wall(is_wall), .is_source(is_src),
                    .n_in(n), .s_in(s), .e_in(e), .w_in(w),
                    .val(grid[x][y])
                );
            end
        end
    endgenerate
endmodule

// --- MODULE 3: THE TESTBENCH (The Verifier) ---
module umer_testbench;
    reg clk;
    reg rst;
    wire [15:0] result;

    umer_grid uut (.clk(clk), .rst(rst), .probe_val(result));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("umer_all.vcd");
        $dumpvars(0, umer_testbench);

        clk = 0; rst = 1;
        
        #20; rst = 0;
        
        // Watch for the specific value '6'
        wait (result === 6);
        
        $display("------------------------------------------------");
        $display("   VICTORY! Target Reached.");
        $display("   Final Time: %0t ns", $time);
        $display("   Latency:    %0d ns (Cycles: %0d)", ($time - 20), ($time - 20)/10);
        $display("------------------------------------------------");
        $finish;
    end
endmodule