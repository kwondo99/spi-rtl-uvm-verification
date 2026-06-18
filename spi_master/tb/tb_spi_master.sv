import uvm_pkg::*;
import spi_master_pkg::*;

module tb_spi_master ();

  logic clk;
  logic rst;

  spi_master_interface spi_master_if (clk);

  spi_master dut (
      .clk    (clk),
      .rst    (spi_master_if.rst),
      .start  (spi_master_if.start),
      .cpol   (spi_master_if.cpol),
      .cpha   (spi_master_if.cpha),
      .clk_div(spi_master_if.clk_div),
      .tx_data(spi_master_if.tx_data),
      .busy   (spi_master_if.busy),
      .rx_data(spi_master_if.rx_data),
      .done   (spi_master_if.done),
      .sclk   (spi_master_if.sclk),
      .mosi   (spi_master_if.mosi),
      .ss_n   (spi_master_if.ss_n),
      .miso   (spi_master_if.miso)
  );

  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    $fsdbDumpfile("spi_master_tb.fsdb");
    $fsdbDumpvars(0);
    $fsdbDumpMDA();
  end

  initial begin
    uvm_config_db#(virtual spi_master_interface)::set(null, "", "spi_master_vif", spi_master_if);
    run_test("spi_master_test");
  end

endmodule
