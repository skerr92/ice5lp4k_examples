`default_nettype none

module program_mem(input wire clk, rst, input wire [9:0] pc, output reg [31:0] instruction);
    reg [31:0] pmem [2047:0];
    initial begin 
        // fill regfile with intermed values
        pmem[0] = 32'hFFFFFFFF;
        pmem[1] = 32'b1000100000000000_1100000011100000;
        pmem[2] = 32'b1000100000010000_1111000011100000;
        pmem[3] = 32'b1000100000100000_0000000000000001;
        pmem[4] = 32'b1000100000110000_0000000000000010;
        pmem[5] = 32'b1000100001000000_0001000000000000;
        pmem[6] = 32'b1000100001010000_0000000000000100;
        pmem[7] = 32'b1000100001100000_0000000000000000;
        pmem[8] = 32'b1000100001110000_1111001000100000;
        pmem[9] = 32'b1000100010000000_0000000000100000;
        pmem[10] = 32'b1000100010010000_1000000000100001;
        pmem[11] = 32'b1000100010100000_0000000000000111;
        pmem[12] = 32'b1000100010110000_0000100011100001;
        pmem[13] = 32'b1000100011000000_1100000011111111;
        pmem[14] = 32'b1000100011010000_1100000010001000;
        pmem[15] = 32'b1000100011100000_1100000110001110;
        pmem[16] = 32'b1000100011110000_1100001111100000;

        // instr     op  aluop i operA   operB
        pmem[17] = 32'b0001000100011000_0001000000000000;
        // instr     op  aluop i operA   intermed
        pmem[18] = 32'b0001000110001000_0001000000001000;
        // instr     op  memwe waddr    datain
        pmem[19] = 32'b0010100010001000_0000111100001000;
        // instr     op  memwe raddr    
        pmem[20] = 32'b0010000110001000_1100000000000000;
        // instr      op  aluop i operA   intermed 
        pmem[21] = 32'b0001011010011000_1100111010110000;
        // instr     op  memwe waddr  reg
        pmem[22] = 32'b0010100010001001_0011000000000000;
        // jump instruction
        pmem[23] = 32'b1100_0000_0000_10001_000000000000000;
        
        pmem[24] = 32'hFFFFFFFF;
    end
    always @(posedge clk) begin 
        if (rst) begin 
            instruction <= pmem[0];
        end
        instruction <= pmem[pc];
    end
endmodule