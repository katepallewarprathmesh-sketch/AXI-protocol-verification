class axi_base_seq extends uvm_sequence #(axi_transaction);
  `uvm_object_utils(axi_base_seq)

  function new(string name = "axi_base_seq");
    super.new(name);
  endfunction

  protected function axi_transaction create_xact(axi_xact_type_e typ);
    axi_transaction tr = axi_transaction::type_id::create("tr");
    tr.xact_type = typ;
    return tr;
  endfunction

endclass
