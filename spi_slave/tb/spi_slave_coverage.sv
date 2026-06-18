class spi_slave_coverage extends uvm_subscriber #(spi_seq_item);
  `uvm_component_utils(spi_slave_coverage)

  spi_seq_item tr;

  covergroup spi_slave_cg;
    option.per_instance = 1;
    cp_master_tx: coverpoint tr.master_tx_data {
      bins zeros = {8'h00}; bins ones = {8'hFF}; bins others[8] = {[8'h01:8'hFE]};
    }
    cp_slave_tx: coverpoint tr.tx_data {
      bins zeros = {8'h00}; bins ones = {8'hff}; bins others[8] = {[8'h01:8'hFE]}; 
    }
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    spi_slave_cg = new();
  endfunction

  function void write(spi_seq_item t);
    tr = t;
    `uvm_info("COV", $sformatf(" master_tx : %2h, slave_tx : %2h", tr.master_tx_data, tr.tx_data),
              UVM_HIGH)
    spi_slave_cg.sample();
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("COV", "*****************", UVM_LOW);
    `uvm_info("COV", "**** Functional Coverage result ****", UVM_LOW);
    `uvm_info("COV", $sformatf(" total : %6.2f %%", spi_slave_cg.get_inst_coverage()), UVM_LOW)
    `uvm_info("COV", $sformatf(
              " master_tx : %6.2f %%", spi_slave_cg.cp_master_tx.get_inst_coverage()), UVM_LOW)
    `uvm_info("COV", $sformatf(" slave_tx : %6.2f %%", spi_slave_cg.cp_slave_tx.get_inst_coverage()
              ), UVM_LOW)
    `uvm_info("COV", "*****************", UVM_LOW);
  endfunction

endclass : spi_slave_coverage
