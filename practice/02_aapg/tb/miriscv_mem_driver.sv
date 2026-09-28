class miriscv_mem_driver;

  virtual miriscv_mem_intf vif;

  mailbox #(miriscv_mem_item) mbx;

  function new(virtual miriscv_mem_intf vif);
    this.vif = vif;
  endfunction : new

  virtual task run();
    wait (vif.arst_n === 1'b0);
    reset();
    wait (vif.arst_n === 1'b1);
    forever begin
      vif.wait_clks(1);
      get_and_drive();
    end
  endtask : run

  virtual task reset();
    vif.instr_rvalid <= 'b0;
    vif.instr_rdata  <= 'b0;
    vif.data_rvalid  <= 'b0;
    vif.data_rdata   <= 'b0;
  endtask : reset

  virtual task get_and_drive();
    miriscv_mem_item t;
    mbx.get(t);
    drive_data(t);
  endtask : get_and_drive

  virtual task drive_data(miriscv_mem_item t);
    vif.instr_rvalid <= t.instr_rvalid;
    vif.instr_rdata  <= t.instr_rdata;
    vif.data_rvalid  <= t.data_rvalid;
    vif.data_rdata   <= t.data_rdata;
  endtask : drive_data
  
endclass : miriscv_mem_driver
