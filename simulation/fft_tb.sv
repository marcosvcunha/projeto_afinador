`timescale 1ns / 1ps

module fft_tb(

);
    localparam H_PERIOD = 5;

    bit clk = 0;
    bit rst_n = 0;
    reg [10:0] addr;
    reg [10:0] addr_load;
    reg [10:0] addr_fft;
    wire [9:0] data_out_load_mem;
    wire [9:0] data_out_fft;
    reg [9:0] data_in;
    wire [9:0] data_out;
    bit do_load;
    bit data_loaded;
    bit load_mem_write_enable;
    bit fft_write_enable;
    bit write_enable;
    bit read_enable;
    bit do_fft;
    bit fft_done;

    typedef enum {IDLE, LOAD_SOUND, DO_FFT, END} state_type;

    state_type state;

    always #H_PERIOD clk = ~clk;
    
    // assign addr = addr_load ? do_load == 1 : addr_read;

    load_mem load_mem_inst(
        .clk(clk),
        .addr(addr_load),
        .data_out_wire(data_out_load_mem),
        .do_load(do_load),
        .data_loaded(data_loaded),
        .write_enable(load_mem_write_enable)
    );

    mem mem_inst(
        .clk(clk),
        .fft_rst_n(rst_n),
        .fft_we(write_enable),
        .fft_addr(addr),
        .fft_data_in(data_in),
        .fft_data_out(data_out)
    );

    fft fft_inst(
        .clk(clk),
        .rst_n(rst_n),
        .addr(addr_fft),
        .write_enable(fft_write_enable),
        .data_in(data_out),
        .data_out_wire(data_out_fft),
        .do_fft(do_fft),
        .fft_done(fft_done)
    );


    // read_mem read_mem_inst(
    //     .clk(clk),
    //     .read_enable(read_enable),
    //     .addr(addr_read),
    //     .data_in(data_out)
    // );

    // always @(*) begin
    //     if(write_enable == 0) begin
    //         addr = addr_read;
    //     end else begin
    //         addr = addr_load;
    //     end
    // end

    always @(*) begin
        if(do_load == 1) begin
            write_enable <= load_mem_write_enable;
            addr <= addr_load;
            data_in <= data_out_load_mem;
        end else if(do_fft == 1) begin
            write_enable <= fft_write_enable;
            addr <= addr_fft;
            data_in <= data_out_fft;
        end else begin
            write_enable <= 0;
            data_in <= 0;
            addr <= 0;
        end
    end

    always @(posedge clk) begin
        if(rst_n == 0) begin
            state <= IDLE;
            do_load <= 0;
            write_enable <= 0;
            read_enable <= 0;
            do_fft <= 0;
        end else begin
            case(state)
                IDLE:
                    begin
                        do_load <= 1;
                        state <= LOAD_SOUND;
                    end
                LOAD_SOUND:
                    begin
                        if(data_loaded == 1) begin
                            do_load <= 0;
                            state <= DO_FFT;
                        end
                    end
                DO_FFT:
                    begin
                        if(fft_done == 0) begin
                            do_fft <= 1;
                        end else begin
                            state <= END;
                        end
                    end
                END:
                    state <= END;
                default:
                    state <= IDLE;
            endcase;
        end
    end


    // always @(posedge clk) begin
    //     if(data_loaded == 0)
    //         read_enable = 0;
    //     else
    //         read_enable = 1;
    // end

    initial begin
        #40
        rst_n = 1;
        
    end

endmodule
