`timescale 1ns / 1ps

module transmitter (
    input       clk,
    input       rstn,
    input       baud_tick,
    input       tx_start,
    input [7:0] tx_data,

    output tx,
    output tx_busy,
    output tx_done
);

    localparam IDLE = 0;
    localparam START_READY = 1;
    localparam TX_START = 2;
    localparam DATA = 3;
    localparam STOP = 4;

    reg [2:0] state, next_state;
    reg [7:0] temp_data, temp_next;
    reg tx_reg, tx_next;
    reg busy_reg, busy_next;
    reg done_reg, done_next;
    reg [3:0] tick_cnt_reg, tick_cnt_next;
    reg [2:0] bit_cnt_reg, bit_cnt_next;

    assign tx = tx_reg;
    assign tx_busy = busy_reg;
    assign tx_done = done_reg;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state        <= IDLE;
            temp_data    <= 0;
            tx_reg       <= 1;
            busy_reg     <= 0;
            done_reg     <= 0;
            tick_cnt_reg <= 0;
            bit_cnt_reg  <= 0;
        end else begin
            state        <= next_state;
            temp_data    <= temp_next;
            tx_reg       <= tx_next;
            busy_reg     <= busy_next;
            done_reg     <= done_next;
            tick_cnt_reg <= tick_cnt_next;
            bit_cnt_reg  <= bit_cnt_next;
        end
    end

    always @(*) begin
        next_state    = state;
        temp_next     = temp_data;
        tx_next       = tx_reg;
        busy_next     = busy_reg;
        done_next     = done_reg;
        tick_cnt_next = tick_cnt_reg;
        bit_cnt_next  = bit_cnt_reg;
        case (state)
            IDLE: begin
                done_next = 0;
                busy_next = 0;
                if (tx_start) begin
                    next_state = START_READY;
                    temp_next  = tx_data;
                    busy_next  = 1;
                end
            end
            START_READY: begin
                if (baud_tick) begin
                    next_state = TX_START;
                    tick_cnt_next = 0;
                end
            end
            TX_START: begin
                tx_next = 0;
                if (baud_tick) begin
                    if (tick_cnt_reg == 15) begin
                        tick_cnt_next = 0;
                        bit_cnt_next = 0;
                        next_state = DATA;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            DATA: begin
                tx_next = temp_data[bit_cnt_reg];
                if (baud_tick) begin
                    if (tick_cnt_reg == 15) begin
                        tick_cnt_next = 0;
                        if (bit_cnt_reg == 7) begin
                            next_state   = STOP;
                            bit_cnt_next = 0;
                        end else begin
                            bit_cnt_next = bit_cnt_reg + 1;
                        end
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            STOP: begin
                tx_next = 1;
                if (baud_tick) begin
                    if (tick_cnt_reg == 15) begin
                        next_state = IDLE;
                        tick_cnt_next = 0;
                        done_next = 1;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
        endcase
    end

endmodule
