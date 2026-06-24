module umer_grid (
    input clk,
    input rst,                 // <--- Fixed: Added comma
    output [15:0] probe_val    // <--- Fixed: Debug Port
);
    // Wires to hold the distance value of each cell
    wire [15:0] grid [3:0][3:0]; // 4x4 array

    // Constant for "Infinity" (Edge of map)
    wire [15:0] INF = 16'hFFFF;

    // Connect the Probe to the Target Pixel (3,3)
    assign probe_val = grid[3][3];  // <--- Fixed: Now we can see the result!

    // Generate 16 Pixels
    genvar x, y;
    generate
        for (x=0; x<4; x=x+1) begin : COL
            for (y=0; y<4; y=y+1) begin : ROW
                
                // Declare the neighbor wires first
                wire [15:0] n, s, e, w;

                // CONDITIONAL WIRING (The Safe Way)
                // This prevents the "out of bounds" warnings
                
                // North
                if (y == 0) assign n = INF;
                else        assign n = grid[x][y-1];

                // South
                if (y == 3) assign s = INF;
                else        assign s = grid[x][y+1];

                // West
                if (x == 0) assign w = INF;
                else        assign w = grid[x-1][y];

                // East
                if (x == 3) assign e = INF;
                else        assign e = grid[x+1][y];

                // Pixel Logic
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