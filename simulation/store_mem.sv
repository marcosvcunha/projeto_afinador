module store_mem(
    input bit clk,
    output reg [10:0] addr,
    input reg signed [9:0] data_in,
    input bit do_store,
    output bit mem_stored
);
    typedef enum {IDLE, SET_ADDR, READ_MEM, END} state_type;
    
    state_type state;

    int i = 0;
    // Pega o conteudo da memória e descarrega em um arquivo de texto.
    always @(posedge clk) begin
        if(do_store == 1) begin
            case(state)
                IDLE:
                    begin
                        state <= SET_ADDR;
                    end
                SET_ADDR:
                    begin
                        if(i < 2048) begin
                            addr <= i;
                            state <= READ_MEM;
                        end else begin
                            state <= END;
                        end
                    end
                READ_MEM:
                    begin
                        $display(data_in);
                        i = i + 1;
                        state <= SET_ADDR;
                    end
                END:
                    begin
                        state <= END;
                        mem_stored <= 1;
                    end
                    
            endcase
        end else begin
            state <= IDLE;
            mem_stored <= 0;
        end
    end        

endmodule