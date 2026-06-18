class spi_master_test extends uvm_test;
  `uvm_component_utils(spi_master_test);

  spi_master_env env;

  function new(string name = "spi_master_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = spi_master_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    spi_master_base_seq seq;
    `uvm_info("TEST TOP", "run_phase started", UVM_MEDIUM)
    phase.raise_objection(this);

    seq = spi_master_base_seq::type_id::create("seq");
    `uvm_info("TEST TOP", $sformatf("seq start"), UVM_MEDIUM)
    seq.start(env.agt.sqr);
    #100;
    phase.drop_objection(this);

  endtask

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction

endclass : spi_master_test
;
