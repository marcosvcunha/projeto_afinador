module get_audio(
    input bit clk,
    input bit rst_n,
    output bit write_enable,
    output reg [10:0] mem_addr,
    output reg [9:0] data_out, // Entra na memoria
    input bit do_get_audio, // O top_module sobe o bit, este modulo começa a captar o áudio, quando terminar, desce o bit
    output bit did_get_audio,
    output bit micLRSel,
    input bit micData
);
    typedef enum {IDLE, START, LOOP1, LOOP2, READ_MIC, STORE_DATA, INCREMENT_INDEX, END} state_type;

    reg [10:0] index;
    wire [9:0] index_inv;
    reg [32:0] count; // Amostra o som a cada 10k ciclos de 1,024 MHz
    reg signed [10:0] micSum;
    bit dataRead;
    
    state_type state;
    
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

    assign micLRSEL = 0;

    always @(posedge clk) begin
        if(rst_n == 0) begin
            count <= 0;
            state <= IDLE;
            dataRead <= 0;
            write_enable <= 0;
            did_get_audio <= 0;
        end else begin
            case(state)
                IDLE:begin
                    did_get_audio <= 0;
                    state <= START;
                end
                START:begin
                    if(do_get_audio == 1)begin
                        state <= LOOP1;
                        micSum <= 0;
                        count <= 0;
                        index <= 0;
                    end else
                        state <= START;
                end
                LOOP1:begin
                    if(count < 973) begin
                        count <= count + 1;
                        micSum <= micSum + micData;
                    end else begin
                        count <= 0;
                        state <= LOOP2;
                    end
                end
                LOOP2: begin
                    if(index < 1024) begin
                        state <= READ_MIC;
                    end else begin
                        state <= END;
                    end
                end
                READ_MIC: begin
                        dataRead <= micData;
                        state <= STORE_DATA;
                    end
                STORE_DATA: begin
                    write_enable <= 1;
                    data_out[9:0] <= micSum[10:1];
                    // if(dataRead == 0) begin
                    //     data_out <= 0;
                    // end else begin
                    //     data_out <= 200;                        
                    // end
                    mem_addr <=  index_inv;
                    state <= INCREMENT_INDEX;
                end
                INCREMENT_INDEX:begin
                    write_enable <= 0;
                    index <= index + 1;
                    state <= LOOP1;
                    micSum <= 0;             
                end
                END:begin
                    did_get_audio <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
