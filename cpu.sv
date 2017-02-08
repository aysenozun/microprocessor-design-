/*
author: Hanchen Huang
*/

import lc3b_types::*;

module cpu
(
    input clk,

    /* Memory signals */
    input mem_resp,
    output mem_read,
    output mem_write,
    output lc3b_mem_wmask mem_byte_enable,
    
    input lc3b_word mem_rdata,
    output lc3b_word mem_address,
    output lc3b_word mem_wdata
);

/* control to datapath */
logic load_pc;
logic load_ir;
logic load_regfile;
logic load_mar;
logic load_mdr;
logic load_cc;

logic pcmux_sel;
logic storemux_sel;
logic alumux_sel;
logic regfilemux_sel;
logic marmux_sel;
logic mdrmux_sel;
lc3b_aluop aluop;
logic mdrmarmux_sel;
logic sextmux_sel;
logic zextmux_sel;
logic byte_enable_mux_sel;
logic splitdatamux_sel;
index0 MAR0;

logic trappcmux_sel;
logic trapdestmux_sel;
logic trapvecmux_sel;
logic trapaddrmux_sel;

logic sr2mux_sel;
logic addr1mux_sel;
logic addr2mux_sel;
logic leamux_sel;
index4 ir4;
index5 ir5;
index11 ir11;
logic jmpmux_sel;

/* datapath to control */
lc3b_opcode opcode;
logic branch_enable;


/* Instantiate MP 0 top level blocks here */
cpu_datapath cpu_datapath
(
    .clk(clk),

    /* control signals */
    .load_pc(load_pc),
    .load_ir(load_ir),
    .load_regfile(load_regfile),
    .load_mar(load_mar),
    .load_mdr(load_mdr),
    .load_cc(load_cc),

    .pcmux_sel(pcmux_sel),
    .storemux_sel(storemux_sel),
    .alumux_sel(alumux_sel),
    .regfilemux_sel(regfilemux_sel),
    .marmux_sel(marmux_sel),
    .mdrmux_sel(mdrmux_sel),
    .aluop(aluop),
    .mdrmarmux_sel(mdrmarmux_sel),
    .sextmux_sel(sextmux_sel),
    .jmpmux_sel(jmpmux_sel),
    .zextmux_sel(zextmux_sel),
    .byte_enable_mux_sel(byte_enable_mux_sel),
    .splitdatamux_sel(splitdatamux_sel),

    .trappcmux_sel(trappcmux_sel),
    .trapdestmux_sel(trapdestmux_sel),
    .trapvecmux_sel(trapvecmux_sel),
    .trapaddrmux_sel(trapaddrmux_sel),

    .sr2mux_sel(sr2mux_sel),
    .addr1mux_sel(addr1mux_sel),
    .addr2mux_sel(addr2mux_sel),
    .leamux_sel(leamux_sel),
    .ir4(ir4),
    .ir5(ir5),
    .ir11(ir11),


    .opcode(opcode),
    .branch_enable(branch_enable),
    
    /* Memory signals */
    .mem_rdata(mem_rdata),
    .mem_address(mem_address),
    .mem_wdata(mem_wdata)

);

cpu_control cpu_control
(
    .clk(clk),
    /* Datapath */
    .opcode(opcode),
    .branch_enable(branch_enable),

    .MAR0(mem_address[0]),
    .ir11(ir11),
    .ir5(ir5),
    .ir4(ir4),
    .sr2mux_sel(sr2mux_sel),
    .addr1mux_sel(addr1mux_sel),
    .addr2mux_sel(addr2mux_sel),
    .leamux_sel(leamux_sel),

    .load_pc(load_pc),
    .load_ir(load_ir),
    .load_regfile(load_regfile),
    .load_mar(load_mar),
    .load_mdr(load_mdr),
    .load_cc(load_cc),

    .pcmux_sel(pcmux_sel),
    .storemux_sel(storemux_sel),
    .alumux_sel(alumux_sel),
    .regfilemux_sel(regfilemux_sel),
    .marmux_sel(marmux_sel),
    .mdrmux_sel(mdrmux_sel),
    .aluop(aluop),
    .mdrmarmux_sel(mdrmarmux_sel),
    .sextmux_sel(sextmux_sel),
    .jmpmux_sel(jmpmux_sel),
    .zextmux_sel(zextmux_sel),
    .byte_enable_mux_sel(byte_enable_mux_sel),
    .splitdatamux_sel(splitdatamux_sel),

    .trappcmux_sel(trappcmux_sel),
    .trapdestmux_sel(trapdestmux_sel),
    .trapvecmux_sel(trapvecmux_sel),
    .trapaddrmux_sel(trapaddrmux_sel),

    /* Memory signals */
    .mem_resp(mem_resp),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .mem_byte_enable(mem_byte_enable)
);


endmodule : cpu
