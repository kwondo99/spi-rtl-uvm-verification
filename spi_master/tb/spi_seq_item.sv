class spi_seq_item extends uvm_sequence_item;
  //external signal
  bit            sclk;
  bit            mosi;
  bit            ss_n;
  bit            miso;
  // internal signal
  rand bit [7:0] tx_data;
  bit      [7:0] rx_data;
  bit            start;
  rand bit       cpol;
  rand bit       cpha;
  rand bit      [7:0] clk_div;
  bit            busy;
  bit            done;

	int 					sclk_edge_cnt;
	bit 					sclk_idle;

  rand bit [7:0] slave_tx_data;
  bit      [7:0] master_tx_data;

  `uvm_object_utils_begin(spi_seq_item)
    `uvm_field_int(sclk, UVM_ALL_ON)
    `uvm_field_int(mosi, UVM_ALL_ON)
    `uvm_field_int(ss_n, UVM_ALL_ON)
    `uvm_field_int(miso, UVM_ALL_ON)
    `uvm_field_int(tx_data, UVM_ALL_ON)
    `uvm_field_int(rx_data, UVM_ALL_ON)
    `uvm_field_int(start, UVM_ALL_ON)
    `uvm_field_int(cpol, UVM_ALL_ON)
    `uvm_field_int(cpha, UVM_ALL_ON)
    `uvm_field_int(clk_div, UVM_ALL_ON)
    `uvm_field_int(busy, UVM_ALL_ON)
    `uvm_field_int(done, UVM_ALL_ON)
    `uvm_field_int(slave_tx_data, UVM_ALL_ON)
    `uvm_field_int(master_tx_data, UVM_ALL_ON)
    `uvm_field_int(sclk_edge_cnt, UVM_ALL_ON)
    `uvm_field_int(sclk_idle, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "spi_seq_item");
    super.new(name);
  endfunction

endclass
