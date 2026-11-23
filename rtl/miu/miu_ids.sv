//===-- miu_ids.sv - MIU DCU req_ids: free list, preselected ids, entries -===//
//
// Spec: docs/design-snapshots/miu-spec.md (live: CCV per-block architecture
//       specs, MIU tab, "MA's Phase 2", slice 1: the stage table's A2 row,
//       the module partition's miu_ids row; "Entries, credits and req_ids",
//       MA-6: 64 ids toward DCU).
//
// A lookup holds its req_id from launch (the payload at A2's flops, H+2) to
// the response MIU holds (R1). A dropped lookup (MA-27) gives its id back:
// miu_a2's drop flop names it a cycle after the take, and the id is free
// two cycles after that. The 64
// ids split into NS quarters of 16, and lookup slot k takes only from
// quarter k, so the four takes of a cycle never meet and each quarter's pick
// is its own: a priority over 16 bits, never a serial search for four free
// ids among 64. A slot whose quarter is empty holds its lookup, as the
// model's IdPool does when the pool is (MI-27 notes the narrower rule).
//
// Each quarter keeps its next id preselected in a flop (pid, valid pv), from
// the free vector a cycle ahead. In A2 slot k takes it (tk[k], miu_lead's
// launch flop: miu_a2 reads pid into the req payload). The next pick is computed before the
// take arrives: the lowest free id of the quarter other than the preselected
// one, so the take only drives a 2:1 at the flop (take, or no id held: the
// new pick; else keep). An id released this cycle is free from the next.
//
// The id-to-entry table: at the take, row id gets the lookup's MQ entry
// (te[k]). At R2 a response's req_id (qid, miu_rcap's capture) reads its
// row into a flop (qe), and this module holds the id. A cycle on, rl frees
// the held id, unless the response was a recovered UE's first answer, whose
// id stays live for the second (AR 370; the releaser decides, once the
// syndrome's flag is flopped). So no release carries an id: it names a read.
//
// Stage tags: A2 is 06. The free vector, the preselected ids, the table,
// the held drops and this module's own leads are its state, one stage, 06,
// as a queue's entries are (CCV-L23's own-stage state); the drops (A2's flop
// a cycle on) and the releases arrive at 06 too, numbered back from their
// effect, as miu_cred's refunds are. A read is numbered back from the free
// vector its release changes: the read 05, its flops (the entry out, the id
// held) 06.
//
// Clock gating (CG-5): the takes, drops, releases and reads are inputs, so
// no enable sees them. This module flops its own leads: a lookup in A1
// (lv, a take may follow), a take (a drop may follow) and a response
// captured (rs: reads follow, then releases); every gate opens on those.
//
// Inputs are other MIU modules' flops: qid from miu_rcap's at arrival 0
// (miu_ids.ngd.json, MI-28), the rest at the default, and
// every output comes straight from a flop (MIU tab, Port NGD budgets).
//
// The reference is the MIU model's IdPool (sim/skel/stub.h) and its uses in
// sim/miu/miu_block.cpp; test/miu/ids_tb.cpp holds this module to a value
// model of the scheme above.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK miu_core_clk
`define CCV_RST rst_r01h
module miu_ids #(
  parameter  int NS = ccv_params_pkg::CCV_MIU_PIPES,                 // lookup slots, 4
  parameter  int IW = ccv_prov_pkg::CCV_P_W_REQ_MIU_DCU,           // req_id, 6
  parameter  int NE = ccv_params_pkg::CCV_MIU_PIPES * ccv_prov_pkg::CCV_MEMOP_CREDITS,   // MQ entries, 40
  parameter  int NR = ccv_params_pkg::CCV_MIU_PIPES,                 // releases and reads a cycle, 4
  localparam int NI = 1 << IW,                                       // ids, 64
  localparam int QN = NI / NS,                                       // ids a quarter, 16
  localparam int QW = $clog2(QN),
  localparam int EW = $clog2(NE)
) (
  input  logic             miu_core_clk,
  input  logic             rst_n,
  // A1: slot k holds a lookup, which may take its id in A2 next cycle.
  input  logic [NS-1:0]    lv_cm05h,
  // A2: slot k's lookup launches (miu_lead's flops) and takes its
  // preselected id, for MQ entry te[k].
  input  logic [NS-1:0]    tk_cm06h,
  input  logic [NS*EW-1:0] te_cm06h,
  // A2's drop (miu_a2's flops, a cycle on): slot k's lookup that took an id
  // last cycle was dropped; the id is free two cycles on.
  input  logic [NS-1:0]    dp_cm06h,
  // A2: slot k's preselected id and whether it holds one.
  output logic [NS*IW-1:0] pid_cm06h,
  output logic [NS-1:0]    pv_cm06h,
  // A response is captured: its reads come next cycle.
  input  logic             rs_cm04h,
  // Reads: rsp slot j's req_id qid[j] (miu_rcap's capture) reads its entry,
  // flopped; the id is held here too, for the release.
  input  logic [NR-1:0]    qv_cm05h,
  input  logic [NR*IW-1:0] qid_cm05h,
  output logic [NR*EW-1:0] qe_cm06h,
  // Releases, a cycle after the read: rl[j] frees the id read last cycle on
  // read port j, free from the next cycle.
  input  logic [NR-1:0]    rl_cm06h
);

  if (NI % NS != 0 || QN < 2) begin : g_chk
    $error("miu_ids: %0d ids do not split into %0d quarters of 2 or more", NI, NS);
  end

  // rst_n flopped before any use (RST-1), inverted after the flop.
  logic rst_cr01h_n;
  always_ff @(posedge miu_core_clk) begin
    rst_cr01h_n <= rst_n;
  end
  wire rst_r01h = !rst_cr01h_n;

  // ---- This module's own record of what may change (CG-5) ----------------
  // lv_q[k]: slot k had a lookup in A1 last cycle, so it may take now; rs_q:
  // a response was captured last cycle, so ids are read now; rd_q: ids were
  // read last cycle, so they may be released now.
  // Every enable below comes from these flops, never from the take or the
  // release on the wire, which only select data.
  logic [NS-1:0] lv_q_cm06h;
  logic          rs_q_cm05h;
  logic          rd_q_cm06h;
  logic          ch_q_cm06h;           // a release or a drop freed an id last cycle
  logic          tl_q_cm06h;           // a take last cycle (a drop may follow)
  always_ff @(posedge miu_core_clk) begin
    if (rst_r01h) begin
      lv_q_cm06h <= '0;
      rs_q_cm05h <= 1'b0;
      rd_q_cm06h <= 1'b0;
      ch_q_cm06h <= 1'b1;
      tl_q_cm06h <= 1'b0;
    end else begin
      lv_q_cm06h <= lv_cm05h;
      rs_q_cm05h <= rs_cm04h;
      rd_q_cm06h <= rs_q_cm05h;
      ch_q_cm06h <= (|rl_cm06h) || (|dqv_q_cm06h);
      tl_q_cm06h <= |tk_cm06h;
    end
  end

  // ---- The free vector -----------------------------------------------------
  logic [NI-1:0] fr_q_cm06h;           // 1: free
  // The preselected id within its quarter and its valid: one copy for the
  // outputs, one for the picks and the table's enables (NGD-7).
  (* keep *) logic [NS-1:0]    pv_q_cm06h, pvo_q_cm06h;
  (* keep *) logic [NS*QW-1:0] pq_q_cm06h, pqo_q_cm06h;

  // The ids read last cycle (written with the entries read, below).
  logic [NR*IW-1:0] qi_q_cm06h;

  // The releases, decoded.
  logic [NI-1:0] rl_oh_cm06h;
  always_comb begin
    rl_oh_cm06h = '0;
    for (int j = 0; j < NR; j++)
      if (rl_cm06h[j]) rl_oh_cm06h[qi_q_cm06h[j*IW +: IW]] = 1'b1;
  end

  // The id each slot took last cycle, for a drop to give back.
  logic [NS*QW-1:0] tid_q_cm06h;
  wire tid_en_cm06h = |lv_q_cm06h;
  always_ff @(posedge miu_core_clk) begin
    if (tid_en_cm06h) tid_q_cm06h <= pq_q_cm06h;
  end
  // A drop, held a cycle with the id it gives back (each slot's valid and
  // id), so the free vector opens only when an id is freed: the gate opens
  // after a take, when a drop may arrive, or while one is held.
  logic [NS-1:0]    dqv_q_cm06h;
  logic [NS*QW-1:0] dqi_q_cm06h;
  wire dq_en_cm06h = tl_q_cm06h || (|dqv_q_cm06h) || rst_r01h;
  always_ff @(posedge miu_core_clk) begin
    if (dq_en_cm06h) begin
      if (rst_r01h) dqv_q_cm06h <= '0;
      else          dqv_q_cm06h <= dp_cm06h;
      dqi_q_cm06h <= tid_q_cm06h;
    end
  end
  logic [NI-1:0] dp_oh_cm06h;
  always_comb begin
    dp_oh_cm06h = '0;
    for (int k = 0; k < NS; k++)
      if (dqv_q_cm06h[k]) dp_oh_cm06h[IW'(k * QN) | IW'(dqi_q_cm06h[k*QW +: QW])] = 1'b1;
  end

  // Per quarter: the next pick, the lowest free id but the preselected one;
  // the takes, decoded; the preselect's next value.
  logic [NS*QW-1:0] nq_cm06h, pq_d_cm06h;
  logic [NS-1:0]    nv_cm06h, pv_d_cm06h;
  logic [NI-1:0]    tk_oh_cm06h;
  always_comb begin
    tk_oh_cm06h = '0;
    for (int k = 0; k < NS; k++) begin
      logic [QN-1:0] f;
      f = fr_q_cm06h[k*QN +: QN];
      if (pv_q_cm06h[k]) f[pq_q_cm06h[k*QW +: QW]] = 1'b0;
      nq_cm06h[k*QW +: QW] = '0;
      nv_cm06h[k] = 1'b0;
      for (int i = QN - 1; i >= 0; i--)
        if (f[i]) begin
          nq_cm06h[k*QW +: QW] = QW'(i);
          nv_cm06h[k] = 1'b1;
        end
      if (tk_cm06h[k]) tk_oh_cm06h[IW'(k * QN) | IW'(pq_q_cm06h[k*QW +: QW])] = 1'b1;
      if (tk_cm06h[k] || !pv_q_cm06h[k]) begin
        pv_d_cm06h[k]          = nv_cm06h[k];
        pq_d_cm06h[k*QW +: QW] = nq_cm06h[k*QW +: QW];
      end else begin
        pv_d_cm06h[k]          = 1'b1;
        pq_d_cm06h[k*QW +: QW] = pq_q_cm06h[k*QW +: QW];
      end
    end
  end

  // The free vector changes on a take or a release; the picks on a take, or
  // while a quarter holds no id and a release may have refilled it.
  wire fr_en_cm06h = (|(lv_q_cm06h & pv_q_cm06h)) || rd_q_cm06h || (|dqv_q_cm06h) || rst_r01h;
  always_ff @(posedge miu_core_clk) begin
    if (fr_en_cm06h) begin
      if (rst_r01h) fr_q_cm06h <= '1;
      else          fr_q_cm06h <= (fr_q_cm06h & ~tk_oh_cm06h) | rl_oh_cm06h | dp_oh_cm06h;
    end
  end
  wire pk_en_cm06h = (|(lv_q_cm06h & pv_q_cm06h)) || (ch_q_cm06h && !(&pv_q_cm06h)) || rst_r01h;
  always_ff @(posedge miu_core_clk) begin
    if (pk_en_cm06h) begin
      if (rst_r01h) begin
        pv_q_cm06h  <= '0;
        pvo_q_cm06h <= '0;
        pq_q_cm06h  <= '0;
        pqo_q_cm06h <= '0;
      end else begin
        pv_q_cm06h  <= pv_d_cm06h;
        pvo_q_cm06h <= pv_d_cm06h;
        pq_q_cm06h  <= pq_d_cm06h;
        pqo_q_cm06h <= pq_d_cm06h;
      end
    end
  end
  always_comb
    for (int k = 0; k < NS; k++)
      pid_cm06h[k*IW +: IW] = IW'(k * QN) | IW'(pqo_q_cm06h[k*QW +: QW]);
  assign pv_cm06h = pvo_q_cm06h;

  // ---- The id-to-entry table ---------------------------------------------
  // One clock gate a quarter (16 rows, 96 flops), open when the quarter had
  // a lookup in A1 and holds a preselected id. Its preselected row is
  // written with the lookup's entry whether or not the lookup takes the id:
  // that row's id is free, so its row is read only after a take, which
  // writes it. The row is chosen by the preselect, this module's own flop,
  // and the other rows hold as AND-OR on D, keeping the quarter's one
  // enable (rtl-coding-style.md, "A field held inside a group"); the take
  // touches the free vector only.
  logic [NI*EW-1:0] tb_q_cm06h;
  for (genvar k = 0; k < NS; k = k + 1) begin : g_tq
    wire tb_en_cm06h = lv_q_cm06h[k] && pv_q_cm06h[k];
    logic [QN*EW-1:0] tb_d_cm06h;
    always_comb
      for (int r = 0; r < QN; r++) begin
        logic w;
        w = pq_q_cm06h[k*QW +: QW] == QW'(r);
        tb_d_cm06h[r*EW +: EW] = ({EW{w}} & te_cm06h[k*EW +: EW]) |
                                 ({EW{!w}} & tb_q_cm06h[(k*QN + r)*EW +: EW]);
      end
    always_ff @(posedge miu_core_clk) begin
      if (tb_en_cm06h) tb_q_cm06h[k*QN*EW +: QN*EW] <= tb_d_cm06h;
    end
  end
  logic [NR*EW-1:0] qe_d_cm05h;
  always_comb
    for (int j = 0; j < NR; j++)
      qe_d_cm05h[j*EW +: EW] = tb_q_cm06h[qid_cm05h[j*IW +: IW]*EW +: EW];
  // The entries read and the ids, one gate.
  wire qe_en_cm05h = rs_q_cm05h;
  logic [NR*EW-1:0] qe_q_cm06h;
  always_ff @(posedge miu_core_clk) begin
    if (qe_en_cm05h) begin
      qe_q_cm06h <= qe_d_cm05h;
      qi_q_cm06h <= qid_cm05h;
    end
  end
  assign qe_cm06h = qe_q_cm06h;

  // ---- Checks --------------------------------------------------------------
  // A take holds its id; a release frees one held.
  logic [NR-1:0] rl_free_cm06h;        // a release of an id already free
  always_comb
    for (int j = 0; j < NR; j++)
      rl_free_cm06h[j] = rl_cm06h[j] && fr_q_cm06h[qi_q_cm06h[j*IW +: IW]];
  `CCV_ASSERT(tk_held, (tk_cm06h & ~(pv_q_cm06h & lv_q_cm06h)) == '0)
  `CCV_ASSERT(dp_take, tl_q_cm06h || dp_cm06h == '0)
  `CCV_ASSERT(rs_lead, rs_q_cm05h || qv_cm05h == '0)
  `CCV_ASSERT(rl_read, rd_q_cm06h || rl_cm06h == '0)
  `CCV_ASSERT(rl_live, rl_free_cm06h == '0)

endmodule
`undef CCV_CLK
`undef CCV_RST
