module read_mem(
    input bit clk,
    input bit read_enable,
    output reg [10:0] addr,
    input reg [9:0] data_in
);
    int i = 0;
    always @(posedge clk) begin
        if(read_enable == 1) begin
            if(i < 10) begin
                addr = i;
                $display("%d \t %d", data_in, $realtime);
                i = i + 1;
            end
        end
    end

endmodule