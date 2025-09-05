module mar #(
    parameter ADDR_S = 3
)(
    input clk,
    input rst,
    input load,
    input [ADDR_S-1:0] d,
    output reg [ADDR_S-1:0] q
);
    always @(posedge clk) begin
        if (rst) q <= {ADDR_S{1'b0}};
        else if (load) q <= d;
    end
endmodule
