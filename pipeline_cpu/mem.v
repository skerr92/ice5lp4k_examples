`default_nettype none

module mem(input clk, rst, we, input [15:0] data_in, input [6:0] w_addr, input [6:0] r_addr, output [15:0] data_out);
    reg [15:0] mem [511:0];
    integer i;
    initial begin 
        
        for (i = 0; i < 512; i = i + 1) begin 
            mem[i] = 16'hFF;
        end
    end

    always @(posedge clk) begin 
        if (rst) begin 
            data_out <= 16'hFF;
        end
        if (we) begin 
            mem[w_addr] <= data_in;
            data_out <= mem[w_addr];
        end
        else begin 
            data_out <= mem[r_addr];
        end
    end
endmodule