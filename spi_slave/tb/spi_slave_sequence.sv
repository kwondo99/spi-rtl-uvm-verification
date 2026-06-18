class spi_slave_base_seq extends uvm_sequence #(spi_seq_item);
  `uvm_object_utils(spi_slave_base_seq)

  function new(string name = "spi_slave_base_seq");
    super.new(name);
  endfunction

  task body();
    // 8'h00 test
      spi_seq_item item;
      item = spi_seq_item::type_id::create("item");
      start_item(item);
			item.randomize();
			item.tx_data = 8'h00;
			item.master_tx_data = 8'h00;
			`uvm_info("SEQ", $sformatf("PASS"), UVM_MEDIUM)	
      finish_item(item);

      // 8'hff test
      item = spi_seq_item::type_id::create("item");
      start_item(item);
			item.randomize();
			item.tx_data = 8'hff;
			item.master_tx_data = 8'hff;
			`uvm_info("SEQ", $sformatf("PASS"), UVM_MEDIUM)	
      finish_item(item);

    // randomize test
   	repeat(100) begin 
      item = spi_seq_item::type_id::create("item");
      start_item(item);
			item.randomize();
			`uvm_info("SEQ", $sformatf("PASS"), UVM_MEDIUM)	
      finish_item(item);
    end
  endtask

endclass
