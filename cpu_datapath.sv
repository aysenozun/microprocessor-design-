/*
author: Hanchen Huang
*/

import lc3b_types::*;

module cpu_datapath
(
    input clk,

    /* control signals */
    input load_pc,
    input load_ir,
    input load_regfile,
    input load_mar,
    input load_mdr,
    input load_cc,

    input pcmux_sel,
    input storemux_sel,
    input alumux_sel,
    input regfilemux_sel,
    input marmux_sel,
    input mdrmux_sel,
    input lc3b_aluop aluop,
    input mdrmarmux_sel,
    input sextmux_sel,
    input jmpmux_sel,
    input zextmux_sel,
    input byte_enable_mux_sel,
    input splitdatamux_sel,

    input trappcmux_sel,
    input trapdestmux_sel,
    input trapvecmux_sel,
    input trapaddrmux_sel,

    input sr2mux_sel,
    input addr1mux_sel,
    input addr2mux_sel,
    input leamux_sel,
    output index4 ir4,
    output index5 ir5,
    output index11 ir11,


    output lc3b_opcode opcode,
    output logic branch_enable,
    
    /* Memory signals */
    input lc3b_word mem_rdata,
    output lc3b_word mem_address,
    output lc3b_word mem_wdata

);

/* declare internal signals */
lc3b_word pcmux_out;
lc3b_word pc_out;
lc3b_word br_add_out;
lc3b_word pc_plus2_out;

/* adj9 */
lc3b_offset9 offset9;
lc3b_word adj9_out;

lc3b_imm5 imm5;
lc3b_word sext5_out;
lc3b_word sr2mux_out;
lc3b_word addr1mux_out;
lc3b_word addr2mux_out;
lc3b_word leamux_out;
lc3b_word sext6_out;
lc3b_word sextmux_out;
lc3b_word jmpmux_out;
lc3b_word adj11_out;
lc3b_word byte_enable_mux_out;
lc3b_word splitdatamux_out;

lc3b_word trappcmux_out;
lc3b_reg trapdestmux_out;
lc3b_vec8 trapvec8;
lc3b_word zext8_shf_out;
lc3b_word trapvecmux_out;
lc3b_word trapaddrmux_out;


/* IR */
lc3b_word zextmux_out;
lc3b_word zext4_out;
lc3b_imm4 imm4;
lc3b_offset11 offset11;
lc3b_offset6 offset6;
lc3b_word adj6_out;
lc3b_reg sr2;
lc3b_reg sr1;
lc3b_reg dest;
lc3b_reg storemux_out;

/* alu */
lc3b_word regfilemux_out;
lc3b_word sr1_out;
lc3b_word sr2_out;
lc3b_word alumux_out;
lc3b_word alu_out;

/* mar mdr */
lc3b_word marmux_out;
lc3b_word mdrmux_out;
lc3b_word mdrmarmux_out;

/* cc */
lc3b_nzp gencc_out;
lc3b_nzp cc_out;

/*
 * PC
 */
mux2 pcmux
(
    .sel(pcmux_sel),
    .a(pc_plus2_out),
    .b(trapaddrmux_out),
    .f(pcmux_out)
);

mux2 trapaddrmux
(
    .sel(trapaddrmux_sel),
    .a(br_add_out),
    .b(mem_wdata),
    .f(trapaddrmux_out)
);

register pc
(
    .clk(clk),
    .load(load_pc),
    .in(pcmux_out),
    .out(pc_out)
);

plus2 pc_plus2
(
    .in(pc_out),
    .out(pc_plus2_out)
);

adder br_add
(
    .a(addr2mux_out),
    .b(addr1mux_out),
    .f(br_add_out)
);

mux2 addr1mux
(
    .sel(addr1mux_sel),
    .a(pc_out),
    .b(jmpmux_out),
    .f(addr1mux_out)
);

mux2 addr2mux
(
    .sel(addr2mux_sel),
    .a(adj9_out),
    .b(16'b0),
    .f(addr2mux_out)
);

adj #(.width(9)) adj9(
    .in(offset9),
    .out(adj9_out)
);

mux2 jmpmux
(
    .sel(jmpmux_sel),
    .a(sr1_out),
    .b(adj11_out),
    .f(jmpmux_out)
);

adj #(.width(11))  adj11(
    .in(offset11),
    .out(adj11_out)
);

