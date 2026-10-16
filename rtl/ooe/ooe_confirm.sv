//===-- ooe_confirm.sv - OOE confirmation and transitive cancel -----------===//
//
// Spec: the design doc's Confirmation and transitive cancel section (A-46:
//       a miss poisons everything woken from the load, transitively, and
//       poisoned entries return to Waiting), its scheduler timing findings
//       (OA-1: "transitive cancel moves one hop per cycle", held by V-59),
//       OI-12 (an entry with a destination is held until its own result
//       confirms) and V-16.
//
// Cancel. An issued, unconfirmed entry returns to Waiting when it depends
// on an entry that missed its L1 slot this cycle or returned to Waiting
// last cycle: one hop through the dependency matrix a cycle. The hop is
// decided whole, so an entry replayed now reaches its own dependants only
// at the next hop, through the register of this cycle's replays. A miss
// starts a hop in its own cycle: the timers report it from the edge's next
// state (ooe_wake's miss, taken a cycle early here), so its direct
// dependants never issue again on the withdrawn wake.
//
// Confirm. An issued entry confirms when no dependency bit is left in its
// row and either it writes nothing or its timer calls its result final
// (ooe_wake's fin: the full-latency wake raised, no miss check pending). A
// confirmed producer is freed and its column cleared, so a consumer of one
// confirmed now confirms from the next cycle: one level a cycle, as the
// model's confirmPass now takes it. An entry replayed now is never
// confirmed now: it depends on a poisoned producer, whose bit is still set.
//
// The reference is the model's cancelHop and confirmPass, which log their
// inputs and decisions every cycle (Core::wakeLog: hop_iss, hop_dep, miss,
// replay; cf_iss, cf_fin, cf_prod, cf_dep, conf). test/ooe/confirm_tb.cpp
// drives this module with the inputs and compares both decisions, cycle by
// cycle, the hop register included.
//
// Reset line (decision 6): the replay register resets to empty. State is
// one register, its next value a function of it and this cycle's inputs
// (CCV-L23); the flop takes one function, step(), with reset folded in.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK ooe_core_clk
`define CCV_RST ooe_rst_r00h
module ooe_confirm #(
  parameter int N = 45     // RS entries (CCV_P_RS_RCU + CCV_P_RS_MIU)
) (
  input  logic           ooe_core_clk,
  input  logic           ooe_rst_r00h,
  input  logic [N-1:0]   iss_cq01h,      // issued and unconfirmed
  input  logic [N*N-1:0] dep_cq01h,      // row i, column j: i waits on j
  input  logic [N-1:0]   miss_cq01h,     // missed its L1 slot this cycle
  input  logic [N-1:0]   fin_cq01h,      // its timer calls its result final
  input  logic [N-1:0]   prod_cq01h,     // writes a register some entry may wake on
  output logic [N-1:0]   replay_cq02h,   // returns to Waiting this cycle
  output logic [N-1:0]   conf_cq01h      // confirmed this cycle: free it
);

  `CCV_ASSERT_KNOWN(iss_known, iss_cq01h)
  `CCV_ASSERT_KNOWN(miss_known, miss_cq01h)

  // The hop: an issued entry with a dependency on a poisoned producer.
  function automatic logic [N-1:0] hop(input logic [N-1:0] iss, input logic [N*N-1:0] dep,
                                       input logic [N-1:0] poison);
    logic [N-1:0] r;
    for (int i = 0; i < N; i++) r[i] = iss[i] && |(dep[i * N +: N] & poison);
    hop = r;
  endfunction

  // Confirmation: no dependency left, and the result final or none.
  function automatic logic [N-1:0] confirm(input logic [N-1:0] iss, input logic [N*N-1:0] dep,
                                           input logic [N-1:0] fin, input logic [N-1:0] prod);
    logic [N-1:0] c;
    for (int i = 0; i < N; i++) c[i] = iss[i] && dep[i * N +: N] == '0 && (fin[i] || !prod[i]);
    confirm = c;
  endfunction

  // One edge: reset, or this cycle's replays.
  function automatic logic [N-1:0] step(input logic [N-1:0] rep, input logic rst, input logic [N-1:0] iss,
                                        input logic [N*N-1:0] dep, input logic [N-1:0] miss);
    step = rst ? '0 : hop(iss, dep, miss | rep);
  endfunction

  logic [N-1:0] rep_cq02h;   // the entries the last hop returned to Waiting
  always_comb begin
    replay_cq02h = hop(iss_cq01h, dep_cq01h, miss_cq01h | rep_cq02h);
    conf_cq01h   = confirm(iss_cq01h, dep_cq01h, fin_cq01h, prod_cq01h);
  end

  // V-16, as this block sees it: nothing is both replayed and confirmed.
  `CCV_ASSERT(replay_or_confirm, (replay_cq02h & conf_cq01h) == '0)

  always_ff @(posedge ooe_core_clk) begin
    rep_cq02h <= step(rep_cq02h, ooe_rst_r00h, iss_cq01h, dep_cq01h, miss_cq01h);
  end

endmodule
`undef CCV_CLK
`undef CCV_RST
