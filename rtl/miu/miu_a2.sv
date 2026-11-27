//===-- miu_a2.sv - MIU A2: the leaders' L0 lookup, PA, drop and no-hit ----===//
//
// Spec: CCV per-block architecture specs, MIU tab (MA's Phase 2, slice 1:
//       the stage table's H+1 row, the module partition's miu_a2 row, "The
//       drop", "Translation"), MA rev 199 (re:MI-31): the fixed leader and
//       an L0 of 6 entries per lookup slot at A2 (MA rev 206).
//
// A2 (H+1, tag 06) for each lookup slot k whose req valid launched (miu_lead's
// rv): the leader's VPN, its L0 lookup, the PA and pa_fold for the req
// payload, and the drop; per address slot, the no-hit.
//
// The leader's VPN. miu_lead flops the leader's (address slot, quarter)
// one-hot lq; lookup slot k can take only (0, k) (footprint 4), (s, 2) for
// s < k (a footprint-2 memop's second group) and (k, 0), so the AND-OR over
// miu_agu8's flopped sums S (lane 0 of each octet) reads those alone. By
// the form (miu_lead's fm): local, miu_form's C of the leader's address slot,
// C[47:16]; interleaved, {l6[6] ? R1 : R0, l6[5:0]}, all miu_lead's flops
// (l6 = {0, S[15:11]} + bl, R(ctx)'s VPN[31:6] for its carry 0 and 1);
// else S[47:16]. The page offset: local C[15:0] | lane << 2; interleaved
// {S[10:2], lane, S[1:0]} (O-83); else S[15:0]. The lane is the quarter's
// lane 0, 8q.
//
// The L0 (miu_tlb's flops, 6 entries per lookup slot): hit = any valid
// entry whose VPN matches; the PPN, the PFN's fold (pa_fold, MA-30) and the
// perms by an AND-OR on the match. A miss flops ms and the VPN for
// miu_tlb's refill from the 32-entry TLB in A3 (MA rev 199): the L0's
// refill loop, read here at A2 from flops miu_tlb writes later.
//
// The drop (MA-27), one OR, flopped: the leader lane inactive (the fixed
// leader, MA rev 199); an L0 miss; a faulting lane of the memop (F-ALIGN,
// and F-ADDR: S[49:48] not 0, O-75, or the run's windows, O-83; below); a
// bank's loser (dedupe and bank conflict, from A1's flopped
// lead_set_index: a lower lookup slot launching to the same bank; a
// duplicate line is such a bank's loser too); and the group check, ge:
// miu_grp, an inner helper here (MA rev 209), per address slot, each active
// lane on its group leader's line and the active groups' leaders on one
// page, routed to the lookup slots it leads by lq, meeting the rest only at
// this OR. F is read from lq: a leader at quarter 1 only for 4 pipes, at
// quarter 2 for 2 or 4 (miu_lead). The faults route the same way and meet
// ge only at this OR. A dropped
// lookup frees its id and refunds its credit (miu_ids, miu_cred) from this
// flop. The no-hit (MA-4, OA-408): per address slot, any of its memop's
// launched lookups dropped, flopped for ccv_miu_ooe_cmpl_hint at H+2.
//
// Not yet here: the MQ entry's lines and lane map, and drop_held (an older
// store's overlap found at A2): they come with the MQ's A2 write. Nor a
// predicate transfer's faults (ld.pred, st.pred: lane d's b alone, l = 0),
// which come with its single address from miu_lead.
//
// Flops (tag 07): per lookup slot the PA (48), pa_fold, perms, drop, the
// L0 miss and its VPN; per address slot the no-hit. Clocked by this
// module's flop of the address slots' valids two cycles on (CG-5). Inputs
// are flops (arrival 0), lc_cm06h miu_agu8's (* keep *) copies of lanes 0's
// and 16's lines for miu_grp's far lanes (MA rev 209, fix (i)); every
// output straight from a flop.
`include "ccv_assert.svh"
`define CCV_CLK miu_core_clk
`define CCV_RST rst_r01h
module miu_a2 #(
  parameter  int NS = ccv_params_pkg::CCV_MIU_PIPES,          // address and lookup slots, 4
  parameter  int N0 = 6,                                      // L0 entries a slot (MA rev 206)
  parameter  int FW = ccv_prov_pkg::CCV_W_PA_FOLD,            // pa_fold, 4
  parameter  int PM = 1,                                      // perms (slice 2's PTE)
  localparam int NQ = 4,                                      // lane quarters (octets)
  localparam int VW = 50,                                     // miu_agu8's exact sum
  localparam int SW = 9,                                      // lead_set_index
  localparam int BW = $clog2(ccv_params_pkg::CCV_DCU_BANKS)   // the bank: lsi's low bits
) (
  input  logic                miu_core_clk,
  input  logic                rst_n,
  // miu_cap's valids a cycle on, per address slot (this module's enables).
  input  logic [NS-1:0]       v_cm04h,
  // ---- miu_lead's flops: per lookup slot ---------------------------------
  input  logic [NS-1:0]       rv_cm06h,      // the req valid launched
  input  logic [NS*SW-1:0]    lsi_cm06h,     // lead_set_index
  input  logic [NS*NS*NQ-1:0] lq_cm06h,      // the leader's (address slot, quarter)
  input  logic [NS-1:0]       la_cm06h,      // the leader lane active
  input  logic [NS*2-1:0]     fm_cm06h,      // {interleaved, local}
  input  logic [NS*7-1:0]     l6_cm06h,
  input  logic [NS*52-1:0]    rh_cm06h,      // R(ctx)'s VPN[31:6], carry 1 high
  // ---- miu_agu8's and miu_form's flops: per address slot -----------------
  input  logic [NS*NQ*VW-1:0] va_cm06h,      // each octet's lane 0 sum
  input  logic [NS*VW-1:0]    c_cm06h,       // the local form's C
  // ---- miu_agu8's flops: per address slot, miu_grp's lanes ----------------
  input  logic [NS*32*VW-1:0] lv_cm06h,      // every lane's sum (miu_agu8's flops)
  input  logic [NS*32-1:0]    am_cm06h,      // every lane's active bit
  input  logic [NS*2*41-1:0]  lc_cm06h,      // lanes 0's and 16's lines again (miu_agu8's keep copies)
  // ---- miu_agu8's flops: per address slot, the lanes' faults -------------
  input  logic [NS*32-1:0]    fal_cm06h,     // F-ALIGN, active lanes only
  input  logic [NS*NQ-1:0]    ilv_cm06h,     // interleaved (O-83), each octet's copy
  input  logic [NS*NQ-1:0]    ow_cm06h,      // an ordinary .global access, each octet's copy
  input  logic [NS*32-1:0]    we_cm06h,      // each lane's S[47:16+k] == W >> k
  // ---- miu_tlb's L0 flops: slot k's entry e at [k*N0 + e] -----------------
  input  logic [NS*N0-1:0]    l0v_cm11h,
  input  logic [NS*N0*32-1:0] l0vpn_cm11h,
  input  logic [NS*N0*32-1:0] l0ppn_cm11h,
  input  logic [NS*N0*FW-1:0] l0fold_cm11h,
  input  logic [NS*N0*PM-1:0] l0pm_cm11h,
  // ---- A2's flops ----------------------------------------------------------
  output logic [NS*48-1:0]    pa_cm07h,      // the req payload's PA
  output logic [NS*FW-1:0]    pf_cm07h,      // pa_fold
  output logic [NS*PM-1:0]    pm_cm07h,      // the page's perms
  output logic [NS-1:0]       dr_cm07h,      // drop
  output logic [NS-1:0]       ms_cm07h,      // L0 miss, to miu_tlb's refill
  output logic [NS*32-1:0]    vpn_cm07h,     // the leader's VPN, to miu_tlb
  output logic [NS-1:0]       nh_cm07h       // per address slot: the no-hit
);

  // rst_n flopped before any use (RST-1), inverted after the flop.
  logic rst_cr01h_n;
  always_ff @(posedge miu_core_clk) begin
    rst_cr01h_n <= rst_n;
  end
  wire rst_r01h = !rst_cr01h_n;

  // ---- The valids, two cycles on: a memop in A2 (CG-5) -------------------
  // Only any slot's valid is read, so one flop a stage: these and the
  // reset's are this module's only flops under no enable (CG-1's allowance).
  logic v_q_cm05h, v_q_cm06h;
  always_ff @(posedge miu_core_clk) begin
    if (rst_r01h) begin
      v_q_cm05h <= 1'b0;
      v_q_cm06h <= 1'b0;
    end else begin
      v_q_cm05h <= |v_cm04h;
      v_q_cm06h <= v_q_cm05h;
    end
  end

  // ---- The lanes' faults, per address slot (MA rev 206's drop list) -----
  // F-ALIGN (miu_agu8's, active lanes only); F-ADDR: an ordinary .global
  // lane's S[49:48] not 0 (O-75), or its S in the run's own windows, S >> (16
  // + k) == W >> k (O-83, IS's rev 171); an interleaved lane's b outside
  // [0, L), which is S >> (16 + k) != W >> k, W a multiple of 2^k. The
  // compare is miu_agu8's, beside its adders (we), each lane reading its own
  // octet's ilv and ow. A faulting memop drops every lookup it leads
  // (drop_fault), its completion the fault's (the MQ's; MIU tab, "The drop").
  logic [NS-1:0] ft_cm06h;
  always_comb
    for (int a = 0; a < NS; a++) begin
      ft_cm06h[a] = 1'b0;
      for (int l = 0; l < 32; l++) begin
        logic [VW-1:0] v;
        logic          hi, eq, iv, ov;
        v  = lv_cm06h[(a*32 + l)*VW +: VW];
        iv = ilv_cm06h[a*NQ + l/8];
        ov = ow_cm06h[a*NQ + l/8];
        hi = v[VW-1:48] != '0;
        eq = we_cm06h[a*32 + l];
        ft_cm06h[a] = ft_cm06h[a] | fal_cm06h[a*32 + l] |
                      (am_cm06h[a*32 + l] && (iv ? (hi || !eq) : (ov && (hi || eq))));
      end
    end

  // ---- The group and page check, one miu_grp per address slot -----------
  // Address slot a's footprint from the leaders' quarters: a leader at
  // quarter 1 only for 4 pipes, at quarter 2 for 2 or 4.
  logic [NS-1:0] ok_cm06h;
  logic [NS-1:0] ge_cm06h;
  logic [NS*2-1:0] fl_cm06h;
  always_comb
    for (int a = 0; a < NS; a++) begin
      fl_cm06h[a*2 +: 2] = '0;
      for (int k = 0; k < NS; k++) begin
        fl_cm06h[a*2 + 1] = fl_cm06h[a*2 + 1] | lq_cm06h[(k*NS + a)*NQ + 1];
        fl_cm06h[a*2]     = fl_cm06h[a*2]     | lq_cm06h[(k*NS + a)*NQ + 2];
      end
    end
  for (genvar a = 0; a < NS; a++) begin : g_grp
    miu_grp #(.NL(32), .VW(VW)) u_grp (
      .am(am_cm06h[a*32 +: 32]), .va(lv_cm06h[a*32*VW +: 32*VW]),
      .lc(lc_cm06h[a*2*41 +: 2*41]), .fl(fl_cm06h[a*2 +: 2]), .ok(ok_cm06h[a]));
  end
  logic [NS-1:0] fd_cm06h;   // the lookup's memop has a faulting lane
  always_comb
    for (int k = 0; k < NS; k++) begin
      ge_cm06h[k] = 1'b0;
      fd_cm06h[k] = 1'b0;
      for (int a = 0; a < NS; a++) begin
        ge_cm06h[k] = ge_cm06h[k] | (|lq_cm06h[(k*NS + a)*NQ +: NQ] && ok_cm06h[a]);
        fd_cm06h[k] = fd_cm06h[k] | (|lq_cm06h[(k*NS + a)*NQ +: NQ] && ft_cm06h[a]);
      end
    end

  // Lookup slot k's possible leaders: (0, k), (s < k, 2), (k, 0).
  function automatic logic can(input int k, input int s, input int q);
    can = (s == 0 && q == k) || (s < k && q == 2) || (s == k && q == 0);
  endfunction

  logic [NS*48-1:0] pa_d_cm06h;
  logic [NS*FW-1:0] pf_d_cm06h;
  logic [NS*PM-1:0] pm_d_cm06h;
  logic [NS-1:0]    dr_d_cm06h, ms_d_cm06h;
  logic [NS*32-1:0] vpn_d_cm06h;
  logic [NS-1:0]    nh_d_cm06h;
  always_comb begin
    nh_d_cm06h = '0;
    for (int k = 0; k < NS; k++) begin
      logic [VW-1:0] s;
      logic [VW-1:0] c;
      logic [4:0]    ln;
      logic [NS-1:0] so;
      logic          il, lc, hit, bl;
      logic [31:0]   vpn, ppn;
      logic [15:0]   off;
      logic [FW-1:0] fo;
      logic [PM-1:0] pg;
      logic [6:0]    l6;
      logic [25:0]   r0, r1;
      s = '0; c = '0; ln = '0; so = '0;
      for (int a = 0; a < NS; a++)
        for (int q = 0; q < NQ; q++)
          if (can(k, a, q)) begin
            logic h;
            h  = lq_cm06h[(k*NS + a)*NQ + q];
            s  = s | ({VW{h}} & va_cm06h[(a*NQ + q)*VW +: VW]);
            c  = c | ({VW{h}} & c_cm06h[a*VW +: VW]);
            ln = ln | ({5{h}} & 5'(q * 8));
            so[a] = so[a] | h;
          end
      {il, lc} = fm_cm06h[k*2 +: 2];
      l6 = l6_cm06h[k*7 +: 7];
      {r1, r0} = rh_cm06h[k*52 +: 52];
      vpn = lc ? c[47:16] : il ? {l6[6] ? r1 : r0, l6[5:0]} : s[47:16];
      off = lc ? (c[15:0] | 16'({ln, 2'b00})) : il ? {s[10:2], ln, s[1:0]} : s[15:0];
      // The L0.
      hit = 1'b0; ppn = '0; fo = '0; pg = '0;
      for (int e = 0; e < N0; e++) begin
        logic m;
        m   = l0v_cm11h[k*N0 + e] && l0vpn_cm11h[(k*N0 + e)*32 +: 32] == vpn;
        hit = hit | m;
        ppn = ppn | ({32{m}} & l0ppn_cm11h[(k*N0 + e)*32 +: 32]);
        fo  = fo | ({FW{m}} & l0fold_cm11h[(k*N0 + e)*FW +: FW]);
        pg  = pg | ({PM{m}} & l0pm_cm11h[(k*N0 + e)*PM +: PM]);
      end
      // A lower slot launching to the bank.
      bl = 1'b0;
      for (int j = 0; j < k; j++)
        bl = bl | (rv_cm06h[j] && lsi_cm06h[j*SW +: BW] == lsi_cm06h[k*SW +: BW]);
      pa_d_cm06h[k*48 +: 48]  = {ppn, off};
      pf_d_cm06h[k*FW +: FW]  = fo;
      pm_d_cm06h[k*PM +: PM]  = pg;
      ms_d_cm06h[k]           = rv_cm06h[k] && la_cm06h[k] && !hit;
      vpn_d_cm06h[k*32 +: 32] = vpn;
      dr_d_cm06h[k]           = !la_cm06h[k] || !hit || fd_cm06h[k] || bl || !ge_cm06h[k];
      nh_d_cm06h              = nh_d_cm06h | ({NS{rv_cm06h[k] && dr_d_cm06h[k]}} & so);
    end
  end

  // ---- Flops: H+2 ----------------------------------------------------------
  // The payload under an address slot's memop in A2; the miss and the
  // no-hit also the cycle after, to clear them (CG-5: this module's flops).
  logic [NS*48-1:0] pa_q_cm07h;
  logic [NS*FW-1:0] pf_q_cm07h;
  logic [NS*PM-1:0] pm_q_cm07h;
  logic [NS-1:0]    dr_q_cm07h, ms_q_cm07h, nh_q_cm07h;
  logic [NS*32-1:0] vpn_q_cm07h;
  wire pay_en_cm06h = v_q_cm06h;
  wire ms_en_cm06h  = pay_en_cm06h || (|ms_q_cm07h) || (|nh_q_cm07h) || rst_r01h;
  always_ff @(posedge miu_core_clk) begin
    if (pay_en_cm06h) begin
      pa_q_cm07h  <= pa_d_cm06h;
      pf_q_cm07h  <= pf_d_cm06h;
      pm_q_cm07h  <= pm_d_cm06h;
      dr_q_cm07h  <= dr_d_cm06h;
      vpn_q_cm07h <= vpn_d_cm06h;
    end
  end
  always_ff @(posedge miu_core_clk) begin
    if (ms_en_cm06h) begin
      ms_q_cm07h <= (rst_r01h || !pay_en_cm06h) ? '0 : ms_d_cm06h;
      nh_q_cm07h <= (rst_r01h || !pay_en_cm06h) ? '0 : nh_d_cm06h;
    end
  end
  assign pa_cm07h  = pa_q_cm07h;
  assign pf_cm07h  = pf_q_cm07h;
  assign pm_cm07h  = pm_q_cm07h;
  assign dr_cm07h  = dr_q_cm07h;
  assign ms_cm07h  = ms_q_cm07h;
  assign vpn_cm07h = vpn_q_cm07h;
  assign nh_cm07h  = nh_q_cm07h;

  // A lookup launches only with a memop in A2.
  `CCV_ASSERT(rv_pay, (rv_cm06h == '0) || pay_en_cm06h)

endmodule
`undef CCV_CLK
`undef CCV_RST
