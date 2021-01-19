`timescale 1ns / 1ps

module teste(

);
    bit clk = 0;
    reg signed [9:0] a = -22;
    reg signed [9:0] b = -24;
    reg signed [9:0] sum = 0;

    initial begin
        #10
        sum = a + b;
    end


endmodule