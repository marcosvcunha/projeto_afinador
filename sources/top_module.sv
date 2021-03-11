module top_module(
    input clk_100,
    input rst_n,
    output [7:0] an,
    output [7:0] seg,
    output micLRSel,
    input micData,
    output mic_clk,
    output tx // Para Serial Transmitter
);
    typedef enum {IDLE, START, GET_AUDIO, DO_FFT, FIND_FREQ, END} state_type;
    state_type state;
    typedef enum {IDLE, START, GET_AUDIO, TRANSFER_DATA, END} get_audio_state_type;
    get_audio_state_type get_audio_state;
    typedef enum {IDLE, START, DO_FFT, FIND_FREQ, END} fft_state_type;
    fft_state_type fft_state;

    // Estado
    reg [2:0] current_state = 0;

    // Sinais memória FFT
    bit fft_write_enable = 0;
    bit fft_mem_rst_n = 0;
    reg [10:0] fft_addr;
    reg [9:0] fft_data_out; // Dado que vai para memória
    reg [9:0] fft_data_in; // Dado que sai da memoria

    // Sinais memória GET_AUDIO
    bit ga_write_enable = 0;
    bit ga_mem_rst_n = 0;
    reg [10:0] ga_addr;
    reg [9:0] ga_data_out; // Dado que vai para memória
    reg [9:0] ga_data_in; // Dado que sai da memoria
    

    // Sinais Get Audio
    bit write_enable_get_audio;
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

    reg [10:0] ga_addr_get_audio;
    bit ga_write_enable_get_audio;
    reg [9:0] ga_data_out_get_audio;

    // Sinais find_freq
    bit find_freq_enable = 0;
    bit did_find_freq;
    reg [10:0] addr_find_freq;
    reg signed [9:0] difference_to_note;
    reg [2:0] note;

    // Sinais TransferData
    reg [10:0] fft_addr_transfer_data;
    bit fft_write_enable_transfer_data;
    reg [9:0] fft_data_out_transfer_data;

    reg [10:0] ga_addr_transfer_data;
    bit ga_write_enable_transfer_data;
    reg [9:0] ga_data_out_transfer_data;


    //// Sinais de controle
    bit start_fft = 0;
    bit doing_fft = 0;
    bit start_get_audio = 0;

    // Sinais display_result
    // an
    // seg

    // // Sinais Serial Transmitter
    // reg [10:0] mem_index;
    // reg [7:0] tx_data;
    // bit tx_req = 0;
    // bit tx_ack;

    // CLK de aproximadamente 1,024 MHz
    // bit sclk = 0;
    bit clk = 0;
    reg [7:0] counter = 0;
    // assign mic_clk = clk;

    always @(posedge clk_100) begin
        if(counter < 51) begin
            counter <= counter + 1;
        end else begin
            counter <= 0;
            clk <= ~clk;           
        end
    end
    
    // BUFG clk_buffer(
    //     .I(sclk),
    //     .O(clk)
    // );

    // Seleção de Sinais de Memoria

    always @(*) begin
        if(doing_fft) begin
            case(fft_state)
            DO_FFT: begin
                fft_addr <= addr_fft;
                fft_write_enable <= write_enable_fft;
                fft_data_out <= data_out_fft;
            end
            FIND_FREQ: begin
                fft_addr <= addr_find_freq;
                fft_write_enable <= 0;
                fft_data_out <= 0;
            end
            default: begin
                fft_addr <= 0;
                fft_write_enable <= 0;
                fft_data_out <= 0;
            end
        endcase
        end else begin
            if(get_audio_state == TRANSFER_DATA) begin
                fft_addr <= fft_addr_transfer_data;
                fft_write_enable <= fft_write_enable_transfer_data;
                fft_data_out <= fft_data_out_transfer_data;

                ga_addr <= ga_addr_transfer_data;
                ga_write_enable <= ga_write_enable_transfer_data;
                ga_data_out <= ga_data_out_transfer_data;
            end else begin
                fft_addr <= 0;
                fft_write_enable <= 0;
                fft_data_out <= 0;

                ga_addr <= ga_addr_get_audio;
                ga_write_enable <= ga_write_enable_get_audio;
                ga_data_out <= ga_data_out_get_audio;
            end
        end
    end

    // Maquina de Estados

    always @(posedge clk_100) begin
        if(rst_n == 0) begin
            state <= IDLE;
        end else begin
            case(state)
                IDLE: begin
                    state <= START;
                end
                START: begin
                    current_state <= 0;
                    start_get_audio <= 1;
                    state <= START;
                end
                END: begin
                    state <= START;
                end
            endcase
        end
    end

    // GET_AUDIO Estados

    always @(posedge clk) begin
        if(rst_n == 0) begin
            get_audio_state <= IDLE;        
            start_fft <= 0;
            ga_mem_rst_n <= 0;
        end else begin
            case(get_audio_state)
                IDLE: begin
                    ga_mem_rst_n <= 1;
                end
                START: begin
                    start_fft <= 0;
                    if(start_get_audio) begin
                        get_audio_state <= GET_AUDIO;
                    end else begin
                        get_audio_state <= START;
                    end
                end
                GET_AUDIO: begin
                    if(~did_get_audio) begin
                        do_get_audio <= 1;
                        get_audio_state <= GET_AUDIO;
                    end else begin
                        do_get_audio <= 0;
                        get_audio_state <= TRANSFER_DATA;
                    end
                end
                TRANSFER_DATA: begin
                    if(doing_fft) begin
                        get_audio_state <= TRANSFER_DATA;
                    end else begin
                        // TODO: Habilitar para começar a transferir os dados
                    end
                end
                END: begin
                    start_fft <= 1;
                    get_audio_state <= IDLE;
                end
                default:
                    get_audio_state <= IDLE;
            endcase

        end
    end

    // FFT Estados

    always @(posedge clk) begin
        if(rst_n == 0) begin
            fft_state <= IDLE;            
            doing_fft <= 0;
            fft_mem_rst_n <= 0;
        end else begin
            case(fft_audio_state)
                IDLE: begin
                    doing_fft <= 0;
                    fft_mem_rst_n <= 1;         
                end
                START: begin
                    if(start_fft) begin
                        fft_audio_state <= DO_FFT;
                        doing_fft <= 1;
                    end else begin
                        fft_audio_state <= START;
                    end
                end
                DO_FFT: begin
                    if(fft_done == 0) begin
                        do_fft <= 1;
                        fft_audio_state <= DO_FFT;
                    end else begin
                        do_fft <= 0;
                        fft_audio_state <= FIND_FREQ;
                    end
                end
                FIND_FREQ: begin
                    if(did_find_freq == 0) begin
                        find_freq_enable <= 1;
                        fft_audio_state <= FIND_FREQ;
                    end else begin
                        find_freq_enable <= 0;
                        fft_audio_state <= END;
                        fft_mem_rst_n <= 0;
                    end
                end
                END: begin
                    doing_fft <= 0;
                    fft_audio_state <= IDLE;          
                end
                default:
                    get_audio_state <= IDLE;
                    doing_fft <= 0;                    
            endcase

        end
    end

    // serial_transmitter #(
    //     .CLK_FREQ(1_000_000)
    // )serial_transmitter_inst(
    //     .clk(clk_100),
    //     .rst_n(rst_n),
    //     .tx(tx),
    //     .req(tx_req),
    //     .data(tx_data),
    //     .ack(tx_ack)
    // );

    get_audio2 get_audio2_inst(
        .clk_100(clk_100),
        .rst_n(rst_n),
        .write_enable(ga_write_enable_get_audio),
        .addr(ga_addr_get_audio),
        .data_out(ga_data_out_get_audio),
        .req(do_get_audio),
        .did_get(did_get_audio),
        .micClk(mic_clk),
        .micData(micData),
        .micLRSel(micLRSel)
    );


    mem fft_mem_inst(
        .clk(clk_100),
        .rst_n(fft_mem_rst_n),
        .write_enable(fft_write_enable),
        .addr(fft_addr),
        .data_in(fft_data_out),
        .data_out(fft_data_in)
    );

    mem ga_mem_inst(
        .clk(clk_100),
        .rst_n(ga_mem_rst_n),
        .write_enable(ga_write_enable),
        .addr(ga_addr),
        .data_in(ga_data_out),
        .data_out(ga_data_in)
    );

    find_freq find_freq_inst(
        .clk(clk_100),
        .rst_n(rst_n),
        .enable(find_freq_enable),
        .did_find(did_find_freq),
        .mem_addr(addr_find_freq),
        .data_in(fft_data_in),
        .difference(difference_to_note),
        .note(note)
    );

    fft fft_inst(
        .clk(clk_100),
        .rst_n(rst_n),
        .addr(addr_fft),
        .write_enable(write_enable_fft),
        .data_in(fft_data_in),
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