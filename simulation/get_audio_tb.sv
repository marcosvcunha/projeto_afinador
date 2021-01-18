`timescale 1ns / 1ps

module get_audio_tb();
    bit clk = 0;
    bit rst_n = 0;
    bit write_enable;
    reg [10:0] mem_addr;
    reg [9:0] data_out;
    bit do_get_audio = 0;
    bit did_get_audio;
    bit micLRSel;
    bit micData = 0;

    typedef enum {IDLE, START, CAPTURING_AUDIO, END} state_type;
    
    state_type state;
    
    always #5 clk = ~clk;

    get_audio get_audio_inst(
        .clk(clk),
        .rst_n(rst_n),
        .write_enable(write_enable),
        .mem_addr(mem_addr),
        .data_out(data_out),
        .do_get_audio(do_get_audio),
        .did_get_audio(did_get_audio),
        .micLRSel(micLRSel),
        .micData(micData)
    );


    always @(posedge clk) begin
        if(rst_n == 0) begin
            do_get_audio <= 0;
        end else begin
            case(state)
                IDLE:
                    state <= START;
                START: begin
                    do_get_audio <= 1;
                    state <= CAPTURING_AUDIO;
                end
                CAPTURING_AUDIO:begin
                    do_get_audio <= 0;
                    if(did_get_audio == 1)
                        state <= END;
                    else
                        state <= CAPTURING_AUDIO;
                end
            endcase
        end
    end


    


endmodule