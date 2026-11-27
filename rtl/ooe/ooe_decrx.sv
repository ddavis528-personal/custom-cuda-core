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
// The arrivals are this module's too, in their lead cycle (OA 432, re:OI-169:
// warp_id and fetch_epoch are lead fields of ccv_dec_ooe_uop, beside each
// port's valid, a cycle ahead of the payload). Each uop is compared there by
// ooe_decrx_keep, an inner helper timed here, and the kept valid and its slot
// are flopped on the edge the payload lands: ooe_decq takes them with the
// payload, from these flops (its lead and the payload come from OOE's
// boundary, not through this module). So no cycle is added (OA 429's flop
// form added one: OI-169's price). A uop kept under an epoch a flush of its
// slot ends reaches ooe_decq in that flush's cycle; ooe_decq's late flush
// drops it (OA 430, re:OI-168 (B)), and decrx_tb checks that every uop so
// dropped is stale.
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
// A demotion's straggler walk (AR 395 / OA 457, #71): a demoting slot's
// notice opens its walk (wo, from ooe_slot), and until the slot is
// released or a kill's notice closes it, a uop of the warp carrying the
// epoch the demotion ended (the walk epoch, the slot's epoch before the
// notice's advance) is kept too: a straggler, which ooe_decq holds until
// the beat that names its lanes has left. No uop of the current epoch
// arrives for a demoting slot (OA 460: FET fetches nothing past the
// notice), so every uop kept for a slot whose walk is open is a straggler,
// and ooe_decq reads that from the slot's walk bit (wo_o), not a flag per
// port. The walk bit and epoch are table flops, in the tables' gate.
//
// The reference is the model's arrival check (Core::uop) and its slot and
// epoch tables: test/ooe/decrx_tb.cpp drives this module and the helper with
// the live model's arrivals, dropped ones included, and its events, and
// compares every keep, every slot and every resident warp's epoch.
//
// Local clock gating: the tables are one gate on the event lead's flop
// (ev_q). The verdict (kept valids and slots) captures lead fields as they
// land, so no flop of this module's leads its edge: it is ungated, a lead
// capture as ooe_cmcap's cv is (OI-170 asks OA how it is to be counted).
// Reset line: the event lead, each slot's valid, every warp's epoch and the
// kept valids reset; a slot's warp and its three epochs are payload under
// its valid, the kept slots under theirs.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK ooe_core_clk
`define CCV_RST rst_r01h
module ooe_decrx #(
  parameter int S  = 4,                  // tier-1 slots (CCV_TIER1_WARPS)
  parameter int E  = 6,                  // arrivals a cycle (ccv_dec_ooe_uop's rate)
  parameter int NW = 32,                 // warp_ids (2 ** CCV_W_WARP_ID)
  parameter int EP = 3,                  // fetch epoch bits (CCV_P_W_FETCH_EPOCH)
  localparam int LS = $clog2(S),
  localparam int LW = $clog2(NW)
) (
  input  logic             ooe_core_clk,
  input  logic             ooe_rst_r00h,
  input  logic [S:0]       ev_l_cq00h,     // an event comes next cycle, a lead per source (OA 447): slot s's
                                           // ooe_rob_w (its rd_e: an advance), and ooe_slot (bit S)
  input  logic [S-1:0]     adv_cq01h,      // slot s's warp's epoch advances: a redirect
  input  logic [S-1:0]     adn_cq01h,      // and again: a demotion's or a kill's notice
  input  logic [S-1:0]     wo_cq01h,       // slot s's notice is a demotion's: its straggler walk opens
  input  logic [S-1:0]     rel_cq01h,      // slot s is released
  input  logic [S-1:0]     al_v_cq01h,     // a warp takes slot s (launch or restore)
  input  logic [S*LW-1:0]  al_warp_cq01h,  // the warp
  input  logic [E-1:0]     arv_v_cq01h,    // port k carries a uop (the valid: its payload lands next cycle)
  input  logic [E*LW-1:0]  arv_warp_cq01h, // its warp_id (a lead field)
  input  logic [E*EP-1:0]  arv_ep_cq01h,   // its fetch_epoch (a lead field)
  output logic [E-1:0]     enq_v_cq02h,    // port k's uop was kept: with its payload, at ooe_decq
  output logic [E*LS-1:0]  enq_slot_cq02h, // its slot
  output logic [S*LW-1:0]  sw_o_cq02h,     // each slot's warp, and the epoch after its warp's:
  output logic [S*EP-1:0]  sn_o_cq02h,     // ooe_redir reads a redirect's in its squash's cycle (OI-179)
  output logic [S-1:0]     wo_o_cq02h      // slot s's straggler walk is open: its kept uops are stragglers
);
  logic rst_r01h;
  always_ff @(posedge ooe_core_clk) rst_r01h <= ooe_rst_r00h;

  logic ev_q_cq01h;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) ev_q_cq01h <= 1'b0;
    else ev_q_cq01h <= |ev_l_cq00h;
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
  logic [S-1:0] sv_nx_cq01h;
  logic [S*LW-1:0] sw_nx_cq01h;
  logic [S*EP-1:0] se_nx_cq01h, sn_nx_cq01h, s2_nx_cq01h;
  always_comb begin
    for (int s = 0; s < S; s++) begin
      logic [EP-1:0] row, b0, b1, b2;
      logic          byp;
      row = we_cq02h[al_warp_cq01h[s * LW +: LW] * EP +: EP];
      // The same-cycle bypass: the epochs of the slot releasing this
      // allocation's warp (at most one; an AND-OR), the table's D side.
      byp = 1'b0;
      b0  = '0;
      b1  = '0;
      b2  = '0;
      for (int t = 0; t < S; t++)
        if (rel_cq01h[t] && swi_cq02h[t * LW +: LW] == al_warp_cq01h[s * LW +: LW]) begin
          byp = 1'b1;
          b0  = b0 | sa_cq01h[t * EP +: EP];
          b1  = b1 | sa1_cq01h[t * EP +: EP];
          b2  = b2 | sa2_cq01h[t * EP +: EP];
        end
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
        if (byp) begin
          se_nx_cq01h[s * EP +: EP] = b0;
          sn_nx_cq01h[s * EP +: EP] = b1;
          s2_nx_cq01h[s * EP +: EP] = b2;
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
  // Each slot's straggler walk: open from a demotion's notice until a kill's
  // notice or the slot's release (an allocation finds it closed), and the
  // epoch its stragglers carry, the slot's before the notice: its epoch if
  // the notice advances it alone, the one after if a redirect advances it
  // too. An AND-OR on D, in the tables' gate.
  logic [S-1:0]    wq_cq02h, wq_nx_cq01h;
  logic [S*EP-1:0] wep_cq02h, wep_nx_cq01h;
  always_comb
    for (int s = 0; s < S; s++) begin
      logic [EP-1:0] wd;
      wd = adv_cq01h[s] ? sni_cq02h[s * EP +: EP] : sei_cq02h[s * EP +: EP];
      wq_nx_cq01h[s] = wo_cq01h[s] | (wq_cq02h[s] & ~adn_cq01h[s] & ~rel_cq01h[s] & ~al_v_cq01h[s]);
      wep_nx_cq01h[s * EP +: EP] = ({EP{wo_cq01h[s]}} & wd) | ({EP{!wo_cq01h[s]}} & wep_cq02h[s * EP +: EP]);
    end
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) wq_cq02h <= '0;
    else if (tb_en_cq01h) wq_cq02h <= wq_nx_cq01h;
  end
  always_ff @(posedge ooe_core_clk)
    if (tb_en_cq01h) wep_cq02h <= wep_nx_cq01h;

  // Their copies out (an output's register drives nothing else, each kept).
  (* keep *) logic [S*LW-1:0] swo_cq02h;
  (* keep *) logic [S*EP-1:0] sno_cq02h;
  (* keep *) logic [S-1:0]    woo_cq02h;
  always_ff @(posedge ooe_core_clk)
    if (tb_en_cq01h) begin
      swo_cq02h <= sw_nx_cq01h;
      sno_cq02h <= sn_nx_cq01h;
    end
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) woo_cq02h <= '0;
    else if (tb_en_cq01h) woo_cq02h <= wq_nx_cq01h;
  end
  assign sw_o_cq02h = swo_cq02h;
  assign sn_o_cq02h = sno_cq02h;
  assign wo_o_cq02h = woo_cq02h;

  // The arrivals, in their lead cycle: each compared (the inner helper), and
  // the verdict flopped on the edge the payload lands, ooe_decq's inputs
  // beside it. The valids reset; a slot is read only under its valid.
  logic [E-1:0]    kv_cq01h;
  logic [E*LS-1:0] ks_cq01h;
  ooe_decrx_keep #(.S(S), .E(E), .NW(NW), .EP(EP)) u_keep (
    .arv_v_cq01h, .arv_warp_cq01h, .arv_ep_cq01h, .adv_cq01h, .adn_cq01h, .wo_cq01h,
    .wq_cq02h, .wep_cq02h, .sv_cq02h, .sw_cq02h(swi_cq02h), .se_cq02h(sei_cq02h), .sn_cq02h(sni_cq02h), .s2_cq02h(s2i_cq02h),
    .enq_v_cq01h(kv_cq01h), .enq_slot_cq01h(ks_cq01h));
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) enq_v_cq02h <= '0;
    else enq_v_cq02h <= kv_cq01h;
  end
  always_ff @(posedge ooe_core_clk) enq_slot_cq02h <= ks_cq01h;

  // The input contract.
  `CCV_ASSERT_KNOWN(ev_l_known, ev_l_cq00h)
  `CCV_ASSERT_KNOWN(adv_known, adv_cq01h)
  `CCV_ASSERT_KNOWN(adn_known, adn_cq01h)
  `CCV_ASSERT_KNOWN(wo_known, wo_cq01h)
  // A walk opens at a demotion's notice, on a slot whose walk is closed.
  `CCV_ASSERT(wo_on_notice, (wo_cq01h & ~adn_cq01h) == '0)
  `CCV_ASSERT(wo_once, (wo_cq01h & wq_cq02h) == '0)
  `CCV_ASSERT_KNOWN(rel_known, rel_cq01h)
  `CCV_ASSERT_KNOWN(al_v_known, al_v_cq01h)
  `CCV_ASSERT_KNOWN_IF(al_known, al_v_cq01h != '0, al_warp_cq01h)
  `CCV_ASSERT_KNOWN(arv_v_known, arv_v_cq01h)
  // Every event comes under its lead.
  `CCV_ASSERT(ev_led, (adv_cq01h == '0 && adn_cq01h == '0 && wo_cq01h == '0 && rel_cq01h == '0 && al_v_cq01h == '0) || ev_q_cq01h)
  // An advance or a release names a slot that holds a warp.
  `CCV_ASSERT_READ_VALID(adv_resident, (adv_cq01h | adn_cq01h) != '0, ((adv_cq01h | adn_cq01h) & ~sv_cq02h) == '0)
  `CCV_ASSERT_READ_VALID(rel_resident, rel_cq01h != '0, (rel_cq01h & ~sv_cq02h) == '0)
  // An allocation takes a free slot (or one released in its cycle), for a
  // warp that holds no slot (or is released in the cycle) and is not
  // allocated twice.
  logic [S-1:0] al_busy_cq02h, al_dup_cq02h;   // against the table
  logic [S-1:0] al_two_cq01h;                  // two allocations of one warp
  always_comb
    for (int s = 0; s < S; s++) begin
      al_busy_cq02h[s] = al_v_cq01h[s] && sv_cq02h[s] && !rel_cq01h[s];
      al_dup_cq02h[s] = 1'b0;
      al_two_cq01h[s] = 1'b0;
      for (int t = 0; t < S; t++) begin
        if (al_v_cq01h[s] && sv_cq02h[t] && !rel_cq01h[t] && al_warp_cq01h[s * LW +: LW] == swi_cq02h[t * LW +: LW])
          al_dup_cq02h[s] = 1'b1;
        if (al_v_cq01h[s] && al_v_cq01h[t] && t != s && al_warp_cq01h[s * LW +: LW] == al_warp_cq01h[t * LW +: LW])
          al_two_cq01h[s] = 1'b1;
      end
    end
  `CCV_ASSERT(al_free_slot, al_busy_cq02h == '0)
  `CCV_ASSERT(al_new_warp, al_dup_cq02h == '0 && al_two_cq01h == '0)
  `CCV_ASSERT(al_not_advanced, (al_v_cq01h & (adv_cq01h | adn_cq01h)) == '0)
  // keep_row_settled (OA 509 (3c), u_keep's table): u_keep reads a slot's
  // row (sv, sw, se, sn, s2, wq, wep) as the flops hold it, and a release
  // or an allocation writes the row at this edge, for the next cycle; an
  // advance it bypasses (adv, adn). So no uop of a warp released or
  // allocated in this cycle arrives in it: the read never meets the write.
  logic [E-1:0] chk_rdwr_cq02h;
  always_comb
    for (int k = 0; k < E; k++) begin
      chk_rdwr_cq02h[k] = 1'b0;
      for (int s = 0; s < S; s++)
        if (arv_v_cq01h[k] &&
            ((rel_cq01h[s] && sv_cq02h[s] && arv_warp_cq01h[k * LW +: LW] == swi_cq02h[s * LW +: LW]) ||
             (al_v_cq01h[s] && arv_warp_cq01h[k * LW +: LW] == al_warp_cq01h[s * LW +: LW])))
          chk_rdwr_cq02h[k] = 1'b1;
    end
  `CCV_ASSERT(keep_row_settled, chk_rdwr_cq02h == '0)
  // keep_ep_settled (OA 515 (1), u_keep's tables on se, sn, s2, wq and
  // wep): the same claim for the row's five epoch fields, which a release
  // or an allocation writes with it. No arrival of the slot's warp meets a
  // change of any of them at that write (an advance's change u_keep
  // bypasses, so only the release's and the allocation's count).
  logic [S-1:0] ep_wr_cq02h;
  logic [E-1:0] chk_epwr_cq02h;
  always_comb begin
    for (int s = 0; s < S; s++)
      ep_wr_cq02h[s] = (rel_cq01h[s] | al_v_cq01h[s]) &&
                       (se_nx_cq01h[s * EP +: EP] != sei_cq02h[s * EP +: EP] ||
                        sn_nx_cq01h[s * EP +: EP] != sni_cq02h[s * EP +: EP] ||
                        s2_nx_cq01h[s * EP +: EP] != s2i_cq02h[s * EP +: EP] ||
                        // wq clears at the write unless a walk opens, and
                        // wep takes the walk's epoch only then
                        wq_cq02h[s] != wo_cq01h[s] ||
                        (wo_cq01h[s] && wep_cq02h[s * EP +: EP] !=
                         (adv_cq01h[s] ? sni_cq02h[s * EP +: EP] : sei_cq02h[s * EP +: EP])));
    for (int k = 0; k < E; k++) begin
      chk_epwr_cq02h[k] = 1'b0;
      for (int s = 0; s < S; s++)
        if (arv_v_cq01h[k] && ep_wr_cq02h[s] &&
            ((sv_cq02h[s] && arv_warp_cq01h[k * LW +: LW] == swi_cq02h[s * LW +: LW]) ||
             (al_v_cq01h[s] && arv_warp_cq01h[k * LW +: LW] == al_warp_cq01h[s * LW +: LW])))
          chk_epwr_cq02h[k] = 1'b1;
    end
  end
  `CCV_ASSERT(keep_ep_settled, chk_epwr_cq02h == '0)
endmodule
`undef CCV_CLK
`undef CCV_RST
