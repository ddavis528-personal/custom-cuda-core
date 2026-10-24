//===-- ooe_confirm.sv - OOE confirmation and transitive cancel -----------===//
//
// Spec: the design doc's Confirmation and transitive cancel section (A-46:
//       a miss poisons everything woken from the load, transitively, and
//       poisoned entries return to Waiting), OA's response OI-50 (the
//       cancel is a level, decided every cycle from flops; V-67, V-68),
//       OA-17 (why a pulse is not enough), OI-12 (an entry with a
//       destination is held until its own result confirms) and V-16.
//
// An inner helper (ooe_confirm.ngd.json): combinational, no flops, timed in
// its parents. ooe_wake and ooe_rs each compute it from their own state
// (OI-50), so the replay reaches only the parent's own flops.
//
// Cancel. An issued entry returns to Waiting when it depends on a producer
// that is not issued (returned to Waiting, or never issued) or has missed
// its L1 slot (msd: the miss, held from the cycle after it until the load's
// completion). It is a level, decided every cycle, so an entry issued on a
// stale ready bit is caught in the cycle it issues (OA-17). A replay
// reaches the next level only through the parent's edge: one level a cycle.
//
// Confirm. An issued entry confirms when no dependency bit is left in its
// row and either it writes nothing or its result is final (ooe_wake's fin:
// the full-latency wake raised, no miss check pending). A confirmed
// producer is freed and its column cleared, so a consumer of one confirmed
// now confirms from the next cycle: one level a cycle. An entry replayed
// now is never confirmed now: its row names the producer that sends it
// back, so its row is not empty (V-16; confirm_tb checks it).
//
// The reference is the model's cancelHop and confirmPass, which log their
// inputs and decisions every cycle (Core::wakeLog: hop_iss, hop_dep,
// hop_msd, replay; cf_fin, cf_prod, conf). test/ooe/confirm_tb.cpp drives
// this module with them and compares both decisions, cycle by cycle, and
// runs OA-17's directed case.
//===----------------------------------------------------------------------===//
module ooe_confirm #(
  parameter int N = 45     // RS entries (CCV_P_RS_RCU + CCV_P_RS_MIU)
) (
  input  logic [N-1:0]   iss_cq01h,      // issued and unconfirmed
  input  logic [N*N-1:0] dep_cq01h,      // row i, column j: i waits on j
  input  logic [N-1:0]   msd_cq01h,      // missed its L1 slot, until its completion
  input  logic [N-1:0]   fin_cq01h,      // its timer calls its result final
  input  logic [N-1:0]   prod_cq01h,     // writes a register some entry may wake on
  output logic [N-1:0]   replay_cq01h,   // returns to Waiting this cycle
  output logic [N-1:0]   conf_cq01h      // confirmed this cycle: free it
);

  // A producer an issued entry may no longer stand on.
  logic [N-1:0] gone;
  assign gone = ~iss_cq01h | msd_cq01h;

  always_comb
    for (int i = 0; i < N; i++) begin
      replay_cq01h[i] = iss_cq01h[i] && |(dep_cq01h[i * N +: N] & gone);
      conf_cq01h[i]   = iss_cq01h[i] && dep_cq01h[i * N +: N] == '0 && (fin_cq01h[i] || !prod_cq01h[i]);
    end

endmodule
