/*
author: Hanchen Huang
*/

import lc3b_types::*;

module mp2
(
    input clk,

    /* Memory signals */
    input pmem_resp,
    output pmem_read,
    output pmem_write,
    
    input lc3b_line pmem_rdata,
    output lc3b_word pmem_address,
    output lc3b_line pmem_wdata
);


logic mem_resp;
logic mem_read;
logic mem_write;
lc3b_mem_wmask mem_byte_enable;

lc3b_word mem_rdata;
lc3b_word mem_address;
lc3b_word mem_wdata;

cpu cpu
(
    .clk,

    /* with cache */
    .mem_resp,
    .mem_read,
    .mem_write,
    .mem_byte_enable,
    
    .mem_rdata,
    .mem_address,
    .mem_wdata
);

cache cache
(
    .clk,

    /* with CPU */
    .mem_resp,
    .mem_read,
    .mem_write,
    .mem_byte_enable,
    
    .mem_rdata,
    .mem_address,
    .mem_wdata,

    /* with Memory */
    .pmem_resp,
    .pmem_read,
    .pmem_write,
    
    .pmem_rdata,
    .pmem_address,
    .pmem_wdata
);




endmodule : mp2
