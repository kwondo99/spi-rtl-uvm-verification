class spi_master_agent extends uvm_agent;
  `uvm_component_utils(spi_master_agent);

  spi_master_monitor mon;
  spi_master_driver drv;
  uvm_sequencer #(spi_seq_item) sqr;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon = spi_master_monitor::type_id::create("mon", this);
    drv = spi_master_driver::type_id::create("drv", this);
    sqr = uvm_sequencer#(spi_seq_item)::type_id::create("sqr", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(sqr.seq_item_export);
  endfunction

endclass
