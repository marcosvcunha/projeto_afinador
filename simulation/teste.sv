`timescale 1ns / 1ps

module teste(

);
    bit clk = 0;
    reg signed [9:0] a = -22;
    reg signed [9:0] b = -24;
    reg signed [9:0] c = 362;
    reg signed [9:0] d = 362;
    reg signed [18:0] result_a = 0;
    reg signed [18:0] result_b = 0;

    // always #5 clk = ~clk;

    // always @(posedge clk) begin
    //     if(i < 10) begin
    //         addr <= i;
    //         i = i + 1;
    //     end
    // end
    initial begin
        #10
        result_a <= (a * d - b * c);
        result_b <= (a * c + b * d);
    end


endmodule