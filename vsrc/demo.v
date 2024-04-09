`timescale 1ns/1ps

module demo(
        input clk,
        input rst,
        input wire a,
        output reg w
    );

    reg [2:0] buffer; //要检测的序列长度为3

    always @(posedge clk) begin
        if(rst) begin
            buffer <= 3'b0;
            w <= 1'b0;
        end
        else begin
            buffer <= {buffer[1:0], a};

            //相当于 w = ( 更新后的buffer == 3'b101)
            w <=  (buffer[1] & (~buffer[0]) & a);
        end
    end
endmodule
