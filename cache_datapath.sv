/*
author: Hanchen Huang
*/

import lc3b_types::*;

module cache_datapath (
	input clk,

	/* with CPU */
	output lc3b_word mem_rdata,
	input lc3b_word mem_address,
	input lc3b_word mem_wdata,
	input lc3b_mem_wmask mem_byte_enable,

	output logic hit,
	output logic dirty,
	output logic LRU_out,
	output logic hit_1,

	input cache_write,
	input cache_choose,
	input LRU_write,
	input data_mux_sel,
	input db_data,
	input pmem_address_mux_sel,
	
	/* with Memory */	
	input lc3b_line pmem_rdata,
	output lc3b_word pmem_address,
	output lc3b_line pmem_wdata
	
);


logic hit_0;
//logic hit_1;
logic db0_out;
logic db1_out;
logic valid0_out;
logic valid1_out;
logic [8:0] tag0_out;
logic [8:0] tag1_out;
logic comp0_out;
logic comp1_out;
logic [127:0] data0_out;
logic [127:0] data1_out;

logic [127:0] data_mux_out;
logic [1:0] cache_choose_decoder_out;
logic cache_write_mux0_out;
logic cache_write_mux1_out;

logic [7:0] split_decoder_out;
logic [15:0] mux2_sel0_out;
logic [15:0] mux2_sel1_out;
logic [15:0] mux2_sel2_out;
logic [15:0] mux2_sel3_out;
logic [15:0] mux2_sel4_out;
logic [15:0] mux2_sel5_out;
logic [15:0] mux2_sel6_out;
logic [15:0] mux2_sel7_out;

logic [127:0] data_in;
logic [127:0] data_in_mux0_out;
logic [127:0] data_in_mux1_out;

logic [8:0] tag_mux_out;
logic valid_mux_out;


always_comb
begin
    hit_0 = valid0_out && comp0_out;
    hit_1 = valid1_out && comp1_out;
    hit = hit_0 || hit_1;
    pmem_wdata = data_mux_out;
    data_in = {mux2_sel7_out, mux2_sel6_out, mux2_sel5_out, mux2_sel4_out, mux2_sel3_out, mux2_sel2_out, mux2_sel1_out, mux2_sel0_out};

end


data_array #(.width(1)) LRU_array
(
	.clk,
	.load(LRU_write),
	.index(mem_address[6:4]),
	.in(~hit_1),
	.out(LRU_out)
);



data_array #(.width(1)) dirty_array0
(
	.clk,
	.load(cache_write_mux0_out),
	.index(mem_address[6:4]),
	.in(db_data),
	.out(db0_out)
);

