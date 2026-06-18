class spi_master_coverage extends uvm_subscriber #(spi_seq_item);
  `uvm_component_utils(spi_master_coverage)

  spi_seq_item tr;

  covergroup spi_master_cg;
    option.per_instance = 1;
    cp_cpol: coverpoint tr.cpol {bins cpol0 = {1'b0}; bins cpol1 = {1'b1};}

    cp_cpha: coverpoint tr.cpha {bins cpha0 = {1'b0}; bins cpha1 = {1'b1};}

    cx_mode: cross cp_cpol, cp_cpha;
    cp_slave_tx: coverpoint tr.slave_tx_data {
      bins zeros = {8'h00}; bins ones = {8'hFF}; bins others[8] = {[8'h01 : 8'hFE]};
    }
    cp_master_tx: coverpoint tr.tx_data {
      bins zeros = {8'h00}; bins ones = {8'hff}; bins others[8] = {[8'h01 : 8'hFE]};
    }

		cx_mode_slave_tx : cross cx_mode, cp_slave_tx;
		cx_mode_master_tx : cross cx_mode, cp_master_tx;
 
		cp_clk_div : coverpoint tr.clk_div{
			bins val[4] = {[0:255]};
		}
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    spi_master_cg = new();
  endfunction

  function void write(spi_seq_item t);
    tr = t;
    `uvm_info("COV", $sformatf(" master_tx : %2h, master_tx : %2h", tr.master_tx_data, tr.tx_data),
              UVM_HIGH)
    spi_master_cg.sample();
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("COV", "*****************", UVM_LOW);
    `uvm_info("COV", "**** Functional Coverage result ****", UVM_LOW);
    `uvm_info("COV", $sformatf(" total : %6.2f %%", spi_master_cg.get_inst_coverage()), UVM_LOW)
    `uvm_info("COV", $sformatf(
              " slave_tx : %6.2f %%", spi_master_cg.cx_mode_slave_tx.get_inst_coverage()), UVM_LOW)
    `uvm_info("COV", $sformatf(
              " master_tx : %6.2f %%", spi_master_cg.cx_mode_master_tx.get_inst_coverage()), UVM_LOW)
    `uvm_info("COV", $sformatf(
              " clk_div : %6.2f %%", spi_master_cg.cp_clk_div.get_inst_coverage()), UVM_LOW)
    `uvm_info("COV", "*****************", UVM_LOW);
  endfunction

endclass : spi_master_coverage
