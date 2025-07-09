module program_counter_reg #(
    parameter WIDTH = 8
) (
    
    input clk,
    input rst,
    input increment,
    output reg [WIDTH-1:0] pc
);

always @(posedge clk) begin
    
    if(rst) begin
        pc <= {WIDTH{1'b0}};
    end else if (increment) begin
        pc <= pc + 1;
    end
end
endmodule
