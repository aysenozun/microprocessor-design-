/*
author: Hanchen Huang
*/

import lc3b_types::*; /* Import types defined in lc3b_types.sv */


module cache_control (
	input clk,

	/* with CPU */
	output logic mem_resp,
	input mem_read,
	input mem_write,
	input lc3b_mem_wmask mem_byte_enable,

	input hit,
	input dirty,
	input LRU_out,
	input hit_1,

	output logic cache_write,
	output logic cache_choose,
	output logic LRU_write,
	output logic data_mux_sel,
    output logic db_data,
	// output logic miss_write,
	output logic pmem_address_mux_sel,
	
	/* with Memory */
	input pmem_resp,
	output logic pmem_read,
	output logic pmem_write

);


enum int unsigned {
    /* List of states */
    idle,
    write_back,
    read_in,
    read_in2

} state, next_state;


always_comb
begin : state_actions
    /* Default output assignments */
    /* Actions for each state */
    mem_resp = 1'b0;
    cache_write = 1'b0;
    cache_choose = LRU_out;
    LRU_write = 1'b0;
    data_mux_sel = hit_1;
    db_data = 1'b0;
    // miss_write = 1'b0;
    pmem_address_mux_sel = 1'b0;
    
    pmem_read = 1'b0;
    pmem_write = 1'b0;
    
    /* et cetera (see Appendix E) */

    case(state)
    	idle: begin
    		if(mem_read == 1 && hit == 1) begin
    			LRU_write = 1'b1;
    			mem_resp = 1'b1;
    		end
    		else if(mem_write == 1 && hit == 1) begin
                db_data = 1'b1;
    			cache_choose = hit_1;
    			cache_write = 1'b1;
    			LRU_write = 1'b1;
    			mem_resp = 1'b1;
    		end
    		else begin
    		end
    	end

    	write_back: begin
    		data_mux_sel = LRU_out;
			pmem_address_mux_sel = 1'b1;
			pmem_write = 1'b1;

    	end

    	read_in: begin
			pmem_read = 1'b1;
    	end

    	read_in2: begin
            db_data = 1'b0;
    		cache_write = 1'b1;
    		//miss_write = 1'b1;
    	end

        default: /* Do nothing */;

    endcase
end


always_comb
begin : next_state_logic
    /* Next state information and conditions (if any)
     * for transitioning between states */
    next_state = state;
    
    case (state)
    	idle: begin
    		/* read/write miss + clean */
    		if((mem_read == 1 || mem_write == 1) && hit == 0 && dirty == 0 )
    			next_state = read_in;
    		/* read/write miss + dirty */
    		else if((mem_read == 1 || mem_write == 1) && hit == 0 && dirty == 1 )
    			next_state = write_back;
    		else
    			next_state = idle;
    	end

    	write_back: begin
    		if(pmem_resp == 0)
    			next_state = write_back;
    		else
    			next_state = read_in;
    	end

    	read_in: begin
    		if(pmem_resp == 0)
    			next_state = read_in;
    		else
    			next_state = read_in2;
    	end

    	read_in2: begin
    		next_state = idle;
    	end

        default : /* default */;
    endcase

end


always_ff @(posedge clk)
begin: next_state_assignment
    /* Assignment of next state on clock edge */
    state <= next_state;
end

endmodule : cache_control






