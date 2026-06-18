class spi_master_driver extends uvm_driver #(spi_seq_item);
  `uvm_component_utils(spi_master_driver)

  virtual spi_master_interface spi_master_vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual spi_master_interface)::get(
            this, "", "spi_master_vif", spi_master_vif
        ))
      `uvm_fatal("DRV", "get virtual spi_master_vif error from uvm_config_db")
  endfunction

  task spi_master_drive(spi_seq_item tr);
    wait (spi_master_vif.busy == 1'b0);
    @(spi_master_vif.drv_cb);
    spi_master_vif.drv_cb.cpol    <= tr.cpol;
    spi_master_vif.drv_cb.cpha    <= tr.cpha;
    spi_master_vif.drv_cb.clk_div <= tr.clk_div;
    spi_master_vif.drv_cb.tx_data <= tr.tx_data;
    spi_master_vif.drv_cb.start   <= 1'b1;

    @(posedge spi_master_vif.busy);
    spi_master_vif.drv_cb.start <= 1'b0;

		// wait done signal
    @(posedge spi_master_vif.done);
  endtask

  task spi_slave_drive(spi_seq_item tr);
    bit [7:0] s_shift;
    s_shift = tr.slave_tx_data;

    @(negedge spi_master_vif.ss_n);

	// mode 0, 2(cpha : 1'b0)
    if (tr.cpha == 1'b0) begin
      spi_master_vif.drv_cb.miso <= s_shift[7];
      s_shift = {s_shift[6:0], 1'b0};
      for (int i = 0; i < 7; i++) begin
        if (tr.cpol == 1'b0) @(negedge spi_master_vif.sclk);  // Mode 0
        else @(posedge spi_master_vif.sclk);  // Mode 2
        if (spi_master_vif.ss_n === 1'b0) begin
          spi_master_vif.drv_cb.miso <= s_shift[7];
          s_shift = {s_shift[6:0], 1'b0};
        end
      end
	// mode 1,3 (cpha : 1'b1)
    end else begin
      for (int i = 0; i < 8; i++) begin
        if (tr.cpol == 1'b0) @(posedge spi_master_vif.sclk);  // Mode 1
        else @(negedge spi_master_vif.sclk);  // Mode 3
        if (spi_master_vif.ss_n === 1'b0) begin
          spi_master_vif.drv_cb.miso <= s_shift[7];
          s_shift = {s_shift[6:0], 1'b0};
        end
      end
    end

    @(posedge spi_master_vif.ss_n);
    spi_master_vif.drv_cb.miso <= 1'b1;  
  endtask

  task run_phase(uvm_phase phase);
	// reset
    spi_master_vif.drv_cb.rst     <= 1'b1;
    spi_master_vif.drv_cb.start   <= 1'b0;
    spi_master_vif.drv_cb.cpol    <= 1'b0;
    spi_master_vif.drv_cb.cpha    <= 1'b0;
    spi_master_vif.drv_cb.clk_div <= '0;
    spi_master_vif.drv_cb.tx_data <= '0;
    spi_master_vif.drv_cb.miso    <= 1'b1;
    repeat (2) @(spi_master_vif.drv_cb);
    spi_master_vif.drv_cb.rst <= 1'b0;

    forever begin
      seq_item_port.get_next_item(req);
      `uvm_info("DRV", "get req", UVM_MEDIUM)
      fork
        spi_master_drive(req);
        spi_slave_drive(req);
      join
      seq_item_port.item_done();
    end
  endtask
endclass
