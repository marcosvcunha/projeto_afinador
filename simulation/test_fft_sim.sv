`timescale 1ns / 1ps


module test_fft_sim(
    // input clk_100,
    output [7:0] an,
    output [7:0] seg
);
    typedef enum {IDLE, START, LOAD_TO_MEM, DO_FFT, FIND_FREQ, END} state_type;
    state_type state;
    
    bit rst_n = 0;
    // Estado
    reg [2:0] current_state = 0;

    // Sinais load_to_mem
    reg [10:0] addr_load_to_mem;
    reg [9:0] data_out_load_to_mem;
    bit write_enable_load_to_mem;
    bit do_load = 0;
    bit did_load;

    // Sinais memória
    bit write_enable = 0;
    bit mem_rst_n = 0;
    reg [10:0] addr;
    reg [9:0] data_out; // Dado que vai para memória
    reg [9:0] data_in; // Dado que sai da memoria

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
    reg signed [9:0] difference_to_note;
    reg [2:0] note;

    // Sinais display_result
    // an
    // seg

    bit clk_100 = 0;

    always #5 clk_100 = ~clk_100;

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
            LOAD_TO_MEM: begin
                addr <= addr_load_to_mem;
                write_enable <= write_enable_load_to_mem;
                data_out <= data_out_load_to_mem;
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
                    mem_rst_n <= 1;
                    // state_to_display <= 0;
                    state <= LOAD_TO_MEM;
                end
                LOAD_TO_MEM: begin
                    current_state <= 1;
                    if(did_load == 0) begin
                        do_load <= 1;
                        state <= LOAD_TO_MEM;
                    end else begin
                        do_load <= 0;
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
                    mem_rst_n <= 0;
                    state <= END;
                end
            endcase
        end
    end

    load_to_mem load_to_mem_inst(
        .clk(clk),
        .rst_n(rst_n),
        .addr(addr_load_to_mem),
        .data_out(data_out_load_to_mem),
        .write_enable(write_enable_load_to_mem),
        .do_load(do_load),
        .did_load(did_load)
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

    initial begin
        #20
        rst_n <= 1;
    end
endmodule