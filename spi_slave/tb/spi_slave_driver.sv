class spi_slave_driver extends uvm_driver #(spi_seq_item);
  `uvm_component_utils(spi_slave_driver);

  virtual spi_slave_interface spi_slave_vif;

  parameter CLK_DIV = 4;
  parameter HALF_PERIOD = 10 * CLK_DIV;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual spi_slave_interface)::get(this, "", "spi_slave_vif", spi_slave_vif))
      `uvm_fatal("DRV", " get virtual spi_slave_vif error from uvm_config_db")
  endfunction

  task spi_drive(spi_seq_item tr);
		bit [7:0] tx_shift;
		tx_shift = tr.master_tx_data;
		spi_slave_vif.drv_cb.tx_data <= tr.tx_data;
		#10;
    spi_slave_vif.drv_cb.ss_n <= 1'b0;
    #100;
    for (int i = 0; i < 8; i++) begin
      spi_slave_vif.drv_cb.mosi <= tx_shift[7];
      #(HALF_PERIOD);
      spi_slave_vif.drv_cb.sclk <= 1'b1;
      tx_shift = {tx_shift[6:0], 1'b0};
      #(HALF_PERIOD);
      spi_slave_vif.drv_cb.sclk <= 1'b0;
    end
    #(HALF_PERIOD);
    spi_slave_vif.drv_cb.ss_n <= 1'b1;
  endtask

  task run_phase(uvm_phase phase);
		spi_slave_vif.rst <= 1;
		@(posedge spi_slave_vif.clk);
		spi_slave_vif.rst <= 0;
    forever begin
      seq_item_port.get_next_item(req);
			`uvm_info("DRV", $sformatf("get req"), UVM_MEDIUM)
      spi_drive(req);
      seq_item_port.item_done();
    end
  endtask

endclass
