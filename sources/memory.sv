
module mem
#(
    parameter NUM_BITS = 10,
    parameter FFT_MEM_SIZE = 2048,
    parameter SOUND_MEM_SIZE = 1024
)(
    input bit clk,

    input bit fft_rst_n,
    input bit fft_we,
    input wire [10:0] fft_addr,
    input reg [9:0] fft_data_in,
    output wire [9:0] fft_data_out

    // input bit sound_rst_n;
    // input bit sound_we;
    // input wire [10:0] sound_addr;
    // input reg [9:0] sound_data_in;
    // output wire [9:0] sound_data_out;
);

    xpm_memory_spram #(
        // Common module parameters
        .MEMORY_SIZE (FFT_MEM_SIZE*NUM_BITS), //positive integer
        .MEMORY_PRIMITIVE ("auto"), //string; "auto", "distributed", "block" or "ultra";
        .MEMORY_INIT_FILE ("none"), //string; "none" or "<filename>.mem"
        .MEMORY_INIT_PARAM ("" ), //string;
        .USE_MEM_INIT (1), //integer; 0,1
        .WAKEUP_TIME ("disable_sleep"),//string; "disable_sleep" or "use_sleep_pin"
        .MESSAGE_CONTROL (0), //integer; 0,1
        // Port A module parameters
        .WRITE_DATA_WIDTH_A (NUM_BITS), //positive integer
        .READ_DATA_WIDTH_A (NUM_BITS), //positive integer
        .BYTE_WRITE_WIDTH_A (NUM_BITS), //integer; 8, 9, or WRITE_DATA_WIDTH_A value
        .ADDR_WIDTH_A (NUM_BITS + 1), //positive integer
        .READ_RESET_VALUE_A ("0"), //string
        .READ_LATENCY_A (1), //non-negative integer
        .WRITE_MODE_A ("read_first") //string; "write_first", "read_first", "no_change"
        ) fft_mem_inst (
        // Common module ports
        .sleep (1'b0),
        // Port A module ports
        .clka (clk),
        .rsta (~fft_rst_n),
        .ena (1'b1),
        .regcea (1'b1),
        .wea (fft_we),
        .addra (fft_addr),
        .dina (fft_data_in),
        .injectsbiterra (1'b0), //do not change
        .injectdbiterra (1'b0), //do not change
        .douta (fft_data_out),
        .sbiterra (), //do not change
        .dbiterra () //do not change
    );


endmodule