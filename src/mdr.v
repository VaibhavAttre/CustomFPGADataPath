module mdr #(
    parameter WIDTH = 8
)(
    input clk,
    input rst,
    input load,
    input sel_mem, 
    input [WIDTH-1:0] mem_in,
    input [WIDTH-1:0] bus_in,
    output reg [WIDTH-1:0] q
);
    always @(posedge clk) begin
        if (rst) q <= {WIDTH{1'b0}};
        else if (load) q <= (sel_mem ? mem_in : bus_in);
    end
endmodule
