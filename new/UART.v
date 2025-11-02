`timescale 1ns / 1ps

module UART (
    input clk,
    input rstn,

    //tx Signals
    input [7:0] tx_data,
    input tx_start,
    output tx,
    output tx_busy,
    output tx_done,

    //rx Signals
    //input rx,
    output [7:0] rx_data,
    output rx_busy,
    output rx_done
);

    wire w_baud_tick;

    baud_gen #(
        .SYS_CLK(100_000_000),
        .BAUD_RATE(9600),
        .SAMPLE_RATE(16)
    ) U_BAUD_GEN (
        .clk (clk),
        .rstn(rstn),

        .baud_tick(w_baud_tick)
    );

    // transmitter U_TRANSMITTER (
    //     .clk(clk),
    //     .rstn(rstn),
    //     .baud_tick(w_baud_tick),
    //     .tx_start(tx_start),
    //     .tx_data(tx_data),

    //     .tx(tx),
    //     .tx_busy(tx_busy),
    //     .tx_done(tx_done)
    // );

    // receiver U_RECEIVER (
    //     .clk(clk),
    //     .rstn(rstn),
    //     .baud_tick(w_baud_tick),
    //     .rx(rx),

    //     .rx_busy(rx_busy),
    //     .rx_done(rx_done),
    //     .rx_data(rx_data)
    // );

/****************************************************************/
/**********************TX -> RX TEST**************************/
/****************************************************************/

    transmitter U_TRANSMITTER (
        .clk(clk),
        .rstn(rstn),
        .baud_tick(w_baud_tick),
        .tx_start(tx_start),
        .tx_data(tx_data),

        .tx(tx),
        .tx_busy(tx_busy),
        .tx_done(tx_done)
    );

    receiver U_RECEIVER (
        .clk(clk),
        .rstn(rstn),
        .baud_tick(w_baud_tick),
        .rx(tx),

        .rx_busy(rx_busy),
        .rx_done(rx_done),
        .rx_data(rx_data)
    );

endmodule
