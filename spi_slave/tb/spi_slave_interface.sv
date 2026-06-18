interface spi_slave_interface (
    input logic clk
);
  logic       rst;
  // external signal
  logic       sclk;
  logic       mosi;
  logic       ss_n;
  logic       miso;
  // internal signal
  logic [7:0] tx_data;
  logic [7:0] rx_data;
  logic       busy;
  logic       done;

  clocking drv_cb @(posedge clk);
    default input #1step output #0;
    output sclk;
    output mosi;
    output ss_n;
    output tx_data;
  endclocking

  clocking mon_cb @(posedge clk);
    default input #1step;
    input sclk;
    input mosi;
    input ss_n;
    input miso;
    input tx_data;
    input rx_data;
    input busy;
    input done;
  endclocking

endinterface
