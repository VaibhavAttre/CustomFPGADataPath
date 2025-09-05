
module program_counter_reg #(
    parameter WIDTH = 8
)(
    input clk,
    input rst,
    input load,    
    input inc,         
    input [WIDTH-1:0] d,
    output reg [WIDTH-1:0] pc
);
    always @(posedge clk) begin
        if (rst) pc <= {WIDTH{1'b0}};
        else if (load) pc <= d;
        else if (inc) pc <= pc + 1'b1;
    end
endmodule
