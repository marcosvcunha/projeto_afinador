module load_mem(
    input bit clk,
    output reg [10:0] addr,
    output wire [9:0] data_out_wire,
    output bit write_enable,
    input bit do_load,
    output bit data_loaded
);
    int fd;
    int i = 0;
    string line;
    int num;
    reg [9:0] data_out;
    assign data_out_wire = data_out;

    always @(posedge clk) begin
        if(do_load == 1) begin
            if(i < 10) begin
                $fgets(line, fd);
                num = line.atoi();
               data_out <= num;
                write_enable <= 1;
                addr <= i;
                i <= i + 1;
            end else begin
                write_enable <= 0;
                data_loaded <= 1;
            end
        end
    end

    initial begin
        data_loaded = 0;
        write_enable = 0;
        fd = $fopen("data.txt", "r");
        if(fd) $display("File was opened successfully: %0d", fd);
        else   $display("File was NOT opened: %0d", fd);

    end
    

endmodule