import uvm_pkg::*;
import spi_slave_pkg::*;

module tb_spi_slave ();

  logic clk;
	logic rst;

  spi_slave_interface spi_slave_if (
      clk
  );

  spi_slave dut (
      .clk    (clk),
      .rst    (spi_slave_if.rst),
      .sclk   (spi_slave_if.sclk),
      .mosi   (spi_slave_if.mosi),
      .ss_n   (spi_slave_if.ss_n),
      .miso   (spi_slave_if.miso),
      .tx_data(spi_slave_if.tx_data),
      .rx_data(spi_slave_if.rx_data),
      .busy   (spi_slave_if.busy),
      .done   (spi_slave_if.done)
  );

  initial clk = 0;
  always #5 clk = ~clk;

	initial begin
		$fsdbDumpfile("spi_slave_tb.fsdb");
		$fsdbDumpvars(0);
		$fsdbDumpMDA();
	end

	initial begin
		uvm_config_db#(virtual spi_slave_interface)::set(null,"","spi_slave_vif", spi_slave_if);
		run_test("spi_slave_test");
	end

endmodule
