module load_mem(
    input bit clk,
    output reg [10:0] addr,
    output wire [9:0] data_out_wire,
    output bit write_enable,
    input bit do_load,
    output bit data_loaded
);
    int fd;
    reg [9:0] i = 0;
    wire [9:0] i_inv;
    string line;
    int num;
    reg [9:0] data_out;
    assign data_out_wire = data_out;

    assign i_inv[0] = i[9];
    assign i_inv[1] = i[8];
    assign i_inv[2] = i[7];
    assign i_inv[3] = i[6];
    assign i_inv[4] = i[5];
    assign i_inv[5] = i[4];
    assign i_inv[6] = i[3];
    assign i_inv[7] = i[2];
    assign i_inv[8] = i[1];
    assign i_inv[9] = i[0];


    always @(posedge clk) begin
        if(do_load == 1) begin
            $fgets(line, fd);

            if (line.len() > 0) begin
                num = line.atoi();
                data_out <= num * 250;
                write_enable <= 1;
                addr <= i_inv;
                i <= i + 1;
            end else begin
                write_enable <= 0;
                data_loaded <= 1;
            end
        end else begin
            write_enable <= 0;
        end
    end

    initial begin
        data_loaded = 0;
        write_enable = 0;
        fd = $fopen("A.txt", "r");
        if(fd) $display("File was opened successfully: %0d", fd);
        else   $display("File was NOT opened: %0d", fd);

    end
    

endmodule