class miriscv_mem_monitor;

  virtual miriscv_mem_intf vif;

  mailbox#(miriscv_mem_item) mbx;

  function new(virtual miriscv_mem_intf vif);
    this.vif = vif;
  endfunction : new

  virtual task run();
    wait(vif.arst_n === 1'b1);
    forever begin
      vif.wait_clks(1);
      get_and_put();
    end
  endtask : run

  virtual task get_data(miriscv_mem_item t);
    vif.get_bus_status(t);
  endtask : get_data

  virtual task get_and_put();
    miriscv_mem_item t = new();
    get_data(t);
    mbx.put(t);
  endtask : get_and_put
  
endclass : miriscv_mem_monitor
