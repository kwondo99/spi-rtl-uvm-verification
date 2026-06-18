class spi_master_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(spi_master_scoreboard)

  uvm_analysis_imp #(spi_seq_item, spi_master_scoreboard) imp;

  int unsigned total, passed, failed;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp = new("imp", this);
  endfunction

  function void write(spi_seq_item tr);
    bit pass = 1'b1;
    bit [7:0] exp_idle;

    total++;

    //  MOSI tx_data 
    if (tr.master_tx_data !== tr.tx_data) begin
      pass = 1'b0;
      `uvm_error("SCB", $sformatf(
          "MOSI mismatch: tx_data=0x%02h, observed MOSI=0x%02h",
          tr.tx_data, tr.master_tx_data))
    end

    // MISO rx_data
    if (tr.rx_data !== tr.slave_tx_data) begin
      pass = 1'b0;
      `uvm_error("SCB", $sformatf(
          "MISO/rx_data mismatch: slave_tx=0x%02h, observed MISO/rx=0x%02h",
          tr.slave_tx_data, tr.rx_data))
    end

    // check sclk_edge_cnt
    if (tr.sclk_edge_cnt != 8) begin
      pass = 1'b0;
      `uvm_error("SCB", $sformatf(
          "SCLK edge count error: expected 8, got %0d", tr.sclk_edge_cnt))
    end
    // check idle sclk
    exp_idle = tr.cpol;  // CPOL=0 -> idle low, CPOL=1 -> idle high
    if (tr.sclk_idle !== exp_idle[0]) begin
      pass = 1'b0;
      `uvm_error("SCB", $sformatf(
          "SCLK idle level error: cpol=%0b expected idle=%0b, got=%0b",
          tr.cpol, exp_idle[0], tr.sclk_idle))
    end

    if (pass) begin
      passed++;
      `uvm_info("SCB", $sformatf(
          "PASS: mode=%0b%0b tx=0x%02h rx=0x%02h",
          tr.cpol, tr.cpha, tr.tx_data, tr.rx_data), UVM_MEDIUM)
    end else begin
      failed++;
    end
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("SCB", $sformatf("**** Scoreboard report ****"), UVM_LOW)
		`uvm_info("SCB", $sformatf("**** Total : %0d ****", total), UVM_LOW)
		`uvm_info("SCB", $sformatf("**** PASS : %0d ****", passed), UVM_LOW)
		`uvm_info("SCB", $sformatf("**** FAIL : %0d ****", failed), UVM_LOW)
    if (failed != 0)
      `uvm_error("SCB", $sformatf("%0d transaction(s) FAILED", failed))
  endfunction
endclass
