class spi_slave_monitor extends uvm_monitor;
  `uvm_component_utils(spi_slave_monitor);

  virtual spi_slave_interface spi_slave_vif;

  uvm_analysis_port #(spi_seq_item) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual spi_slave_interface)::get(this, "", "spi_slave_vif", spi_slave_vif))
      `uvm_fatal("MON", " get spi_slave_vif error from uvm_config_db ")
  endfunction

  task run_phase(uvm_phase phase);
    spi_seq_item tr;
    forever begin
      @(posedge spi_slave_vif.clk);
      if (!spi_slave_vif.ss_n) begin
        tr = spi_seq_item::type_id::create("tr");
        tr.tx_data = spi_slave_vif.tx_data;
        repeat (8) begin
          @(posedge spi_slave_vif.sclk);
          tr.master_tx_data = {tr.master_tx_data[6:0], spi_slave_vif.mosi};
          tr.slave_tx_data  = {tr.slave_tx_data[6:0], spi_slave_vif.miso};
        end
        wait (spi_slave_vif.done);
        tr.rx_data = spi_slave_vif.rx_data;
        ap.write(tr);
      end
    end
  endtask

endclass
