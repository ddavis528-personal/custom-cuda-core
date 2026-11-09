// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-ops.py from params/ops.json (RI-21 (4)).
// Edit the source and regenerate; tools/verify.sh fails if this file is stale.

`ifndef CCV_OPS_PKG_SV
`define CCV_OPS_PKG_SV

`include "ccv_params_pkg.sv"

// The opcode table's codes and the attributes an RTL module's own decode
// reads per opcode (RI-21 (4)). The table is a catalogue: no module uses
// every code, so the unused-parameter warning is off for this file only.
/* verilator lint_off UNUSEDPARAM */
package ccv_ops_pkg;

  localparam int W_OPCODE = ccv_prelim_pkg::CCV_L_W_OPCODE;  // 9
  localparam int N_OPS = 146;

  // Opcodes: a row's position in params/ops.json + 1; 0 is reserved and
  // ccv_prelim_pkg::CCV_OP_PRF_COPY, the all-ones code, is the copy-only op.
  localparam logic [W_OPCODE-1:0] OP_POR = 9'd1;
  localparam logic [W_OPCODE-1:0] OP_MOVI48 = 9'd2;
  localparam logic [W_OPCODE-1:0] OP_SRD_SEL0 = 9'd3;
  localparam logic [W_OPCODE-1:0] OP_LD_GLOBAL = 9'd4;
  localparam logic [W_OPCODE-1:0] OP_MADLO = 9'd5;
  localparam logic [W_OPCODE-1:0] OP_SETP_LT = 9'd6;
  localparam logic [W_OPCODE-1:0] OP_BRA_PRED = 9'd7;
  localparam logic [W_OPCODE-1:0] OP_LD_GLOBAL_IDX = 9'd8;
  localparam logic [W_OPCODE-1:0] OP_C_ADD = 9'd9;
  localparam logic [W_OPCODE-1:0] OP_ADD_P = 9'd10;
  localparam logic [W_OPCODE-1:0] OP_ST_GLOBAL_IDX = 9'd11;
  localparam logic [W_OPCODE-1:0] OP_SZ_GLOBAL_LD_U8 = 9'd12;
  localparam logic [W_OPCODE-1:0] OP_SZ_GLOBAL_LD_S8 = 9'd13;
  localparam logic [W_OPCODE-1:0] OP_SZ_GLOBAL_LD_U16 = 9'd14;
  localparam logic [W_OPCODE-1:0] OP_SZ_GLOBAL_LD_S16 = 9'd15;
  localparam logic [W_OPCODE-1:0] OP_SZ_GLOBAL_ST_8 = 9'd16;
  localparam logic [W_OPCODE-1:0] OP_SZ_GLOBAL_ST_16 = 9'd17;
  localparam logic [W_OPCODE-1:0] OP_C_EXIT = 9'd18;
  localparam logic [W_OPCODE-1:0] OP_MOVI = 9'd19;
  localparam logic [W_OPCODE-1:0] OP_SEL = 9'd20;
  localparam logic [W_OPCODE-1:0] OP_SRD_SEL1 = 9'd21;
  localparam logic [W_OPCODE-1:0] OP_SRD_SEL2 = 9'd22;
  localparam logic [W_OPCODE-1:0] OP_SRD_SEL3 = 9'd23;
  localparam logic [W_OPCODE-1:0] OP_LD_GLOBAL_P = 9'd24;
  localparam logic [W_OPCODE-1:0] OP_ADD = 9'd25;
  localparam logic [W_OPCODE-1:0] OP_MUL_LO = 9'd26;
  localparam logic [W_OPCODE-1:0] OP_C_MUL_LO = 9'd27;
  localparam logic [W_OPCODE-1:0] OP_C_MOV = 9'd28;
  localparam logic [W_OPCODE-1:0] OP_C_ADDI = 9'd29;
  localparam logic [W_OPCODE-1:0] OP_C_SHLI = 9'd30;
  localparam logic [W_OPCODE-1:0] OP_SHLI = 9'd31;
  localparam logic [W_OPCODE-1:0] OP_ADDI48 = 9'd32;
  localparam logic [W_OPCODE-1:0] OP_C_SHRI = 9'd33;
  localparam logic [W_OPCODE-1:0] OP_MADLO_P = 9'd34;
  localparam logic [W_OPCODE-1:0] OP_SETP_EQ_NP = 9'd35;
  localparam logic [W_OPCODE-1:0] OP_SETP_LE_U_NP = 9'd36;
  localparam logic [W_OPCODE-1:0] OP_SETP_LT_U_NP = 9'd37;
  localparam logic [W_OPCODE-1:0] OP_SETP_LT_NPI = 9'd38;
  localparam logic [W_OPCODE-1:0] OP_C_FMUL = 9'd39;
  localparam logic [W_OPCODE-1:0] OP_FNEG_F0 = 9'd40;
  localparam logic [W_OPCODE-1:0] OP_FFMA_F0 = 9'd41;
  localparam logic [W_OPCODE-1:0] OP_FFMA_ACC_F0 = 9'd42;
  localparam logic [W_OPCODE-1:0] OP_ST_GLOBAL = 9'd43;
  localparam logic [W_OPCODE-1:0] OP_C_BRA = 9'd44;
  localparam logic [W_OPCODE-1:0] OP_PMOV_IMM = 9'd45;
  localparam logic [W_OPCODE-1:0] OP_SHFL_IDX = 9'd46;
  localparam logic [W_OPCODE-1:0] OP_SHFL_IDX_R = 9'd47;
  localparam logic [W_OPCODE-1:0] OP_SHFL_UP = 9'd48;
  localparam logic [W_OPCODE-1:0] OP_SHFL_UP_R = 9'd49;
  localparam logic [W_OPCODE-1:0] OP_SHFL_DOWN = 9'd50;
  localparam logic [W_OPCODE-1:0] OP_SHFL_DOWN_R = 9'd51;
  localparam logic [W_OPCODE-1:0] OP_SHFL_BFLY = 9'd52;
  localparam logic [W_OPCODE-1:0] OP_SHFL_BFLY_R = 9'd53;
  localparam logic [W_OPCODE-1:0] OP_VOTE_ANY = 9'd54;
  localparam logic [W_OPCODE-1:0] OP_VOTE_ALL = 9'd55;
  localparam logic [W_OPCODE-1:0] OP_BALLOT = 9'd56;
  localparam logic [W_OPCODE-1:0] OP_UNBALLOT = 9'd57;
  localparam logic [W_OPCODE-1:0] OP_LD_GLOBAL_SLOT = 9'd58;
  localparam logic [W_OPCODE-1:0] OP_ST_GLOBAL_SLOT = 9'd59;
  localparam logic [W_OPCODE-1:0] OP_LD_PRED_G = 9'd60;
  localparam logic [W_OPCODE-1:0] OP_ST_PRED_G = 9'd61;
  localparam logic [W_OPCODE-1:0] OP_LD_LOCAL = 9'd62;
  localparam logic [W_OPCODE-1:0] OP_ST_LOCAL = 9'd63;
  localparam logic [W_OPCODE-1:0] OP_LD_PRED_LOCAL = 9'd64;
  localparam logic [W_OPCODE-1:0] OP_ST_PRED_LOCAL = 9'd65;
  localparam logic [W_OPCODE-1:0] OP_C_FENCE = 9'd66;
  localparam logic [W_OPCODE-1:0] OP_C_BAR_ARRIVE = 9'd67;
  localparam logic [W_OPCODE-1:0] OP_C_BAR_WAIT = 9'd68;
  localparam logic [W_OPCODE-1:0] OP_ADDI = 9'd69;
  localparam logic [W_OPCODE-1:0] OP_ANDI = 9'd70;
  localparam logic [W_OPCODE-1:0] OP_ORI = 9'd71;
  localparam logic [W_OPCODE-1:0] OP_MULI = 9'd72;
  localparam logic [W_OPCODE-1:0] OP_SHRI = 9'd73;
  localparam logic [W_OPCODE-1:0] OP_SRAI = 9'd74;
  localparam logic [W_OPCODE-1:0] OP_C_ANDI = 9'd75;
  localparam logic [W_OPCODE-1:0] OP_AND = 9'd76;
  localparam logic [W_OPCODE-1:0] OP_ANDN = 9'd77;
  localparam logic [W_OPCODE-1:0] OP_OR = 9'd78;
  localparam logic [W_OPCODE-1:0] OP_XOR = 9'd79;
  localparam logic [W_OPCODE-1:0] OP_SUB = 9'd80;
  localparam logic [W_OPCODE-1:0] OP_MUL_HI_U = 9'd81;
  localparam logic [W_OPCODE-1:0] OP_C_AND = 9'd82;
  localparam logic [W_OPCODE-1:0] OP_C_ANDN = 9'd83;
  localparam logic [W_OPCODE-1:0] OP_C_OR = 9'd84;
  localparam logic [W_OPCODE-1:0] OP_C_XOR = 9'd85;
  localparam logic [W_OPCODE-1:0] OP_C_SUB = 9'd86;
  localparam logic [W_OPCODE-1:0] OP_C_NEG = 9'd87;
  localparam logic [W_OPCODE-1:0] OP_C_NOT = 9'd88;
  localparam logic [W_OPCODE-1:0] OP_MAD_ACC = 9'd89;
  localparam logic [W_OPCODE-1:0] OP_CVT_SEXT = 9'd90;
  localparam logic [W_OPCODE-1:0] OP_ADDI_P = 9'd91;
  localparam logic [W_OPCODE-1:0] OP_MOV_P = 9'd92;
  localparam logic [W_OPCODE-1:0] OP_SETP_LT_NP = 9'd93;
  localparam logic [W_OPCODE-1:0] OP_SETP_NE_NP = 9'd94;
  localparam logic [W_OPCODE-1:0] OP_SETP_EQ_NPI = 9'd95;
  localparam logic [W_OPCODE-1:0] OP_SETP_NE_NPI = 9'd96;
  localparam logic [W_OPCODE-1:0] OP_SETP_LT_U_NPI = 9'd97;
  localparam logic [W_OPCODE-1:0] OP_PAND = 9'd98;
  localparam logic [W_OPCODE-1:0] OP_BRA = 9'd99;
  localparam logic [W_OPCODE-1:0] OP_CALL = 9'd100;
  localparam logic [W_OPCODE-1:0] OP_C_RET = 9'd101;
  localparam logic [W_OPCODE-1:0] OP_C_CHWIDTH = 9'd102;
  localparam logic [W_OPCODE-1:0] OP_CHWIDTH_MULTI = 9'd103;
  localparam logic [W_OPCODE-1:0] OP_LD_SHARED = 9'd104;
  localparam logic [W_OPCODE-1:0] OP_ATOM_ADD_G = 9'd105;
  localparam logic [W_OPCODE-1:0] OP_ATOM_MIN_S_G = 9'd106;
  localparam logic [W_OPCODE-1:0] OP_ATOM_MIN_U_G = 9'd107;
  localparam logic [W_OPCODE-1:0] OP_ATOM_MAX_S_G = 9'd108;
  localparam logic [W_OPCODE-1:0] OP_ATOM_MAX_U_G = 9'd109;
  localparam logic [W_OPCODE-1:0] OP_ATOM_AND_G = 9'd110;
  localparam logic [W_OPCODE-1:0] OP_ATOM_OR_G = 9'd111;
  localparam logic [W_OPCODE-1:0] OP_ATOM_XOR_G = 9'd112;
  localparam logic [W_OPCODE-1:0] OP_ATOM_EXCH_G = 9'd113;
  localparam logic [W_OPCODE-1:0] OP_ATOM_ADD_S = 9'd114;
  localparam logic [W_OPCODE-1:0] OP_ATOM_MIN_S_S = 9'd115;
  localparam logic [W_OPCODE-1:0] OP_ATOM_MIN_U_S = 9'd116;
  localparam logic [W_OPCODE-1:0] OP_ATOM_MAX_S_S = 9'd117;
  localparam logic [W_OPCODE-1:0] OP_ATOM_MAX_U_S = 9'd118;
  localparam logic [W_OPCODE-1:0] OP_ATOM_AND_S = 9'd119;
  localparam logic [W_OPCODE-1:0] OP_ATOM_OR_S = 9'd120;
  localparam logic [W_OPCODE-1:0] OP_ATOM_XOR_S = 9'd121;
  localparam logic [W_OPCODE-1:0] OP_ATOM_EXCH_S = 9'd122;
  localparam logic [W_OPCODE-1:0] OP_ATOM_ADD_F_G = 9'd123;
  localparam logic [W_OPCODE-1:0] OP_ATOM_ADD_F_S = 9'd124;
  localparam logic [W_OPCODE-1:0] OP_CAS_G = 9'd125;
  localparam logic [W_OPCODE-1:0] OP_CAS_S = 9'd126;
  localparam logic [W_OPCODE-1:0] OP_ST_SHARED = 9'd127;
  localparam logic [W_OPCODE-1:0] OP_LD_SHARED_IDX = 9'd128;
  localparam logic [W_OPCODE-1:0] OP_ST_SHARED_IDX = 9'd129;
  localparam logic [W_OPCODE-1:0] OP_C_LD_GLOBAL = 9'd130;
  localparam logic [W_OPCODE-1:0] OP_C_ST_GLOBAL = 9'd131;
  localparam logic [W_OPCODE-1:0] OP_C_ORI = 9'd132;
  localparam logic [W_OPCODE-1:0] OP_SUB_P = 9'd133;
  localparam logic [W_OPCODE-1:0] OP_MUL_HI_U_P = 9'd134;
  localparam logic [W_OPCODE-1:0] OP_OR_P = 9'd135;
  localparam logic [W_OPCODE-1:0] OP_SHLI_P = 9'd136;
  localparam logic [W_OPCODE-1:0] OP_SHRI_P = 9'd137;
  localparam logic [W_OPCODE-1:0] OP_C_FADD = 9'd138;
  localparam logic [W_OPCODE-1:0] OP_FSUB = 9'd139;
  localparam logic [W_OPCODE-1:0] OP_CVT_F32_S32_P = 9'd140;
  localparam logic [W_OPCODE-1:0] OP_RCP_U32 = 9'd141;
  localparam logic [W_OPCODE-1:0] OP_RSQRT_F32 = 9'd142;
  localparam logic [W_OPCODE-1:0] OP_RCP_F32_P = 9'd143;
  localparam logic [W_OPCODE-1:0] OP_PXOR = 9'd144;
  localparam logic [W_OPCODE-1:0] OP_C_RECONV = 9'd145;
  localparam logic [W_OPCODE-1:0] OP_PMOV = 9'd146;

  // uop class (UopClass in sim/skel/stub.h).
  localparam int W_CLS = 4;
  localparam logic [W_CLS-1:0] CLS_ALU = 4'd0;
  localparam logic [W_CLS-1:0] CLS_LOAD = 4'd1;
  localparam logic [W_CLS-1:0] CLS_STORE = 4'd2;
  localparam logic [W_CLS-1:0] CLS_BRANCH = 4'd3;
  localparam logic [W_CLS-1:0] CLS_EXIT = 4'd4;
  localparam logic [W_CLS-1:0] CLS_PRED_LOGIC = 4'd5;
  localparam logic [W_CLS-1:0] CLS_IMM = 4'd6;
  localparam logic [W_CLS-1:0] CLS_FENCE = 4'd7;
  localparam logic [W_CLS-1:0] CLS_BAR_ARRIVE = 4'd8;
  localparam logic [W_CLS-1:0] CLS_BAR_WAIT = 4'd9;
  localparam logic [W_CLS-1:0] CLS_ATOMIC = 4'd10;
  localparam logic [W_CLS-1:0] CLS_NOP = 4'd11;

  // imm_kind (ccv_dec_ooe_uop; immKindOf in sim/skel/stub.h).
  localparam int W_IMM_KIND = 3;
  localparam logic [W_IMM_KIND-1:0] IMM_LITERAL = 3'd0;
  localparam logic [W_IMM_KIND-1:0] IMM_PRED_SRCS = 3'd1;
  localparam logic [W_IMM_KIND-1:0] IMM_WARP_BASE = 3'd2;
  localparam logic [W_IMM_KIND-1:0] IMM_CTAID = 3'd3;
  localparam logic [W_IMM_KIND-1:0] IMM_LANE_CTX = 3'd4;
  localparam logic [W_IMM_KIND-1:0] IMM_PRIV_OFF = 3'd5;
  localparam logic [W_IMM_KIND-1:0] IMM_CALL_LINK = 3'd6;

  localparam int W_SCHED_ATTR = ccv_prelim_pkg::CCV_P_W_SCHED_ATTR;  // 21

  // An opcode's attributes, MSB first. sched_attr is schedAttrOf()'s
  // value (its pair and commit_width bits, which DEC sets per slot, are
  // 0); imm_kind is immKindOf()'s. The rest are OpInfo's fields, cross
  // as cross_lane (cross is a keyword).
  typedef struct packed {
    logic [3:0] cls;
    logic [2:0] nsrc;
    logic gdst;
    logic pread;
    logic pwrite;
    logic guard;
    logic pdata;
    logic cross_lane;
    logic pxfer;
    logic ret;
    logic [1:0] chw;
    logic shared;
    logic [20:0] sched_attr;
    logic [2:0] imm_kind;
  } ccv_op_attr_t;

  // Pure combinational; an opcode outside the table returns zeros.
  function automatic ccv_op_attr_t ccv_op_attr(input logic [W_OPCODE-1:0] opc);
    ccv_op_attr_t a;
    a = '0;
    case (opc)
      OP_POR: a = {4'd5, 3'd0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h15200, 3'd1};
      OP_MOVI48: a = {4'd6, 3'd0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h01400, 3'd0};
      OP_SRD_SEL0: a = {4'd0, 3'd0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd2};
      OP_LD_GLOBAL: a = {4'd1, 3'd1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h0a402, 3'd0};
      OP_MADLO: a = {4'd0, 3'd3, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_SETP_LT: a = {4'd0, 3'd2, 1'b0, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00201, 3'd0};
      OP_BRA_PRED: a = {4'd3, 3'd0, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h01040, 3'd0};
      OP_LD_GLOBAL_IDX: a = {4'd1, 3'd2, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h0a402, 3'd0};
      OP_C_ADD: a = {4'd0, 3'd2, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_ADD_P: a = {4'd0, 3'd2, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_ST_GLOBAL_IDX: a = {4'd2, 3'd3, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h0a083, 3'd0};
      OP_SZ_GLOBAL_LD_U8: a = {4'd1, 3'd2, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h0a402, 3'd0};
      OP_SZ_GLOBAL_LD_S8: a = {4'd1, 3'd2, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h0a402, 3'd0};
      OP_SZ_GLOBAL_LD_U16: a = {4'd1, 3'd2, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h0a402, 3'd0};
      OP_SZ_GLOBAL_LD_S16: a = {4'd1, 3'd2, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h0a402, 3'd0};
      OP_SZ_GLOBAL_ST_8: a = {4'd2, 3'd3, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h0a083, 3'd0};
      OP_SZ_GLOBAL_ST_16: a = {4'd2, 3'd3, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h0a083, 3'd0};
      OP_C_EXIT: a = {4'd4, 3'd0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h01018, 3'd0};
      OP_MOVI: a = {4'd6, 3'd0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h01400, 3'd0};
      OP_SEL: a = {4'd0, 3'd2, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_SRD_SEL1: a = {4'd0, 3'd0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd3};
      OP_SRD_SEL2: a = {4'd0, 3'd0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd4};
      OP_SRD_SEL3: a = {4'd0, 3'd0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd5};
      OP_LD_GLOBAL_P: a = {4'd1, 3'd1, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h0a402, 3'd0};
      OP_ADD: a = {4'd0, 3'd2, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_MUL_LO: a = {4'd0, 3'd2, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_C_MUL_LO: a = {4'd0, 3'd2, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_C_MOV: a = {4'd0, 3'd1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_C_ADDI: a = {4'd0, 3'd1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_C_SHLI: a = {4'd0, 3'd1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_SHLI: a = {4'd0, 3'd1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_ADDI48: a = {4'd0, 3'd1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_C_SHRI: a = {4'd0, 3'd1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_MADLO_P: a = {4'd0, 3'd3, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_SETP_EQ_NP: a = {4'd0, 3'd2, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00201, 3'd0};
      OP_SETP_LE_U_NP: a = {4'd0, 3'd2, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00201, 3'd0};
      OP_SETP_LT_U_NP: a = {4'd0, 3'd2, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00201, 3'd0};
      OP_SETP_LT_NPI: a = {4'd0, 3'd1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00201, 3'd0};
      OP_C_FMUL: a = {4'd0, 3'd2, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h04401, 3'd0};
      OP_FNEG_F0: a = {4'd0, 3'd1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h04401, 3'd0};
      OP_FFMA_F0: a = {4'd0, 3'd3, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h04401, 3'd0};
      OP_FFMA_ACC_F0: a = {4'd0, 3'd3, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h04401, 3'd0};
      OP_ST_GLOBAL: a = {4'd2, 3'd2, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h0a083, 3'd0};
      OP_C_BRA: a = {4'd3, 3'd0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h01040, 3'd0};
      OP_PMOV_IMM: a = {4'd6, 3'd0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h01200, 3'd0};
      OP_SHFL_IDX: a = {4'd0, 3'd1, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 2'd0, 1'b0, 21'h11c05, 3'd0};
      OP_SHFL_IDX_R: a = {4'd0, 3'd2, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 2'd0, 1'b0, 21'h11c05, 3'd0};
      OP_SHFL_UP: a = {4'd0, 3'd1, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 2'd0, 1'b0, 21'h11c05, 3'd0};
      OP_SHFL_UP_R: a = {4'd0, 3'd2, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 2'd0, 1'b0, 21'h11c05, 3'd0};
      OP_SHFL_DOWN: a = {4'd0, 3'd1, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 2'd0, 1'b0, 21'h11c05, 3'd0};
      OP_SHFL_DOWN_R: a = {4'd0, 3'd2, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 2'd0, 1'b0, 21'h11c05, 3'd0};
      OP_SHFL_BFLY: a = {4'd0, 3'd1, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 2'd0, 1'b0, 21'h11c05, 3'd0};
      OP_SHFL_BFLY_R: a = {4'd0, 3'd2, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 2'd0, 1'b0, 21'h11c05, 3'd0};
      OP_VOTE_ANY: a = {4'd0, 3'd0, 1'b0, 1'b1, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 2'd0, 1'b0, 21'h11a05, 3'd1};
      OP_VOTE_ALL: a = {4'd0, 3'd0, 1'b0, 1'b1, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 2'd0, 1'b0, 21'h11a05, 3'd1};
      OP_BALLOT: a = {4'd0, 3'd0, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 2'd0, 1'b0, 21'h11c05, 3'd1};
      OP_UNBALLOT: a = {4'd0, 3'd1, 1'b0, 1'b1, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 2'd0, 1'b0, 21'h11a05, 3'd0};
      OP_LD_GLOBAL_SLOT: a = {4'd1, 3'd1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h0a402, 3'd0};
      OP_ST_GLOBAL_SLOT: a = {4'd2, 3'd2, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h0a083, 3'd0};
      OP_LD_PRED_G: a = {4'd1, 3'd1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 2'd0, 1'b0, 21'h0a202, 3'd0};
      OP_ST_PRED_G: a = {4'd2, 3'd1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 2'd0, 1'b0, 21'h0a083, 3'd0};
      OP_LD_LOCAL: a = {4'd1, 3'd0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h0a402, 3'd0};
      OP_ST_LOCAL: a = {4'd2, 3'd1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h0a083, 3'd0};
      OP_LD_PRED_LOCAL: a = {4'd1, 3'd0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 2'd0, 1'b0, 21'h0a202, 3'd0};
      OP_ST_PRED_LOCAL: a = {4'd2, 3'd0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 2'd0, 1'b0, 21'h0a083, 3'd0};
      OP_C_FENCE: a = {4'd7, 3'd0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h02183, 3'd0};
      OP_C_BAR_ARRIVE: a = {4'd8, 3'd0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h01020, 3'd0};
      OP_C_BAR_WAIT: a = {4'd9, 3'd0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h01010, 3'd0};
      OP_ADDI: a = {4'd0, 3'd1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_ANDI: a = {4'd0, 3'd1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_ORI: a = {4'd0, 3'd1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_MULI: a = {4'd0, 3'd1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_SHRI: a = {4'd0, 3'd1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_SRAI: a = {4'd0, 3'd1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_C_ANDI: a = {4'd0, 3'd1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_AND: a = {4'd0, 3'd2, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_ANDN: a = {4'd0, 3'd2, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_OR: a = {4'd0, 3'd2, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_XOR: a = {4'd0, 3'd2, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_SUB: a = {4'd0, 3'd2, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_MUL_HI_U: a = {4'd0, 3'd2, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_C_AND: a = {4'd0, 3'd2, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_C_ANDN: a = {4'd0, 3'd2, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_C_OR: a = {4'd0, 3'd2, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_C_XOR: a = {4'd0, 3'd2, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_C_SUB: a = {4'd0, 3'd2, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_C_NEG: a = {4'd0, 3'd1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_C_NOT: a = {4'd0, 3'd1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_MAD_ACC: a = {4'd0, 3'd3, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_CVT_SEXT: a = {4'd0, 3'd1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_ADDI_P: a = {4'd0, 3'd1, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_MOV_P: a = {4'd0, 3'd1, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_SETP_LT_NP: a = {4'd0, 3'd2, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00201, 3'd0};
      OP_SETP_NE_NP: a = {4'd0, 3'd2, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00201, 3'd0};
      OP_SETP_EQ_NPI: a = {4'd0, 3'd1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00201, 3'd0};
      OP_SETP_NE_NPI: a = {4'd0, 3'd1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00201, 3'd0};
      OP_SETP_LT_U_NPI: a = {4'd0, 3'd1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00201, 3'd0};
      OP_PAND: a = {4'd5, 3'd0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h15200, 3'd1};
      OP_BRA: a = {4'd3, 3'd0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h01040, 3'd0};
      OP_CALL: a = {4'd3, 3'd0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h01440, 3'd6};
      OP_C_RET: a = {4'd3, 3'd1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 2'd0, 1'b0, 21'h81040, 3'd0};
      OP_C_CHWIDTH: a = {4'd0, 3'd1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd1, 1'b0, 21'h00409, 3'd0};
      OP_CHWIDTH_MULTI: a = {4'd0, 3'd1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd2, 1'b0, 21'h00409, 3'd0};
      OP_LD_SHARED: a = {4'd1, 3'd1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b1, 21'h0a402, 3'd0};
      OP_ATOM_ADD_G: a = {4'd10, 3'd3, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h0a503, 3'd0};
      OP_ATOM_MIN_S_G: a = {4'd10, 3'd3, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h0a503, 3'd0};
      OP_ATOM_MIN_U_G: a = {4'd10, 3'd3, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h0a503, 3'd0};
      OP_ATOM_MAX_S_G: a = {4'd10, 3'd3, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h0a503, 3'd0};
      OP_ATOM_MAX_U_G: a = {4'd10, 3'd3, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h0a503, 3'd0};
      OP_ATOM_AND_G: a = {4'd10, 3'd3, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h0a503, 3'd0};
      OP_ATOM_OR_G: a = {4'd10, 3'd3, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h0a503, 3'd0};
      OP_ATOM_XOR_G: a = {4'd10, 3'd3, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h0a503, 3'd0};
      OP_ATOM_EXCH_G: a = {4'd10, 3'd3, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h0a503, 3'd0};
      OP_ATOM_ADD_S: a = {4'd10, 3'd3, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b1, 21'h0a503, 3'd0};
      OP_ATOM_MIN_S_S: a = {4'd10, 3'd3, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b1, 21'h0a503, 3'd0};
      OP_ATOM_MIN_U_S: a = {4'd10, 3'd3, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b1, 21'h0a503, 3'd0};
      OP_ATOM_MAX_S_S: a = {4'd10, 3'd3, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b1, 21'h0a503, 3'd0};
      OP_ATOM_MAX_U_S: a = {4'd10, 3'd3, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b1, 21'h0a503, 3'd0};
      OP_ATOM_AND_S: a = {4'd10, 3'd3, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b1, 21'h0a503, 3'd0};
      OP_ATOM_OR_S: a = {4'd10, 3'd3, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b1, 21'h0a503, 3'd0};
      OP_ATOM_XOR_S: a = {4'd10, 3'd3, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b1, 21'h0a503, 3'd0};
      OP_ATOM_EXCH_S: a = {4'd10, 3'd3, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b1, 21'h0a503, 3'd0};
      OP_ATOM_ADD_F_G: a = {4'd10, 3'd3, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h0a503, 3'd0};
      OP_ATOM_ADD_F_S: a = {4'd10, 3'd3, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b1, 21'h0a503, 3'd0};
      OP_CAS_G: a = {4'd10, 3'd4, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h0a703, 3'd0};
      OP_CAS_S: a = {4'd10, 3'd4, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b1, 21'h0a703, 3'd0};
      OP_ST_SHARED: a = {4'd2, 3'd2, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b1, 21'h0a083, 3'd0};
      OP_LD_SHARED_IDX: a = {4'd1, 3'd2, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b1, 21'h0a402, 3'd0};
      OP_ST_SHARED_IDX: a = {4'd2, 3'd3, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b1, 21'h0a083, 3'd0};
      OP_C_LD_GLOBAL: a = {4'd1, 3'd1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h0a402, 3'd0};
      OP_C_ST_GLOBAL: a = {4'd2, 3'd2, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h0a083, 3'd0};
      OP_C_ORI: a = {4'd0, 3'd1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_SUB_P: a = {4'd0, 3'd2, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_MUL_HI_U_P: a = {4'd0, 3'd2, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_OR_P: a = {4'd0, 3'd2, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_SHLI_P: a = {4'd0, 3'd1, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_SHRI_P: a = {4'd0, 3'd1, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00401, 3'd0};
      OP_C_FADD: a = {4'd0, 3'd2, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h04401, 3'd0};
      OP_FSUB: a = {4'd0, 3'd2, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h04401, 3'd0};
      OP_CVT_F32_S32_P: a = {4'd0, 3'd1, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h04401, 3'd0};
      OP_RCP_U32: a = {4'd0, 3'd1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h0c401, 3'd0};
      OP_RSQRT_F32: a = {4'd0, 3'd1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h0c401, 3'd0};
      OP_RCP_F32_P: a = {4'd0, 3'd1, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h0c401, 3'd0};
      OP_PXOR: a = {4'd5, 3'd0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h15200, 3'd1};
      OP_C_RECONV: a = {4'd11, 3'd0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h00028, 3'd0};
      OP_PMOV: a = {4'd5, 3'd0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd0, 1'b0, 21'h15200, 3'd1};
      default: a = '0;
    endcase
    return a;
  endfunction

endpackage
/* verilator lint_on UNUSEDPARAM */

`endif  // CCV_OPS_PKG_SV
