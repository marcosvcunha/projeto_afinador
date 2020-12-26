`timescale 1ns / 1ps

module teste(

);
    bit clk = 0;
    reg [10:0] addr;
    int i = 0;


    always #5 clk = ~clk;

    always @(posedge clk) begin
        if(i < 10) begin
            addr <= i;
            i = i + 1;
        end
    end

endmodule