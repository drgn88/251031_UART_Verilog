`timescale 1ns / 1ps

module baud_gen #(
    parameter SYS_CLK = 100_000_000,
    parameter BAUD_RATE = 9600,
    parameter SAMPLE_RATE = 16
) (
    input clk,
    input rstn,

    output reg baud_tick
);

    reg [($clog2(SYS_CLK/BAUD_RATE/SAMPLE_RATE) - 1):0] counter;

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            counter <= 0;
            baud_tick <= 0;
        end
        else if(counter == ((SYS_CLK/BAUD_RATE/SAMPLE_RATE) - 1)) begin
            counter <= 0;
            baud_tick <= 1;
        end
        else begin
            counter <= counter + 1;
            baud_tick <= 0;
        end
    end
endmodule
