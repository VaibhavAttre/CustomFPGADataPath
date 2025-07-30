module rc_adc (
    input clk,
    inout gpio_pin,    
    output reg [9:0] adc_value  
);
    reg [31:0] counter = 0;
    reg charging = 1;    

    assign gpio_pin = charging ? 1'b1 : 1'bz;  

    always @(posedge clk) begin
        if (charging) begin
            if (counter < 500_000) begin 
                counter <= counter + 1;
            end else begin
                charging <= 0;  
                counter <= 0;
            end
        end else begin
            if (gpio_pin == 1'b1) begin
                counter <= counter + 1;
            end else begin
                adc_value <= counter[25:16];  
                charging <= 1; 
                counter <= 0;
            end
        end
    end
endmodule