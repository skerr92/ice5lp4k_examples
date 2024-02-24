`default_nettype none
`include "cpu.v"

module top(input reset, output [15:0] out, output [2:0] RGB, output LED2, LED3);
    wire clk_src;
    reg [31:0] clk;
    reg [15:0] out_reg;
    reg [1:0] pc_out;

    assign out = out_reg;
    assign LED2 = pc_out[0];
    assign LED3 = pc_out[1];

    SB_HFOSC SB_HFOSC_inst(
      .CLKHFEN(1),
      .CLKHFPU(1),
      .CLKHF(clk_src)
   );

    cpu cpu_init(.clk(clk[24]), .rst(reset), .out(out_reg), .stage(RGB), .pc_out(pc_out));
    
    always @(posedge clk_src) begin 
        if (reset) begin 
            clk <= 0;
        end
        clk <= clk + 1;
    end
endmodule