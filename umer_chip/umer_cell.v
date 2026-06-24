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
    // Define Infinity locally
    parameter INF = 16'hFFFF;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            val <= (is_source) ? 16'd0 : INF;
        end else if (!is_wall && !is_source) begin
            reg [15:0] best;
            best = val; 

            // THE FIX: Check for Overflow!
            // Only consider neighbor if they are NOT Infinity
            if (n_in != INF && n_in + 1 < best) best = n_in + 1;
            if (s_in != INF && s_in + 1 < best) best = s_in + 1;
            if (e_in != INF && e_in + 1 < best) best = e_in + 1;
            if (w_in != INF && w_in + 1 < best) best = w_in + 1;

            val <= best;
        end
    end
endmodule