ir IR(
    .clk(clk),
    .load(load_ir),
    .in(byte_enable_mux_out),
    .opcode(opcode),
    .dest(dest), .src1(sr1), .src2(sr2),
    .offset6(offset6),
    .offset9(offset9),
    .offset11(offset11),
    .imm4(imm4),
    .imm5(imm5),
    .ir4(ir4),
    .ir5(ir5),
    .ir11(ir11),
    .trapvec8(trapvec8)
);

mux2 #(.width(3)) trapdestmux
(
    .sel(trapdestmux_sel),
    .a(dest),
    .b(3'b111),
    .f(trapdestmux_out)
);

mux2 #(.width(3)) storemux
(
    .sel(storemux_sel),
    .a(sr1),
    .b(dest),
    .f(storemux_out)
);

adj #(.width(6)) adj6(
    .in(offset6),
    .out(adj6_out)
);

mux2 zextmux(
    .sel(zextmux_sel),
    .a(adj6_out),
    .b(zext4_out),
    .f(zextmux_out)
);

zext4 zext4(
    .in(imm4),
    .out(zext4_out)
);


sext #(.width(6)) sext6(
    .in(offset6),
    .out(sext6_out)
);

mux2 sextmux
(
    .sel(sextmux_sel),
    .a(sext5_out),
    .b(sext6_out),
    .f(sextmux_out)
);

sext #(.width(5)) sext5(
    .in(imm5),
    .out(sext5_out)
);

regfile regfile
(
    .clk(clk),
    .load(load_regfile),
    .in(regfilemux_out),
    .src_a(storemux_out), .src_b(sr2), .dest(trapdestmux_out),
    .reg_a(sr1_out), .reg_b(sr2_out)
);

mux2 leamux
(
    .sel(leamux_sel),
    .a(alu_out),
    .b(br_add_out),
    .f(leamux_out)
);

mux2 regfilemux
(
    .sel(regfilemux_sel),
    .a(leamux_out),
    .b(byte_enable_mux_out),
    .f(regfilemux_out)
);

mux2 splitdatamux
(
    .sel(splitdatamux_sel),
    .a( {8'b0, mem_wdata[7:0]} ),
    .b( {8'b0, mem_wdata[15:8]} ),
    .f(splitdatamux_out)
);

mux2 byte_enable_mux
(
    .sel(byte_enable_mux_sel),
    .a(mem_wdata),
    .b(splitdatamux_out),
    .f(byte_enable_mux_out)
);

mux2 sr2mux
(
    .sel(sr2mux_sel),
    .a(sr2_out),
    .b(sextmux_out),
    .f(sr2mux_out)
);

mux2 alumux
(
    .sel(alumux_sel),
    .a(sr2mux_out),
    .b(zextmux_out),
    .f(alumux_out)
);

alu ALU
(
    .aluop(aluop),
    .a(trappcmux_out), .b(alumux_out),
    .f(alu_out)
);

zext8_shf zext8_shf
(
    .in(trapvec8),
    .out(zext8_shf_out)
);

mux2 trapvecmux
(
    .sel(trapvecmux_sel),
    .a(pc_out),
    .b(zext8_shf_out),
    .f(trapvecmux_out)
);

mux2 trappcmux
(
    .sel(trappcmux_sel),
    .a(sr1_out),
    .b(trapvecmux_out),
    .f(trappcmux_out)
);

mux2 marmux
(
    .sel(marmux_sel),
    .a(alu_out),
    .b(pc_out),
    .f(marmux_out)
);

register MAR
(
    .clk(clk),
    .load(load_mar),
    .in(mdrmarmux_out),
    .out(mem_address)
);

mux2 mdrmarmux
(
    .sel(mdrmarmux_sel),
    .a(marmux_out),
    .b(mem_wdata),
    .f(mdrmarmux_out)
);

mux2 mdrmux
(
    .sel(mdrmux_sel),
    .a(alu_out),
    .b(mem_rdata),
    .f(mdrmux_out)
);

register MDR
(
    .clk(clk),
    .load(load_mdr),
    .in(mdrmux_out),
    .out(mem_wdata)
);

gencc gencc
(
    .in(regfilemux_out),
    .out(gencc_out)
);

register #(.width(3)) CC
(
    .clk(clk),
    .load(load_cc),
    .in(gencc_out),
    .out(cc_out)
);

nzp cccomp
(
    .nzp(cc_out),
    .in(dest),
    .f(branch_enable)
);

endmodule : cpu_datapath









