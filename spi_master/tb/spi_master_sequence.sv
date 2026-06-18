class spi_master_base_seq extends uvm_sequence #(spi_seq_item);
  `uvm_object_utils(spi_master_base_seq)

  function new(string name = "spi_master_base_seq");
    super.new(name);
  endfunction

  task mode(bit con_cpol, bit con_cpha);
    spi_seq_item req;
		req = spi_seq_item::type_id::create("item");
		start_item(req);
		req.randomize() with {cpol == con_cpol; cpha == con_cpha; tx_data == 8'h00; slave_tx_data ==8'h00;};	
		finish_item(req);

		req = spi_seq_item::type_id::create("item");
		start_item(req);
		req.randomize() with {cpol == con_cpol; cpha == con_cpha; tx_data == 8'hff; slave_tx_data ==8'hff;};	
		finish_item(req);
		repeat(100) begin
		req = spi_seq_item::type_id::create("item");
		start_item(req);
		req.randomize() with {cpol == con_cpol; cpha == con_cpha;};	
		finish_item(req);
		end
  endtask

  task body();
    mode(0, 0);
    mode(0, 1);
    mode(1, 0);
    mode(1, 1);
  endtask

endclass
