class spi_slave_env extends uvm_env;
 `uvm_component_utils(spi_slave_env);

	spi_slave_agent agt;
	spi_slave_scoreboard scb;
	spi_slave_coverage cov;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
		agt = spi_slave_agent::type_id::create("agt", this);
		scb = spi_slave_scoreboard::type_id::create("scb", this);
		cov = spi_slave_coverage::type_id::create("cov", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
		agt.mon.ap.connect(scb.imp);
		agt.mon.ap.connect(cov.analysis_export);
  endfunction

endclass
