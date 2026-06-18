class spi_master_env extends uvm_env;
 `uvm_component_utils(spi_master_env);

	spi_master_agent agt;
	spi_master_scoreboard scb;
	spi_master_coverage cov;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
		agt = spi_master_agent::type_id::create("agt", this);
		scb = spi_master_scoreboard::type_id::create("scb", this);
		cov = spi_master_coverage::type_id::create("cov", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
		agt.mon.ap.connect(scb.imp);
		agt.mon.ap.connect(cov.analysis_export);
  endfunction

endclass
