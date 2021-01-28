module get_audio2_test (
    input clk_100,
    input rst_n,
    output [7:0] an,
    output [7:0] seg,
    output micLRSel,
    input micData,
    output mic_clk,
    output tx // Para Serial Transmitter
);
    typedef enum {IDLE, START, GET_AUDIO, READ_MEM, WAIT_MEM, SEND_REQ, WAIT_AKC_1, WAIT_AKC_0, END} state_type;
    state_type state;

    reg [2:0] current_state;

    // Sinais memoria
    bit write_enable = 0;
    bit mem_rst_n = 0;
    reg [10:0] addr;
    reg [9:0] data_out;
    reg [9:0] data_in;

    // Sinais Serial Transmitter
    reg [10:0] mem_index;
    reg [7:0] tx_data;
    bit tx_req = 0;
    bit tx_ack;

    // Sinais Get Audio
    bit write_enable_get_audio;
    reg [10:0] addr_get_audio;
    reg [9:0] data_out_get_audio;
    bit req_get_audio = 0;
    bit ack_get_audio;

    // // Clock de 1 MHz
    bit clk_1 = 0;
    reg [7:0] clock_counter = 0;
    always @(posedge clk_100) begin
        if(clock_counter < 51) begin
            clock_counter <= clock_counter + 1;
        end else begin
            clock_counter <= 0;
            clk_1 <= ~clk_1;
        end
    end



    always @(*) begin
        case(state)
            GET_AUDIO: begin
                addr <= addr_get_audio;
                write_enable <= write_enable_get_audio;
                data_out <= data_out_get_audio;
            end
            READ_MEM: begin
                addr <= mem_index;
                write_enable <= 0;
                data_out <= 0;
            end
            WAIT_MEM: begin
                addr <= mem_index;
                write_enable <= 0;
                data_out <= 0;
            end
            SEND_REQ: begin
                addr <= mem_index;
                write_enable <= 0;
                data_out <= 0;
            end
            default: begin
                addr <= 0;
                write_enable <= 0;
                data_out <= 0;
            end
        endcase
    end

    always @(posedge clk_100) begin
        if(rst_n == 0)begin
            mem_rst_n <= 0;
            state <= IDLE;
            tx_req <= 0;
            req_get_audio <= 0;
            current_state <= 0;
        end else begin
            case(state)
                START: begin
                    mem_rst_n <= 1;
                    current_state <= 1;
                    state <= GET_AUDIO;
                end
                GET_AUDIO: begin
                    current_state <= 2;
                    if(~ack_get_audio) begin
                        req_get_audio <= 1;
                        state <= GET_AUDIO;
                    end else begin
                        req_get_audio <= 0;
                        state <= READ_MEM;
                    end
                end
                READ_MEM: begin
                    current_state <= 3;
                    if(mem_index < 1024) begin
                        state <= WAIT_MEM;
                    end else begin
                        state <= END;
                    end
                end
                WAIT_MEM: begin
                    state <= SEND_REQ;
                end
                SEND_REQ: begin
                    current_state <= 4;
                    tx_data[7:0] <= data_in[9:2];
                    tx_req <= 1;
                    state <= WAIT_AKC_1;
                end
                WAIT_AKC_1: begin
                    current_state <= 5;
                    if(tx_ack) begin
                        state <= WAIT_AKC_0;
                        tx_req <= 0;
                    end
                end
                WAIT_AKC_0: begin
                    current_state <= 6;
                    if(~tx_ack) begin
                        state <= READ_MEM;
                        mem_index <= mem_index + 1;
                    end
                end
                END: begin
                    state <= IDLE;
                end
                default: begin
                    mem_rst_n <= 0;
                    current_state <= 0;
                    tx_req <= 0;
                    req_get_audio <= 0;
                    state <= START;
                    mem_index <= 0;
                end
            endcase
        end
    end


    get_audio2 get_audio2_inst(
        .clk_100(clk_100),
        .rst_n(rst_n),
        .write_enable(write_enable_get_audio),
        .addr(addr_get_audio),
        .data_out(data_out_get_audio),
        .req(req_get_audio),
        .did_get(ack_get_audio),
        .micClk(mic_clk),
        .micData(micData),
        .micLRSel(micLRSel)
    );

    serial_transmitter #(
        .CLK_FREQ(100_000_000)
    )serial_transmitter_inst(
        .clk(clk_100),
        .rst_n(rst_n),
        .tx(tx),
        .req(tx_req),
        .data(tx_data),
        .ack(tx_ack)
    );

    mem memory_inst(
        .clk(clk_100),
        .rst_n(mem_rst_n),
        .write_enable(write_enable),
        .addr(addr),
        .data_in(data_out),
        .data_out(data_in)
    );

    display_result display_result_inst(
        .clk(clk_1),
        .rst_n(rst_n),
        .an(an),
        .seg(seg),
        .num_to_display(299),
        .note(3),
        .current_state(current_state)
    );

endmodule