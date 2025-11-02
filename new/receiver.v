// `timescale 1ns / 1ps

// module receiver (
//     input clk,
//     input rstn,
//     input baud_tick,
//     input rx,

//     output       rx_busy,
//     output       rx_done,
//     output [7:0] rx_data
// );

//     localparam IDLE = 0;
//     localparam START_READY = 1;
//     localparam RX_START = 2;
//     localparam DATA = 3;
//     localparam STOP = 4;

//     reg [2:0] state, next_state;
//     reg [7:0] rx_data_reg, rx_data_next;
//     reg rx_busy_reg, rx_busy_next;
//     reg rx_done_reg, rx_done_next;
//     reg [3:0] tick_cnt_reg, tick_cnt_next;
//     reg [2:0] bit_cnt_reg, bit_cnt_next;

//     assign rx_busy = rx_busy_reg;
//     assign rx_done = rx_done_reg;
//     assign rx_data = rx_data_reg;

//     always @(posedge clk or negedge rstn) begin
//         if (!rstn) begin
//             state        <= IDLE;
//             rx_data_reg  <= 0;
//             rx_busy_reg  <= 0;
//             rx_done_reg  <= 0;
//             tick_cnt_reg <= 0;
//             bit_cnt_reg  <= 0;
//         end else begin
//             state        <= next_state;
//             rx_data_reg  <= rx_data_next;
//             rx_busy_reg  <= rx_busy_next;
//             rx_done_reg  <= rx_done_next;
//             tick_cnt_reg <= tick_cnt_next;
//             bit_cnt_reg  <= bit_cnt_next;
//         end
//     end

//     always @(*) begin
//         next_state = state;
//         rx_data_next = rx_data_reg;
//         rx_busy_next = rx_busy_reg;
//         rx_done_next = rx_done_reg;
//         tick_cnt_next = tick_cnt_reg;
//         bit_cnt_next = bit_cnt_reg;
//         case (state)
//             IDLE: begin
//                 rx_busy_next = 0;
//                 rx_done_next = 0;
//                 if (!rx) begin
//                     next_state = START_READY;
//                 end
//             end
//             START_READY: begin
//                 rx_data_next = 0;
//                 rx_busy_next = 1;
//                 if (baud_tick) begin
//                     if (tick_cnt_reg == 7) begin
//                         tick_cnt_next = 0;
//                         next_state = RX_START;
//                     end else begin
//                         tick_cnt_next = tick_cnt_reg + 1;
//                     end
//                 end
//             end
//             RX_START: begin
//                 if (baud_tick) begin
//                     if (tick_cnt_reg == 15) begin
//                         tick_cnt_next = 0;
//                         bit_cnt_next = 0;
//                         rx_data_next[7] = rx;
//                         next_state = DATA;
//                     end else begin
//                         tick_cnt_next = tick_cnt_reg + 1;
//                     end
//                 end
//             end
//             DATA: begin
//                 if (baud_tick) begin
//                     if (tick_cnt_reg == 15) begin
//                         tick_cnt_next = 0;
//                         rx_data_next  = {rx, rx_data_reg[7:6]};
//                         if (bit_cnt_reg == 7) begin
//                             bit_cnt_next = 0;
//                             next_state   = STOP;
//                         end else begin
//                             bit_cnt_next = bit_cnt_reg + 1;
//                         end
//                     end else begin
//                         tick_cnt_next = tick_cnt_reg + 1;
//                     end
//                 end
//             end
//             STOP: begin
//                 if (baud_tick) begin
//                     if (tick_cnt_reg == 7) begin
//                         tick_cnt_next = 0;
//                         rx_done_next = 1;
//                         next_state   = IDLE;
//                     end
//                     else begin
//                         tick_cnt_next = tick_cnt_reg + 1;
//                     end
//                 end
//             end
//         endcase
//     end

// endmodule


`timescale 1ns / 1ps

module receiver (
    input clk,
    input rstn,
    input baud_tick,
    input rx,

    output       rx_busy,
    output       rx_done,
    output [7:0] rx_data
);

    localparam IDLE = 0;
    localparam START = 1;
    localparam DATA = 2;
    localparam STOP = 3;

    reg [1:0] state, next_state;
    reg [7:0] rx_data_reg, rx_data_next;
    reg rx_busy_reg, rx_busy_next;
    reg rx_done_reg, rx_done_next;
    reg [4:0] tick_cnt_reg, tick_cnt_next;
    reg [2:0] bit_cnt_reg, bit_cnt_next;

    assign rx_busy = rx_busy_reg;
    assign rx_done = rx_done_reg;
    assign rx_data = rx_data_reg;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state        <= IDLE;
            rx_data_reg  <= 0;
            rx_busy_reg  <= 0;
            rx_done_reg  <= 0;
            tick_cnt_reg <= 0;
            bit_cnt_reg  <= 0;
        end else begin
            state        <= next_state;
            rx_data_reg  <= rx_data_next;
            rx_busy_reg  <= rx_busy_next;
            rx_done_reg  <= rx_done_next;
            tick_cnt_reg <= tick_cnt_next;
            bit_cnt_reg  <= bit_cnt_next;
        end
    end

    always @(*) begin
        next_state = state;
        rx_data_next = rx_data_reg;
        rx_busy_next = rx_busy_reg;
        rx_done_next = rx_done_reg;
        tick_cnt_next = tick_cnt_reg;
        bit_cnt_next = bit_cnt_reg;
        case (state)
            IDLE: begin
                rx_busy_next = 0;
                rx_done_next = 0;
                if (!rx) begin
                    next_state = START;
                end
            end
            START: begin
                rx_data_next = 0;
                rx_busy_next = 1;
                if (baud_tick) begin
                    if (tick_cnt_reg == 7) begin
                        tick_cnt_next = 0;
                        bit_cnt_next = 0;
                        next_state = DATA;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            DATA: begin
                if (baud_tick) begin
                    if (tick_cnt_reg == 15) begin
                        tick_cnt_next = 0;
                        rx_data_next  = {rx, rx_data_reg[7:1]};
                        if (bit_cnt_reg == 7) begin
                            bit_cnt_next = 0;
                            next_state   = STOP;
                        end else begin
                            bit_cnt_next = bit_cnt_reg + 1;
                        end
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            STOP: begin
                if (baud_tick) begin
                    if (tick_cnt_reg == 23) begin
                        tick_cnt_next = 0;
                        rx_done_next = 1;
                        next_state = IDLE;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
        endcase
    end

endmodule
