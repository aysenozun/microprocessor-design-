/*
author: Hanchen Huang
*/

import lc3b_types::*; /* Import types defined in lc3b_types.sv */

module cpu_control
(
    /* Input and output port declarations */
    input clk,
    /* Datapath controls */
    input lc3b_opcode opcode,
    input branch_enable,

    input index0 MAR0,
    input index11 ir11,
    input index5 ir5,
    input index4 ir4,
    output logic sr2mux_sel,
    output logic addr1mux_sel,
    output logic addr2mux_sel,
    output logic leamux_sel,

    output logic load_pc,
    output logic load_ir,
    output logic load_regfile,
    output logic load_mar,
    output logic load_mdr,
    output logic load_cc,
    
    /* et cetera */
    output logic pcmux_sel,
    output logic storemux_sel,
    output logic alumux_sel,
    output logic regfilemux_sel,
    output logic marmux_sel,
    output logic mdrmux_sel,
    output lc3b_aluop aluop,
    output logic mdrmarmux_sel,
    output logic sextmux_sel,
    output logic jmpmux_sel,
    output logic zextmux_sel,
    output logic byte_enable_mux_sel,
    output logic splitdatamux_sel,

    output logic trappcmux_sel,
    output logic trapdestmux_sel,
    output logic trapvecmux_sel,
    output logic trapaddrmux_sel,

    /* Memory signals */
    input mem_resp,
    output logic mem_read,
    output logic mem_write,
    output lc3b_mem_wmask mem_byte_enable
);

enum int unsigned {
    /* List of states */
    fetch1,
    fetch2,
    fetch3,
    decode,
    s_add,
    s_and,
    s_not,
    s_br,
    br_taken,
    calc_addr,
    ldr1,
    ldr2,
    str1,
    str2,
    s_jmp,
    s_lea,
    ldi1,
    ldi2,
    sti1,
    sti2,
    jsr,
    shf,
    calc_addressb,
    ldb,
    stb,
    trap1,
    trap2,
    trap3

} state, next_state;

