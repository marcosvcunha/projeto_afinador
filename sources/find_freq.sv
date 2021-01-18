module find_freq(
    input bit clk,
    input bit rst_n,
    input bit enable,
    output bit did_find,
    output reg [10:0] mem_addr,
    input reg signed [9:0] data_in,
);
    typedef enum {IDLE, START, SET_ADDR, READ_MEM_R, READ_MEM_I, SUM, IS_GREATER, INCREMENT_INDEX, END} state_type;
    state_type state;

    reg [9:0] index;
    reg signed [9:0] num_r;
    reg signed [9:0] num_i;
    reg [9:0] sum;
    reg [9:0] greater_num;
    reg [9:0] greater_index;

    always @(posedge clk) begin
        if(rst_n == 0) begin
            state <= IDLE;
        end else begin
            case(state)
                IDLE: begin
                    state <= START;
                end
                START: begin
                    index <= 0;
                    num_r <= 0;
                    num_i <= 0;
                    sum <= 0;
                    greater_num <= 0;
                    greater_index <= 0;
                    if(enable == 1) begin
                        state <= SET_ADDR;
                    end else begin
                        state <= START;
                    end
                end
                SET_ADDR: begin
                    if(index < 1024) begin
                        mem_addr <= index;                        
                        state <= READ_MEM_R;
                    end else begin
                        state <= END;
                    end
                end
                READ_MEM_R: begin
                    num_r <= data_in;
                    mem_addr <= index + 1024;
                    state <= READ_MEM_I;
                end
                READ_MEM_I: begin
                    num_i <= data_in;
                    state <= IS_GREATER;
                end
                SUM: begin
                    sum <= num_r[8:0] + num_i[8:0];
                end
                IS_GREATER: begin
                    if(sum > greater_num) begin
                        greater_num <= sum;
                        greater_index <= index;
                    end
                    state <= INCREMENT_INDEX;
                end
                INCREMENT_INDEX: begin
                    index <= index + 1;
                    state <= SET_ADDR;
                end
                END: begin
                    did_find <= 1;
                    state <= END;
                end
            endcase
        end
    end

endmodule