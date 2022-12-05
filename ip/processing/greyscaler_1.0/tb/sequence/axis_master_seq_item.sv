// axis_master_seq_item.sv
//
// 
class axis_master_seq_item extends uvm_sequence_item;

/*
* DATA FIELDS
*/

    // Required
    rand  bit [(`DATA_WIDTH)-1 :0]  data [$];
    randc int                       clk_count;
    
    // Optional
    randc bit [6:0] id;
    randc bit [3:0] dest;
    rand  bit [5:0] size;
    rand  bit [(`DATA_WIDTH/8)-1 :0] tstrb [$];
    rand  bit [(`DATA_WIDTH/8)-1 :0] tkeep [$];

    // Config
    rand bit sparse_continuous_aligned_en;


/*
* UVM MACROS
*/
    `uvm_object_utils_begin(axis_master_seq_item)
    `uvm_object_utils_end 

/*
* CONSTRAINTS
*/
    //
    constraint range {
        clk_count inside{[1:2]};
    }
    
    //
    constraint q_size {
        data.size  == this.size;
        tstrb.size == this.size;
        tkeep.size == this.size;
    }

    // 
    constraint size_var {
        size inside{[1:10]};
    }

    // 
    constraint order {
        solve size before data;
        solve size before tstrb;
        solve size before tkeep;
        solve sparse_continuous_aligned_en before tstrb;
        solve sparse_continuous_aligned_en before tkeep;
    }

    //
    constraint tkeep_spare_continuous_aligned_stream {
        foreach(tkeep[i]) tkeep[i] == {(`DATA_WIDTH/8) {1'b1}};
    }
    
    //
    constraint tstrb_sparse_continuous_aligned_stream {
        if(sparse_continuous_aligned_en == 1'b1) 
            foreach(tstrb[i]) {tstrb[i] % 2 != 0; tstrb[i] > 1; ^tstrb[i] == 1;}
        else if(sparse_continuous_aligned_en == 1'b0) 
            foreach(tstrb[i]) {tstrb[i] == {(`DATA_WIDTH/8){1'b1}}; }
    }

/*
* CONSTRUCTOR
*/
    function new(string name = "axis_master_seq_item");
        super.new(name);
    endfunction

endclass


