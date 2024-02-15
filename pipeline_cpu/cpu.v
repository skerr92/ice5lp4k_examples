`default_nettype none
`include "alu.v"
`include "mem.v"
`include "program.v"

module cpu(input clk, rst, output [15:0] out, output [2:0] stage);
    localparam INIT = 1;
    localparam FETCH = 2;
    localparam DECODE = 4;
    localparam EXEC = 5;
    localparam ACCESS = 6;
    localparam WRITE = 7;

    reg [15:0] regfile [15:0];

    reg [15:0] operA;
    reg [15:0] operB;
    reg [15:0] alu_out;
    reg [3:0] alu_op;

    wire [6:0] w_addr;
    wire [6:0] r_addr;
    reg [15:0] data_in;
    reg [15:0] data_out;
    wire we;

    reg [31:0] instruction;
    reg [9:0] pc;

    reg [3:0] mv_addr;
    reg [3:0] mvf_addr;
    reg intermed;

    reg [2:0] state;
    assign stage = state;
    integer i;
    initial begin 
        state = INIT;
        pc = 0;
        
        for (i = 0; i < 16; i = i + 1) begin 
            regfile[i] = 16'hFF;
        end
    end

    alu alu_init(.clk(clk), .operA(operA), 
                 .operB(operB), 
                 .alu_op(alu_op),
                 .alu_out(alu_out));
    mem mem_init(.clk(clk), 
                 .rst(rst), 
                 .we(we), 
                 .data_in(data_in), 
                 .w_addr(w_addr), 
                 .r_addr(r_addr), 
                 .data_out(data_out));
    program_mem program_mem_init(.clk(clk), .rst(rst), .pc(pc), .instruction(instruction));

    always @(posedge clk) begin 
        if (rst) begin
            state <= INIT;
            pc <= 0;
        end
        case (state)
            INIT: begin
                state <= FETCH;
                out <= 16'h1111;
            end
            FETCH: begin
                pc <= pc + 1;
                state <= DECODE;
                out <= 16'h2222;
            end
            DECODE: begin
                case (instruction[31:28])
                1: begin 
                    alu_op <= instruction[26:23];
                    if (instruction[24]) begin
                        operA <= regfile[instruction[22:19]];
                        operB <= instruction[15:0];
                    end
                    else begin 
                        operA <= regfile[instruction[23:20]];
                        operB <= regfile[instruction[15:12]];
                    end
                end
                2: begin 
                    if (instruction[27]) begin
                        w_addr <= instruction[26:18];
                        data_in <= instruction[15:0];
                    end
                    else begin 
                        r_addr <= instruction[26:18];
                    end
                end
                8: begin 
                    if (instruction[27] == 1) begin 
                        intermed <= 1;
                    end
                    else begin 
                        mvf_addr <= instruction[19:16];
                    end
                    mv_addr <= instruction[23:20];
                end
                12: begin 
                    if (instruction[27:24] == 0) begin 
                        pc <= instruction[23:15];
                    end
                end
                15: begin 
                    // no op
                    out <= 16'h0000;
                end
                endcase
                state <= EXEC;
                out <= 16'hFFFF;
            end
            EXEC: begin 
                state <= ACCESS;
                out <= alu_out;
            end
            ACCESS: begin
                if (instruction[31:28] == 2) begin
                    we <= instruction[27];
                    out <= data_out;
                end
                state <= WRITE;
                out <= data_out;
            end
            WRITE: begin
                // Move instruction which supports storing intermediates
                // and moving contents from one register to the next
                if (instruction[31:28] == 8) begin 
                    if (intermed) begin 
                        regfile[mv_addr] <= instruction[15:0];
                    end
                    else begin 
                        regfile[mv_addr] <= regfile[mvf_addr];
                    end
                    out <= regfile[mv_addr];
                end
                // memory instructions
                if (instruction[31:28] == 2) begin
                    we <= instruction[27];
                    if (we == 0) begin 
                        regfile[instruction[17:14]] <= data_out;
                    end
                    out <= data_out;
                end
                if (instruction[31:28] == 1) begin
                    regfile[instruction[23:20]] <= alu_out;
                    out <= alu_out;
                end
                state <= FETCH;
                
            end
            default: begin
                state <= INIT;
                out <= 16'hFFFF;
            end
        endcase
    end

endmodule