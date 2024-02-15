`default_nettype none

module alu(input clk, input [15:0] operA, operB, input [3:0] alu_op, output [15:0] alu_out, output [3:0] flags);

    always @(posedge clk) begin 
        flags <= 4'h0;
        // flags are:
        // flags[3] carry
        // flags[2] negative
        // flags[1] overfloow
        // flags[0] zero
        case (alu_op)
            1: begin
                alu_out <= operA + operB;
                if ((operA + operB) == 17'h10000) begin
                    flags[3] <= 1; // carry
                end
                if ((operA + operB) > 17'h10000) begin
                    flags[1] <= 1; // overflow
                end
                if ((operA + operB) == 16'h0000) begin 
                    flags[0] <= 1;
                end
            end
            2: begin
                alu_out <= operB - operA;
                if (operA > operB) begin 
                    flags[2] <= 1;
                end
                if (operA == operB) begin 
                    flags[0] <= 1;
                end
            end
            3: begin
                alu_out <= operA & operB;
                if (operA == 0 || operB == 0) begin 
                    flags[0] <= 1;
                end
            end
            4: begin
                alu_out <= operA | operB;
                if (alu_out == 0) begin 
                    flags[0] <= 1;
                end
            end
            5: begin
                alu_out <= operA ^ operB;
                if (alu_out == 0) begin 
                    flags[0] <= 1;
                end
            end
            6: begin 
                alu_out <= operA << 1;
                if (alu_out == 0) begin 
                    flags[0] <= 1;
                end
            end
            7: begin 
                alu_out <= operB >> 1;
                if (alu_out == 0) begin 
                    flags[0] <= 1;
                end
            end
            15: begin 
                alu_out <= ~operA;
                if (alu_out == 0) begin 
                    flags[0] <= 1;
                end
            end
        endcase
    end

endmodule