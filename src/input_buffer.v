module input_buffer #(
    parameter WIDTH = 8,
    parameter MAX = WIDTH - 1
)(
    input clk,
    input rst,
    input bit_in,
    input store,
    output reg [WIDTH-1:0] out,
    output reg ready,
    output [WIDTH-1:0] current_shift
);

reg store_d;
wire store_edge = store & ~store_d;
always @(posedge clk)  store_d <= store;

reg [WIDTH-1:0] shift_reg = 0;
reg [$clog2(WIDTH)-1:0] count;

assign current_shift = shift_reg;

always @(posedge clk) begin
    if(!rst) begin  
        shift_reg <= {WIDTH{1'b0}};
        count <= 0;
        out <= {WIDTH{1'b0}};
        ready <= 1'b0;
    end else if(store_edge  ) begin
        shift_reg <= {shift_reg[WIDTH-2:0], bit_in};
        if(count == MAX) begin
            out <= {shift_reg[WIDTH-2:0], bit_in};
            ready <= 1'b1;
            count <= 0;
        end else begin     
            count <= count + 1;
            ready <= 1'b0;
        end
    end else begin      
        ready <= 1'b0;
    end
end

endmodule