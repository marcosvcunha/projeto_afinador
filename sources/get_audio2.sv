module get_audio2(
    input bit clk_100,
    // input bit clk,
    input bit rst_n,
    output bit write_enable,
    output reg [10:0] addr,
    output reg [9:0] data_out,
    input bit req,
    output bit did_get,
    output bit micClk,
    input bit micData,
    output bit micLRSel
);
    typedef enum {IDLE, START, GET_DATA, INCREMENT_INDEX, END} state_type;
    state_type state;

    reg [10:0] index;
    reg [10:0] index_inv;
    reg [16:0] counter;

    bit data_mic_valid;
    reg [15:0] data_mic;
    reg [15:0] last_data;
    bit pdm_data_o;
    bit pdm_en_o;


    assign index_inv[0] = index[9];
    assign index_inv[1] = index[8];
    assign index_inv[2] = index[7];
    assign index_inv[3] = index[6];
    assign index_inv[4] = index[5];
    assign index_inv[5] = index[4];
    assign index_inv[6] = index[3];
    assign index_inv[7] = index[2];
    assign index_inv[8] = index[1];
    assign index_inv[9] = index[0];
    assign index_inv[10] = 0;


    always @(posedge clk_100) begin
        if(data_mic_valid) begin
            last_data <= data_mic;
        end
    end
    
    always @(posedge clk_100) begin
        if(rst_n == 0) begin
            state <= IDLE;
            write_enable <= 0;
            index <= 0;
            counter <= 0;
            did_get <= 0;
        end else begin
            case(state)
                START: begin
                    if(req) begin
                        state <= GET_DATA;
                    end
                end
                GET_DATA: begin
                    if(counter < 97656) begin
                        counter <= counter + 1;
                    end else begin
                        data_out[9:0] <= last_data[10:3];
                        write_enable <= 1;
                        addr <= index_inv;
                        state <= INCREMENT_INDEX;
                    end
                end
                INCREMENT_INDEX: begin
                    write_enable <= 0;
                    if(index < 1023) begin
                        index <= index + 1;
                        state <= GET_DATA;
                        counter <= 0;
                    end else begin
                        state <= END;
                    end
                end
                END: begin
                    did_get <= 1;
                    state <= IDLE;
                end
                default: begin
                    write_enable <= 0;
                    index <= 0;
                    counter <= 0;
                    state <= START;
                    did_get <= 0;
                end
            endcase
        end
    end

    audio_demo audio_demo_inst(
        .clk_i(clk_100),
        .rst_i(0),
        .pdm_clk_o(micClk),
        .pdm_data_i(micData),
        .pdm_lrsel_o(micLRSel),
        .data_mic_valid(data_mic_valid),
        .data_mic(data_mic),
        .pdm_data_o(pdm_data_o),
        .pdm_en_o(pdm_en_o)
    );
endmodule