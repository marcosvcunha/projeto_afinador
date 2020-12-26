`timescale 1ns / 1ps

module mem_test 
#(
    parameter NUM_BITS = 8,
    parameter MEM_SIZE = 128
)(

);

    reg [3:0] a = 10;
    reg [3:0] b = 2;
    reg [7:0] tempC;
    wire [3:0] c;
    
    assign c = tempC[7:4];
    
    
    
    
    //teste_inv[8] = teste[0];
 
    
    

    bit clk = 0;
    bit rst_n = 1;
    bit we = 0;
    reg [(NUM_BITS-1):0] data_in;
    wire [(NUM_BITS-1):0] data_out;
    reg [6:0] addr;
    // reg signed [10:0] a;
    // reg signed [10:0] b;
    // reg signed [10:0] result;

    xpm_memory_spram #(
        // Common module parameters
        .MEMORY_SIZE (MEM_SIZE*NUM_BITS), //positive integer
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
        .ADDR_WIDTH_A (7), //positive integer
        .READ_RESET_VALUE_A ("0"), //string
        .READ_LATENCY_A (1), //non-negative integer
        .WRITE_MODE_A ("read_first") //string; "write_first", "read_first", "no_change"
        ) xpm_memory_spram_inst (
        // Common module ports
        .sleep (1'b0),
        // Port A module ports
        .clka (clk),
        .rsta (~rst_n),
        .ena (1'b1),
        .regcea (1'b1),
        .wea (we),
        .addra (addr),
        .dina (data_in),
        .injectsbiterra (1'b0), //do not change
        .injectdbiterra (1'b0), //do not change
        .douta (data_out),
        .sbiterra (), //do not change
        .dbiterra () //do not change
    );

    always #5 clk = ~clk;

    task store();
        int i;

        #10
        for(i = 0; i < 10; i++) begin
            addr = i;
            data_in = i;
            we = 1'b1;
            #10
            we = 1'b0;
        end
    endtask

    task read();
        int i; 
        #10

        for (i = 0; i< 10; i++) begin
            addr = i;
            #10
            $display(data_out);
        end
    endtask

    initial begin
        tempC = a*b;
        rst_n = 0;
        #10
        rst_n = 1;
        store();
        #10
        read();
    end

endmodule