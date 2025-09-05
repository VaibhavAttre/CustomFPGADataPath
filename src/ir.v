module ir #(
    parameter WIDTH = 8,
    parameter OPCODE_S = 3
)(
    input clk,
    input rst,
    input load,    
    input [WIDTH-1:0] d,
    output reg [OPCODE_S-1:0] opcode, 
    output reg [WIDTH-OPCODE_S-1:0] operand,
    output reg [WIDTH-1:0] raw
);
    always @(posedge clk) begin
        if (rst) begin
            raw <= {WIDTH{1'b0}};
            opcode <= {OPCODE_S{1'b0}};
            operand <= {(WIDTH-OPCODE_S){1'b0}};
        end else if (load) begin
            raw <= d;
            opcode <= d[WIDTH-1 -: OPCODE_S]; 
            operand <= d[WIDTH-OPCODE_S-1:0];
        end
    end
endmodule
