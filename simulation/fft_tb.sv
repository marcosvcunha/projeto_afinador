`timescale 1ns / 1ps

module fft_tb(

);
    localparam H_PERIOD = 5;

    bit clk = 0;
    bit rst_n = 0;
    reg [10:0] addr;
    reg [10:0] addr_load;
    reg [10:0] addr_read;
    wire [9:0] data_in;
    wire [9:0] data_out;
    bit do_load = 0;
    bit data_loaded;
    bit write_enable;
    bit read_enable;

    // fft fft_instance(
    //     .clk(clk),
    //     .rst(rst),
    //     .addr(addr),
    //     .data_in(data_in),
    //     .data_out(data_out)
    // );

    always #H_PERIOD clk = ~clk;
    
    // assign addr = addr_load ? do_load == 1 : addr_read;


    always @(*) begin
        if(write_enable == 0) begin
            addr = addr_read;
        end else begin
            addr = addr_load;
        end
    end

    load_mem load_mem_inst(
        .clk(clk),
        .addr(addr_load),
        .data_out_wire(data_in),
        .do_load(do_load),
        .data_loaded(data_loaded),
        .write_enable(write_enable)
    );

    mem mem_inst(
        .clk(clk),
        .fft_rst_n(rst_n),
        .fft_we(write_enable),
        .fft_addr(addr),
        .fft_data_in(data_in),
        .fft_data_out(data_out)
    );

    read_mem read_mem_inst(
        .clk(clk),
        .read_enable(read_enable),
        .addr(addr_read),
        .data_in(data_out)
    );

    always @(posedge clk) begin
        if(data_loaded == 0)
            read_enable = 0;
        else
            read_enable = 1;
    end

    initial begin
        #10
        rst_n = 1;
        do_load = 1;
        
    end

endmodule
