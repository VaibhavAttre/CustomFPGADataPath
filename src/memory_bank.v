module memory_bank #(
    
    parameter WIDTH = 8,
    parameter REGS = 8,
    parameter ADDR_S = 3
) (
    
    input clk,
    input rst,
    input wr_en,
    input [ADDR_S - 1 : 0] addr,
    input [WIDTH - 1: 0] d_in,
    output reg [WIDTH - 1: 0] d_out    
);

reg [WIDTH-1:0] registers [0:REGS-1];

always @(posedge clk) begin
    
    if(rst) begin
        d_out <= 0;
    end else begin
        if(wr_en) begin
           registers[addr] <= d_in; 
        end
        d_out <= registers[addr];
    end
end

endmodule