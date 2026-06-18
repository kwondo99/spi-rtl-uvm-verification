interface spi_master_interface (
    input logic clk
);
  logic       rst;
  // external signal (DUT가 출력)
  logic       sclk;
  logic       mosi;
  logic       ss_n;
  logic       miso;   // slave가 구동 (TB가 driver로 구동)
  // internal signal
  logic       start;
  logic       cpol;
  logic       cpha;
  logic [7:0] clk_div;
  logic [7:0] tx_data;
  logic [7:0] rx_data;
  logic       busy;
  logic       done;

  clocking drv_cb @(posedge clk);
    default input #1step output #0;
    output rst;
    output start;
    output cpol;
    output cpha;
    output clk_div;
    output tx_data;
    output miso;       // slave 응답 구동용
  endclocking

  clocking mon_cb @(posedge clk);
    default input #1step;
    input sclk, mosi, ss_n, miso;
    input tx_data, rx_data, busy, done;
    input start, cpol, cpha, clk_div;
  endclocking
endinterface
