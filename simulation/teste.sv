`timescale 1ns / 1ps

module teste(

);
    bit clk = 0;
    reg [7:0] a = 8'b10010000;
    reg signed [9:0] b = 10'b1100000000;

    initial begin
        #10
        b[9:0] <= a[7:0];
    end

endmodule