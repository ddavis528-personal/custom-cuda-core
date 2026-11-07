//===-- rcu_mem.sv - RCU memory path: memop operands to MIU ---------------===//
//
// Spec: docs/design-snapshots/rcu-arch-lane-memory.md (live: CCV RCU
//       Architecture, Lane and memory paths tab: Memop operands);
//       docs/design-snapshots/rcu-arch-partition.md (rcu_mem's row, the
//       rcu_miu_addr field groups); docs/payload-spec.md (ccv_rcu_miu_addr).
//
// The P slots P0-P3: slot j's memop has lead pipe j and owns the banks of
// its footprint (pipe k = section k), disjoint between slots. A memop's
// footprint is the union of its operands' sections, so each operand's
// slice lies in banks its memop owns, and bank k's M ports read the rows of
// its owner's operands: M0 the base, M1 the index, M2 the store data. The
// read requests are decoded where the slices are assembled; this module
// takes their data.
//
// COPIES lanes (32 in the block; 4 in the loop unit).
//
// Port timing (local stages, cr01h = A-1, cr02h = A, cr03h = A+1):
//   cr01h  the P slots' issue valid lead and lead_src_used, and the issue
//          wake. Registered.
//   cr02h  A: each slot's payload and op-class decode: a memop (unit Mem,
//          not a continuation), a fence, a predicate store, and which
//          source (0 phys_src[15:8], 1 [7:0], 2 phys_src2, 3 none) is the
//          base, the index and the store data (3 unless a store reads one).
//          addr_v_a[j] at A's edge for every memop, a fence included (RA-21);
//          the operands' positions and widths, the rob_tag and the
//          predicate-store flag into the slot's A+1 flops.
//   cr03h  A+1: the valid on the wire; the banks' M0-M2 reads and
//          rcu_pred's active_a and pst_a. Each operand right-aligned and
//          zero-extended at its position and width (a missing one is 0);
//          a predicate store's data is lane 0 = pst_a, the raw row, and 0
//          on every other lane. Into the payload flops.
//   cr04h  A+2: the payload on the wire (CCV_LAT_RCU_ADDR_BASE = 1: valid
//          a cycle after A, its payload a cycle after that).
//
// Field groups (Partition tab, rcu_miu_addr): rob_tag and active_mask load
// with the valid; the base and the index for every memop but a fence, the
// store data for a store or a predicate store. A group the memop does not
// use holds its value (don't-care on the wire: a fence's operands, a load's
// store data). A missing base or index is not don't-care: MIU adds them, so
// it loads 0, and only when the held value may be non-zero (the same rule
// as the lane bypass selects), which keeps a run of index-less memops from
// clocking the group for nothing.
//
// MIU's lead capture (the load write-back's predecode, about 110 flops a
// slot in the Partition tab) is not here: the bank slices capture their
// MW rows (RI-9 (b)) and rcu_pred its MP rows (RA-40). For RA (RI tab).
//
// The reference is the RCU model (sim/rcu/rcu_core.cpp, issueMem);
// test/rcu/mem_tb.cpp holds this module to a value model of it.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK rcu_core_clk
`define CCV_RST rst_r01h
module rcu_mem #(
  parameter  int COPIES = 32,                                // lanes
  localparam int N  = COPIES,
  localparam int NK = ccv_params_pkg::CCV_SECTIONS,          // P slots, pipes, banks: 4
  localparam int NM = 3,                                     // M0 base, M1 index, M2 data
  localparam int WT = ccv_prov_pkg::CCV_P_W_ROB_TAG
) (
  input  logic                    rcu_core_clk,
  input  logic                    rcu_rst_r00h,
  input  logic                    iw_cr01h,        // ooe_rcu_issue_wake
  // The P slots' lead (A-1).
  input  logic [NK-1:0]           iv_cr01h,        // slot j issues next cycle
  input  logic [NK*3-1:0]         lsrc_cr01h,      // lead_src_used
  // The payload and its op-class decode (A).
  input  logic [NK-1:0]           mem_cr02h,       // class: a memop (unit Mem), not a continuation
  input  logic [NK-1:0]           fen_cr02h,       // class: a fence
  input  logic [NK-1:0]           psk_cr02h,       // class: a predicate store
  input  logic [NK*2-1:0]         bsl_cr02h,       // class: the base's source, 3 none
  input  logic [NK*2-1:0]         xsl_cr02h,       // class: the index's source, 3 none
  input  logic [NK*2-1:0]         dsl_cr02h,       // class: the store data's source, 3 none
  input  logic [NK*NK-1:0]        foot_cr02h,      // footprint
  input  logic [NK*6-1:0]         spos_cr02h,      // src_pos, source i at 2i
  input  logic [NK*6-1:0]         swid_cr02h,      // src_width
  input  logic [NK*WT-1:0]        tag_cr02h,       // rob_tag
  // A+1.
  input  logic [NK*N-1:0]         act_cr03h,       // rcu_pred: active_a, P slot j
  input  logic [NK*N-1:0]         pst_cr03h,       // rcu_pred: pst_a, P slot j's raw guard row
  input  logic [NK*NM*N*8-1:0]    rd_cr03h,        // bank k port Mm lane l: ((k*NM + m)*N + l)*8
  // ccv_rcu_miu_addr, slot j.
  output logic                    mwk_cr02h,       // wake
  output logic [NK-1:0]           mv_cr03h,        // valid
  output logic [NK*WT-1:0]        mtag_cr04h,      // rob_tag
  output logic [NK*N-1:0]         mam_cr04h,       // active_mask
  output logic [NK*N*32-1:0]      mbase_cr04h,     // base_per_lane
  output logic [NK*N*32-1:0]      midx_cr04h,      // index_per_lane
  output logic [NK*N*32-1:0]      msd_cr04h        // store_data
);

  logic rst_r01h;
  always_ff @(posedge rcu_core_clk) begin
    rst_r01h <= rcu_rst_r00h;
  end

  function automatic logic [NK-1:0] secmask(input logic [1:0] w, input logic [1:0] pos);
    logic [NK-1:0] span;
    span = (w == 2'd0) ? NK'(4'b1111) : (w == 2'd1) ? NK'(4'b0011) : NK'(4'b0001);
    secmask = span << pos;
  endfunction

  // ---- A-1: the issue valid, the lead and the wake ----------------------
  // Loaded every cycle: the module's ungated allowance.
  logic [NK-1:0]   v_cr02h;
  logic [NK*3-1:0] lsrc_cr02h;
  logic            wk_cr02h;
  always_ff @(posedge rcu_core_clk) begin
    if (rst_r01h) begin
      v_cr02h  <= '0;
      wk_cr02h <= 1'b0;
    end else begin
      v_cr02h  <= iv_cr01h;
      wk_cr02h <= iw_cr01h;
    end
    lsrc_cr02h <= lsrc_cr01h;
  end
  assign mwk_cr02h = wk_cr02h;

  // ---- A: the valid, and each slot's operand selects --------------------
  // Each operand's position and width, from its source's (a missing one's
  // are don't-care), and whether it is read.
  logic [NK*NM*2-1:0] pos_cr02h, wid_cr02h;
  logic [NK*NM-1:0]   use_cr02h;
  always_comb begin
    for (int j = 0; j < NK; j++)
      for (int m = 0; m < NM; m++) begin
        logic [1:0] sl_cr02h;
        sl_cr02h = m == 0 ? bsl_cr02h[2*j +: 2] : m == 1 ? xsl_cr02h[2*j +: 2] : dsl_cr02h[2*j +: 2];
        use_cr02h[j*NM + m] = sl_cr02h != 2'd3 && !fen_cr02h[j];
        pos_cr02h[(j*NM + m)*2 +: 2] = '0;
        wid_cr02h[(j*NM + m)*2 +: 2] = '0;
        for (int i = 0; i < 3; i++)
          if (sl_cr02h == 2'(i)) begin
            pos_cr02h[(j*NM + m)*2 +: 2] = spos_cr02h[6*j + 2*i +: 2];
            wid_cr02h[(j*NM + m)*2 +: 2] = swid_cr02h[6*j + 2*i +: 2];
          end
      end
  end

  // addr_v_a (ungated: 4 flops).
  always_ff @(posedge rcu_core_clk) begin
    if (rst_r01h) mv_cr03h <= '0;
    else          mv_cr03h <= v_cr02h & mem_cr02h;
  end

  // mem_a1, one group a slot, loaded when the slot issues.
  logic [NK*NM*2-1:0] pos_cr03h, wid_cr03h;
  logic [NK*NM-1:0]   use_cr03h;
  logic [NK-1:0]      fen_cr03h, psk_cr03h;
  logic [NK*WT-1:0]   tag_cr03h;
  for (genvar j = 0; j < NK; j++) begin : g_a1
    wire ma_en_cr02h = v_cr02h[j];
    always_ff @(posedge rcu_core_clk) begin
      if (ma_en_cr02h) begin
        pos_cr03h[j*NM*2 +: NM*2] <= pos_cr02h[j*NM*2 +: NM*2];
        wid_cr03h[j*NM*2 +: NM*2] <= wid_cr02h[j*NM*2 +: NM*2];
        use_cr03h[j*NM +: NM]     <= use_cr02h[j*NM +: NM];
        fen_cr03h[j]              <= fen_cr02h[j];
        psk_cr03h[j]              <= psk_cr02h[j];
        tag_cr03h[j*WT +: WT]     <= tag_cr02h[j*WT +: WT];
      end
    end
  end

  // ---- A+1: assembly ----------------------------------------------------
  // Operand m of slot j, lane l: byte b from bank pos + b while b is within
  // the width, else 0 (right-aligned, zero-extended).
  logic [NK*NM*N*32-1:0] opd_cr03h;
  always_comb begin
    for (int j = 0; j < NK; j++)
      for (int m = 0; m < NM; m++) begin
        logic [1:0] p_cr03h, w_cr03h;
        logic [2:0] nb_cr03h;
        p_cr03h  = pos_cr03h[(j*NM + m)*2 +: 2];
        w_cr03h  = wid_cr03h[(j*NM + m)*2 +: 2];
        nb_cr03h = w_cr03h == 2'd0 ? 3'd4 : w_cr03h == 2'd1 ? 3'd2 : 3'd1;
        for (int l = 0; l < N; l++)
          for (int b = 0; b < 4; b++) begin
            logic [7:0] y_cr03h;
            y_cr03h = '0;
            for (int k = 0; k < NK; k++)
              if (32'(p_cr03h) + 32'(b) == 32'(k)) y_cr03h = rd_cr03h[((k*NM + m)*N + l)*8 +: 8];
            if (3'(b) >= nb_cr03h || !use_cr03h[j*NM + m]) y_cr03h = '0;
            opd_cr03h[((j*NM + m)*N + l)*32 + 8*b +: 8] = y_cr03h;
          end
      end
  end

  // Whether the held base and index may be non-zero: loaded with the group.
  logic [NK-1:0] bnzh_cr04h, xnzh_cr04h;
  for (genvar j = 0; j < NK; j++) begin : g_nz
    wire nz_en_cr03h = mv_cr03h[j] & ~fen_cr03h[j];
    always_ff @(posedge rcu_core_clk) begin
      if (rst_r01h) begin
        bnzh_cr04h[j] <= 1'b0;
        xnzh_cr04h[j] <= 1'b0;
      end else if (nz_en_cr03h) begin
        bnzh_cr04h[j] <= use_cr03h[j*NM + 0];
        xnzh_cr04h[j] <= use_cr03h[j*NM + 1];
      end
    end
  end

  // ---- A+1: the payload flops --------------------------------------------
  for (genvar j = 0; j < NK; j++) begin : g_pay
    wire ct_en_cr03h = mv_cr03h[j];
    always_ff @(posedge rcu_core_clk) begin
      if (ct_en_cr03h) begin
        mtag_cr04h[j*WT +: WT] <= tag_cr03h[j*WT +: WT];
        mam_cr04h[j*N +: N]    <= act_cr03h[j*N +: N];
      end
    end
    wire bs_en_cr03h = mv_cr03h[j] & ~fen_cr03h[j] & (use_cr03h[j*NM + 0] | bnzh_cr04h[j]);
    wire ix_en_cr03h = mv_cr03h[j] & ~fen_cr03h[j] & (use_cr03h[j*NM + 1] | xnzh_cr04h[j]);
    wire sd_en_cr03h = mv_cr03h[j] & (use_cr03h[j*NM + 2] | psk_cr03h[j]);
    for (genvar l = 0; l < N; l++) begin : g_lane
      logic [31:0] sd_cr03h;
      if (l == 0) begin : g_l0
        assign sd_cr03h = psk_cr03h[j] ? 32'(pst_cr03h[j*N +: N]) : opd_cr03h[((j*NM + 2)*N + l)*32 +: 32];
      end else begin : g_ln
        assign sd_cr03h = psk_cr03h[j] ? 32'd0 : opd_cr03h[((j*NM + 2)*N + l)*32 +: 32];
      end
      always_ff @(posedge rcu_core_clk) begin
        if (bs_en_cr03h) mbase_cr04h[(j*N + l)*32 +: 32] <= opd_cr03h[((j*NM + 0)*N + l)*32 +: 32];
      end
      always_ff @(posedge rcu_core_clk) begin
        if (ix_en_cr03h) midx_cr04h[(j*N + l)*32 +: 32] <= opd_cr03h[((j*NM + 1)*N + l)*32 +: 32];
      end
      always_ff @(posedge rcu_core_clk) begin
        if (sd_en_cr03h) msd_cr04h[(j*N + l)*32 +: 32] <= sd_cr03h;
      end
    end
  end

  // ---- Checks -------------------------------------------------------------
  // A source the class reads that the lead did not promise.
  logic [NK-1:0] prm_bad_cr02h;
  always_comb begin
    for (int j = 0; j < NK; j++) begin
      prm_bad_cr02h[j] = 1'b0;
      for (int m = 0; m < NM; m++) begin
        logic [1:0] sl_cr02h;
        sl_cr02h = m == 0 ? bsl_cr02h[2*j +: 2] : m == 1 ? xsl_cr02h[2*j +: 2] : dsl_cr02h[2*j +: 2];
        for (int i = 0; i < 3; i++)
          if (sl_cr02h == 2'(i) && !lsrc_cr02h[3*j + i]) prm_bad_cr02h[j] = 1'b1;
      end
    end
  end
  for (genvar j = 0; j < NK; j++) begin : g_chk
    // A memop issues only on a valid slot, and its operands' sources are
    // ones its lead promised.
    `CCV_ASSERT(mem_valid, !mem_cr02h[j] || v_cr02h[j])
    `CCV_ASSERT(mem_lead_promise, !(v_cr02h[j] && mem_cr02h[j]) || !prm_bad_cr02h[j])
    // The footprint's lowest pipe is the slot, and every operand lies in it.
    `CCV_ASSERT(mem_foot, !(v_cr02h[j] && mem_cr02h[j]) ||
                (foot_cr02h[j*NK + j] && (foot_cr02h[j*NK +: NK] & NK'((1 << j) - 1)) == '0))
    `CCV_ASSERT(mem_operand_owned, !(v_cr02h[j] && mem_cr02h[j]) ||
                ((!use_cr02h[j*NM + 0] || (secmask(wid_cr02h[(j*NM + 0)*2 +: 2], pos_cr02h[(j*NM + 0)*2 +: 2])
                                            & ~foot_cr02h[j*NK +: NK]) == '0) &&
                 (!use_cr02h[j*NM + 1] || (secmask(wid_cr02h[(j*NM + 1)*2 +: 2], pos_cr02h[(j*NM + 1)*2 +: 2])
                                            & ~foot_cr02h[j*NK +: NK]) == '0) &&
                 (!use_cr02h[j*NM + 2] || (secmask(wid_cr02h[(j*NM + 2)*2 +: 2], pos_cr02h[(j*NM + 2)*2 +: 2])
                                            & ~foot_cr02h[j*NK +: NK]) == '0)))
    // A fence reads nothing; a predicate store reads no GPR data.
    `CCV_ASSERT(mem_fence_bare, !(v_cr02h[j] && mem_cr02h[j] && fen_cr02h[j]) ||
                (bsl_cr02h[2*j +: 2] == 2'd3 && xsl_cr02h[2*j +: 2] == 2'd3 && dsl_cr02h[2*j +: 2] == 2'd3
                 && !psk_cr02h[j]))
    `CCV_ASSERT(mem_pstore_data, !(v_cr02h[j] && mem_cr02h[j] && psk_cr02h[j]) || dsl_cr02h[2*j +: 2] == 2'd3)
  end
  // The memops of one cycle own disjoint pipes.
  logic ovl_cr02h;
  always_comb begin
    logic [NK-1:0] seen_cr02h;
    seen_cr02h = '0;
    ovl_cr02h  = 1'b0;
    for (int j = 0; j < NK; j++)
      if (v_cr02h[j] && mem_cr02h[j]) begin
        if ((seen_cr02h & foot_cr02h[j*NK +: NK]) != '0) ovl_cr02h = 1'b1;
        seen_cr02h = seen_cr02h | foot_cr02h[j*NK +: NK];
      end
  end
  `CCV_ASSERT(mem_disjoint, !ovl_cr02h)

endmodule
`undef CCV_CLK
`undef CCV_RST
