module find_freq(
    input bit clk,
    input bit rst_n,
    input bit enable,
    output bit did_find,
    output reg [10:0] mem_addr,
    input reg signed [9:0] data_in,
    output reg signed [9:0] difference,
    output  reg [2:0] note
);
    typedef enum {IDLE, START, SET_ADDR, WAIT_DATA1, READ_MEM_R, WAIT_DATA2, READ_MEM_I, SUM, IS_GREATER, INCREMENT_INDEX, 
        FIND_NOTE, END} state_type;
    state_type state;

    const bit signed [9:0] freqs[0:5] = {165, 110, 147, 196, 247, 330};
    reg [2:0] idx_note;
    reg signed [9:0] difference_aux;

    reg [10:0] index;
    reg signed [9:0] num_r;
    reg signed [9:0] num_i;
    reg signed [10:0] sum;
    reg [10:0] greater_num;
    reg [9:0] greater_index;

    function reg[9:0] abs(reg[9:0] num);
        if(num[9] == 1) begin
            abs = -num;
        end else begin
            abs = num;
        end
    endfunction

    always @(posedge clk) begin
        if(rst_n == 0) begin
            state <= IDLE;
            did_find <= 0;
            difference <= 511;
        end else begin
            case(state)
                IDLE: begin
                    state <= START;
                    did_find <= 0;
                    state <= START;
                end
                START: begin
                    if(enable == 1) begin
                        did_find <= 0;
                        index <= 20; // Começa em 1 mesmo por que o 0 sempre tem o maior valor (na versão binaria)
                        num_r <= 0;
                        num_i <= 0;
                        sum <= 0;
                        greater_num <= 0;
                        greater_index <= 20;
                        state <= SET_ADDR;
                    end else begin
                        state <= START;
                    end
                end
                SET_ADDR: begin
                    if(index < 350) begin
                        mem_addr <= index;                        
                        state <= WAIT_DATA1;
                    end else begin
                        difference <= 511;
                        note <= 0;
                        idx_note <= 0;
                        state <= FIND_NOTE;
                    end
                end
                WAIT_DATA1:
                    state <= READ_MEM_R;
                READ_MEM_R: begin
                    num_r <= data_in;
                    mem_addr <= index + 1024;
                    state <= WAIT_DATA2;
                end
                WAIT_DATA2:
                    state <= READ_MEM_I;
                READ_MEM_I: begin
                    num_i <= data_in;
                    state <= SUM;
                end
                SUM: begin
                    sum <= abs(num_r) + abs(num_i);
                    state <= IS_GREATER;
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
                FIND_NOTE: begin
                    // difference <= greater_index;
                    if(idx_note < 6) begin
                        if(abs(difference) > abs(greater_index - freqs[idx_note])) begin
                            difference <= freqs[idx_note] - greater_index;
                            note <= idx_note;
                        end
                        idx_note = idx_note + 1;
                    end else
                        state <= END;
                end
                END: begin
                    did_find <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule