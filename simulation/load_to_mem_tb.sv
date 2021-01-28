`timescale 1ns / 1ps

module load_to_mem_tb(

);

    typedef enum {IDLE, START, LOAD_MEM, END} state_type;
    state_type state;
    

    bit clk = 0;
    bit rst_n = 0;
    bit write_enable;
    reg [10:0] addr;
    reg [9:0] data_in;
    reg [9:0] data_out;

    bit do_load = 0;
    bit did_load;

    always #5 clk = ~clk;

    always @(posedge clk) begin
        if(rst_n == 0) begin
            state <= IDLE;
        end else begin
            case(state)
                IDLE: begin
                   state <= START; 
                end
                START: begin
                    state <= LOAD_MEM;
                end
                LOAD_MEM: begin
                    if(did_load == 0) begin
                        do_load <= 1;
                        state <= LOAD_MEM;
                    end else begin
                        do_load <= 0;
                        state <= END;
                    end
                end
                END: begin
                    state <= END;
                end
            endcase
        end
    end

    load_to_mem load_to_mem_inst(
        .clk(clk),
        .rst_n(rst_n),
        .addr(addr),
        .data_out(data_out),
        .write_enable(write_enable),
        .do_load(do_load),
        .did_load(did_load)
    );

    mem mem_inst(
        .clk(clk),
        .rst_n(rst_n),
        .write_enable(write_enable),
        .addr(addr),
        .data_in(data_out),
        .data_out(data_in)
    );
    initial begin
        #20
        rst_n <= 1;
    end
endmodule