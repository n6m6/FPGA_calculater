`timescale 1ns / 1ps

module Top_tb;

    // Inputs
    reg clk_in;
    reg rst_n;
    reg [3:0] KeyBoard_col;

    // Outputs
    wire [3:0] row_out;
    wire top_rclk_out;
    wire top_sclk_out;
    wire top_sdio_out;

    // Instantiate the module to be tested
    Top dut (
        .clk_in(clk_in),
        .rst_n(rst_n),
        .KeyBoard_col(KeyBoard_col),
        .row_out(row_out),
        .top_rclk_out(top_rclk_out),
        .top_sclk_out(top_sclk_out),
        .top_sdio_out(top_sdio_out)
    );

    // Clock generation
    always begin
        #5 clk_in = ~clk_in; // Assuming a 10ns clock period
    end

    // Reset generation
    initial begin
        rst_n = 0;
        #20;
        rst_n = 1;
    end

    // Stimulus generation
    initial begin
        // Insert your stimulus here
        // You can modify KeyBoard_col and observe the outputs
        // Example:
        #10 KeyBoard_col = 4'b0001; // Example input
        #10 KeyBoard_col = 4'b0010; // Another example input
        // Add more stimulus as needed
        #100 $stop; // Stop simulation after 100 time units
    end

endmodule
