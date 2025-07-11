module register_file # (
    parameter WIDTH = 8
) (
    
    input clk,
    input rst,
    input loadA,
    input loadB,
    input [WIDTH-1:0] data_in,
    output reg [WIDTH-1:0] A,
    output reg [WIDTH-1:0] B
);

always @(posedge clk) begin
    
    if(!rst) begin
        A <= {WIDTH{1'b0}};
        B <= {WIDTH{1'b0}};
    end else begin
        if(loadA) A <= data_in;
        if(loadB) B <= data_in;
    end
end

endmodule