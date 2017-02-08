/*
author: Hanchen Huang
*/

import lc3b_types::*;

module cache (
	input clk,

	/* with CPU */
	output mem_resp,
	input mem_read,
	input mem_write,
	input lc3b_mem_wmask mem_byte_enable,
	
	output lc3b_word mem_rdata,
	input lc3b_word mem_address,
	input lc3b_word mem_wdata,

	/* with Memory */
	input pmem_resp,
	output pmem_read,
	output pmem_write,
	
	input lc3b_line pmem_rdata,
	output lc3b_word pmem_address,
	output lc3b_line pmem_wdata
	
);


logic hit;
logic dirty;
logic LRU_out;
logic hit_1;

logic cache_write;
logic cache_choose;
logic LRU_write;
logic data_mux_sel;
logic db_data;
logic pmem_address_mux_sel;

cache_datapath cache_datapath
(
	.clk,

	/* with CPU */
	.mem_rdata,
	.mem_address,
	.mem_wdata,
	.mem_byte_enable,

	.hit,
	.dirty,
	.LRU_out,
	.hit_1,

	.cache_write,
	.cache_choose,
	.LRU_write,
	.data_mux_sel,
	.db_data,
	.pmem_address_mux_sel,

	/* with Memory */	
	.pmem_rdata,
	.pmem_address,
	.pmem_wdata
);


cache_control cache_control
(
	.clk,

	/* with CPU */
	.mem_resp,
	.mem_read,
	.mem_write,
	.mem_byte_enable,

	.hit,
	.dirty,
	.LRU_out,
	.hit_1,

	.cache_write,
	.cache_choose,
	.LRU_write,
	.data_mux_sel,
	.db_data,
	.pmem_address_mux_sel,

	/* with Memory */
	.pmem_resp,
	.pmem_read,
	.pmem_write

);


endmodule : cache



