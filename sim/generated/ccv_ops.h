//===-- ccv_ops.h - the skeleton's opcode table ------------*- C++ -*-===//
//
// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-ops.py from params/ops.json (RI-21 (4)).
// Edit the source and regenerate; tools/verify.sh fails if this file is stale.
//
// kOps[]: an opcode is its row's position + 1. Included by
// sim/skel/stub.h where the table stood, inside namespace ccv::skel,
// after struct OpInfo, UopClass and the bypass groups: not a header
// of its own.
//===----------------------------------------------------------------------===//
#ifndef CCV_OPS_H
#define CCV_OPS_H

inline constexpr OpInfo kOps[] = {
  {"POR",             kPredLogic,  0, false, true, true, false, false, -1, -1, -1, -1, -1, -1, -1},  // 1
  {"MOVI48",          kImm,        0, true, false, false, false, false, -1, -1, -1, -1, -1, 0, 0},  // 2
  // srd #0 (%ctatid): the immediate is warp_base, and the lane ORs its index.
  {"SRD",             kAlu,        0, true, false, false, false, false, -1, -1, -1, -1, -1, 0, 0, 0, true},  // 3
  {"LD_GLOBAL",       kLoad,       1, true, false, false, false, false, 0, -1, -1, 0, -1, -1, -1},  // 4
  {"MADLO",           kAlu,        3, true, false, false, false, false, -1, -1, -1, -1, -1, -1, -1},  // 5
  {"SETP_LT",         kAlu,        2, false, true, true, true, false, -1, -1, -1, -1, -1, -1, -1},  // 6
  {"BRA_PRED",        kBranch,     0, false, true, false, true, false, -1, -1, -1, -1, -1, -1, -1},  // 7
  {"LD_GLOBAL_IDX",   kLoad,       2, true, false, false, false, false, 0, 1, -1, 1, 0, -1, -1},  // 8
  {"C_ADD",           kAlu,        2, true, false, false, false, false, -1, -1, -1, -1, -1, -1, -1},  // 9
  // add under a guard (Format Ap): the guard switches lanes off, and they
  // keep the destination's old value, carried as merge_data (A-33, A-44).
  {"ADD_P",           kAlu,        2, true, true, false, true, false, -1, -1, -1, -1, -1, -1, -1},  // 10
  {"ST_GLOBAL_IDX",   kStore,      3, false, false, false, false, false, 1, 2, 0, 1, 0, -1, -1},  // 11
  // O-80's sized forms (DA tab rev 90): the base + index layout, rdata's
  // width untouched; the transfer is the opcode's (xferOf).
  {"SZ_GLOBAL_LD_U8", kLoad,       2, true, false, false, false, false, 0, 1, -1, 1, 0, -1, -1},  // 12
  {"SZ_GLOBAL_LD_S8", kLoad,       2, true, false, false, false, false, 0, 1, -1, 1, 0, -1, -1},  // 13
  {"SZ_GLOBAL_LD_U16", kLoad,       2, true, false, false, false, false, 0, 1, -1, 1, 0, -1, -1},  // 14
  {"SZ_GLOBAL_LD_S16", kLoad,       2, true, false, false, false, false, 0, 1, -1, 1, 0, -1, -1},  // 15
  {"SZ_GLOBAL_ST_8",  kStore,      3, false, false, false, false, false, 1, 2, 0, 1, 0, -1, -1},  // 16
  {"SZ_GLOBAL_ST_16", kStore,      3, false, false, false, false, false, 1, 2, 0, 1, 0, -1, -1},  // 17
  {"C_EXIT",          kExit,       0, false, false, false, false, false, -1, -1, -1, -1, -1, -1, -1},  // 18
  {"MOVI",            kImm,        0, true, false, false, false, false, -1, -1, -1, -1, -1, 0, 0},  // 19
  // sel's qualifier is DATA: every issue-mask lane writes rd, choosing rs0 or
  // rs1 by it. So no enable narrowing, and the predicate rides as pred_data.
  // (Format A always encodes rs2; the sel kernel names R2 for it, which the
  // oracle folds into the rs1 use.)
  {"SEL",             kAlu,        2, true, true, false, false, true, -1, -1, -1, -1, -1, -1, -1},  // 20
  // srd #1 (%ctaid): the immediate is the value; the lane passes it through.
  {"SRD",             kAlu,        0, true, false, false, false, false, -1, -1, -1, -1, -1, 0, 0, 1},  // 21
  // srd #2 (%lanectx, O-64): the immediate is the hardware warp context << 5,
  // the core's index above it; the lane ORs its index, as for #0.
  {"SRD",             kAlu,        0, true, false, false, false, false, -1, -1, -1, -1, -1, 0, 0, 2, true},  // 22
  // srd #3 (%privoff, O-83): the immediate is the private run's offset from
  // local_base in windows, 3 * CCV_LANE_CONTEXTS, the same on every lane,
  // warp and CTA of a device; the lane passes it through, as for #1.
  {"SRD",             kAlu,        0, true, false, false, false, false, -1, -1, -1, -1, -1, 0, 0, 3},  // 23
  // A guarded load (Format Dp): MIU writes the active lanes, and the inactive
  // ones keep their old value through a copy-only op (A-33, A-38).
  {"LD_GLOBAL_P",     kLoad,       1, true, true, false, true, false, 0, -1, -1, 0, -1, -1, -1},  // 24
  // rope's (CP's release kernel, TI-30). The lanes return ccv-sim's results,
  // so a row is the operand shape and where the op runs.
  {"ADD",             kAlu,        2, true, false, false, false, false, -1, -1, -1, -1, -1, -1, -1},  // 25
  {"MUL_LO",          kAlu,        2, true, false, false, false, false, -1, -1, -1, -1, -1, -1, -1},  // 26
  {"C_MUL_LO",        kAlu,        2, true, false, false, false, false, -1, -1, -1, -1, -1, -1, -1},  // 27
  {"C_MOV",           kAlu,        1, true, false, false, false, false, -1, -1, -1, -1, -1, -1, -1},  // 28
  {"C_ADDI",          kAlu,        1, true, false, false, false, false, -1, -1, -1, -1, -1, 0, 1},  // 29
  {"C_SHLI",          kAlu,        1, true, false, false, false, false, -1, -1, -1, -1, -1, 0, 1},  // 30
  // The 32-bit forms with a separate destination (Format A's immediate
  // forms): rd = rs op imm, the immediate in operand slot 1.
  {"SHLI",            kAlu,        1, true, false, false, false, false, -1, -1, -1, -1, -1, 0, 1},  // 31
  {"ADDI48",          kAlu,        1, true, false, false, false, false, -1, -1, -1, -1, -1, 0, 1},  // 32
  {"C_SHRI",          kAlu,        1, true, false, false, false, false, -1, -1, -1, -1, -1, 0, 1},  // 33
  // mad.lo under a guard: as add.p, the guard's off lanes keep the old value.
  {"MADLO_P",         kAlu,        3, true, true, false, true, false, -1, -1, -1, -1, -1, -1, -1},  // 34
  // Format C" compares (O-32): no qualifier, every issue-mask lane written.
  {"SETP_EQ_NP",      kAlu,        2, false, false, true, false, false, -1, -1, -1, -1, -1, -1, -1},  // 35
  {"SETP_LE_U_NP",    kAlu,        2, false, false, true, false, false, -1, -1, -1, -1, -1, -1, -1},  // 36
  {"SETP_LT_U_NP",    kAlu,        2, false, false, true, false, false, -1, -1, -1, -1, -1, -1, -1},  // 37
  {"SETP_LT_NPI",     kAlu,        1, false, false, true, false, false, -1, -1, -1, -1, -1, 0, 1},  // 38
  // FP: integer lanes' timing for now, FP's bypass group (OI-16).
  {"C_FMUL",          kAlu,        2, true, false, false, false, false, -1, -1, -1, -1, -1, -1, -1, -1, false, false, kBypFp},  // 39
  {"FNEG_F0",         kAlu,        1, true, false, false, false, false, -1, -1, -1, -1, -1, -1, -1, -1, false, false, kBypFp},  // 40
  {"FFMA_F0",         kAlu,        3, true, false, false, false, false, -1, -1, -1, -1, -1, -1, -1, -1, false, false, kBypFp},  // 41
  {"FFMA_ACC_F0",     kAlu,        3, true, false, false, false, false, -1, -1, -1, -1, -1, -1, -1, -1, false, false, kBypFp},  // 42
  {"ST_GLOBAL",       kStore,      2, false, false, false, false, false, 1, -1, 0, 0, -1, -1, -1},  // 43
  {"C_BRA",           kBranch,     0, false, false, false, false, false, -1, -1, -1, -1, -1, -1, -1},  // 44
  // pmov.imm: bit n of the immediate is lane n's predicate bit on the issue-
  // mask lanes, the rest kept from the old predicate (RA-19): an immediate
  // RCU writes and merges.
  {"PMOV_IMM",        kImm,        0, false, false, true, false, false, -1, -1, -1, -1, -1, 0, 0},  // 45
  // shfl.idx: each guarded issue lane takes the source register at one lane,
  // active or not (Format G): RCU, which holds every lane's register.
  {"SHFL_IDX",        kAlu,        1, true, true, false, true, false, -1, -1, -1, -1, -1, 0, -1, -1, false, true},  // 46
  // The rest of Format G's collectives (O-85, RA-20; DA tab rev 100, ISA v1.9
  // section 3, CP-76's opcode points). Each acts on its participating lanes,
  // issue mask AND guard, and writes only them. shfl.up/down/bfly read lane l
  // - c, l + c, l ^ c, a source outside 0..31 keeping the lane's own; the _R
  // forms take c per lane from the low 5 bits of the index register
  // ([22:19]), src_arch's second field. vote.any/all and ballot read one
  // predicate, which rides in imm as predicate logic's do (imm_kind 1);
  // unballot is diagonal: lane l's bit l of its own rs.
  {"SHFL_IDX_R",      kAlu,        2, true, true, false, true, false, -1, -1, -1, -1, -1, -1, -1, -1, false, true},  // 47
  {"SHFL_UP",         kAlu,        1, true, true, false, true, false, -1, -1, -1, -1, -1, 0, -1, -1, false, true},  // 48
  {"SHFL_UP_R",       kAlu,        2, true, true, false, true, false, -1, -1, -1, -1, -1, -1, -1, -1, false, true},  // 49
  {"SHFL_DOWN",       kAlu,        1, true, true, false, true, false, -1, -1, -1, -1, -1, 0, -1, -1, false, true},  // 50
  {"SHFL_DOWN_R",     kAlu,        2, true, true, false, true, false, -1, -1, -1, -1, -1, -1, -1, -1, false, true},  // 51
  {"SHFL_BFLY",       kAlu,        1, true, true, false, true, false, -1, -1, -1, -1, -1, 0, -1, -1, false, true},  // 52
  {"SHFL_BFLY_R",     kAlu,        2, true, true, false, true, false, -1, -1, -1, -1, -1, -1, -1, -1, false, true},  // 53
  {"VOTE_ANY",        kAlu,        0, false, true, true, true, false, -1, -1, -1, -1, -1, -1, -1, -1, false, true},  // 54
  {"VOTE_ALL",        kAlu,        0, false, true, true, true, false, -1, -1, -1, -1, -1, -1, -1, -1, false, true},  // 55
  {"BALLOT",          kAlu,        0, true, true, false, true, false, -1, -1, -1, -1, -1, -1, -1, -1, false, true},  // 56
  {"UNBALLOT",        kAlu,        1, false, true, true, true, false, -1, -1, -1, -1, -1, -1, -1, -1, false, true},  // 57
  // The launch-slot forms (O-45; TI-31): [slot, rindex, scale, disp], the
  // window from launch slot `slot`, so no base register (base -1).
  {"LD_GLOBAL_SLOT",  kLoad,       1, true, false, false, false, false, -1, 0, -1, 2, 1, -1, -1, -1, false, false, -1, 0},  // 58
  {"ST_GLOBAL_SLOT",  kStore,      2, false, false, false, false, false, -1, 1, 0, 2, 1, -1, -1, -1, false, false, -1, 0},  // 59
  // Predicate transfers (O-19, O-62, O-63; TI-36): [mask in quals, rbase,
  // disp]. ld.pred writes its predicate; st.pred reads it as data, renamed as
  // sel's selector is (pdata), never as a guard.
  {"LD_PRED_G",       kLoad,       1, false, false, true, false, false, 0, -1, -1, 0, -1, -1, -1, -1, false, false, -1, -1, true},  // 60
  {"ST_PRED_G",       kStore,      1, false, true, false, false, true, 0, -1, -1, 0, -1, -1, -1, -1, false, false, -1, -1, true},  // 61
  // The interleaved local forms (O-69; IS-19): [rdata, b] and [mask in quals,
  // b], no base register; the predicate forms crack as ld.pred's.
  {"LD_LOCAL",        kLoad,       0, true, false, false, false, false, -1, -1, -1, 0, -1, -1, -1, -1, false, false, -1, -1, false, true},  // 62
  {"ST_LOCAL",        kStore,      1, false, false, false, false, false, -1, -1, 0, 0, -1, -1, -1, -1, false, false, -1, -1, false, true},  // 63
  {"LD_PRED_LOCAL",   kLoad,       0, false, false, true, false, false, -1, -1, -1, 0, -1, -1, -1, -1, false, false, -1, -1, true, true},  // 64
  {"ST_PRED_LOCAL",   kStore,      0, false, true, false, false, true, -1, -1, -1, 0, -1, -1, -1, -1, false, false, -1, -1, true, true},  // 65
  // A fence (Format E, IS-11): its immediate is the ordering MIU takes. The
  // barriers (O-27): bar.arrive #id and bar.wait #id, the id their immediate.
  // bar.init and bar.wait.phase have no row yet: no kernel the compiler emits
  // uses them (F-118), and DEC refuses what it cannot decode.
  {"C_FENCE",         kFence,      0, false, false, false, false, false, -1, -1, -1, -1, -1, -1, -1},  // 66
  {"C_BAR_ARRIVE",    kBarArrive,  0, false, false, false, false, false, -1, -1, -1, -1, -1, -1, -1},  // 67
  {"C_BAR_WAIT",      kBarWait,    0, false, false, false, false, false, -1, -1, -1, -1, -1, -1, -1},  // 68
  // CoreMark-derived's (AR-20, AR-24): the integer ALU forms, register and
  // immediate, 32-bit and compressed, as their siblings above.
  {"ADDI",            kAlu,        1, true, false, false, false, false, -1, -1, -1, -1, -1, 0, 1},  // 69
  {"ANDI",            kAlu,        1, true, false, false, false, false, -1, -1, -1, -1, -1, 0, 1},  // 70
  {"ORI",             kAlu,        1, true, false, false, false, false, -1, -1, -1, -1, -1, 0, 1},  // 71
  {"MULI",            kAlu,        1, true, false, false, false, false, -1, -1, -1, -1, -1, 0, 1},  // 72
  {"SHRI",            kAlu,        1, true, false, false, false, false, -1, -1, -1, -1, -1, 0, 1},  // 73
  {"SRAI",            kAlu,        1, true, false, false, false, false, -1, -1, -1, -1, -1, 0, 1},  // 74
  {"C_ANDI",          kAlu,        1, true, false, false, false, false, -1, -1, -1, -1, -1, 0, 1},  // 75
  {"AND",             kAlu,        2, true, false, false, false, false, -1, -1, -1, -1, -1, -1, -1},  // 76
  {"ANDN",            kAlu,        2, true, false, false, false, false, -1, -1, -1, -1, -1, -1, -1},  // 77
  {"OR",              kAlu,        2, true, false, false, false, false, -1, -1, -1, -1, -1, -1, -1},  // 78
  {"XOR",             kAlu,        2, true, false, false, false, false, -1, -1, -1, -1, -1, -1, -1},  // 79
  {"SUB",             kAlu,        2, true, false, false, false, false, -1, -1, -1, -1, -1, -1, -1},  // 80
  {"MUL_HI_U",        kAlu,        2, true, false, false, false, false, -1, -1, -1, -1, -1, -1, -1},  // 81
  {"C_AND",           kAlu,        2, true, false, false, false, false, -1, -1, -1, -1, -1, -1, -1},  // 82
  {"C_ANDN",          kAlu,        2, true, false, false, false, false, -1, -1, -1, -1, -1, -1, -1},  // 83
  {"C_OR",            kAlu,        2, true, false, false, false, false, -1, -1, -1, -1, -1, -1, -1},  // 84
  {"C_XOR",           kAlu,        2, true, false, false, false, false, -1, -1, -1, -1, -1, -1, -1},  // 85
  {"C_SUB",           kAlu,        2, true, false, false, false, false, -1, -1, -1, -1, -1, -1, -1},  // 86
  {"C_NEG",           kAlu,        1, true, false, false, false, false, -1, -1, -1, -1, -1, -1, -1},  // 87
  {"C_NOT",           kAlu,        1, true, false, false, false, false, -1, -1, -1, -1, -1, -1, -1},  // 88
  // mad.acc: rd = rs0 * rs1 + rd, the accumulator its third source.
  {"MAD_ACC",         kAlu,        3, true, false, false, false, false, -1, -1, -1, -1, -1, -1, -1},  // 89
  // cvt.sext reads rs0 only; the 32-bit form's other register fields are
  // listed by ccv-sim but unread.
  {"CVT_SEXT",        kAlu,        1, true, false, false, false, false, -1, -1, -1, -1, -1, -1, -1, -1, false, false, -1, -1, false, false, false, true},  // 90
  // Guarded forms (Format Ap): off lanes keep the old destination (A-33).
  {"ADDI_P",          kAlu,        1, true, true, false, true, false, -1, -1, -1, -1, -1, 0, 1},  // 91
  {"MOV_P",           kAlu,        1, true, true, false, true, false, -1, -1, -1, -1, -1, -1, -1, -1, false, false, -1, -1, false, false, true},  // 92
  // The compares not yet here: Format C" (no qualifier), register and
  // immediate.
  {"SETP_LT_NP",      kAlu,        2, false, false, true, false, false, -1, -1, -1, -1, -1, -1, -1},  // 93
  {"SETP_NE_NP",      kAlu,        2, false, false, true, false, false, -1, -1, -1, -1, -1, -1, -1},  // 94
  {"SETP_EQ_NPI",     kAlu,        1, false, false, true, false, false, -1, -1, -1, -1, -1, 0, 1},  // 95
  {"SETP_NE_NPI",     kAlu,        1, false, false, true, false, false, -1, -1, -1, -1, -1, 0, 1},  // 96
  {"SETP_LT_U_NPI",   kAlu,        1, false, false, true, false, false, -1, -1, -1, -1, -1, 0, 1},  // 97
  {"PAND",            kPredLogic,  0, false, true, true, false, false, -1, -1, -1, -1, -1, -1, -1},  // 98
  // Control flow. bra is c.bra's 32-bit form. call writes its link register
  // (rd, or R14 for call.short) with the next instruction's address, low 32
  // bits (CP-9, AR-22); RCU writes it, as it does movi. ret jumps each lane
  // to {PC[47:32], rs}: the link register is its source (AR-24 (b)).
  {"BRA",             kBranch,     0, false, false, false, false, false, -1, -1, -1, -1, -1, -1, -1},  // 99
  {"CALL",            kBranch,     0, true, false, false, false, false, -1, -1, -1, -1, -1, -1, -1},  // 100
  {"C_RET",           kBranch,     1, false, false, false, false, false, -1, -1, -1, -1, -1, -1, -1, -1, false, false, -1, -1, false, false, false, false, 0, true},  // 101
  // chwidth (O-6): a register's element width, held by rename until it
  // retires. The uop reads the register and writes it: a widening clears the
  // bits it exposes, so the value may change (AR-24 (c)).
  {"C_CHWIDTH",       kAlu,        1, true, false, false, false, false, -1, -1, -1, -1, -1, -1, -1, -1, false, false, -1, -1, false, false, false, false, 1},  // 102
  {"CHWIDTH_MULTI",   kAlu,        1, true, false, false, false, false, -1, -1, -1, -1, -1, -1, -1, -1, false, false, -1, -1, false, false, false, false, 2},  // 103
  // The four-warp corpus's (CP-62, AR-24). .shared, as .global's forms are
  // laid out: [rdata, rbase, disp] and [rdata, rbase, rindex, scale, disp]; a
  // store's data first among its sources.
  {"LD_SHARED",       kLoad,       1, true, false, false, false, false, 0, -1, -1, 0, -1, -1, -1, -1, false, false, -1, -1, false, false, false, false, 0, false, true},  // 104
  // Format M's simple RMW atomics (O-72, O-73; IS-21): rd the old value;
  // sources rbase, rindex, rs in that order (srcRegs reads them from the
  // encoding, since ccv-sim's record folds a repeated register); imms [scale-
  // enable, displacement]. DEC sends each as a pair of decode slots (OI-80
  // (d), DA tab rev 94): the first the address, the second rs and rd.
  {"ATOM_ADD_G",      kAtomic,     3, true, false, false, false, false, 0, 1, 2, 1, 0, -1, -1},  // 105
  {"ATOM_MIN_S_G",    kAtomic,     3, true, false, false, false, false, 0, 1, 2, 1, 0, -1, -1},  // 106
  {"ATOM_MIN_U_G",    kAtomic,     3, true, false, false, false, false, 0, 1, 2, 1, 0, -1, -1},  // 107
  {"ATOM_MAX_S_G",    kAtomic,     3, true, false, false, false, false, 0, 1, 2, 1, 0, -1, -1},  // 108
  {"ATOM_MAX_U_G",    kAtomic,     3, true, false, false, false, false, 0, 1, 2, 1, 0, -1, -1},  // 109
  {"ATOM_AND_G",      kAtomic,     3, true, false, false, false, false, 0, 1, 2, 1, 0, -1, -1},  // 110
  {"ATOM_OR_G",       kAtomic,     3, true, false, false, false, false, 0, 1, 2, 1, 0, -1, -1},  // 111
  {"ATOM_XOR_G",      kAtomic,     3, true, false, false, false, false, 0, 1, 2, 1, 0, -1, -1},  // 112
  {"ATOM_EXCH_G",     kAtomic,     3, true, false, false, false, false, 0, 1, 2, 1, 0, -1, -1},  // 113
  {"ATOM_ADD_S",      kAtomic,     3, true, false, false, false, false, 0, 1, 2, 1, 0, -1, -1, -1, false, false, -1, -1, false, false, false, false, 0, false, true},  // 114
  {"ATOM_MIN_S_S",    kAtomic,     3, true, false, false, false, false, 0, 1, 2, 1, 0, -1, -1, -1, false, false, -1, -1, false, false, false, false, 0, false, true},  // 115
  {"ATOM_MIN_U_S",    kAtomic,     3, true, false, false, false, false, 0, 1, 2, 1, 0, -1, -1, -1, false, false, -1, -1, false, false, false, false, 0, false, true},  // 116
  {"ATOM_MAX_S_S",    kAtomic,     3, true, false, false, false, false, 0, 1, 2, 1, 0, -1, -1, -1, false, false, -1, -1, false, false, false, false, 0, false, true},  // 117
  {"ATOM_MAX_U_S",    kAtomic,     3, true, false, false, false, false, 0, 1, 2, 1, 0, -1, -1, -1, false, false, -1, -1, false, false, false, false, 0, false, true},  // 118
  {"ATOM_AND_S",      kAtomic,     3, true, false, false, false, false, 0, 1, 2, 1, 0, -1, -1, -1, false, false, -1, -1, false, false, false, false, 0, false, true},  // 119
  {"ATOM_OR_S",       kAtomic,     3, true, false, false, false, false, 0, 1, 2, 1, 0, -1, -1, -1, false, false, -1, -1, false, false, false, false, 0, false, true},  // 120
  {"ATOM_XOR_S",      kAtomic,     3, true, false, false, false, false, 0, 1, 2, 1, 0, -1, -1, -1, false, false, -1, -1, false, false, false, false, 0, false, true},  // 121
  {"ATOM_EXCH_S",     kAtomic,     3, true, false, false, false, false, 0, 1, 2, 1, 0, -1, -1, -1, false, false, -1, -1, false, false, false, false, 0, false, true},  // 122
  {"ATOM_ADD_F_G",    kAtomic,     3, true, false, false, false, false, 0, 1, 2, 1, 0, -1, -1},  // 123
  {"ATOM_ADD_F_S",    kAtomic,     3, true, false, false, false, false, 0, 1, 2, 1, 0, -1, -1, -1, false, false, -1, -1, false, false, false, false, 0, false, true},  // 124
  // CAS (Format M', 48 bits; O-72, O-73): rd the old word, pd the success
  // predicate, under the pred qualifier; sources rbase, rindex, rs_cmp,
  // rs_swap (srcRegs reads them from the encoding); imms [scale-enable,
  // displacement]. A pair like the RMW forms (TI-39), the second slot
  // carrying rs_cmp, rs_swap, rd and pd (OI-127, OA rev 380).
  {"CAS_G",           kAtomic,     4, true, true, true, true, false, 0, 1, -1, 1, 0, -1, -1},  // 125
  {"CAS_S",           kAtomic,     4, true, true, true, true, false, 0, 1, -1, 1, 0, -1, -1, -1, false, false, -1, -1, false, false, false, false, 0, false, true},  // 126
  {"ST_SHARED",       kStore,      2, false, false, false, false, false, 1, -1, 0, 0, -1, -1, -1, -1, false, false, -1, -1, false, false, false, false, 0, false, true},  // 127
  {"LD_SHARED_IDX",   kLoad,       2, true, false, false, false, false, 0, 1, -1, 1, 0, -1, -1, -1, false, false, -1, -1, false, false, false, false, 0, false, true},  // 128
  {"ST_SHARED_IDX",   kStore,      3, false, false, false, false, false, 1, 2, 0, 1, 0, -1, -1, -1, false, false, -1, -1, false, false, false, false, 0, false, true},  // 129
  // c.ld.global: [rdata, rbase], no displacement.
  {"C_LD_GLOBAL",     kLoad,       1, true, false, false, false, false, 0, -1, -1, -1, -1, -1, -1},  // 130
  // Its store (Format K, coremark-derived-priv): st.global's row, no
  // displacement.
  {"C_ST_GLOBAL",     kStore,      2, false, false, false, false, false, 1, -1, 0, -1, -1, -1, -1},  // 131
  {"C_ORI",           kAlu,        1, true, false, false, false, false, -1, -1, -1, -1, -1, 0, 1},  // 132
  // Guarded forms, as add.p and mad.lo.p: off lanes keep the destination.
  {"SUB_P",           kAlu,        2, true, true, false, true, false, -1, -1, -1, -1, -1, -1, -1},  // 133
  {"MUL_HI_U_P",      kAlu,        2, true, true, false, true, false, -1, -1, -1, -1, -1, -1, -1},  // 134
  // coremark-derived-priv's guarded forms (CP-63, compiler d9ddd2c): the
  // unguarded op's row with its guard read.
  {"OR_P",            kAlu,        2, true, true, false, true, false, -1, -1, -1, -1, -1, -1, -1},  // 135
  {"SHLI_P",          kAlu,        1, true, true, false, true, false, -1, -1, -1, -1, -1, 0, 1},  // 136
  {"SHRI_P",          kAlu,        1, true, true, false, true, false, -1, -1, -1, -1, -1, 0, 1},  // 137
  // FP and SFU: integer lanes' timing for now, as C_FMUL's (OI-16), in their
  // bypass groups.
  {"C_FADD",          kAlu,        2, true, false, false, false, false, -1, -1, -1, -1, -1, -1, -1, -1, false, false, kBypFp},  // 138
  {"FSUB",            kAlu,        2, true, false, false, false, false, -1, -1, -1, -1, -1, -1, -1, -1, false, false, kBypFp},  // 139
  {"CVT_F32_S32_P",   kAlu,        1, true, true, false, true, false, -1, -1, -1, -1, -1, -1, -1, -1, false, false, kBypFp},  // 140
  {"RCP_U32",         kAlu,        1, true, false, false, false, false, -1, -1, -1, -1, -1, -1, -1, -1, false, false, kBypSfu},  // 141
  {"RSQRT_F32",       kAlu,        1, true, false, false, false, false, -1, -1, -1, -1, -1, -1, -1, -1, false, false, kBypSfu},  // 142
  {"RCP_F32_P",       kAlu,        1, true, true, false, true, false, -1, -1, -1, -1, -1, -1, -1, -1, false, false, kBypSfu},  // 143
  // pxor (ISA v1.9 Format K, opcode 62; RA-16 (f)): PAND's row, RCU-only on
  // R, appended so no opcode moves.
  {"PXOR",            kPredLogic,  0, false, true, true, false, false, -1, -1, -1, -1, -1, -1, -1},  // 144
  // reconv.hint (C_RECONV, FormatKraw 55; RA-16 (f), OA's rev 393): a hint,
  // serial 5 and every other sched_attr bit 0; its 8-bit payload is ignored.
  // Appended so no opcode moves.
  {"C_RECONV",        kNop,        0, false, false, false, false, false, -1, -1, -1, -1, -1, -1, -1},  // 145
  // register pmov (Format K 63; OA's rev 396): predicate logic on R, pd = ps0
  // under its negate, merged on the issue mask; DEC sends ps0 as both
  // sources, so OOE renames it as por pd, ps0, ps0. Executed, never elided.
  // Appended so no opcode moves.
  {"PMOV",            kPredLogic,  0, false, true, true, false, false, -1, -1, -1, -1, -1, -1, -1},  // 146
};

#endif  // CCV_OPS_H