data_array #(.width(1)) valid_array0
(
	.clk,
	.load(cache_write_mux0_out),
	.index(mem_address[6:4]),
	.in(1'b1),
	.out(valid0_out)
);

data_array #(.width(9)) tag_array0
(
	.clk,
	.load(cache_write_mux0_out),
	.index(mem_address[6:4]),
	.in(mem_address[15:7]),
	.out(tag0_out)
);

comparator #(.width(9)) comp0
(
	.a(mem_address[15:7]),
	.b(tag0_out),
	.f(comp0_out)
);

data_array #(.width(128)) data_array0
(
	.clk,
	.load(cache_write_mux0_out),
	.index(mem_address[6:4]),
	.in(data_in_mux0_out),
	.out(data0_out)
);

mux2 #(.width(128)) data_in_mux0
(
    .sel(~hit),
    .a(data_in),
    .b(pmem_rdata),
    .f(data_in_mux0_out)
);




data_array #(.width(1)) dirty_array1
(
	.clk,
	.load(cache_write_mux1_out),
	.index(mem_address[6:4]),
	.in(db_data),
	.out(db1_out)
);

data_array #(.width(1)) valid_array1
(
	.clk,
	.load(cache_write_mux1_out),
	.index(mem_address[6:4]),
	.in(1'b1),
	.out(valid1_out)
);

data_array #(.width(9)) tag_array1
(
	.clk,
	.load(cache_write_mux1_out),
	.index(mem_address[6:4]),
	.in(mem_address[15:7]),
	.out(tag1_out)
);

comparator #(.width(9)) comp1
(
	.a(mem_address[15:7]),
	.b(tag1_out),
	.f(comp1_out)
);

data_array #(.width(128)) data_array1
(
	.clk,
	.load(cache_write_mux1_out),
	.index(mem_address[6:4]),
	.in(data_in_mux1_out),
	.out(data1_out)
);

mux2 #(.width(128)) data_in_mux1
(
    .sel(~hit),
    .a(data_in),
    .b(pmem_rdata),
    .f(data_in_mux1_out)
);



mux2 #(.width(128)) data_mux
(
    .sel(data_mux_sel),
    .a(data0_out),
    .b(data1_out),
    .f(data_mux_out)
);

split_mux split_mux
(
	.sel(mem_address[3:1]),
	.in(data_mux_out),
	.f(mem_rdata)
);


decoder8 split_decoder
(
	.in(mem_address[3:1]),
	.f(split_decoder_out)
);

mux2_sel mux2_sel0
(
	.sel(split_decoder_out[0]),
	.mem_byte_enable(mem_byte_enable),
	.a(data_mux_out[15:0]),
	.b(mem_wdata),
	.f(mux2_sel0_out)
);
mux2_sel mux2_sel1
(
	.sel(split_decoder_out[1]),
	.mem_byte_enable(mem_byte_enable),
	.a(data_mux_out[31:16]),
	.b(mem_wdata),
	.f(mux2_sel1_out)
);
mux2_sel mux2_sel2
(
	.sel(split_decoder_out[2]),
	.mem_byte_enable(mem_byte_enable),
	.a(data_mux_out[47:32]),
	.b(mem_wdata),
	.f(mux2_sel2_out)
);
mux2_sel mux2_sel3
(
	.sel(split_decoder_out[3]),
	.mem_byte_enable(mem_byte_enable),
	.a(data_mux_out[63:48]),
	.b(mem_wdata),
	.f(mux2_sel3_out)
);
mux2_sel mux2_sel4
(
	.sel(split_decoder_out[4]),
	.mem_byte_enable(mem_byte_enable),
	.a(data_mux_out[79:64]),
	.b(mem_wdata),
	.f(mux2_sel4_out)
);
mux2_sel mux2_sel5
(
	.sel(split_decoder_out[5]),
	.mem_byte_enable(mem_byte_enable),
	.a(data_mux_out[95:80]),
	.b(mem_wdata),
	.f(mux2_sel5_out)
);
mux2_sel mux2_sel6
(
	.sel(split_decoder_out[6]),
	.mem_byte_enable(mem_byte_enable),
	.a(data_mux_out[111:96]),
	.b(mem_wdata),
	.f(mux2_sel6_out)
);
mux2_sel mux2_sel7
(
	.sel(split_decoder_out[7]),
	.mem_byte_enable(mem_byte_enable),
	.a(data_mux_out[127:112]),
	.b(mem_wdata),
	.f(mux2_sel7_out)
);


decoder2 cache_choose_decoder
(
	.in(cache_choose),
	.f(cache_choose_decoder_out)
);

mux2 #(.width(1)) cache_write_mux0
(
    .sel(cache_write),
    .a(1'b0),
    .b(cache_choose_decoder_out[0]),
    .f(cache_write_mux0_out)
);
mux2 #(.width(1)) cache_write_mux1
(
    .sel(cache_write),
    .a(1'b0),
    .b(cache_choose_decoder_out[1]),
    .f(cache_write_mux1_out)
);



mux2 #(.width(1)) dirty_mux
(
    .sel(cache_choose),
    .a(db0_out),
    .b(db1_out),
    .f(dirty)
);
mux2 #(.width(1)) valid_mux
(
    .sel(cache_choose),
    .a(valid0_out),
    .b(valid1_out),
    .f(valid_mux_out)
);
mux2 #(.width(9)) tag_mux
(
    .sel(cache_choose),
    .a(tag0_out),
    .b(tag1_out),
    .f(tag_mux_out)
);

mux2 pmem_address_mux
(
    .sel(pmem_address_mux_sel),
    .a({mem_address[15:4], 4'b0}),
    .b({tag_mux_out, mem_address[6:0]}),
    .f(pmem_address)
);


endmodule : cache_datapath




