module top_module(
    input clk_100,
    input rst_n,
    output [7:0] an,
    output [7:0] seg 
);
    typedef enum {IDLE, START, STATE1, STATE2, STATE3, STATE4, STATE5, STATE6, END} state_type;
    state_type state;
    
    reg signed [9:0] num_to_display;
    reg [2:0] note;
    
    bit clk = 0;
    reg [7:0] counter = 0;

    // Reduz o clk para aproximadamente 1,024 MHz 
    always @(posedge clk_100) begin
        if(counter < 49) begin
            counter <= counter + 1;
        end else begin
            counter <= 0;
            clk <= ~clk;           
        end
    end

    reg [31:0] aux_counter;
    // Processo que altera a nota e o número
    always @(posedge clk) begin
        if(rst_n == 0 )begin
            num_to_display <= 0;
            note <= 0;
            state <= IDLE;
            aux_counter = 0;
        end else begin
            case(state)
                IDLE: begin
                    state <= START;
                    num_to_display <= 0;
                    note <= 0;
                end
                START: begin
                    state <= STATE1;
                    aux_counter <= 0;
                end
                STATE1: begin
                    if(aux_counter < 2048000) begin
                        aux_counter <= aux_counter + 1;
                        state <= STATE1;
                    end else begin
                        aux_counter <= 0;
                        num_to_display <= -25;
                        note <= 0;
                        state <= STATE2;
                    end
                end
                STATE2: begin
                    if(aux_counter < 2048000) begin
                        aux_counter <= aux_counter + 1;
                        state <= STATE2;
                    end else begin
                        aux_counter <= 0;
                        num_to_display <= 2;
                        note <= 1;
                        state <= STATE3;
                    end
                end
                STATE3: begin
                    if(aux_counter < 2048000) begin
                        aux_counter <= aux_counter + 1;
                        state <= STATE3;
                    end else begin
                        aux_counter <= 0;
                        num_to_display <= -5;
                        note <= 2;
                        state <= STATE4;
                    end
                end
                STATE4: begin
                    if(aux_counter < 2048000) begin
                        aux_counter <= aux_counter + 1;
                        state <= STATE4;
                    end else begin
                        aux_counter <= 0;
                        num_to_display <= 16;
                        note <= 3;
                        state <= STATE5;
                    end
                end
                STATE5: begin
                    if(aux_counter < 2048000) begin
                        aux_counter <= aux_counter + 1;
                        state <= STATE5;
                    end else begin
                        aux_counter <= 0;
                        num_to_display <= -112;
                        note <= 4;
                        state <= STATE6;
                    end
                end
                STATE6: begin
                    if(aux_counter < 2048000) begin
                        aux_counter <= aux_counter + 1;
                        state <= STATE6;
                    end else begin
                        aux_counter <= 0;
                        num_to_display <= 80;
                        note <= 5;
                        state <= END;
                    end
                end
                END:
                    state <= START;
                default:
                    state <= IDLE;
            endcase
        end
    end


    display_result display_result_inst(
        .clk(clk),
        .rst_n(rst_n),
        .an(an),
        .seg(seg),
        .num_to_display(num_to_display),
        .note(note)
    );

endmodule