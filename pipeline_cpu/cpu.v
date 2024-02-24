`default_nettype none
`include "alu.v"
`include "mem.v"
`include "program.v"

module cpu(input wire clk, rst, output reg [15:0] out, output reg [2:0] stage, output reg [1:0] pc_out);
    localparam INIT = 1;
    localparam FETCH = 2;
    localparam DECODE = 4;
    localparam EXEC = 5;
    localparam ACCESS = 6;
    localparam WRITE = 7;
    // hello
    reg [15:0] regfile [15:0];

    reg [15:0] operA;
    reg [15:0] operB;
    reg [15:0] alu_out;
    reg [3:0] alu_op;
  reg [3:0] flags;

    reg [6:0] w_addr;
    reg [6:0] r_addr;
    reg [15:0] data_in;
    reg [15:0] data_out;
    reg we;

    reg [31:0] instruction;
    reg [31:0] cur_instr;
    reg [9:0] pc;

    reg [3:0] mv_addr;
    reg [3:0] mvf_addr;
    reg intermed;
    reg [2:0] state;
    assign stage = state;
    assign pc_out = pc[1:0];
    integer i;
    initial begin 
        state = INIT;
        out = 16'h0000;
        pc = 0;
        for (i = 0; i < 16; i = i + 1) begin 
            regfile[i] = 16'hFF;
        end
    end

    alu alu_init(.clk(clk), .operA(operA), 
                 .operB(operB), 
                 .alu_op(alu_op),
                 .alu_out(alu_out),
                 .flags(flags));
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
            out <= 0;
        end
        if (state == INIT) begin state <= FETCH; end
        else if (state == FETCH) begin state <= DECODE;end
        else if (state == DECODE) begin state <= EXEC; end
        else if (state == EXEC) begin state <= ACCESS; end
        else if (state == ACCESS) begin state <= WRITE; end
        else if (state == WRITE) begin state <= FETCH; end

        case (state)
            INIT: begin
                //state <= FETCH;
                out <= 16'h0000;
                we <= 0;
            end
            FETCH: begin
                
                //state <= DECODE;
                out <= instruction[31:16];
                cur_instr <= instruction;
                
            end
            DECODE: begin
                pc <= pc + 1;
                case (cur_instr[31:28])
                'b0001: begin 
                  alu_op <= cur_instr[27:24];
                  if (cur_instr[23]) begin
                        operA <= regfile[cur_instr[22:19]];
                        operB <= cur_instr[15:0];
                        out <= 16'h0001;
                    end
                    else begin 
                      operA <= regfile[cur_instr[22:19]];
                        operB <= regfile[cur_instr[15:12]];
                        out <= 16'h0001;
                    end
                end
                'b0010: begin 
                    if (cur_instr[27]) begin
                      if (cur_instr[16]==0) begin
                        w_addr <= cur_instr[26:18];
                        data_in <= cur_instr[15:0];
                        out <= 16'hABAB;
                      end
                      else begin 
                      	w_addr <= cur_instr[26:18];
                        data_in <= regfile[cur_instr[15:12]];
                        out <= 16'hDABB;
                      end
                    end
                    else begin 
                        r_addr <= cur_instr[26:18];
                        out <= out <= 16'h0002;
                    end
                end
                'b1000: begin 
                    if (cur_instr[27] == 1) begin 
                        intermed <= 1;
                    end
                    else begin 
                        mvf_addr <= cur_instr[19:16];
                    end
                    mv_addr <= cur_instr[23:20];
                    out <= 16'h0004;
                end
                'hC: begin 
                     if (cur_instr[27:24] == 0) begin 
                       pc <= cur_instr[23:15];
                     end
                     out <= 16'hFEFE;
                     state<=FETCH;
                end
                'hF: begin 
                    // no op
                    out <= 16'hEEEE;
                end
                endcase
                //state <= EXEC;
            end
            EXEC: begin 
                //state <= ACCESS;
                out <= alu_out;
            end
            ACCESS: begin
                if (cur_instr[31:28] == 4'h2) begin
                    we <= cur_instr[27];
                    out <= data_out;
                end
                //state <= WRITE;
            end
            WRITE: begin
                // Move instruction which supports storing intermediates
                // and moving contents from one register to the next
                if (cur_instr[31:28] == 4'h8) begin 
                    if (intermed) begin 
                        regfile[mv_addr] <= cur_instr[15:0];
                        out <= cur_instr[15:0];
                    end
                    else begin 
                        regfile[mv_addr] <= regfile[mvf_addr];
                        out <= regfile[mv_addr];
                    end
                    
                end
                // memory instructions
                else if (cur_instr[31:28] == 4'h2) begin
                    we <= cur_instr[27];
                    if (we == 0) begin 
                        regfile[cur_instr[17:14]] <= data_out;
                    end
                    out <= data_out;
                end
                else if (cur_instr[31:28] == 4'h1) begin
                  regfile[cur_instr[22:19]] <= alu_out;
                    out <= alu_out;
                end
                else begin 
                    out <= 16'hAAAA;
                end
                
                //state <= FETCH;
            end
            default: begin
                //state <= INIT;
                out <= 16'hFFFF;
            end
        endcase
    end

endmodule