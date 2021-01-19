module top_module(
    input clk_100,
    input rst_n,
    output [7:0] an,
    output [7:0] seg,
    output micLRSEL,
    input micData,
    output mic_clk
);
    typedef enum {IDLE, START, GET_AUDIO, DO_FFT, FIND_FREQ, END} state_type;
    state_type state;
    

    // Estado
    reg [2:0] current_state = 0;

    // Sinais memória
    bit write_enable = 0;
    bit mem_rst_n = 0;
    reg [10:0] addr;
    reg [9:0] data_out; // Dado que vai para memória
    reg [9:0] data_in; // Dado que sai da memoria

    // Sinais Get Audio
    bit write_enable_get_audio;
    reg [10:0] addr_get_audio;
    reg [9:0] data_out_get_audio;
    bit do_get_audio = 0;
    bit did_get_audio;
    // micLRSEL
    // micData

    // Sinais fft
    reg [10:0] addr_fft;
    bit write_enable_fft;
    reg [9:0] data_out_fft;
    bit do_fft = 0;
    bit fft_done;

    // Sinais find_freq
    bit find_freq_enable = 0;
    bit did_find_freq;
    reg [10:0] addr_find_freq;
    reg [9:0] difference_to_note;
    reg [2:0] note;

    // Sinais display_result
    // an
    // seg

    // CLK de aproximadamente 1,024 MHz
    bit clk = 0;
    reg [7:0] counter = 0;
    assign mic_clk = clk;

    always @(posedge clk_100) begin
        if(counter < 49) begin
            counter <= counter + 1;
        end else begin
            counter <= 0;
            clk <= ~clk;           
        end
    end
    

    // Seleção de Sinais de Memoria

    always @(*) begin
        case(state)
            GET_AUDIO: begin
                addr <= addr_get_audio;
                write_enable <= write_enable_get_audio;
                data_out <= data_out_get_audio;
            end
            DO_FFT: begin
                addr <= addr_fft;
                write_enable <= write_enable_fft;
                data_out <= data_out_fft;
            end
            FIND_FREQ: begin
                addr <= addr_find_freq;
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

    // Maquina de Estados

    always @(posedge clk) begin
        if(rst_n == 0) begin
            state <= IDLE;
            // state_to_display <= 0;
        end else begin
            case(state)
                IDLE: begin
                    mem_rst_n <= 0;
                    state <= START;
                    // state_to_display <= 0; 
                end
                START: begin
                    current_state <= 0;
                    mem_rst_n <= 0;
                    // state_to_display <= 0;
                    state <= GET_AUDIO;
                end
                GET_AUDIO: begin
                    current_state <= 1;
                    if(did_get_audio == 0) begin
                        do_get_audio <= 1;
                        state <= GET_AUDIO;
                    end else begin
                        do_get_audio <= 0;
                        state <= DO_FFT;
                    end
                end
                DO_FFT: begin
                    current_state <= 2;
                    if(fft_done == 0) begin
                        do_fft <= 1;
                        state <= DO_FFT;
                    end else begin
                        do_fft <= 0;
                        state <= FIND_FREQ;
                    end
                end
                FIND_FREQ: begin
                    current_state <= 3;
                    if(did_find_freq == 0) begin
                        find_freq_enable <= 1;
                        state <= FIND_FREQ;
                    end else begin
                        find_freq_enable <= 0;
                        state <= END;
                    end
                end
                END: begin
                    state <= START;
                end
            endcase
        end
    end


    get_audio get_audio_inst(
        .clk(clk),
        .rst_n(rst_n),
        .write_enable(write_enable_get_audio),
        .mem_addr(addr_get_audio),
        .data_out(data_out_get_audio),
        .do_get_audio(do_get_audio),
        .did_get_audio(did_get_audio),
        .micLRSel(micLRSel),
        .micData(micData)
    );

    mem memory_inst(
        .clk(clk),
        .rst_n(mem_rst_n),
        .write_enable(write_enable),
        .addr(addr),
        .data_in(data_out),
        .data_out(data_in)
    );

    find_freq find_freq_inst(
        .clk(clk),
        .rst_n(rst_n),
        .enable(find_freq_enable),
        .did_find(did_find_freq),
        .mem_addr(addr_find_freq),
        .data_in(data_in),
        .difference(difference_to_note),
        .note(note)
    );

    fft fft_inst(
        .clk(clk),
        .rst_n(rst_n),
        .addr(addr_fft),
        .write_enable(write_enable_fft),
        .data_in(data_in),
        .data_out_wire(data_out_fft),
        .do_fft(do_fft),
        .fft_done(fft_done)
    );

    display_result display_result_inst(
        .clk(clk),
        .rst_n(rst_n),
        .an(an),
        .seg(seg),
        .num_to_display(difference_to_note),
        .note(note),
        .current_state(current_state)
    );

endmodule