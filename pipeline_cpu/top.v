`default_nettype none
`include "cpu.v"

module top(input reset, output [15:0] out, output [2:0] RGB);
    wire clk_src;
    reg [31:0] clk;

    SB_HFOSC SB_HFOSC_inst(
      .CLKHFEN(1),
      .CLKHFPU(1),
      .CLKHF(clk_src)
   );

    cpu cpu_init(.clk(clk[25]), .rst(reset), .out(out), .stage(RGB));

    always @(posedge clk_src) begin 
        if (reset) begin 
            clk <= 0;
        end
        clk <= clk + 1;
    end
endmodule