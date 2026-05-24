class axi_write_read_seq extends axi_base_seq;
  `uvm_object_utils(axi_write_read_seq)

  rand logic [AXI_ADDR_WIDTH-1:0] addr;
  rand logic [AXI_DATA_WIDTH-1:0] data;
  rand int unsigned num_pairs;

  constraint c_pairs { num_pairs inside {[1:8]}; }
  constraint c_addr  { addr[1:0] == 2'b00; addr < AXI_MEM_SIZE - 64; }

  function new(string name = "axi_write_read_seq");
    super.new(name);
  endfunction

  task body();
    for (int i = 0; i < num_pairs; i++) begin
      axi_single_write_seq wr;
      axi_single_read_seq  rd;
      logic [AXI_ADDR_WIDTH-1:0] a = addr + i * 4;
      wr = axi_single_write_seq::type_id::create($sformatf("wr_%0d", i));
      rd = axi_single_read_seq::type_id::create($sformatf("rd_%0d", i));
      wr.addr = a;
      wr.data = data + i;
      wr.id   = i[AXI_ID_WIDTH-1:0];
      rd.addr = a;
      rd.id   = wr.id;
      wr.start(m_sequencer);
      rd.start(m_sequencer);
    end
  endtask

endclass
