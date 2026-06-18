class spi_master_monitor extends uvm_monitor;
  `uvm_component_utils(spi_master_monitor)

  virtual spi_master_interface spi_master_vif;
  uvm_analysis_port #(spi_seq_item) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);
    if (!uvm_config_db#(virtual spi_master_interface)::get(
            this, "", "spi_master_vif", spi_master_vif))
      `uvm_fatal("MON", "get virtual spi_master_vif error from uvm_config_db")
  endfunction

  task run_phase(uvm_phase phase);
    forever collect_transaction();
  endtask

  task collect_transaction();
    spi_seq_item tr;
    bit [7:0] mosi_shift;
    bit [7:0] miso_shift;
    int       sclk_edge_cnt;

    // wait transaction start
    @(negedge spi_master_vif.ss_n);

    tr = spi_seq_item::type_id::create("tr");

    tr.cpol    = spi_master_vif.cpol;
    tr.cpha    = spi_master_vif.cpha;
    tr.clk_div = spi_master_vif.clk_div;
    tr.tx_data = spi_master_vif.tx_data;

    mosi_shift    = 0;
    miso_shift    = 0;
    sclk_edge_cnt = 0;

    for (int i = 0; i < 8; i++) begin
      sample_edge(tr.cpol, tr.cpha);  // select edge 
      mosi_shift = {mosi_shift[6:0], spi_master_vif.mosi};
      miso_shift = {miso_shift[6:0], spi_master_vif.miso};
      sclk_edge_cnt++;
    end

    // wait transaction end
    @(posedge spi_master_vif.ss_n);

    tr.master_tx_data = mosi_shift;        // MOSI 
    tr.rx_data        = spi_master_vif.rx_data;         
    tr.slave_tx_data  = miso_shift;        // MISO 
    tr.sclk_edge_cnt  = sclk_edge_cnt;      
    tr.sclk_idle      = spi_master_vif.sclk; 

    `uvm_info("MON", $sformatf(
        "Collected: mode=%0b%0b tx=0x%02h mosi=0x%02h miso=0x%02h edges=%0d idle=%0b",
        tr.cpol, tr.cpha, tr.tx_data, tr.master_tx_data,
        tr.rx_data, tr.sclk_edge_cnt, tr.sclk_idle), UVM_MEDIUM)

    ap.write(tr);
  endtask

  task sample_edge(bit cpol, bit cpha);
    if (cpha == 1'b0) begin
      if (cpol == 1'b0) @(posedge spi_master_vif.sclk); // Mode 0
      else              @(negedge spi_master_vif.sclk); // Mode 2
    end else begin
      if (cpol == 1'b0) @(negedge spi_master_vif.sclk); // Mode 1
      else              @(posedge spi_master_vif.sclk); // Mode 3
    end
  endtask
endclass
