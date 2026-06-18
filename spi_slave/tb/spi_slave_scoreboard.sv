class spi_slave_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(spi_slave_scoreboard);

  uvm_analysis_imp #(spi_seq_item, spi_slave_scoreboard) imp;

  int total, pass_cnt, fail_cnt;
	bit pass;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    imp = new("imp", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    total = 0;
    pass_cnt = 0;
    fail_cnt = 0;
  endfunction

  function write(spi_seq_item tr);
    total++;
    pass = 1'b1;
    if (tr.tx_data == tr.slave_tx_data) begin
      `uvm_info("SCB", $sformatf("PASS tx_data"), UVM_HIGH)
    end else begin
      pass = 1'b0;
      `uvm_error(
          "SCB", $sformatf(
          "tx_data error : expected tx_data = %2h, miso data = %2h", tr.tx_data, tr.slave_tx_data))
    end
    if (tr.rx_data == tr.master_tx_data) begin
      `uvm_info("SCB", $sformatf("PASS rx_data"), UVM_HIGH)
    end else begin
      pass = 1'b0;
      `uvm_error("SCB", $sformatf(
                 "rx_data error : expected rx_data = %2h, slave_rx_data = %2h",
                 tr.master_tx_data,
                 tr.rx_data
                 ))
    end

    if (pass) pass_cnt++;
    else fail_cnt++;
  endfunction

 virtual function void report_phase(uvm_phase phase);
		`uvm_info("SCB", $sformatf("************************"), UVM_LOW)
		`uvm_info("SCB", $sformatf("**** Scoreboard report ****"), UVM_LOW)
		`uvm_info("SCB", $sformatf("**** total : %0d ****", total), UVM_LOW)
		`uvm_info("SCB", $sformatf("**** pass  : %0d ****", pass_cnt), UVM_LOW)
		`uvm_info("SCB", $sformatf("**** fail  : %0d ****", fail_cnt), UVM_LOW)
		`uvm_info("SCB", $sformatf("************************"), UVM_LOW)
	endfunction
endclass
