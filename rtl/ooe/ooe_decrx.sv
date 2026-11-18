//===-- ooe_decrx.sv - OOE's receiver of ccv_dec_ooe_uop: slots and epochs -===//
//
// Spec: OA 428 (re:OI-165 (a), the register's OA tab): the A-70 arrival
//       drop is OOE's, in one module at its receiving end of
//       ccv_dec_ooe_uop, ahead of ooe_decq. It alone holds the warp-to-slot
//       table and the per-warp 3-bit fetch epochs, and it advances an epoch
//       itself (A-74: OOE alone advances it). A uop is kept only when its
//       warp holds a tier-1 slot and its fetch_epoch is the warp's epoch;
//       ooe_decq takes the kept uop's slot and valid as before, and a
//       dropped uop takes no entry, so it never counts as a credit out.
//
// This module is the state: each tier-1 slot's warp, whether it holds one,
// and its warp's epoch (with the epoch after it, for a same-cycle advance),
// all from flops; and the epoch of every warp_id holding no slot (NW x EP,
// reset to 0 and never reset at a launch; decision 6). A slot's copy is the
// warp's epoch while it is resident: a release saves it into the warp's row
// and an allocation loads the row. So one copy of each warp's epoch is live
// at a time, and nothing keeps two in step.
//
// The arrivals are this module's too (OA 429, re:OI-166: the keep and its
// flop both here, ooe_decq's enq cone unchanged). Each uop is compared by
// ooe_decrx_keep, an inner helper timed here, and the kept valid, its slot
// and its payload are flopped: ooe_decq takes them a cycle after they land,
// from these flops, with its lead (enq_l) this module's flop of DEC's
// channel valid. So a uop kept under an epoch a flush of its slot ends can
// reach ooe_decq in that flush's cycle; ooe_decq's late flush drops it
// (OA 430, re:OI-168 (B)), and decrx_tb checks that every uop so dropped
// is stale.
//
// Events (OOE's own pulses, flopped where they start): per slot, a
// redirect's advance (adv) and an epoch notice's (adn: a demotion or a
// kill), each the pulse that queues its message to FET, which carries the
// new epoch itself; both may land on a slot in one cycle (a due branch
// squash beside a demotion), so the epoch moves by 0, 1 or 2. Then a release per slot, and an allocation per slot (a launch or a
// restore) with its warp: ccv_rau_ooe_alloc brings one a cycle, but the
// port is per slot, as the model's launches are. They come a cycle after a lead (ev_l), this
// module's own flop of which clocks every table (CG-5). An advance takes
// effect at its own cycle's arrivals: the helper compares a slot advancing
// now against the epoch one or two after its copy (OA 428 (2), the ordering invariant:
// an advance is visible at the compare no later than ooe_decq's flush of
// the slot, which it applies an edge later). A release and an allocation
// take effect from the next cycle; no uop of their warp arrives in their
// cycle (assertions).
//
// The reference is the model's arrival check (Core::uop) and its slot and
// epoch tables: test/ooe/decrx_tb.cpp drives this module and the helper with
// the live model's arrivals, dropped ones included, and its events, and
// compares every keep, every slot and every resident warp's epoch.
//
// Local clock gating: the tables are one gate on the event lead's flop
// (ev_q); the kept uops one gate on the arrival lead's flop and its
// successor (aq, aqq: the second clears the valids). The leads' flops and
// enq_l's are outside them. Reset line: the leads, each slot's valid,
// every warp's epoch and the kept valids reset; a slot's warp and its
// three epochs are payload under its valid, the kept slots and payloads
// under theirs.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK ooe_core_clk
`define CCV_RST rst_r01h
module ooe_decrx #(
  parameter int S  = 4,                  // tier-1 slots (CCV_TIER1_WARPS)
  parameter int E  = 6,                  // arrivals a cycle (ccv_dec_ooe_uop's rate)
  parameter int NW = 32,                 // warp_ids (2 ** CCV_W_WARP_ID)
  parameter int EP = 3,                  // fetch epoch bits (CCV_P_W_FETCH_EPOCH)
  parameter int P  = 16,                 // the uop's payload bits, as ooe_decq takes them
  localparam int LS = $clog2(S),
  localparam int LW = $clog2(NW)
) (
  input  logic             ooe_core_clk,
  input  logic             ooe_rst_r00h,
  input  logic             ev_l_cq00h,     // an advance, release or allocation comes next cycle
  input  logic [S-1:0]     adv_cq01h,      // slot s's warp's epoch advances: a redirect
  input  logic [S-1:0]     adn_cq01h,      // and again: a demotion's or a kill's notice
  input  logic [S-1:0]     rel_cq01h,      // slot s is released
  input  logic [S-1:0]     al_v_cq01h,     // a warp takes slot s (launch or restore)
  input  logic [S*LW-1:0]  al_warp_cq01h,  // the warp
  input  logic             arv_l_cq00h,    // DEC's channel valid: uops arrive next cycle
  input  logic [E-1:0]     arv_v_cq01h,    // port k carries a uop
  input  logic [E*LW-1:0]  arv_warp_cq01h, // its warp_id
  input  logic [E*EP-1:0]  arv_ep_cq01h,   // its fetch_epoch
  input  logic [E*P-1:0]   arv_pay_cq01h,  // its payload
  output logic             enq_l_cq01h,    // ooe_decq's lead: kept uops come next cycle
  output logic [E-1:0]     enq_v_cq02h,    // port k's uop was kept
  output logic [E*LS-1:0]  enq_slot_cq02h, // its slot
  output logic [E*P-1:0]   enq_pay_cq02h   // its payload
);
  logic rst_r01h;
  always_ff @(posedge ooe_core_clk) rst_r01h <= ooe_rst_r00h;

  logic ev_q_cq01h;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) ev_q_cq01h <= 1'b0;
    else ev_q_cq01h <= ev_l_cq00h;
  end
  logic tb_en_cq01h;
  assign tb_en_cq01h = ev_q_cq01h;

  // Each slot's table: whether it holds a warp, the warp, its epoch and
  // the two after it.
  logic [S-1:0]    sv_cq02h;
  logic [S*LW-1:0] swi_cq02h;
  logic [S*EP-1:0] sei_cq02h, sni_cq02h, s2i_cq02h;

  // Each slot's epoch after this cycle's advances (0, 1 or 2 of them), and
  // the two after that, chosen from the flops' own increments so that no
  // adder follows a select: ec[k] is the slot's epoch plus k.
  logic [S*EP-1:0] sa_cq01h, sa1_cq01h, sa2_cq01h;
  always_comb
    for (int s = 0; s < S; s++) begin
      logic [EP-1:0] ec [5];
      ec[0] = sei_cq02h[s * EP +: EP];
      ec[1] = sni_cq02h[s * EP +: EP];
      ec[2] = s2i_cq02h[s * EP +: EP];
      ec[3] = s2i_cq02h[s * EP +: EP] + EP'(1);
      ec[4] = s2i_cq02h[s * EP +: EP] + EP'(2);
      if (adv_cq01h[s] && adn_cq01h[s]) begin
        sa_cq01h[s * EP +: EP] = ec[2]; sa1_cq01h[s * EP +: EP] = ec[3]; sa2_cq01h[s * EP +: EP] = ec[4];
      end else if (adv_cq01h[s] || adn_cq01h[s]) begin
        sa_cq01h[s * EP +: EP] = ec[1]; sa1_cq01h[s * EP +: EP] = ec[2]; sa2_cq01h[s * EP +: EP] = ec[3];
      end else begin
        sa_cq01h[s * EP +: EP] = ec[0]; sa1_cq01h[s * EP +: EP] = ec[1]; sa2_cq01h[s * EP +: EP] = ec[2];
      end
    end

  // The warps' rows: a release saves its slot's epoch, advanced if the slot
  // advances in the same cycle. A warp holds one slot, so at most one
  // release names a row: an AND-OR, not a priority chain. A row's hold is
  // an AND-OR on D too, not an if, so the table stays in the slots' gate
  // (rtl-coding-style.md, "AND-OR on D"): 3-flop rows would be 32 gates
  // under 8.
  logic [NW*EP-1:0] we_cq02h, we_nx_cq01h;
  always_comb
    for (int w = 0; w < NW; w++) begin
      logic hit;
      logic [EP-1:0] d;
      hit = 1'b0;
      d = '0;
      for (int s = 0; s < S; s++)
        if (rel_cq01h[s] && swi_cq02h[s * LW +: LW] == LW'(w)) begin
          hit = 1'b1;
          d = d | sa_cq01h[s * EP +: EP];
        end
      we_nx_cq01h[w * EP +: EP] = ({EP{hit}} & d) | ({EP{!hit}} & we_cq02h[w * EP +: EP]);
    end
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) we_cq02h <= '0;
    else if (tb_en_cq01h) we_cq02h <= we_nx_cq01h;
  end

  // The slots' copies. An allocation loads its warp's row, or the epochs of
  // the slot releasing that warp in the same cycle (a free and the restore
  // of the same warp at one RAU decision), which the row takes only at the
  // edge.
  // The same-cycle bypass, per allocating slot s: the epochs of the slot
  // releasing its warp (at most one; an AND-OR).
  logic [S-1:0] byp_cq01h;
  logic [S*EP-1:0] b0_cq01h, b1_cq01h, b2_cq01h;
  always_comb begin
    byp_cq01h = '0;
    b0_cq01h = '0;
    b1_cq01h = '0;
    b2_cq01h = '0;
    for (int s = 0; s < S; s++)
      for (int t = 0; t < S; t++)
        if (rel_cq01h[t] && swi_cq02h[t * LW +: LW] == al_warp_cq01h[s * LW +: LW]) begin
          byp_cq01h[s] = 1'b1;
          b0_cq01h[s * EP +: EP] = b0_cq01h[s * EP +: EP] | sa_cq01h[t * EP +: EP];
          b1_cq01h[s * EP +: EP] = b1_cq01h[s * EP +: EP] | sa1_cq01h[t * EP +: EP];
          b2_cq01h[s * EP +: EP] = b2_cq01h[s * EP +: EP] | sa2_cq01h[t * EP +: EP];
        end
  end

  logic [S-1:0] sv_nx_cq01h;
  logic [S*LW-1:0] sw_nx_cq01h;
  logic [S*EP-1:0] se_nx_cq01h, sn_nx_cq01h, s2_nx_cq01h;
  always_comb begin
    for (int s = 0; s < S; s++) begin
      logic [EP-1:0] row;
      row = we_cq02h[al_warp_cq01h[s * LW +: LW] * EP +: EP];
      sv_nx_cq01h[s] = sv_cq02h[s] & ~rel_cq01h[s];
      // A held warp is an AND-OR on D, not an if, so it stays in the
      // tables' gate (5-flop fields would be gates under 8).
      sw_nx_cq01h[s * LW +: LW] = ({LW{al_v_cq01h[s]}} & al_warp_cq01h[s * LW +: LW]) |
                                  ({LW{!al_v_cq01h[s]}} & swi_cq02h[s * LW +: LW]);
      se_nx_cq01h[s * EP +: EP] = sa_cq01h[s * EP +: EP];
      sn_nx_cq01h[s * EP +: EP] = sa1_cq01h[s * EP +: EP];
      s2_nx_cq01h[s * EP +: EP] = sa2_cq01h[s * EP +: EP];
      if (al_v_cq01h[s]) begin
        sv_nx_cq01h[s] = 1'b1;
        se_nx_cq01h[s * EP +: EP] = row;
        sn_nx_cq01h[s * EP +: EP] = row + EP'(1);
        s2_nx_cq01h[s * EP +: EP] = row + EP'(2);
        if (byp_cq01h[s]) begin
          se_nx_cq01h[s * EP +: EP] = b0_cq01h[s * EP +: EP];
          sn_nx_cq01h[s * EP +: EP] = b1_cq01h[s * EP +: EP];
          s2_nx_cq01h[s * EP +: EP] = b2_cq01h[s * EP +: EP];
        end
      end
    end
  end
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) sv_cq02h <= '0;
    else if (tb_en_cq01h) sv_cq02h <= sv_nx_cq01h;
  end
  always_ff @(posedge ooe_core_clk)
    if (tb_en_cq01h) begin
      swi_cq02h <= sw_nx_cq01h;
      sei_cq02h <= se_nx_cq01h;
      sni_cq02h <= sn_nx_cq01h;
      s2i_cq02h <= s2_nx_cq01h;
    end

  // The arrivals: each compared (the inner helper), the kept ones flopped
  // with their slots and payloads, ooe_decq's inputs a cycle later. The
  // arrival lead's flop (aq) clocks them, and its successor (aqq) once
  // more, to clear the valids; enq_l is a third flop of the lead, the
  // output's own.
  logic aq_cq01h, aqq_cq02h;
  (* keep *) logic enq_lo_cq01h;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      aq_cq01h     <= 1'b0;
      aqq_cq02h    <= 1'b0;
      enq_lo_cq01h <= 1'b0;
    end else begin
      aq_cq01h     <= arv_l_cq00h;
      aqq_cq02h    <= aq_cq01h;
      enq_lo_cq01h <= arv_l_cq00h;
    end
  end
  assign enq_l_cq01h = enq_lo_cq01h;
  logic [E-1:0]    kv_cq01h;
  logic [E*LS-1:0] ks_cq01h;
  ooe_decrx_keep #(.S(S), .E(E), .NW(NW), .EP(EP)) u_keep (
    .arv_v_cq01h, .arv_warp_cq01h, .arv_ep_cq01h, .adv_cq01h, .adn_cq01h,
    .sv_cq02h, .sw_cq02h(swi_cq02h), .se_cq02h(sei_cq02h), .sn_cq02h(sni_cq02h), .s2_cq02h(s2i_cq02h),
    .enq_v_cq01h(kv_cq01h), .enq_slot_cq01h(ks_cq01h));
  logic kq_en_cq01h;
  assign kq_en_cq01h = aq_cq01h || aqq_cq02h;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) enq_v_cq02h <= '0;
    else if (kq_en_cq01h) enq_v_cq02h <= kv_cq01h;
  end
  always_ff @(posedge ooe_core_clk)
    if (kq_en_cq01h) begin
      enq_slot_cq02h <= ks_cq01h;
      enq_pay_cq02h  <= arv_pay_cq01h;
    end

  // The input contract.
  `CCV_ASSERT_KNOWN(ev_l_known, ev_l_cq00h)
  `CCV_ASSERT_KNOWN(adv_known, adv_cq01h)
  `CCV_ASSERT_KNOWN(adn_known, adn_cq01h)
  `CCV_ASSERT_KNOWN(rel_known, rel_cq01h)
  `CCV_ASSERT_KNOWN(al_v_known, al_v_cq01h)
  `CCV_ASSERT_KNOWN_IF(al_known, al_v_cq01h != '0, al_warp_cq01h)
  `CCV_ASSERT_KNOWN(arv_l_known, arv_l_cq00h)
  `CCV_ASSERT_KNOWN(arv_v_known, arv_v_cq01h)
  // Every arrival comes under its lead.
  `CCV_ASSERT(arv_led, arv_v_cq01h == '0 || aq_cq01h)
  // Every event comes under its lead.
  `CCV_ASSERT(ev_led, (adv_cq01h == '0 && adn_cq01h == '0 && rel_cq01h == '0 && al_v_cq01h == '0) || ev_q_cq01h)
  // An advance or a release names a slot that holds a warp.
  `CCV_ASSERT_READ_VALID(adv_resident, (adv_cq01h | adn_cq01h) != '0, ((adv_cq01h | adn_cq01h) & ~sv_cq02h) == '0)
  `CCV_ASSERT_READ_VALID(rel_resident, rel_cq01h != '0, (rel_cq01h & ~sv_cq02h) == '0)
  // An allocation takes a free slot (or one released in its cycle), for a
  // warp that holds no slot (or is released in the cycle) and is not
  // allocated twice.
  logic [S-1:0] al_busy_cq01h, al_dup_cq01h;
  always_comb
    for (int s = 0; s < S; s++) begin
      al_busy_cq01h[s] = al_v_cq01h[s] && sv_cq02h[s] && !rel_cq01h[s];
      al_dup_cq01h[s] = 1'b0;
      for (int t = 0; t < S; t++) begin
        if (al_v_cq01h[s] && sv_cq02h[t] && !rel_cq01h[t] && al_warp_cq01h[s * LW +: LW] == swi_cq02h[t * LW +: LW])
          al_dup_cq01h[s] = 1'b1;
        if (al_v_cq01h[s] && al_v_cq01h[t] && t != s && al_warp_cq01h[s * LW +: LW] == al_warp_cq01h[t * LW +: LW])
          al_dup_cq01h[s] = 1'b1;
      end
    end
  `CCV_ASSERT(al_free_slot, al_busy_cq01h == '0)
  `CCV_ASSERT(al_new_warp, al_dup_cq01h == '0)
  `CCV_ASSERT(al_not_advanced, (al_v_cq01h & (adv_cq01h | adn_cq01h)) == '0)
endmodule
`undef CCV_CLK
`undef CCV_RST
