module display_result(
    input clk, // 1.024 MHz esperados
    input rst_n,
    output [7:0] an,
    output [7:0] seg,
    input reg signed [9:0] num_to_display,
    input reg [2:0] note
    // input reg [2:0] current_state // DEBUG
    );

    typedef enum {DIGIT1, DIGIT2, DIGIT3, DIGIT4, DIGIT5, DIGIT6, DIGIT7, DIGIT8} digit_control_type;
    typedef enum {IDLE, START, SIGN, CENTENA, AUX1, DEZENA, AUX2, UNIDADE, END} state_type;

    state_type state;

    digit_control_type digit_control = DIGIT1;

    reg [7:0] seg1 = 8'b00000001;
    reg [7:0] seg2 = 8'b00000001;
    reg [7:0] seg3 = 8'b00000001;
    reg [7:0] seg4 = 8'b00000001;
    reg [7:0] seg5 = 8'b00000001;
    reg [7:0] seg6 = 8'b00000001;
    reg [7:0] seg7 = 8'b00000001;
    reg [7:0] seg8 = 8'b00000001;

    reg [7:0] an_reg;
    reg [7:0] seg_reg;

    assign an = an_reg;
    assign seg = seg_reg;

    reg signed [9:0] num_to_display_aux;
    reg[9:0] div;

    reg[15:0] counter = 0; // Usado para obter a taxa de atualização correta do display


    always @(posedge clk) begin
        if(rst_n == 0) begin
            state <= IDLE;
            seg1 <= 8'b00000001;
            seg2 <= 8'b00000001;
            seg3 <= 8'b00000001;
            seg4 <= 8'b00000001;
            seg5 <= 8'b00000001;
            seg6 <= 8'b00000001;
            seg7 <= 8'b00000001;
            seg8 <= 8'b00000001;
            div <= 0;
        end else begin
            case(state)
                IDLE:
                    state <= START;
                START: begin
                    state <= SIGN;
                    num_to_display_aux <= num_to_display;
                    display_note(note);
                    // seg5 <= to_seven_seg(current_state); // DEBUG
                end
                SIGN: begin
                    state <= CENTENA;
                    if(num_to_display_aux < 0) begin
                        num_to_display_aux <= - num_to_display_aux;
                        seg1 <= 8'b11111101;                    
                    end else begin
                        seg1 <= 8'b11111111;
                    end
                end
                CENTENA: begin
                    div <= num_to_display_aux / 100;
                    state <= AUX1;
                end
                AUX1: begin
                    seg2 <= to_seven_seg(div);
                    num_to_display_aux <= num_to_display_aux - div * 100;
                    state <= DEZENA; 
                end
                DEZENA: begin
                    div <= num_to_display_aux / 10;
                    state <= AUX2;
                end
                AUX2: begin
                    seg3 <= to_seven_seg(div);
                    num_to_display_aux <= num_to_display_aux - div * 10;
                    state <= UNIDADE;
                end
                UNIDADE: begin
                    seg4 <= to_seven_seg(num_to_display_aux);
                    state <= END;
                end
                END:
                    state <= START;

            endcase
        end
    end

    function display_note(reg [2:0] this_note);
        case(this_note)
            3'h0: // MI
            begin
                // seg5 <= 8'b11111111;
                seg6 <= 8'b11111111;
                seg7 <= 8'b11111111;
                seg8 <= 8'b01100001; // Letra E
            end
            3'h1: // L�?
            begin
                // seg5 <= 8'b11111111;
                seg6 <= 8'b11111111;
                seg7 <= 8'b11111111;
                seg8 <= 8'b00010001; // Letra A
            end
            3'h2: begin// RÉ
                // seg5 <= 8'b11111111;
                seg6 <= 8'b11111111;
                seg7 <= 8'b11111111;
                seg8 <= 8'b10000101;// Letra D
                end
            3'h3: begin // SOL
                // seg5 <= 8'b11111111;
                seg6 <= 8'b01001001; // Letra S
                seg7 <= 8'b00000011; // Letra O
                seg8 <= 8'b11100011;
               end
            3'h4: // SI
            begin
                // seg5 <= 8'b11111111;
                seg6 <= 8'b11111111;
                seg7 <= 8'b11111111;
                seg8 <= 8'b11000001; // Letra B
            end
            3'h5: // MI
            begin
                // seg5 <= 8'b11111111;
                seg6 <= 8'b11111111;
                seg7 <= 8'b11111111;
                seg8 <= 8'b01100001; // Letra E
            end
            default:
                begin
                    // seg5 <= 8'b11111111;
                    seg6 <= 8'b11111111;
                    seg7 <= 8'b11111111;
                    seg8 <= 8'b11111111;
                end
        endcase

    endfunction

    function reg[7:0] to_seven_seg(reg[9:0] num);
        case (num)
            9'h0: to_seven_seg = 8'b00000011;
            9'h1: to_seven_seg = 8'b11110011;
            9'h2: to_seven_seg = 8'b00100101;
            9'h3: to_seven_seg = 8'b00001101;
            9'h4: to_seven_seg = 8'b10011001;
            9'h5: to_seven_seg = 8'b01001001;
            9'h6: to_seven_seg = 8'b01000001;
            9'h7: to_seven_seg = 8'b00011111;
            9'h8: to_seven_seg = 8'b00000001;
            9'h9: to_seven_seg = 8'b00001001;
            default:
                to_seven_seg = 8'b11110001;
        endcase
    endfunction
     
    always @(posedge clk) begin
        if(rst_n == 0) begin
            counter <= 0;
            an_reg <= 8'b11111111;
        end else begin
            case(digit_control)
                DIGIT1:begin
                    seg_reg <= seg1;
                    an_reg <= 8'b01111111;
                    if(counter < 2000) begin
                        counter <= counter + 1;
                        digit_control <= DIGIT1;
                    end else begin
                        counter <= 0;
                        digit_control <= DIGIT2;                    
                    end
                end
                DIGIT2:begin
                    seg_reg <= seg2;
                    an_reg <= 8'b10111111;
                    if(counter < 2000) begin
                        counter <= counter + 1;
                        digit_control <= DIGIT2;
                    end else begin
                        counter <= 0;
                        digit_control <= DIGIT3;                    
                    end
                end
                DIGIT3:begin
                    seg_reg <= seg3;
                    an_reg <= 8'b11011111;
                    if(counter < 2000) begin
                        counter <= counter + 1;
                        digit_control <= DIGIT3;
                    end else begin
                        counter <= 0;
                        digit_control <= DIGIT4;                    
                    end
                end
                DIGIT4:begin
                    seg_reg <= seg4;
                    an_reg <= 8'b11101111;
                    if(counter < 2000) begin
                        counter <= counter + 1;
                        digit_control <= DIGIT4;
                    end else begin
                        counter <= 0;
                        digit_control <= DIGIT5;                    
                    end
                end
                DIGIT5:begin
                    seg_reg <= seg5;
                    an_reg <= 8'b11110111;
                    if(counter < 2000) begin
                        counter <= counter + 1;
                        digit_control <= DIGIT5;
                    end else begin
                        counter <= 0;
                        digit_control <= DIGIT6;                    
                    end
                end
                DIGIT6:begin
                    seg_reg <= seg6;
                    an_reg <= 8'b11111011;
                    if(counter < 2000) begin
                        counter <= counter + 1;
                        digit_control <= DIGIT6;
                    end else begin
                        counter <= 0;
                        digit_control <= DIGIT7;                    
                    end
                end
                DIGIT7:begin
                    seg_reg <= seg7;
                    an_reg <= 8'b11111101;
                    if(counter < 2000) begin
                        counter <= counter + 1;
                        digit_control <= DIGIT7;
                    end else begin
                        counter <= 0;
                        digit_control <= DIGIT8;                    
                    end
                end
                DIGIT8:begin
                    seg_reg <= seg8;
                    an_reg <= 8'b11111110;
                    if(counter < 2000) begin
                        counter <= counter + 1;
                        digit_control <= DIGIT8;
                    end else begin
                        counter <= 0;
                        digit_control <= DIGIT1;                    
                    end
                end
                default: begin
                    digit_control <= DIGIT1;
                    counter <= 0;
                end
            endcase
        end
    end
endmodule