always_comb
begin : state_actions
    /* Default output assignments */
    /* Actions for each state */
    load_pc = 1'b0;
    load_ir = 1'b0;
    load_regfile = 1'b0;
    load_mar = 1'b0;
    load_mdr = 1'b0;
    load_cc = 1'b0;
    
    pcmux_sel = 1'b0;
    storemux_sel = 1'b0;
    alumux_sel = 1'b0;
    regfilemux_sel = 1'b0;
    marmux_sel = 1'b0;
    mdrmux_sel = 1'b0;
    sr2mux_sel = 1'b0;
    addr1mux_sel = 1'b0;
    addr2mux_sel = 1'b0;
    leamux_sel = 1'b0;
    mdrmarmux_sel = 1'b0;
    sextmux_sel = 1'b0;
    jmpmux_sel = 1'b0;
    zextmux_sel = 1'b0;
    byte_enable_mux_sel = 1'b0;
    splitdatamux_sel = 1'b0;

    trappcmux_sel = 1'b0;
    trapdestmux_sel = 1'b0;
    trapvecmux_sel = 1'b0;
    trapaddrmux_sel = 1'b0;

    aluop = alu_add;
    mem_read = 1'b0;
    mem_write = 1'b0;
    mem_byte_enable = 2'b11;
    /* et cetera (see Appendix E) */

    case(state)
        fetch1: begin
            /* MAR <= PC */
            marmux_sel = 1;
            load_mar = 1;
            /* PC <= PC + 2 */
            pcmux_sel = 0;
            load_pc = 1;
        end

        fetch2: begin
            /* Read memory */
            mdrmux_sel = 1;
            load_mdr = 1;
            mem_read = 1;
        end

        fetch3: begin
            /* Load IR */
            load_ir = 1;
        end

        decode: /* Do nothing */;

        s_add: begin
            /* DR <= SRA + SRB */
            sr2mux_sel = ir5;
            aluop = alu_add;
            load_regfile = 1;
            //regfilemux_sel = 0;
            load_cc = 1;
        end

        s_and: begin
            sr2mux_sel = ir5;
            aluop = alu_and;
            load_regfile = 1;
            load_cc = 1;
        end

        s_not: begin
            aluop = alu_not;
            load_regfile = 1;
            load_cc = 1;
        end

        s_br: /* Do nothing */;

        br_taken: begin
            pcmux_sel = 1;
            load_pc = 1;
        end

        calc_addr: begin
            alumux_sel = 1;
            aluop = alu_add;
            load_mar = 1;
        end

        ldr1: begin
            mdrmux_sel = 1;
            load_mdr = 1;
            mem_read = 1;
        end

        ldr2: begin
            regfilemux_sel = 1;
            load_regfile = 1;
            load_cc = 1;
        end

        str1: begin
          storemux_sel = 1;
          aluop = alu_pass;
          load_mdr = 1;
        end

        str2: begin
            mem_write = 1;
        end

        s_jmp: begin
            addr1mux_sel = 1;
            addr2mux_sel = 1;
            pcmux_sel = 1;
            load_pc = 1;
        end

        s_lea: begin
            leamux_sel = 1;
            load_regfile = 1;
            load_cc = 1;
        end

        /* MAR <- MDR */
        ldi1: begin
            mdrmarmux_sel = 1;
            load_mar = 1;
        end

        /* MDR <- M[MAR] same as ldr1*/
        ldi2: begin
            mdrmux_sel = 1;
            load_mdr = 1;
            mem_read = 1;
        end

        /* MDR <- M[MAR] same as ldr1*/
        sti1: begin
            mdrmux_sel = 1;
            load_mdr = 1;
            mem_read = 1;
        end

        /* MAR <- MDR */
        sti2: begin
            mdrmarmux_sel = 1;
            load_mar = 1;
        end

        jsr: begin
            /* R7 <- PC */
            trappcmux_sel = 1;
            aluop = alu_pass;
            trapdestmux_sel = 1;
            load_regfile = 1;

            jmpmux_sel = ir11;
            addr1mux_sel = 1;
            addr2mux_sel = 1;
            pcmux_sel = 1;
            load_pc = 1;
        end

        shf: begin
            zextmux_sel = 1;
            alumux_sel = 1;

            if(ir4 == 0)
                aluop = alu_sll;
            else if(ir5 == 0)
                aluop = alu_srl;
            else
                aluop = alu_sra;

            load_regfile = 1;
            load_cc = 1;
        end

        /* MAR <- A + SEXT(IR[5:0]) */
        calc_addressb: begin
            sextmux_sel = 1;
            sr2mux_sel = 1;
            aluop = alu_add;
            load_mar = 1;
        end

        /* DR <- choose Byte from MDR  */
        ldb: begin
            if(MAR0 == 0)
                splitdatamux_sel = 0;
            else
                splitdatamux_sel = 1;
            byte_enable_mux_sel = 1;
            regfilemux_sel = 1;
            load_regfile = 1;
            load_cc = 1;
        end

        /* choose Byte from M[MAR] <- MDR */
        stb: begin
            // 
            if(MAR0 == 0)
                mem_byte_enable = 2'b01;
            else
                mem_byte_enable = 2'b10;
            mem_write = 1;
        end

        trap1: begin
            /* MAR <- ZEXT(vect8) << 1 */
            trapvecmux_sel = 1;
            trappcmux_sel = 1;
            aluop = alu_pass;
            load_mar = 1;
        end
        trap2: begin
            /* MDR <- M[MAR] */
            mdrmux_sel = 1;
            load_mdr = 1;
            mem_read = 1;
            /* R7 <- PC*/
            trapdestmux_sel = 1;
            trappcmux_sel = 1;
            aluop = alu_pass;
            load_regfile = 1;
        end
        trap3: begin
            /* PC <- MDR */
            trapaddrmux_sel = 1;
            pcmux_sel = 1;
            load_pc = 1;
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
        fetch1: next_state = fetch2;
        fetch2:begin
            if(mem_resp == 0)
                next_state = fetch2;
            else
                next_state = fetch3;
        end 
        fetch3: next_state = decode;
        decode: begin
            case (opcode)
                op_add: next_state = s_add;
                op_and: next_state = s_and;
                op_not: next_state = s_not;
                op_br:  next_state = s_br;
                op_ldr: next_state = calc_addr;
                op_str: next_state = calc_addr;
                op_jmp: next_state = s_jmp;
                op_lea: next_state = s_lea;
                op_ldi: next_state = calc_addr;
                op_sti: next_state = calc_addr;
                op_jsr: next_state = jsr;
                op_shf: next_state = shf;
                op_ldb: next_state = calc_addressb;
                op_stb: next_state = calc_addressb;
                op_trap: next_state = trap1;
                default : /* default */;
            endcase
        end
            
        s_add:  next_state = fetch1;
        s_and:  next_state = fetch1;
        s_not:  next_state = fetch1;

        s_br: begin
            if(branch_enable == 1)
                next_state = br_taken;
            else
                next_state = fetch1;
        end
        br_taken:
           next_state = fetch1;

        calc_addr: begin
            if(opcode == op_ldr || opcode == op_ldi)
                next_state = ldr1;
            else if(opcode == op_sti)
                next_state = sti1;
            else
                next_state = str1;
        end

        ldr1:begin
            if(mem_resp == 0)
                next_state = ldr1;
            else if(opcode == op_ldi)
                next_state = ldi1;
            else if(opcode == op_ldb)
                next_state = ldb;
            else
                next_state = ldr2;
        end
        ldr2:
            next_state = fetch1;

        str1: begin
            if(opcode == op_stb)
                next_state = stb;
            else
                next_state = str2;
        end
            

        str2:begin
            if(mem_resp == 0)
                next_state = str2;
            else
                next_state = fetch1;
        end

        s_jmp: begin
            next_state = fetch1;
        end

        s_lea: begin
            next_state = fetch1;
        end


        ldi1: begin
            next_state = ldi2;
        end
        ldi2: begin
            if(mem_resp == 0)
                next_state = ldi2;
            else
                next_state = ldr2;
        end

        sti1: begin
            if(mem_resp == 0)
                next_state = sti1;
            else
                next_state = sti2;
        end
        sti2: begin
            next_state = str1;
        end

        jsr: begin
            next_state = fetch1;
        end

        shf: begin
            next_state = fetch1;
        end

        calc_addressb: begin
            if(opcode == op_ldb)             
                next_state = ldr1;
            else
                next_state = str1;
        end

        ldb: begin
            next_state = fetch1;
        end

        stb: begin
        if(mem_resp == 0)
            next_state = stb;
        else
            next_state = fetch1;
        end

        trap1: begin
            next_state = trap2;
        end

        trap2: begin
        if(mem_resp == 0)
            next_state = trap2;
        else
            next_state = trap3;
        end

        trap3: begin
            next_state = fetch1;
        end

        default : /* default */;
    endcase

end

always_ff @(posedge clk)
begin: next_state_assignment
    /* Assignment of next state on clock edge */
    state <= next_state;
end

endmodule : cpu_control
