`timescale 1ns / 1ps

module spi_slave (
    // global signal
    input  logic       clk,
    input  logic       rst,
    // external signal
    input  logic       sclk,
    input  logic       mosi,
    input  logic       ss_n,
    output logic       miso,
    // internal signal
    input  logic [7:0] tx_data,
    output logic [7:0] rx_data,
    output logic       busy,
    output logic       done
);

    typedef enum {
        IDLE  = 0,
        START,
        DATA,
        STOP
    } state_e;

    state_e state;

    logic [7:0] tx_shift_reg;
    logic [7:0] rx_shift_reg;
    logic [2:0] bit_cnt;

    logic rising_sclk;
    logic falling_sclk;
    logic sclk_sync0;
    logic sclk_sync1;

    assign rising_sclk  = (sclk_sync0) & (~sclk_sync1);
    assign falling_sclk = (~sclk_sync0) & (sclk_sync1);

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            sclk_sync0 <= 0;
            sclk_sync1 <= 0;
        end else begin
            sclk_sync0 <= sclk;
            sclk_sync1 <= sclk_sync0;
        end
    end

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= IDLE;
            tx_shift_reg <= 0;
            rx_shift_reg <= 0;
            bit_cnt <= 0;
            miso <= 1'b1;
            busy <= 1'b0;
            done <= 1'b0;
        end else begin
            done <= 1'b0;
            case (state)
                IDLE: begin
                    miso <= 1'b1;
                    if (!ss_n) begin
                        state <= START;
                        tx_shift_reg <= tx_data;
                        bit_cnt <= 0;
                        busy <= 1'b1;
                    end
                end
                START: begin
                    miso <= tx_shift_reg[7];
                    tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                    state <= DATA;
                end
                DATA: begin
                    if (rising_sclk) begin
                        rx_shift_reg <= {rx_shift_reg[6:0], mosi};
                    end else if (falling_sclk) begin
                        if (bit_cnt == 7) begin
                            rx_data <= rx_shift_reg;
                            state   <= STOP;
                        end else begin
                            miso <= tx_shift_reg[7];
                            tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                            bit_cnt <= bit_cnt + 1;
                        end
                    end
                end
                STOP: begin
                    done  <= 1'b1;
                    busy  <= 1'b0;
                    miso  <= 1'b1;
                    state <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end


endmodule

