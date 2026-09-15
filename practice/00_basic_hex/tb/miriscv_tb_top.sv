import miriscv_pkg::XLEN;

module miriscv_tb_top();

  // --------------------------------------------------------------------------
  // DUT interface signals
  // --------------------------------------------------------------------------

  // Clock period
  parameter CLK_PERIOD = 10;

  // Clock and reset
  logic              clk;
  logic              arstn;

  // Instruction memory interface
  logic              instr_rvalid;
  logic [XLEN-1:0]   instr_rdata;
  logic              instr_req;
  logic [XLEN-1:0]   instr_addr;

  // Data memory interface
  logic              data_rvalid;
  logic [XLEN-1:0]   data_rdata;
  logic              data_req;
  logic              data_we;
  logic [XLEN/8-1:0] data_be;
  logic [XLEN-1:0]   data_addr;
  logic [XLEN-1:0]   data_wdata;

  // --------------------------------------------------------------------------
  // Main memory model
  // --------------------------------------------------------------------------

  logic [31:0] mem [32];
  logic [31:0] aligned_instr_addr;
  assign aligned_instr_addr = {2'b00, instr_addr [31:2]};

  always_ff @(posedge clk or negedge arstn) begin
    if (!arstn) begin
      instr_rvalid <= 0;
    end else begin
      if (instr_req) begin
        instr_rdata  <= mem[aligned_instr_addr];
        instr_rvalid <= 1;
      end else begin
        instr_rvalid <= 0;
      end
    end
  end

  logic [31:0] aligned_data_addr;
  assign aligned_data_addr = {2'b00, data_addr [31:2]};

  always_ff @(posedge clk or negedge arstn) begin
    if (!arstn) begin
      data_rvalid <= 0;
    end else begin
      if (data_req) begin
        if (data_we) begin
          foreach (data_be[i])
            if (data_be[i])
              mem[aligned_data_addr][8*i+:8] <= data_wdata[8*i+:8];
        end else begin
          data_rdata <= mem[aligned_data_addr];
        end
        data_rvalid <= 1;
      end else begin
        data_rvalid <= 0;
      end
    end
  end

  // --------------------------------------------------------------------------
  // Functions & Tasks
  // --------------------------------------------------------------------------

  function automatic void load_binary_to_mem();
    string bin;
    if (!$value$plusargs("bin=%0h", bin))
      $fatal("You must provide 'bin' via command line!");
    $readmemh(bin, mem);
  endfunction : load_binary_to_mem

  // --------------------------------------------------------------------------
  // Processes
  // --------------------------------------------------------------------------

  initial begin : clock_gen_process
    clk <= 0;
    forever
      #(CLK_PERIOD / 2.0) clk = ~clk;
  end

  initial begin : initial_reset_process
    arstn <= 0;
    repeat(10) @(posedge clk);
    arstn <= 1;
  end

  initial begin : main_process
    string dump;
    if (!$value$plusargs("dump=%s", dump))
      dump = "waves.vcd";
    $dumpfile(dump);
    $dumpvars();
    load_binary_to_mem();
    repeat(100) @(posedge clk);
    $finish();
  end

  // --------------------------------------------------------------------------
  // Instances
  // --------------------------------------------------------------------------

  miriscv_core #(
    .RVFI              (0)
  ) DUT (
     .clk_i            (clk)
    ,.arstn_i          (arstn)
    ,.boot_addr_i      ('b0)
    ,.instr_rvalid_i   (instr_rvalid)
    ,.instr_rdata_i    (instr_rdata)
    ,.instr_req_o      (instr_req)
    ,.instr_addr_o     (instr_addr)
    ,.data_rvalid_i    (data_rvalid)
    ,.data_rdata_i     (data_rdata)
    ,.data_req_o       (data_req)
    ,.data_we_o        (data_we)
    ,.data_be_o        (data_be)
    ,.data_addr_o      (data_addr)
    ,.data_wdata_o     (data_wdata)
  );

endmodule : miriscv_tb_top