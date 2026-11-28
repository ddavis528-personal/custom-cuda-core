//===-- ooe_decrx_keep.sv - OOE's A-70 arrival compare --------------------===//
//
// Spec: OA 428 (re:OI-165 (a)); ooe_decrx.sv says what holds the tables.
//
// An inner helper (ooe_decrx_keep.ngd.json): combinational, no flops, timed
// in ooe_decrx, which flops what it keeps (OA 429). Each arriving uop is kept when
// its warp holds a slot (a slot's warp equals the uop's) and its
// fetch_epoch is that slot's epoch, or the one or two after it when the
// slot advances once or twice in this cycle (the ordering invariant, OA 428
// (2)). A uop of a slot whose straggler walk is open is kept too when its
// fetch_epoch is the walk's (AR 395): from the walk's flops, unless a
// kill's notice closes it now, or, in the cycle a demotion's notice opens
// it, the slot's epoch before that notice. A kept uop
// carries its slot. A port may be idle between busy ones once a uop is
// dropped: ooe_decq ranks its arrivals by port, not by position.
//
// The input contract, which ooe_decrx asserts where the clock is: a warp
// holds at most one slot, so at most one slot matches.
//===----------------------------------------------------------------------===//
module ooe_decrx_keep #(
  parameter int S  = 4,                  // tier-1 slots (CCV_TIER1_WARPS)
  parameter int E  = 6,                  // arrivals a cycle (ccv_dec_ooe_uop's rate)
  parameter int NW = 32,                 // warp_ids (2 ** CCV_W_WARP_ID)
  parameter int EP = 3,                  // fetch epoch bits (CCV_P_W_FETCH_EPOCH)
  localparam int LS = $clog2(S),
  localparam int LW = $clog2(NW)
) (
  input  logic [E-1:0]     arv_v_cq01h,    // port k carries a uop
  input  logic [E*LW-1:0]  arv_warp_cq01h, // its warp_id
  input  logic [E*EP-1:0]  arv_ep_cq01h,   // its fetch_epoch
  input  logic [S-1:0]     adv_cq01h,      // slot s advances this cycle: a redirect
  input  logic [S-1:0]     adn_cq01h,      // and again: an epoch notice
  input  logic [S-1:0]     wo_cq01h,       // the notice is a demotion's: the walk opens now
  input  logic [S-1:0]     wq_cq02h,       // the slot's straggler walk is open
  input  logic [S*EP-1:0]  wep_cq02h,      // the epoch its stragglers carry
  input  logic [S-1:0]     sv_cq02h,       // ooe_decrx's tables
  input  logic [S*LW-1:0]  sw_cq02h,
  input  logic [S*EP-1:0]  se_cq02h,
  input  logic [S*EP-1:0]  sn_cq02h,
  input  logic [S*EP-1:0]  s2_cq02h,
  output logic [E-1:0]     enq_v_cq01h,    // port k's uop is kept
  output logic [E*LS-1:0]  enq_slot_cq01h  // its slot
);
  always_comb
    for (int k = 0; k < E; k++) begin
      logic [S-1:0] hit_cq01h, ok_cq01h;
      logic [LS-1:0] slot;
      for (int s = 0; s < S; s++) begin
        hit_cq01h[s] = sv_cq02h[s] && arv_warp_cq01h[k * LW +: LW] == sw_cq02h[s * LW +: LW];
        ok_cq01h[s] = adv_cq01h[s] && adn_cq01h[s] ? arv_ep_cq01h[k * EP +: EP] == s2_cq02h[s * EP +: EP]
              : adv_cq01h[s] || adn_cq01h[s] ? arv_ep_cq01h[k * EP +: EP] == sn_cq02h[s * EP +: EP]
                                             : arv_ep_cq01h[k * EP +: EP] == se_cq02h[s * EP +: EP];
        // The walk's keep: the epoch the demotion ends (it opens the walk
        // in this cycle) or the one an open walk holds. wo comes late, so
        // it enters as one AND of its own (a sum of products).
        ok_cq01h[s] = ok_cq01h[s]
             || (wo_cq01h[s] && adv_cq01h[s] && arv_ep_cq01h[k * EP +: EP] == sn_cq02h[s * EP +: EP])
             || (wo_cq01h[s] && !adv_cq01h[s] && arv_ep_cq01h[k * EP +: EP] == se_cq02h[s * EP +: EP])
             || (wq_cq02h[s] && !adn_cq01h[s] && arv_ep_cq01h[k * EP +: EP] == wep_cq02h[s * EP +: EP]);
      end
      slot = '0;
      for (int s = 0; s < S; s++)
        if (hit_cq01h[s]) slot = slot | LS'(s);
      enq_v_cq01h[k] = arv_v_cq01h[k] && (hit_cq01h & ok_cq01h) != '0;
      enq_slot_cq01h[k * LS +: LS] = slot;
    end
endmodule
