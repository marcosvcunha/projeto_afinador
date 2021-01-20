module test_mic(
    input clk_100,
    input rst_n,
    output [7:0] an,
    output [7:0] seg,
    output micLRSEL,
    input micData,
    output mic_clk
);

    assign mic_clk = clk;
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

    // Sinais Get Audio
    bit write_enable_get_audio;
    reg [10:0] addr_get_audio;
    reg signed [9:0] data_out_get_audio;
    bit do_get_audio = 1;
    bit did_get_audio;

    reg [2:0] note = 4;

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

    display_result display_result_inst(
        .clk(clk),
        .rst_n(rst_n),
        .an(an),
        .seg(seg),
        .num_to_display(data_out_get_audio),
        .note(note)
        // .current_state(current_state)
    );
 endmodule