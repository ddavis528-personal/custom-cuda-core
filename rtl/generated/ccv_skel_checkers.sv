// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-skel.py from schema/interfaces.json,
// params/blocks.json and params/ccv_params.json. Edit a source and
// regenerate; tools/verify.sh fails if this file is stale.


// One ccv_credit_checker per slot of every channel instance --
// 345 in all. Verilated into the C++ skeleton, which drives these
// ports from its channels every cycle, so the skeleton is judged
// by the same checker the RTL will be.
`include "ccv_if.svh"
`include "ccv_params_pkg.sv"

module ccv_skel_checkers (
  input logic                 clk,
  input logic                 rst_n,
  input logic [344:0]          valid,
  input logic [344:0]          credit,
  input logic [344:0]          stall,
  input logic [68696:0]          payload,
  // Test override: switches EVERY multi-slot channel's atomic
  // check on. It can only add checks -- a channel the schema
  // marks atomic is checked whatever this says.
  input logic                 force_atomic,
  // Request/response pairs with an outstanding limit. Off only for
  // the S0 exerciser, whose synthetic traffic sends on each channel
  // independently; on for the functional stubs and in the SV top.
  input logic                 pair_enable,
  // Per channel instance: its _wake, and its receiver's sleep_ok (Q-33).
  // The C++ skeleton drives both low -- no stub sleeps yet -- and the
  // SV top drives the real nets, so the first block that gates its
  // clock is held to the wake contract from its first cycle.
  input logic [107:0]          wake,
  input logic [107:0]          rx_gated
`ifdef CCV_TRACE
  ,
  // Trace-only message identity, 64 bits per slot. Absent
  // without CCV_TRACE, so synthesis never sees it.
  input logic [22079:0]          tid
`endif
);

  ccv_credit_checker #(.PAYLOAD_W(122), .CHANNEL(0)) u_fet_dec_instr_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[0]), .ch_credit(credit[0]), .ch_stall(stall[0]),
    .ch_payload(payload[121:0])
`ifdef CCV_TRACE
    , .ch_tid(tid[63:0])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(122), .CHANNEL(0)) u_fet_dec_instr_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[1]), .ch_credit(credit[1]), .ch_stall(stall[1]),
    .ch_payload(payload[243:122])
`ifdef CCV_TRACE
    , .ch_tid(tid[127:64])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(122), .CHANNEL(0)) u_fet_dec_instr_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[2]), .ch_credit(credit[2]), .ch_stall(stall[2]),
    .ch_payload(payload[365:244])
`ifdef CCV_TRACE
    , .ch_tid(tid[191:128])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(122), .CHANNEL(0)) u_fet_dec_instr_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[3]), .ch_credit(credit[3]), .ch_stall(stall[3]),
    .ch_payload(payload[487:366])
`ifdef CCV_TRACE
    , .ch_tid(tid[255:192])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(122), .CHANNEL(0)) u_fet_dec_instr_s4 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[4]), .ch_credit(credit[4]), .ch_stall(stall[4]),
    .ch_payload(payload[609:488])
`ifdef CCV_TRACE
    , .ch_tid(tid[319:256])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(122), .CHANNEL(0)) u_fet_dec_instr_s5 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[5]), .ch_credit(credit[5]), .ch_stall(stall[5]),
    .ch_payload(payload[731:610])
`ifdef CCV_TRACE
    , .ch_tid(tid[383:320])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(122), .CHANNEL(0)) u_fet_dec_instr_s6 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[6]), .ch_credit(credit[6]), .ch_stall(stall[6]),
    .ch_payload(payload[853:732])
`ifdef CCV_TRACE
    , .ch_tid(tid[447:384])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(122), .CHANNEL(0)) u_fet_dec_instr_s7 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[7]), .ch_credit(credit[7]), .ch_stall(stall[7]),
    .ch_payload(payload[975:854])
`ifdef CCV_TRACE
    , .ch_tid(tid[511:448])
`endif
  );
  ccv_atomic_checker #(.N(8)) u_fet_dec_instr_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[7:0]), .credit(credit[7:0]));
  ccv_credit_checker #(.PAYLOAD_W(137), .CHANNEL(1)) u_dec_ooe_uop_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[8]), .ch_credit(credit[8]), .ch_stall(stall[8]),
    .ch_payload(payload[1112:976])
`ifdef CCV_TRACE
    , .ch_tid(tid[575:512])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(137), .CHANNEL(1)) u_dec_ooe_uop_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[9]), .ch_credit(credit[9]), .ch_stall(stall[9]),
    .ch_payload(payload[1249:1113])
`ifdef CCV_TRACE
    , .ch_tid(tid[639:576])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(137), .CHANNEL(1)) u_dec_ooe_uop_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[10]), .ch_credit(credit[10]), .ch_stall(stall[10]),
    .ch_payload(payload[1386:1250])
`ifdef CCV_TRACE
    , .ch_tid(tid[703:640])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(137), .CHANNEL(1)) u_dec_ooe_uop_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[11]), .ch_credit(credit[11]), .ch_stall(stall[11]),
    .ch_payload(payload[1523:1387])
`ifdef CCV_TRACE
    , .ch_tid(tid[767:704])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(137), .CHANNEL(1)) u_dec_ooe_uop_s4 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[12]), .ch_credit(credit[12]), .ch_stall(stall[12]),
    .ch_payload(payload[1660:1524])
`ifdef CCV_TRACE
    , .ch_tid(tid[831:768])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(137), .CHANNEL(1)) u_dec_ooe_uop_s5 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[13]), .ch_credit(credit[13]), .ch_stall(stall[13]),
    .ch_payload(payload[1797:1661])
`ifdef CCV_TRACE
    , .ch_tid(tid[895:832])
`endif
  );
  ccv_atomic_checker #(.N(6)) u_dec_ooe_uop_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[13:8]), .credit(credit[13:8]));
  ccv_credit_checker #(.PAYLOAD_W(138), .CHANNEL(2)) u_ooe_rcu_issue_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[14]), .ch_credit(credit[14]), .ch_stall(stall[14]),
    .ch_payload(payload[1935:1798])
`ifdef CCV_TRACE
    , .ch_tid(tid[959:896])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(138), .CHANNEL(2)) u_ooe_rcu_issue_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[15]), .ch_credit(credit[15]), .ch_stall(stall[15]),
    .ch_payload(payload[2073:1936])
`ifdef CCV_TRACE
    , .ch_tid(tid[1023:960])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(138), .CHANNEL(2)) u_ooe_rcu_issue_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[16]), .ch_credit(credit[16]), .ch_stall(stall[16]),
    .ch_payload(payload[2211:2074])
`ifdef CCV_TRACE
    , .ch_tid(tid[1087:1024])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(138), .CHANNEL(2)) u_ooe_rcu_issue_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[17]), .ch_credit(credit[17]), .ch_stall(stall[17]),
    .ch_payload(payload[2349:2212])
`ifdef CCV_TRACE
    , .ch_tid(tid[1151:1088])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_ooe_rcu_issue_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[17:14]), .credit(credit[17:14]));
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i0_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[18]), .ch_credit(credit[18]), .ch_stall(stall[18]),
    .ch_payload(payload[2460:2350])
`ifdef CCV_TRACE
    , .ch_tid(tid[1215:1152])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i0_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[19]), .ch_credit(credit[19]), .ch_stall(stall[19]),
    .ch_payload(payload[2571:2461])
`ifdef CCV_TRACE
    , .ch_tid(tid[1279:1216])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i0_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[20]), .ch_credit(credit[20]), .ch_stall(stall[20]),
    .ch_payload(payload[2682:2572])
`ifdef CCV_TRACE
    , .ch_tid(tid[1343:1280])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i0_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[21]), .ch_credit(credit[21]), .ch_stall(stall[21]),
    .ch_payload(payload[2793:2683])
`ifdef CCV_TRACE
    , .ch_tid(tid[1407:1344])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_rcu_lane_ops_i0_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[21:18]), .credit(credit[21:18]));
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i1_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[22]), .ch_credit(credit[22]), .ch_stall(stall[22]),
    .ch_payload(payload[2904:2794])
`ifdef CCV_TRACE
    , .ch_tid(tid[1471:1408])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i1_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[23]), .ch_credit(credit[23]), .ch_stall(stall[23]),
    .ch_payload(payload[3015:2905])
`ifdef CCV_TRACE
    , .ch_tid(tid[1535:1472])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i1_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[24]), .ch_credit(credit[24]), .ch_stall(stall[24]),
    .ch_payload(payload[3126:3016])
`ifdef CCV_TRACE
    , .ch_tid(tid[1599:1536])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i1_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[25]), .ch_credit(credit[25]), .ch_stall(stall[25]),
    .ch_payload(payload[3237:3127])
`ifdef CCV_TRACE
    , .ch_tid(tid[1663:1600])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_rcu_lane_ops_i1_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[25:22]), .credit(credit[25:22]));
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i2_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[26]), .ch_credit(credit[26]), .ch_stall(stall[26]),
    .ch_payload(payload[3348:3238])
`ifdef CCV_TRACE
    , .ch_tid(tid[1727:1664])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i2_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[27]), .ch_credit(credit[27]), .ch_stall(stall[27]),
    .ch_payload(payload[3459:3349])
`ifdef CCV_TRACE
    , .ch_tid(tid[1791:1728])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i2_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[28]), .ch_credit(credit[28]), .ch_stall(stall[28]),
    .ch_payload(payload[3570:3460])
`ifdef CCV_TRACE
    , .ch_tid(tid[1855:1792])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i2_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[29]), .ch_credit(credit[29]), .ch_stall(stall[29]),
    .ch_payload(payload[3681:3571])
`ifdef CCV_TRACE
    , .ch_tid(tid[1919:1856])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_rcu_lane_ops_i2_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[29:26]), .credit(credit[29:26]));
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i3_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[30]), .ch_credit(credit[30]), .ch_stall(stall[30]),
    .ch_payload(payload[3792:3682])
`ifdef CCV_TRACE
    , .ch_tid(tid[1983:1920])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i3_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[31]), .ch_credit(credit[31]), .ch_stall(stall[31]),
    .ch_payload(payload[3903:3793])
`ifdef CCV_TRACE
    , .ch_tid(tid[2047:1984])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i3_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[32]), .ch_credit(credit[32]), .ch_stall(stall[32]),
    .ch_payload(payload[4014:3904])
`ifdef CCV_TRACE
    , .ch_tid(tid[2111:2048])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i3_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[33]), .ch_credit(credit[33]), .ch_stall(stall[33]),
    .ch_payload(payload[4125:4015])
`ifdef CCV_TRACE
    , .ch_tid(tid[2175:2112])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_rcu_lane_ops_i3_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[33:30]), .credit(credit[33:30]));
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i4_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[34]), .ch_credit(credit[34]), .ch_stall(stall[34]),
    .ch_payload(payload[4236:4126])
`ifdef CCV_TRACE
    , .ch_tid(tid[2239:2176])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i4_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[35]), .ch_credit(credit[35]), .ch_stall(stall[35]),
    .ch_payload(payload[4347:4237])
`ifdef CCV_TRACE
    , .ch_tid(tid[2303:2240])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i4_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[36]), .ch_credit(credit[36]), .ch_stall(stall[36]),
    .ch_payload(payload[4458:4348])
`ifdef CCV_TRACE
    , .ch_tid(tid[2367:2304])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i4_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[37]), .ch_credit(credit[37]), .ch_stall(stall[37]),
    .ch_payload(payload[4569:4459])
`ifdef CCV_TRACE
    , .ch_tid(tid[2431:2368])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_rcu_lane_ops_i4_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[37:34]), .credit(credit[37:34]));
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i5_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[38]), .ch_credit(credit[38]), .ch_stall(stall[38]),
    .ch_payload(payload[4680:4570])
`ifdef CCV_TRACE
    , .ch_tid(tid[2495:2432])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i5_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[39]), .ch_credit(credit[39]), .ch_stall(stall[39]),
    .ch_payload(payload[4791:4681])
`ifdef CCV_TRACE
    , .ch_tid(tid[2559:2496])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i5_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[40]), .ch_credit(credit[40]), .ch_stall(stall[40]),
    .ch_payload(payload[4902:4792])
`ifdef CCV_TRACE
    , .ch_tid(tid[2623:2560])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i5_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[41]), .ch_credit(credit[41]), .ch_stall(stall[41]),
    .ch_payload(payload[5013:4903])
`ifdef CCV_TRACE
    , .ch_tid(tid[2687:2624])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_rcu_lane_ops_i5_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[41:38]), .credit(credit[41:38]));
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i6_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[42]), .ch_credit(credit[42]), .ch_stall(stall[42]),
    .ch_payload(payload[5124:5014])
`ifdef CCV_TRACE
    , .ch_tid(tid[2751:2688])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i6_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[43]), .ch_credit(credit[43]), .ch_stall(stall[43]),
    .ch_payload(payload[5235:5125])
`ifdef CCV_TRACE
    , .ch_tid(tid[2815:2752])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i6_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[44]), .ch_credit(credit[44]), .ch_stall(stall[44]),
    .ch_payload(payload[5346:5236])
`ifdef CCV_TRACE
    , .ch_tid(tid[2879:2816])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i6_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[45]), .ch_credit(credit[45]), .ch_stall(stall[45]),
    .ch_payload(payload[5457:5347])
`ifdef CCV_TRACE
    , .ch_tid(tid[2943:2880])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_rcu_lane_ops_i6_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[45:42]), .credit(credit[45:42]));
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i7_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[46]), .ch_credit(credit[46]), .ch_stall(stall[46]),
    .ch_payload(payload[5568:5458])
`ifdef CCV_TRACE
    , .ch_tid(tid[3007:2944])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i7_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[47]), .ch_credit(credit[47]), .ch_stall(stall[47]),
    .ch_payload(payload[5679:5569])
`ifdef CCV_TRACE
    , .ch_tid(tid[3071:3008])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i7_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[48]), .ch_credit(credit[48]), .ch_stall(stall[48]),
    .ch_payload(payload[5790:5680])
`ifdef CCV_TRACE
    , .ch_tid(tid[3135:3072])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i7_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[49]), .ch_credit(credit[49]), .ch_stall(stall[49]),
    .ch_payload(payload[5901:5791])
`ifdef CCV_TRACE
    , .ch_tid(tid[3199:3136])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_rcu_lane_ops_i7_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[49:46]), .credit(credit[49:46]));
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i8_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[50]), .ch_credit(credit[50]), .ch_stall(stall[50]),
    .ch_payload(payload[6012:5902])
`ifdef CCV_TRACE
    , .ch_tid(tid[3263:3200])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i8_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[51]), .ch_credit(credit[51]), .ch_stall(stall[51]),
    .ch_payload(payload[6123:6013])
`ifdef CCV_TRACE
    , .ch_tid(tid[3327:3264])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i8_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[52]), .ch_credit(credit[52]), .ch_stall(stall[52]),
    .ch_payload(payload[6234:6124])
`ifdef CCV_TRACE
    , .ch_tid(tid[3391:3328])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i8_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[53]), .ch_credit(credit[53]), .ch_stall(stall[53]),
    .ch_payload(payload[6345:6235])
`ifdef CCV_TRACE
    , .ch_tid(tid[3455:3392])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_rcu_lane_ops_i8_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[53:50]), .credit(credit[53:50]));
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i9_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[54]), .ch_credit(credit[54]), .ch_stall(stall[54]),
    .ch_payload(payload[6456:6346])
`ifdef CCV_TRACE
    , .ch_tid(tid[3519:3456])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i9_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[55]), .ch_credit(credit[55]), .ch_stall(stall[55]),
    .ch_payload(payload[6567:6457])
`ifdef CCV_TRACE
    , .ch_tid(tid[3583:3520])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i9_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[56]), .ch_credit(credit[56]), .ch_stall(stall[56]),
    .ch_payload(payload[6678:6568])
`ifdef CCV_TRACE
    , .ch_tid(tid[3647:3584])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i9_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[57]), .ch_credit(credit[57]), .ch_stall(stall[57]),
    .ch_payload(payload[6789:6679])
`ifdef CCV_TRACE
    , .ch_tid(tid[3711:3648])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_rcu_lane_ops_i9_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[57:54]), .credit(credit[57:54]));
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i10_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[58]), .ch_credit(credit[58]), .ch_stall(stall[58]),
    .ch_payload(payload[6900:6790])
`ifdef CCV_TRACE
    , .ch_tid(tid[3775:3712])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i10_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[59]), .ch_credit(credit[59]), .ch_stall(stall[59]),
    .ch_payload(payload[7011:6901])
`ifdef CCV_TRACE
    , .ch_tid(tid[3839:3776])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i10_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[60]), .ch_credit(credit[60]), .ch_stall(stall[60]),
    .ch_payload(payload[7122:7012])
`ifdef CCV_TRACE
    , .ch_tid(tid[3903:3840])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i10_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[61]), .ch_credit(credit[61]), .ch_stall(stall[61]),
    .ch_payload(payload[7233:7123])
`ifdef CCV_TRACE
    , .ch_tid(tid[3967:3904])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_rcu_lane_ops_i10_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[61:58]), .credit(credit[61:58]));
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i11_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[62]), .ch_credit(credit[62]), .ch_stall(stall[62]),
    .ch_payload(payload[7344:7234])
`ifdef CCV_TRACE
    , .ch_tid(tid[4031:3968])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i11_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[63]), .ch_credit(credit[63]), .ch_stall(stall[63]),
    .ch_payload(payload[7455:7345])
`ifdef CCV_TRACE
    , .ch_tid(tid[4095:4032])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i11_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[64]), .ch_credit(credit[64]), .ch_stall(stall[64]),
    .ch_payload(payload[7566:7456])
`ifdef CCV_TRACE
    , .ch_tid(tid[4159:4096])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i11_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[65]), .ch_credit(credit[65]), .ch_stall(stall[65]),
    .ch_payload(payload[7677:7567])
`ifdef CCV_TRACE
    , .ch_tid(tid[4223:4160])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_rcu_lane_ops_i11_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[65:62]), .credit(credit[65:62]));
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i12_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[66]), .ch_credit(credit[66]), .ch_stall(stall[66]),
    .ch_payload(payload[7788:7678])
`ifdef CCV_TRACE
    , .ch_tid(tid[4287:4224])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i12_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[67]), .ch_credit(credit[67]), .ch_stall(stall[67]),
    .ch_payload(payload[7899:7789])
`ifdef CCV_TRACE
    , .ch_tid(tid[4351:4288])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i12_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[68]), .ch_credit(credit[68]), .ch_stall(stall[68]),
    .ch_payload(payload[8010:7900])
`ifdef CCV_TRACE
    , .ch_tid(tid[4415:4352])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i12_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[69]), .ch_credit(credit[69]), .ch_stall(stall[69]),
    .ch_payload(payload[8121:8011])
`ifdef CCV_TRACE
    , .ch_tid(tid[4479:4416])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_rcu_lane_ops_i12_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[69:66]), .credit(credit[69:66]));
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i13_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[70]), .ch_credit(credit[70]), .ch_stall(stall[70]),
    .ch_payload(payload[8232:8122])
`ifdef CCV_TRACE
    , .ch_tid(tid[4543:4480])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i13_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[71]), .ch_credit(credit[71]), .ch_stall(stall[71]),
    .ch_payload(payload[8343:8233])
`ifdef CCV_TRACE
    , .ch_tid(tid[4607:4544])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i13_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[72]), .ch_credit(credit[72]), .ch_stall(stall[72]),
    .ch_payload(payload[8454:8344])
`ifdef CCV_TRACE
    , .ch_tid(tid[4671:4608])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i13_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[73]), .ch_credit(credit[73]), .ch_stall(stall[73]),
    .ch_payload(payload[8565:8455])
`ifdef CCV_TRACE
    , .ch_tid(tid[4735:4672])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_rcu_lane_ops_i13_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[73:70]), .credit(credit[73:70]));
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i14_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[74]), .ch_credit(credit[74]), .ch_stall(stall[74]),
    .ch_payload(payload[8676:8566])
`ifdef CCV_TRACE
    , .ch_tid(tid[4799:4736])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i14_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[75]), .ch_credit(credit[75]), .ch_stall(stall[75]),
    .ch_payload(payload[8787:8677])
`ifdef CCV_TRACE
    , .ch_tid(tid[4863:4800])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i14_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[76]), .ch_credit(credit[76]), .ch_stall(stall[76]),
    .ch_payload(payload[8898:8788])
`ifdef CCV_TRACE
    , .ch_tid(tid[4927:4864])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i14_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[77]), .ch_credit(credit[77]), .ch_stall(stall[77]),
    .ch_payload(payload[9009:8899])
`ifdef CCV_TRACE
    , .ch_tid(tid[4991:4928])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_rcu_lane_ops_i14_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[77:74]), .credit(credit[77:74]));
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i15_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[78]), .ch_credit(credit[78]), .ch_stall(stall[78]),
    .ch_payload(payload[9120:9010])
`ifdef CCV_TRACE
    , .ch_tid(tid[5055:4992])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i15_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[79]), .ch_credit(credit[79]), .ch_stall(stall[79]),
    .ch_payload(payload[9231:9121])
`ifdef CCV_TRACE
    , .ch_tid(tid[5119:5056])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i15_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[80]), .ch_credit(credit[80]), .ch_stall(stall[80]),
    .ch_payload(payload[9342:9232])
`ifdef CCV_TRACE
    , .ch_tid(tid[5183:5120])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i15_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[81]), .ch_credit(credit[81]), .ch_stall(stall[81]),
    .ch_payload(payload[9453:9343])
`ifdef CCV_TRACE
    , .ch_tid(tid[5247:5184])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_rcu_lane_ops_i15_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[81:78]), .credit(credit[81:78]));
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i16_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[82]), .ch_credit(credit[82]), .ch_stall(stall[82]),
    .ch_payload(payload[9564:9454])
`ifdef CCV_TRACE
    , .ch_tid(tid[5311:5248])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i16_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[83]), .ch_credit(credit[83]), .ch_stall(stall[83]),
    .ch_payload(payload[9675:9565])
`ifdef CCV_TRACE
    , .ch_tid(tid[5375:5312])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i16_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[84]), .ch_credit(credit[84]), .ch_stall(stall[84]),
    .ch_payload(payload[9786:9676])
`ifdef CCV_TRACE
    , .ch_tid(tid[5439:5376])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i16_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[85]), .ch_credit(credit[85]), .ch_stall(stall[85]),
    .ch_payload(payload[9897:9787])
`ifdef CCV_TRACE
    , .ch_tid(tid[5503:5440])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_rcu_lane_ops_i16_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[85:82]), .credit(credit[85:82]));
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i17_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[86]), .ch_credit(credit[86]), .ch_stall(stall[86]),
    .ch_payload(payload[10008:9898])
`ifdef CCV_TRACE
    , .ch_tid(tid[5567:5504])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i17_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[87]), .ch_credit(credit[87]), .ch_stall(stall[87]),
    .ch_payload(payload[10119:10009])
`ifdef CCV_TRACE
    , .ch_tid(tid[5631:5568])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i17_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[88]), .ch_credit(credit[88]), .ch_stall(stall[88]),
    .ch_payload(payload[10230:10120])
`ifdef CCV_TRACE
    , .ch_tid(tid[5695:5632])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i17_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[89]), .ch_credit(credit[89]), .ch_stall(stall[89]),
    .ch_payload(payload[10341:10231])
`ifdef CCV_TRACE
    , .ch_tid(tid[5759:5696])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_rcu_lane_ops_i17_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[89:86]), .credit(credit[89:86]));
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i18_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[90]), .ch_credit(credit[90]), .ch_stall(stall[90]),
    .ch_payload(payload[10452:10342])
`ifdef CCV_TRACE
    , .ch_tid(tid[5823:5760])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i18_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[91]), .ch_credit(credit[91]), .ch_stall(stall[91]),
    .ch_payload(payload[10563:10453])
`ifdef CCV_TRACE
    , .ch_tid(tid[5887:5824])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i18_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[92]), .ch_credit(credit[92]), .ch_stall(stall[92]),
    .ch_payload(payload[10674:10564])
`ifdef CCV_TRACE
    , .ch_tid(tid[5951:5888])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i18_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[93]), .ch_credit(credit[93]), .ch_stall(stall[93]),
    .ch_payload(payload[10785:10675])
`ifdef CCV_TRACE
    , .ch_tid(tid[6015:5952])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_rcu_lane_ops_i18_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[93:90]), .credit(credit[93:90]));
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i19_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[94]), .ch_credit(credit[94]), .ch_stall(stall[94]),
    .ch_payload(payload[10896:10786])
`ifdef CCV_TRACE
    , .ch_tid(tid[6079:6016])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i19_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[95]), .ch_credit(credit[95]), .ch_stall(stall[95]),
    .ch_payload(payload[11007:10897])
`ifdef CCV_TRACE
    , .ch_tid(tid[6143:6080])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i19_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[96]), .ch_credit(credit[96]), .ch_stall(stall[96]),
    .ch_payload(payload[11118:11008])
`ifdef CCV_TRACE
    , .ch_tid(tid[6207:6144])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i19_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[97]), .ch_credit(credit[97]), .ch_stall(stall[97]),
    .ch_payload(payload[11229:11119])
`ifdef CCV_TRACE
    , .ch_tid(tid[6271:6208])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_rcu_lane_ops_i19_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[97:94]), .credit(credit[97:94]));
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i20_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[98]), .ch_credit(credit[98]), .ch_stall(stall[98]),
    .ch_payload(payload[11340:11230])
`ifdef CCV_TRACE
    , .ch_tid(tid[6335:6272])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i20_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[99]), .ch_credit(credit[99]), .ch_stall(stall[99]),
    .ch_payload(payload[11451:11341])
`ifdef CCV_TRACE
    , .ch_tid(tid[6399:6336])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i20_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[100]), .ch_credit(credit[100]), .ch_stall(stall[100]),
    .ch_payload(payload[11562:11452])
`ifdef CCV_TRACE
    , .ch_tid(tid[6463:6400])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i20_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[101]), .ch_credit(credit[101]), .ch_stall(stall[101]),
    .ch_payload(payload[11673:11563])
`ifdef CCV_TRACE
    , .ch_tid(tid[6527:6464])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_rcu_lane_ops_i20_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[101:98]), .credit(credit[101:98]));
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i21_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[102]), .ch_credit(credit[102]), .ch_stall(stall[102]),
    .ch_payload(payload[11784:11674])
`ifdef CCV_TRACE
    , .ch_tid(tid[6591:6528])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i21_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[103]), .ch_credit(credit[103]), .ch_stall(stall[103]),
    .ch_payload(payload[11895:11785])
`ifdef CCV_TRACE
    , .ch_tid(tid[6655:6592])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i21_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[104]), .ch_credit(credit[104]), .ch_stall(stall[104]),
    .ch_payload(payload[12006:11896])
`ifdef CCV_TRACE
    , .ch_tid(tid[6719:6656])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i21_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[105]), .ch_credit(credit[105]), .ch_stall(stall[105]),
    .ch_payload(payload[12117:12007])
`ifdef CCV_TRACE
    , .ch_tid(tid[6783:6720])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_rcu_lane_ops_i21_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[105:102]), .credit(credit[105:102]));
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i22_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[106]), .ch_credit(credit[106]), .ch_stall(stall[106]),
    .ch_payload(payload[12228:12118])
`ifdef CCV_TRACE
    , .ch_tid(tid[6847:6784])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i22_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[107]), .ch_credit(credit[107]), .ch_stall(stall[107]),
    .ch_payload(payload[12339:12229])
`ifdef CCV_TRACE
    , .ch_tid(tid[6911:6848])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i22_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[108]), .ch_credit(credit[108]), .ch_stall(stall[108]),
    .ch_payload(payload[12450:12340])
`ifdef CCV_TRACE
    , .ch_tid(tid[6975:6912])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i22_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[109]), .ch_credit(credit[109]), .ch_stall(stall[109]),
    .ch_payload(payload[12561:12451])
`ifdef CCV_TRACE
    , .ch_tid(tid[7039:6976])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_rcu_lane_ops_i22_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[109:106]), .credit(credit[109:106]));
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i23_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[110]), .ch_credit(credit[110]), .ch_stall(stall[110]),
    .ch_payload(payload[12672:12562])
`ifdef CCV_TRACE
    , .ch_tid(tid[7103:7040])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i23_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[111]), .ch_credit(credit[111]), .ch_stall(stall[111]),
    .ch_payload(payload[12783:12673])
`ifdef CCV_TRACE
    , .ch_tid(tid[7167:7104])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i23_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[112]), .ch_credit(credit[112]), .ch_stall(stall[112]),
    .ch_payload(payload[12894:12784])
`ifdef CCV_TRACE
    , .ch_tid(tid[7231:7168])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i23_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[113]), .ch_credit(credit[113]), .ch_stall(stall[113]),
    .ch_payload(payload[13005:12895])
`ifdef CCV_TRACE
    , .ch_tid(tid[7295:7232])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_rcu_lane_ops_i23_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[113:110]), .credit(credit[113:110]));
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i24_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[114]), .ch_credit(credit[114]), .ch_stall(stall[114]),
    .ch_payload(payload[13116:13006])
`ifdef CCV_TRACE
    , .ch_tid(tid[7359:7296])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i24_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[115]), .ch_credit(credit[115]), .ch_stall(stall[115]),
    .ch_payload(payload[13227:13117])
`ifdef CCV_TRACE
    , .ch_tid(tid[7423:7360])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i24_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[116]), .ch_credit(credit[116]), .ch_stall(stall[116]),
    .ch_payload(payload[13338:13228])
`ifdef CCV_TRACE
    , .ch_tid(tid[7487:7424])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i24_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[117]), .ch_credit(credit[117]), .ch_stall(stall[117]),
    .ch_payload(payload[13449:13339])
`ifdef CCV_TRACE
    , .ch_tid(tid[7551:7488])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_rcu_lane_ops_i24_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[117:114]), .credit(credit[117:114]));
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i25_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[118]), .ch_credit(credit[118]), .ch_stall(stall[118]),
    .ch_payload(payload[13560:13450])
`ifdef CCV_TRACE
    , .ch_tid(tid[7615:7552])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i25_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[119]), .ch_credit(credit[119]), .ch_stall(stall[119]),
    .ch_payload(payload[13671:13561])
`ifdef CCV_TRACE
    , .ch_tid(tid[7679:7616])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i25_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[120]), .ch_credit(credit[120]), .ch_stall(stall[120]),
    .ch_payload(payload[13782:13672])
`ifdef CCV_TRACE
    , .ch_tid(tid[7743:7680])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i25_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[121]), .ch_credit(credit[121]), .ch_stall(stall[121]),
    .ch_payload(payload[13893:13783])
`ifdef CCV_TRACE
    , .ch_tid(tid[7807:7744])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_rcu_lane_ops_i25_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[121:118]), .credit(credit[121:118]));
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i26_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[122]), .ch_credit(credit[122]), .ch_stall(stall[122]),
    .ch_payload(payload[14004:13894])
`ifdef CCV_TRACE
    , .ch_tid(tid[7871:7808])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i26_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[123]), .ch_credit(credit[123]), .ch_stall(stall[123]),
    .ch_payload(payload[14115:14005])
`ifdef CCV_TRACE
    , .ch_tid(tid[7935:7872])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i26_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[124]), .ch_credit(credit[124]), .ch_stall(stall[124]),
    .ch_payload(payload[14226:14116])
`ifdef CCV_TRACE
    , .ch_tid(tid[7999:7936])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i26_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[125]), .ch_credit(credit[125]), .ch_stall(stall[125]),
    .ch_payload(payload[14337:14227])
`ifdef CCV_TRACE
    , .ch_tid(tid[8063:8000])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_rcu_lane_ops_i26_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[125:122]), .credit(credit[125:122]));
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i27_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[126]), .ch_credit(credit[126]), .ch_stall(stall[126]),
    .ch_payload(payload[14448:14338])
`ifdef CCV_TRACE
    , .ch_tid(tid[8127:8064])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i27_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[127]), .ch_credit(credit[127]), .ch_stall(stall[127]),
    .ch_payload(payload[14559:14449])
`ifdef CCV_TRACE
    , .ch_tid(tid[8191:8128])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i27_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[128]), .ch_credit(credit[128]), .ch_stall(stall[128]),
    .ch_payload(payload[14670:14560])
`ifdef CCV_TRACE
    , .ch_tid(tid[8255:8192])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i27_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[129]), .ch_credit(credit[129]), .ch_stall(stall[129]),
    .ch_payload(payload[14781:14671])
`ifdef CCV_TRACE
    , .ch_tid(tid[8319:8256])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_rcu_lane_ops_i27_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[129:126]), .credit(credit[129:126]));
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i28_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[130]), .ch_credit(credit[130]), .ch_stall(stall[130]),
    .ch_payload(payload[14892:14782])
`ifdef CCV_TRACE
    , .ch_tid(tid[8383:8320])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i28_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[131]), .ch_credit(credit[131]), .ch_stall(stall[131]),
    .ch_payload(payload[15003:14893])
`ifdef CCV_TRACE
    , .ch_tid(tid[8447:8384])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i28_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[132]), .ch_credit(credit[132]), .ch_stall(stall[132]),
    .ch_payload(payload[15114:15004])
`ifdef CCV_TRACE
    , .ch_tid(tid[8511:8448])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i28_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[133]), .ch_credit(credit[133]), .ch_stall(stall[133]),
    .ch_payload(payload[15225:15115])
`ifdef CCV_TRACE
    , .ch_tid(tid[8575:8512])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_rcu_lane_ops_i28_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[133:130]), .credit(credit[133:130]));
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i29_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[134]), .ch_credit(credit[134]), .ch_stall(stall[134]),
    .ch_payload(payload[15336:15226])
`ifdef CCV_TRACE
    , .ch_tid(tid[8639:8576])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i29_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[135]), .ch_credit(credit[135]), .ch_stall(stall[135]),
    .ch_payload(payload[15447:15337])
`ifdef CCV_TRACE
    , .ch_tid(tid[8703:8640])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i29_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[136]), .ch_credit(credit[136]), .ch_stall(stall[136]),
    .ch_payload(payload[15558:15448])
`ifdef CCV_TRACE
    , .ch_tid(tid[8767:8704])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i29_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[137]), .ch_credit(credit[137]), .ch_stall(stall[137]),
    .ch_payload(payload[15669:15559])
`ifdef CCV_TRACE
    , .ch_tid(tid[8831:8768])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_rcu_lane_ops_i29_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[137:134]), .credit(credit[137:134]));
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i30_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[138]), .ch_credit(credit[138]), .ch_stall(stall[138]),
    .ch_payload(payload[15780:15670])
`ifdef CCV_TRACE
    , .ch_tid(tid[8895:8832])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i30_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[139]), .ch_credit(credit[139]), .ch_stall(stall[139]),
    .ch_payload(payload[15891:15781])
`ifdef CCV_TRACE
    , .ch_tid(tid[8959:8896])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i30_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[140]), .ch_credit(credit[140]), .ch_stall(stall[140]),
    .ch_payload(payload[16002:15892])
`ifdef CCV_TRACE
    , .ch_tid(tid[9023:8960])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i30_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[141]), .ch_credit(credit[141]), .ch_stall(stall[141]),
    .ch_payload(payload[16113:16003])
`ifdef CCV_TRACE
    , .ch_tid(tid[9087:9024])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_rcu_lane_ops_i30_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[141:138]), .credit(credit[141:138]));
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i31_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[142]), .ch_credit(credit[142]), .ch_stall(stall[142]),
    .ch_payload(payload[16224:16114])
`ifdef CCV_TRACE
    , .ch_tid(tid[9151:9088])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i31_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[143]), .ch_credit(credit[143]), .ch_stall(stall[143]),
    .ch_payload(payload[16335:16225])
`ifdef CCV_TRACE
    , .ch_tid(tid[9215:9152])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i31_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[144]), .ch_credit(credit[144]), .ch_stall(stall[144]),
    .ch_payload(payload[16446:16336])
`ifdef CCV_TRACE
    , .ch_tid(tid[9279:9216])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(111), .CHANNEL(3), .LEAD_MASK(111'h3f)) u_rcu_lane_ops_i31_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[145]), .ch_credit(credit[145]), .ch_stall(stall[145]),
    .ch_payload(payload[16557:16447])
`ifdef CCV_TRACE
    , .ch_tid(tid[9343:9280])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_rcu_lane_ops_i31_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[145:142]), .credit(credit[145:142]));
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i0_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[146]), .ch_credit(credit[146]), .ch_stall(stall[146]),
    .ch_payload(payload[16591:16558])
`ifdef CCV_TRACE
    , .ch_tid(tid[9407:9344])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i0_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[147]), .ch_credit(credit[147]), .ch_stall(stall[147]),
    .ch_payload(payload[16625:16592])
`ifdef CCV_TRACE
    , .ch_tid(tid[9471:9408])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i0_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[148]), .ch_credit(credit[148]), .ch_stall(stall[148]),
    .ch_payload(payload[16659:16626])
`ifdef CCV_TRACE
    , .ch_tid(tid[9535:9472])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i0_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[149]), .ch_credit(credit[149]), .ch_stall(stall[149]),
    .ch_payload(payload[16693:16660])
`ifdef CCV_TRACE
    , .ch_tid(tid[9599:9536])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_lane_rcu_res_i0_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[149:146]), .credit(credit[149:146]));
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i1_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[150]), .ch_credit(credit[150]), .ch_stall(stall[150]),
    .ch_payload(payload[16727:16694])
`ifdef CCV_TRACE
    , .ch_tid(tid[9663:9600])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i1_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[151]), .ch_credit(credit[151]), .ch_stall(stall[151]),
    .ch_payload(payload[16761:16728])
`ifdef CCV_TRACE
    , .ch_tid(tid[9727:9664])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i1_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[152]), .ch_credit(credit[152]), .ch_stall(stall[152]),
    .ch_payload(payload[16795:16762])
`ifdef CCV_TRACE
    , .ch_tid(tid[9791:9728])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i1_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[153]), .ch_credit(credit[153]), .ch_stall(stall[153]),
    .ch_payload(payload[16829:16796])
`ifdef CCV_TRACE
    , .ch_tid(tid[9855:9792])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_lane_rcu_res_i1_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[153:150]), .credit(credit[153:150]));
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i2_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[154]), .ch_credit(credit[154]), .ch_stall(stall[154]),
    .ch_payload(payload[16863:16830])
`ifdef CCV_TRACE
    , .ch_tid(tid[9919:9856])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i2_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[155]), .ch_credit(credit[155]), .ch_stall(stall[155]),
    .ch_payload(payload[16897:16864])
`ifdef CCV_TRACE
    , .ch_tid(tid[9983:9920])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i2_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[156]), .ch_credit(credit[156]), .ch_stall(stall[156]),
    .ch_payload(payload[16931:16898])
`ifdef CCV_TRACE
    , .ch_tid(tid[10047:9984])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i2_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[157]), .ch_credit(credit[157]), .ch_stall(stall[157]),
    .ch_payload(payload[16965:16932])
`ifdef CCV_TRACE
    , .ch_tid(tid[10111:10048])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_lane_rcu_res_i2_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[157:154]), .credit(credit[157:154]));
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i3_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[158]), .ch_credit(credit[158]), .ch_stall(stall[158]),
    .ch_payload(payload[16999:16966])
`ifdef CCV_TRACE
    , .ch_tid(tid[10175:10112])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i3_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[159]), .ch_credit(credit[159]), .ch_stall(stall[159]),
    .ch_payload(payload[17033:17000])
`ifdef CCV_TRACE
    , .ch_tid(tid[10239:10176])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i3_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[160]), .ch_credit(credit[160]), .ch_stall(stall[160]),
    .ch_payload(payload[17067:17034])
`ifdef CCV_TRACE
    , .ch_tid(tid[10303:10240])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i3_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[161]), .ch_credit(credit[161]), .ch_stall(stall[161]),
    .ch_payload(payload[17101:17068])
`ifdef CCV_TRACE
    , .ch_tid(tid[10367:10304])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_lane_rcu_res_i3_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[161:158]), .credit(credit[161:158]));
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i4_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[162]), .ch_credit(credit[162]), .ch_stall(stall[162]),
    .ch_payload(payload[17135:17102])
`ifdef CCV_TRACE
    , .ch_tid(tid[10431:10368])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i4_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[163]), .ch_credit(credit[163]), .ch_stall(stall[163]),
    .ch_payload(payload[17169:17136])
`ifdef CCV_TRACE
    , .ch_tid(tid[10495:10432])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i4_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[164]), .ch_credit(credit[164]), .ch_stall(stall[164]),
    .ch_payload(payload[17203:17170])
`ifdef CCV_TRACE
    , .ch_tid(tid[10559:10496])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i4_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[165]), .ch_credit(credit[165]), .ch_stall(stall[165]),
    .ch_payload(payload[17237:17204])
`ifdef CCV_TRACE
    , .ch_tid(tid[10623:10560])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_lane_rcu_res_i4_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[165:162]), .credit(credit[165:162]));
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i5_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[166]), .ch_credit(credit[166]), .ch_stall(stall[166]),
    .ch_payload(payload[17271:17238])
`ifdef CCV_TRACE
    , .ch_tid(tid[10687:10624])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i5_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[167]), .ch_credit(credit[167]), .ch_stall(stall[167]),
    .ch_payload(payload[17305:17272])
`ifdef CCV_TRACE
    , .ch_tid(tid[10751:10688])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i5_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[168]), .ch_credit(credit[168]), .ch_stall(stall[168]),
    .ch_payload(payload[17339:17306])
`ifdef CCV_TRACE
    , .ch_tid(tid[10815:10752])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i5_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[169]), .ch_credit(credit[169]), .ch_stall(stall[169]),
    .ch_payload(payload[17373:17340])
`ifdef CCV_TRACE
    , .ch_tid(tid[10879:10816])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_lane_rcu_res_i5_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[169:166]), .credit(credit[169:166]));
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i6_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[170]), .ch_credit(credit[170]), .ch_stall(stall[170]),
    .ch_payload(payload[17407:17374])
`ifdef CCV_TRACE
    , .ch_tid(tid[10943:10880])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i6_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[171]), .ch_credit(credit[171]), .ch_stall(stall[171]),
    .ch_payload(payload[17441:17408])
`ifdef CCV_TRACE
    , .ch_tid(tid[11007:10944])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i6_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[172]), .ch_credit(credit[172]), .ch_stall(stall[172]),
    .ch_payload(payload[17475:17442])
`ifdef CCV_TRACE
    , .ch_tid(tid[11071:11008])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i6_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[173]), .ch_credit(credit[173]), .ch_stall(stall[173]),
    .ch_payload(payload[17509:17476])
`ifdef CCV_TRACE
    , .ch_tid(tid[11135:11072])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_lane_rcu_res_i6_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[173:170]), .credit(credit[173:170]));
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i7_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[174]), .ch_credit(credit[174]), .ch_stall(stall[174]),
    .ch_payload(payload[17543:17510])
`ifdef CCV_TRACE
    , .ch_tid(tid[11199:11136])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i7_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[175]), .ch_credit(credit[175]), .ch_stall(stall[175]),
    .ch_payload(payload[17577:17544])
`ifdef CCV_TRACE
    , .ch_tid(tid[11263:11200])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i7_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[176]), .ch_credit(credit[176]), .ch_stall(stall[176]),
    .ch_payload(payload[17611:17578])
`ifdef CCV_TRACE
    , .ch_tid(tid[11327:11264])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i7_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[177]), .ch_credit(credit[177]), .ch_stall(stall[177]),
    .ch_payload(payload[17645:17612])
`ifdef CCV_TRACE
    , .ch_tid(tid[11391:11328])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_lane_rcu_res_i7_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[177:174]), .credit(credit[177:174]));
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i8_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[178]), .ch_credit(credit[178]), .ch_stall(stall[178]),
    .ch_payload(payload[17679:17646])
`ifdef CCV_TRACE
    , .ch_tid(tid[11455:11392])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i8_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[179]), .ch_credit(credit[179]), .ch_stall(stall[179]),
    .ch_payload(payload[17713:17680])
`ifdef CCV_TRACE
    , .ch_tid(tid[11519:11456])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i8_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[180]), .ch_credit(credit[180]), .ch_stall(stall[180]),
    .ch_payload(payload[17747:17714])
`ifdef CCV_TRACE
    , .ch_tid(tid[11583:11520])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i8_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[181]), .ch_credit(credit[181]), .ch_stall(stall[181]),
    .ch_payload(payload[17781:17748])
`ifdef CCV_TRACE
    , .ch_tid(tid[11647:11584])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_lane_rcu_res_i8_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[181:178]), .credit(credit[181:178]));
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i9_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[182]), .ch_credit(credit[182]), .ch_stall(stall[182]),
    .ch_payload(payload[17815:17782])
`ifdef CCV_TRACE
    , .ch_tid(tid[11711:11648])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i9_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[183]), .ch_credit(credit[183]), .ch_stall(stall[183]),
    .ch_payload(payload[17849:17816])
`ifdef CCV_TRACE
    , .ch_tid(tid[11775:11712])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i9_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[184]), .ch_credit(credit[184]), .ch_stall(stall[184]),
    .ch_payload(payload[17883:17850])
`ifdef CCV_TRACE
    , .ch_tid(tid[11839:11776])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i9_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[185]), .ch_credit(credit[185]), .ch_stall(stall[185]),
    .ch_payload(payload[17917:17884])
`ifdef CCV_TRACE
    , .ch_tid(tid[11903:11840])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_lane_rcu_res_i9_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[185:182]), .credit(credit[185:182]));
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i10_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[186]), .ch_credit(credit[186]), .ch_stall(stall[186]),
    .ch_payload(payload[17951:17918])
`ifdef CCV_TRACE
    , .ch_tid(tid[11967:11904])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i10_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[187]), .ch_credit(credit[187]), .ch_stall(stall[187]),
    .ch_payload(payload[17985:17952])
`ifdef CCV_TRACE
    , .ch_tid(tid[12031:11968])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i10_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[188]), .ch_credit(credit[188]), .ch_stall(stall[188]),
    .ch_payload(payload[18019:17986])
`ifdef CCV_TRACE
    , .ch_tid(tid[12095:12032])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i10_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[189]), .ch_credit(credit[189]), .ch_stall(stall[189]),
    .ch_payload(payload[18053:18020])
`ifdef CCV_TRACE
    , .ch_tid(tid[12159:12096])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_lane_rcu_res_i10_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[189:186]), .credit(credit[189:186]));
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i11_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[190]), .ch_credit(credit[190]), .ch_stall(stall[190]),
    .ch_payload(payload[18087:18054])
`ifdef CCV_TRACE
    , .ch_tid(tid[12223:12160])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i11_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[191]), .ch_credit(credit[191]), .ch_stall(stall[191]),
    .ch_payload(payload[18121:18088])
`ifdef CCV_TRACE
    , .ch_tid(tid[12287:12224])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i11_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[192]), .ch_credit(credit[192]), .ch_stall(stall[192]),
    .ch_payload(payload[18155:18122])
`ifdef CCV_TRACE
    , .ch_tid(tid[12351:12288])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i11_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[193]), .ch_credit(credit[193]), .ch_stall(stall[193]),
    .ch_payload(payload[18189:18156])
`ifdef CCV_TRACE
    , .ch_tid(tid[12415:12352])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_lane_rcu_res_i11_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[193:190]), .credit(credit[193:190]));
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i12_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[194]), .ch_credit(credit[194]), .ch_stall(stall[194]),
    .ch_payload(payload[18223:18190])
`ifdef CCV_TRACE
    , .ch_tid(tid[12479:12416])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i12_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[195]), .ch_credit(credit[195]), .ch_stall(stall[195]),
    .ch_payload(payload[18257:18224])
`ifdef CCV_TRACE
    , .ch_tid(tid[12543:12480])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i12_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[196]), .ch_credit(credit[196]), .ch_stall(stall[196]),
    .ch_payload(payload[18291:18258])
`ifdef CCV_TRACE
    , .ch_tid(tid[12607:12544])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i12_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[197]), .ch_credit(credit[197]), .ch_stall(stall[197]),
    .ch_payload(payload[18325:18292])
`ifdef CCV_TRACE
    , .ch_tid(tid[12671:12608])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_lane_rcu_res_i12_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[197:194]), .credit(credit[197:194]));
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i13_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[198]), .ch_credit(credit[198]), .ch_stall(stall[198]),
    .ch_payload(payload[18359:18326])
`ifdef CCV_TRACE
    , .ch_tid(tid[12735:12672])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i13_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[199]), .ch_credit(credit[199]), .ch_stall(stall[199]),
    .ch_payload(payload[18393:18360])
`ifdef CCV_TRACE
    , .ch_tid(tid[12799:12736])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i13_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[200]), .ch_credit(credit[200]), .ch_stall(stall[200]),
    .ch_payload(payload[18427:18394])
`ifdef CCV_TRACE
    , .ch_tid(tid[12863:12800])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i13_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[201]), .ch_credit(credit[201]), .ch_stall(stall[201]),
    .ch_payload(payload[18461:18428])
`ifdef CCV_TRACE
    , .ch_tid(tid[12927:12864])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_lane_rcu_res_i13_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[201:198]), .credit(credit[201:198]));
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i14_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[202]), .ch_credit(credit[202]), .ch_stall(stall[202]),
    .ch_payload(payload[18495:18462])
`ifdef CCV_TRACE
    , .ch_tid(tid[12991:12928])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i14_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[203]), .ch_credit(credit[203]), .ch_stall(stall[203]),
    .ch_payload(payload[18529:18496])
`ifdef CCV_TRACE
    , .ch_tid(tid[13055:12992])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i14_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[204]), .ch_credit(credit[204]), .ch_stall(stall[204]),
    .ch_payload(payload[18563:18530])
`ifdef CCV_TRACE
    , .ch_tid(tid[13119:13056])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i14_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[205]), .ch_credit(credit[205]), .ch_stall(stall[205]),
    .ch_payload(payload[18597:18564])
`ifdef CCV_TRACE
    , .ch_tid(tid[13183:13120])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_lane_rcu_res_i14_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[205:202]), .credit(credit[205:202]));
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i15_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[206]), .ch_credit(credit[206]), .ch_stall(stall[206]),
    .ch_payload(payload[18631:18598])
`ifdef CCV_TRACE
    , .ch_tid(tid[13247:13184])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i15_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[207]), .ch_credit(credit[207]), .ch_stall(stall[207]),
    .ch_payload(payload[18665:18632])
`ifdef CCV_TRACE
    , .ch_tid(tid[13311:13248])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i15_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[208]), .ch_credit(credit[208]), .ch_stall(stall[208]),
    .ch_payload(payload[18699:18666])
`ifdef CCV_TRACE
    , .ch_tid(tid[13375:13312])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i15_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[209]), .ch_credit(credit[209]), .ch_stall(stall[209]),
    .ch_payload(payload[18733:18700])
`ifdef CCV_TRACE
    , .ch_tid(tid[13439:13376])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_lane_rcu_res_i15_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[209:206]), .credit(credit[209:206]));
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i16_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[210]), .ch_credit(credit[210]), .ch_stall(stall[210]),
    .ch_payload(payload[18767:18734])
`ifdef CCV_TRACE
    , .ch_tid(tid[13503:13440])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i16_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[211]), .ch_credit(credit[211]), .ch_stall(stall[211]),
    .ch_payload(payload[18801:18768])
`ifdef CCV_TRACE
    , .ch_tid(tid[13567:13504])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i16_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[212]), .ch_credit(credit[212]), .ch_stall(stall[212]),
    .ch_payload(payload[18835:18802])
`ifdef CCV_TRACE
    , .ch_tid(tid[13631:13568])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i16_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[213]), .ch_credit(credit[213]), .ch_stall(stall[213]),
    .ch_payload(payload[18869:18836])
`ifdef CCV_TRACE
    , .ch_tid(tid[13695:13632])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_lane_rcu_res_i16_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[213:210]), .credit(credit[213:210]));
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i17_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[214]), .ch_credit(credit[214]), .ch_stall(stall[214]),
    .ch_payload(payload[18903:18870])
`ifdef CCV_TRACE
    , .ch_tid(tid[13759:13696])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i17_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[215]), .ch_credit(credit[215]), .ch_stall(stall[215]),
    .ch_payload(payload[18937:18904])
`ifdef CCV_TRACE
    , .ch_tid(tid[13823:13760])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i17_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[216]), .ch_credit(credit[216]), .ch_stall(stall[216]),
    .ch_payload(payload[18971:18938])
`ifdef CCV_TRACE
    , .ch_tid(tid[13887:13824])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i17_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[217]), .ch_credit(credit[217]), .ch_stall(stall[217]),
    .ch_payload(payload[19005:18972])
`ifdef CCV_TRACE
    , .ch_tid(tid[13951:13888])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_lane_rcu_res_i17_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[217:214]), .credit(credit[217:214]));
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i18_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[218]), .ch_credit(credit[218]), .ch_stall(stall[218]),
    .ch_payload(payload[19039:19006])
`ifdef CCV_TRACE
    , .ch_tid(tid[14015:13952])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i18_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[219]), .ch_credit(credit[219]), .ch_stall(stall[219]),
    .ch_payload(payload[19073:19040])
`ifdef CCV_TRACE
    , .ch_tid(tid[14079:14016])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i18_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[220]), .ch_credit(credit[220]), .ch_stall(stall[220]),
    .ch_payload(payload[19107:19074])
`ifdef CCV_TRACE
    , .ch_tid(tid[14143:14080])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i18_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[221]), .ch_credit(credit[221]), .ch_stall(stall[221]),
    .ch_payload(payload[19141:19108])
`ifdef CCV_TRACE
    , .ch_tid(tid[14207:14144])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_lane_rcu_res_i18_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[221:218]), .credit(credit[221:218]));
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i19_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[222]), .ch_credit(credit[222]), .ch_stall(stall[222]),
    .ch_payload(payload[19175:19142])
`ifdef CCV_TRACE
    , .ch_tid(tid[14271:14208])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i19_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[223]), .ch_credit(credit[223]), .ch_stall(stall[223]),
    .ch_payload(payload[19209:19176])
`ifdef CCV_TRACE
    , .ch_tid(tid[14335:14272])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i19_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[224]), .ch_credit(credit[224]), .ch_stall(stall[224]),
    .ch_payload(payload[19243:19210])
`ifdef CCV_TRACE
    , .ch_tid(tid[14399:14336])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i19_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[225]), .ch_credit(credit[225]), .ch_stall(stall[225]),
    .ch_payload(payload[19277:19244])
`ifdef CCV_TRACE
    , .ch_tid(tid[14463:14400])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_lane_rcu_res_i19_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[225:222]), .credit(credit[225:222]));
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i20_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[226]), .ch_credit(credit[226]), .ch_stall(stall[226]),
    .ch_payload(payload[19311:19278])
`ifdef CCV_TRACE
    , .ch_tid(tid[14527:14464])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i20_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[227]), .ch_credit(credit[227]), .ch_stall(stall[227]),
    .ch_payload(payload[19345:19312])
`ifdef CCV_TRACE
    , .ch_tid(tid[14591:14528])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i20_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[228]), .ch_credit(credit[228]), .ch_stall(stall[228]),
    .ch_payload(payload[19379:19346])
`ifdef CCV_TRACE
    , .ch_tid(tid[14655:14592])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i20_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[229]), .ch_credit(credit[229]), .ch_stall(stall[229]),
    .ch_payload(payload[19413:19380])
`ifdef CCV_TRACE
    , .ch_tid(tid[14719:14656])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_lane_rcu_res_i20_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[229:226]), .credit(credit[229:226]));
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i21_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[230]), .ch_credit(credit[230]), .ch_stall(stall[230]),
    .ch_payload(payload[19447:19414])
`ifdef CCV_TRACE
    , .ch_tid(tid[14783:14720])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i21_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[231]), .ch_credit(credit[231]), .ch_stall(stall[231]),
    .ch_payload(payload[19481:19448])
`ifdef CCV_TRACE
    , .ch_tid(tid[14847:14784])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i21_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[232]), .ch_credit(credit[232]), .ch_stall(stall[232]),
    .ch_payload(payload[19515:19482])
`ifdef CCV_TRACE
    , .ch_tid(tid[14911:14848])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i21_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[233]), .ch_credit(credit[233]), .ch_stall(stall[233]),
    .ch_payload(payload[19549:19516])
`ifdef CCV_TRACE
    , .ch_tid(tid[14975:14912])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_lane_rcu_res_i21_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[233:230]), .credit(credit[233:230]));
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i22_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[234]), .ch_credit(credit[234]), .ch_stall(stall[234]),
    .ch_payload(payload[19583:19550])
`ifdef CCV_TRACE
    , .ch_tid(tid[15039:14976])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i22_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[235]), .ch_credit(credit[235]), .ch_stall(stall[235]),
    .ch_payload(payload[19617:19584])
`ifdef CCV_TRACE
    , .ch_tid(tid[15103:15040])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i22_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[236]), .ch_credit(credit[236]), .ch_stall(stall[236]),
    .ch_payload(payload[19651:19618])
`ifdef CCV_TRACE
    , .ch_tid(tid[15167:15104])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i22_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[237]), .ch_credit(credit[237]), .ch_stall(stall[237]),
    .ch_payload(payload[19685:19652])
`ifdef CCV_TRACE
    , .ch_tid(tid[15231:15168])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_lane_rcu_res_i22_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[237:234]), .credit(credit[237:234]));
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i23_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[238]), .ch_credit(credit[238]), .ch_stall(stall[238]),
    .ch_payload(payload[19719:19686])
`ifdef CCV_TRACE
    , .ch_tid(tid[15295:15232])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i23_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[239]), .ch_credit(credit[239]), .ch_stall(stall[239]),
    .ch_payload(payload[19753:19720])
`ifdef CCV_TRACE
    , .ch_tid(tid[15359:15296])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i23_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[240]), .ch_credit(credit[240]), .ch_stall(stall[240]),
    .ch_payload(payload[19787:19754])
`ifdef CCV_TRACE
    , .ch_tid(tid[15423:15360])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i23_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[241]), .ch_credit(credit[241]), .ch_stall(stall[241]),
    .ch_payload(payload[19821:19788])
`ifdef CCV_TRACE
    , .ch_tid(tid[15487:15424])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_lane_rcu_res_i23_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[241:238]), .credit(credit[241:238]));
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i24_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[242]), .ch_credit(credit[242]), .ch_stall(stall[242]),
    .ch_payload(payload[19855:19822])
`ifdef CCV_TRACE
    , .ch_tid(tid[15551:15488])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i24_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[243]), .ch_credit(credit[243]), .ch_stall(stall[243]),
    .ch_payload(payload[19889:19856])
`ifdef CCV_TRACE
    , .ch_tid(tid[15615:15552])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i24_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[244]), .ch_credit(credit[244]), .ch_stall(stall[244]),
    .ch_payload(payload[19923:19890])
`ifdef CCV_TRACE
    , .ch_tid(tid[15679:15616])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i24_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[245]), .ch_credit(credit[245]), .ch_stall(stall[245]),
    .ch_payload(payload[19957:19924])
`ifdef CCV_TRACE
    , .ch_tid(tid[15743:15680])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_lane_rcu_res_i24_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[245:242]), .credit(credit[245:242]));
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i25_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[246]), .ch_credit(credit[246]), .ch_stall(stall[246]),
    .ch_payload(payload[19991:19958])
`ifdef CCV_TRACE
    , .ch_tid(tid[15807:15744])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i25_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[247]), .ch_credit(credit[247]), .ch_stall(stall[247]),
    .ch_payload(payload[20025:19992])
`ifdef CCV_TRACE
    , .ch_tid(tid[15871:15808])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i25_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[248]), .ch_credit(credit[248]), .ch_stall(stall[248]),
    .ch_payload(payload[20059:20026])
`ifdef CCV_TRACE
    , .ch_tid(tid[15935:15872])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i25_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[249]), .ch_credit(credit[249]), .ch_stall(stall[249]),
    .ch_payload(payload[20093:20060])
`ifdef CCV_TRACE
    , .ch_tid(tid[15999:15936])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_lane_rcu_res_i25_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[249:246]), .credit(credit[249:246]));
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i26_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[250]), .ch_credit(credit[250]), .ch_stall(stall[250]),
    .ch_payload(payload[20127:20094])
`ifdef CCV_TRACE
    , .ch_tid(tid[16063:16000])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i26_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[251]), .ch_credit(credit[251]), .ch_stall(stall[251]),
    .ch_payload(payload[20161:20128])
`ifdef CCV_TRACE
    , .ch_tid(tid[16127:16064])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i26_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[252]), .ch_credit(credit[252]), .ch_stall(stall[252]),
    .ch_payload(payload[20195:20162])
`ifdef CCV_TRACE
    , .ch_tid(tid[16191:16128])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i26_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[253]), .ch_credit(credit[253]), .ch_stall(stall[253]),
    .ch_payload(payload[20229:20196])
`ifdef CCV_TRACE
    , .ch_tid(tid[16255:16192])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_lane_rcu_res_i26_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[253:250]), .credit(credit[253:250]));
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i27_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[254]), .ch_credit(credit[254]), .ch_stall(stall[254]),
    .ch_payload(payload[20263:20230])
`ifdef CCV_TRACE
    , .ch_tid(tid[16319:16256])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i27_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[255]), .ch_credit(credit[255]), .ch_stall(stall[255]),
    .ch_payload(payload[20297:20264])
`ifdef CCV_TRACE
    , .ch_tid(tid[16383:16320])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i27_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[256]), .ch_credit(credit[256]), .ch_stall(stall[256]),
    .ch_payload(payload[20331:20298])
`ifdef CCV_TRACE
    , .ch_tid(tid[16447:16384])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i27_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[257]), .ch_credit(credit[257]), .ch_stall(stall[257]),
    .ch_payload(payload[20365:20332])
`ifdef CCV_TRACE
    , .ch_tid(tid[16511:16448])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_lane_rcu_res_i27_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[257:254]), .credit(credit[257:254]));
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i28_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[258]), .ch_credit(credit[258]), .ch_stall(stall[258]),
    .ch_payload(payload[20399:20366])
`ifdef CCV_TRACE
    , .ch_tid(tid[16575:16512])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i28_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[259]), .ch_credit(credit[259]), .ch_stall(stall[259]),
    .ch_payload(payload[20433:20400])
`ifdef CCV_TRACE
    , .ch_tid(tid[16639:16576])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i28_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[260]), .ch_credit(credit[260]), .ch_stall(stall[260]),
    .ch_payload(payload[20467:20434])
`ifdef CCV_TRACE
    , .ch_tid(tid[16703:16640])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i28_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[261]), .ch_credit(credit[261]), .ch_stall(stall[261]),
    .ch_payload(payload[20501:20468])
`ifdef CCV_TRACE
    , .ch_tid(tid[16767:16704])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_lane_rcu_res_i28_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[261:258]), .credit(credit[261:258]));
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i29_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[262]), .ch_credit(credit[262]), .ch_stall(stall[262]),
    .ch_payload(payload[20535:20502])
`ifdef CCV_TRACE
    , .ch_tid(tid[16831:16768])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i29_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[263]), .ch_credit(credit[263]), .ch_stall(stall[263]),
    .ch_payload(payload[20569:20536])
`ifdef CCV_TRACE
    , .ch_tid(tid[16895:16832])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i29_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[264]), .ch_credit(credit[264]), .ch_stall(stall[264]),
    .ch_payload(payload[20603:20570])
`ifdef CCV_TRACE
    , .ch_tid(tid[16959:16896])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i29_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[265]), .ch_credit(credit[265]), .ch_stall(stall[265]),
    .ch_payload(payload[20637:20604])
`ifdef CCV_TRACE
    , .ch_tid(tid[17023:16960])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_lane_rcu_res_i29_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[265:262]), .credit(credit[265:262]));
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i30_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[266]), .ch_credit(credit[266]), .ch_stall(stall[266]),
    .ch_payload(payload[20671:20638])
`ifdef CCV_TRACE
    , .ch_tid(tid[17087:17024])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i30_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[267]), .ch_credit(credit[267]), .ch_stall(stall[267]),
    .ch_payload(payload[20705:20672])
`ifdef CCV_TRACE
    , .ch_tid(tid[17151:17088])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i30_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[268]), .ch_credit(credit[268]), .ch_stall(stall[268]),
    .ch_payload(payload[20739:20706])
`ifdef CCV_TRACE
    , .ch_tid(tid[17215:17152])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i30_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[269]), .ch_credit(credit[269]), .ch_stall(stall[269]),
    .ch_payload(payload[20773:20740])
`ifdef CCV_TRACE
    , .ch_tid(tid[17279:17216])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_lane_rcu_res_i30_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[269:266]), .credit(credit[269:266]));
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i31_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[270]), .ch_credit(credit[270]), .ch_stall(stall[270]),
    .ch_payload(payload[20807:20774])
`ifdef CCV_TRACE
    , .ch_tid(tid[17343:17280])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i31_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[271]), .ch_credit(credit[271]), .ch_stall(stall[271]),
    .ch_payload(payload[20841:20808])
`ifdef CCV_TRACE
    , .ch_tid(tid[17407:17344])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i31_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[272]), .ch_credit(credit[272]), .ch_stall(stall[272]),
    .ch_payload(payload[20875:20842])
`ifdef CCV_TRACE
    , .ch_tid(tid[17471:17408])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(34), .CHANNEL(4)) u_lane_rcu_res_i31_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[273]), .ch_credit(credit[273]), .ch_stall(stall[273]),
    .ch_payload(payload[20909:20876])
`ifdef CCV_TRACE
    , .ch_tid(tid[17535:17472])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_lane_rcu_res_i31_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[273:270]), .credit(credit[273:270]));
  ccv_credit_checker #(.PAYLOAD_W(73), .CHANNEL(5)) u_rcu_ooe_done_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[274]), .ch_credit(credit[274]), .ch_stall(stall[274]),
    .ch_payload(payload[20982:20910])
`ifdef CCV_TRACE
    , .ch_tid(tid[17599:17536])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(73), .CHANNEL(5)) u_rcu_ooe_done_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[275]), .ch_credit(credit[275]), .ch_stall(stall[275]),
    .ch_payload(payload[21055:20983])
`ifdef CCV_TRACE
    , .ch_tid(tid[17663:17600])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(73), .CHANNEL(5)) u_rcu_ooe_done_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[276]), .ch_credit(credit[276]), .ch_stall(stall[276]),
    .ch_payload(payload[21128:21056])
`ifdef CCV_TRACE
    , .ch_tid(tid[17727:17664])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(73), .CHANNEL(5)) u_rcu_ooe_done_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[277]), .ch_credit(credit[277]), .ch_stall(stall[277]),
    .ch_payload(payload[21201:21129])
`ifdef CCV_TRACE
    , .ch_tid(tid[17791:17728])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_rcu_ooe_done_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[277:274]), .credit(credit[277:274]));
  ccv_credit_checker #(.PAYLOAD_W(2151), .CHANNEL(6)) u_rcu_miu_addr_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[278]), .ch_credit(credit[278]), .ch_stall(stall[278]),
    .ch_payload(payload[23352:21202])
`ifdef CCV_TRACE
    , .ch_tid(tid[17855:17792])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(2151), .CHANNEL(6)) u_rcu_miu_addr_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[279]), .ch_credit(credit[279]), .ch_stall(stall[279]),
    .ch_payload(payload[25503:23353])
`ifdef CCV_TRACE
    , .ch_tid(tid[17919:17856])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(2151), .CHANNEL(6)) u_rcu_miu_addr_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[280]), .ch_credit(credit[280]), .ch_stall(stall[280]),
    .ch_payload(payload[27654:25504])
`ifdef CCV_TRACE
    , .ch_tid(tid[17983:17920])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(2151), .CHANNEL(6)) u_rcu_miu_addr_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[281]), .ch_credit(credit[281]), .ch_stall(stall[281]),
    .ch_payload(payload[29805:27655])
`ifdef CCV_TRACE
    , .ch_tid(tid[18047:17984])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_rcu_miu_addr_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[281:278]), .credit(credit[281:278]));
  ccv_credit_checker #(.PAYLOAD_W(1112), .CHANNEL(7)) u_miu_rcu_data_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[282]), .ch_credit(credit[282]), .ch_stall(stall[282]),
    .ch_payload(payload[30917:29806])
`ifdef CCV_TRACE
    , .ch_tid(tid[18111:18048])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(1112), .CHANNEL(7)) u_miu_rcu_data_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[283]), .ch_credit(credit[283]), .ch_stall(stall[283]),
    .ch_payload(payload[32029:30918])
`ifdef CCV_TRACE
    , .ch_tid(tid[18175:18112])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(1112), .CHANNEL(7)) u_miu_rcu_data_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[284]), .ch_credit(credit[284]), .ch_stall(stall[284]),
    .ch_payload(payload[33141:32030])
`ifdef CCV_TRACE
    , .ch_tid(tid[18239:18176])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(1112), .CHANNEL(7)) u_miu_rcu_data_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[285]), .ch_credit(credit[285]), .ch_stall(stall[285]),
    .ch_payload(payload[34253:33142])
`ifdef CCV_TRACE
    , .ch_tid(tid[18303:18240])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_miu_rcu_data_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[285:282]), .credit(credit[285:282]));
  ccv_credit_checker #(.PAYLOAD_W(93), .CHANNEL(8)) u_ooe_miu_memop_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[286]), .ch_credit(credit[286]), .ch_stall(stall[286]),
    .ch_payload(payload[34346:34254])
`ifdef CCV_TRACE
    , .ch_tid(tid[18367:18304])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(93), .CHANNEL(8)) u_ooe_miu_memop_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[287]), .ch_credit(credit[287]), .ch_stall(stall[287]),
    .ch_payload(payload[34439:34347])
`ifdef CCV_TRACE
    , .ch_tid(tid[18431:18368])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(93), .CHANNEL(8)) u_ooe_miu_memop_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[288]), .ch_credit(credit[288]), .ch_stall(stall[288]),
    .ch_payload(payload[34532:34440])
`ifdef CCV_TRACE
    , .ch_tid(tid[18495:18432])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(93), .CHANNEL(8)) u_ooe_miu_memop_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[289]), .ch_credit(credit[289]), .ch_stall(stall[289]),
    .ch_payload(payload[34625:34533])
`ifdef CCV_TRACE
    , .ch_tid(tid[18559:18496])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_ooe_miu_memop_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[289:286]), .credit(credit[289:286]));
  ccv_credit_checker #(.PAYLOAD_W(110), .CHANNEL(9)) u_miu_ooe_cmpl_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[290]), .ch_credit(credit[290]), .ch_stall(stall[290]),
    .ch_payload(payload[34735:34626])
`ifdef CCV_TRACE
    , .ch_tid(tid[18623:18560])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(110), .CHANNEL(9)) u_miu_ooe_cmpl_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[291]), .ch_credit(credit[291]), .ch_stall(stall[291]),
    .ch_payload(payload[34845:34736])
`ifdef CCV_TRACE
    , .ch_tid(tid[18687:18624])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(110), .CHANNEL(9)) u_miu_ooe_cmpl_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[292]), .ch_credit(credit[292]), .ch_stall(stall[292]),
    .ch_payload(payload[34955:34846])
`ifdef CCV_TRACE
    , .ch_tid(tid[18751:18688])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(110), .CHANNEL(9)) u_miu_ooe_cmpl_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[293]), .ch_credit(credit[293]), .ch_stall(stall[293]),
    .ch_payload(payload[35065:34956])
`ifdef CCV_TRACE
    , .ch_tid(tid[18815:18752])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_miu_ooe_cmpl_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[293:290]), .credit(credit[293:290]));
  ccv_credit_checker #(.PAYLOAD_W(8), .CHANNEL(10)) u_ooe_miu_retire_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[294]), .ch_credit(credit[294]), .ch_stall(stall[294]),
    .ch_payload(payload[35073:35066])
`ifdef CCV_TRACE
    , .ch_tid(tid[18879:18816])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(8), .CHANNEL(10)) u_ooe_miu_retire_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[295]), .ch_credit(credit[295]), .ch_stall(stall[295]),
    .ch_payload(payload[35081:35074])
`ifdef CCV_TRACE
    , .ch_tid(tid[18943:18880])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(8), .CHANNEL(10)) u_ooe_miu_retire_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[296]), .ch_credit(credit[296]), .ch_stall(stall[296]),
    .ch_payload(payload[35089:35082])
`ifdef CCV_TRACE
    , .ch_tid(tid[19007:18944])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(8), .CHANNEL(10)) u_ooe_miu_retire_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[297]), .ch_credit(credit[297]), .ch_stall(stall[297]),
    .ch_payload(payload[35097:35090])
`ifdef CCV_TRACE
    , .ch_tid(tid[19071:19008])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_ooe_miu_retire_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[297:294]), .credit(credit[297:294]));
  ccv_credit_checker #(.PAYLOAD_W(201), .CHANNEL(11)) u_ooe_fet_redirect_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[298]), .ch_credit(credit[298]), .ch_stall(stall[298]),
    .ch_payload(payload[35298:35098])
`ifdef CCV_TRACE
    , .ch_tid(tid[19135:19072])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(1477), .CHANNEL(12)) u_miu_spm_req_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[299]), .ch_credit(credit[299]), .ch_stall(stall[299]),
    .ch_payload(payload[36775:35299])
`ifdef CCV_TRACE
    , .ch_tid(tid[19199:19136])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(1477), .CHANNEL(12)) u_miu_spm_req_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[300]), .ch_credit(credit[300]), .ch_stall(stall[300]),
    .ch_payload(payload[38252:36776])
`ifdef CCV_TRACE
    , .ch_tid(tid[19263:19200])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(1477), .CHANNEL(12)) u_miu_spm_req_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[301]), .ch_credit(credit[301]), .ch_stall(stall[301]),
    .ch_payload(payload[39729:38253])
`ifdef CCV_TRACE
    , .ch_tid(tid[19327:19264])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(1477), .CHANNEL(12)) u_miu_spm_req_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[302]), .ch_credit(credit[302]), .ch_stall(stall[302]),
    .ch_payload(payload[41206:39730])
`ifdef CCV_TRACE
    , .ch_tid(tid[19391:19328])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_miu_spm_req_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[302:299]), .credit(credit[302:299]));
  ccv_credit_checker #(.PAYLOAD_W(1033), .CHANNEL(13)) u_spm_miu_rsp_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[303]), .ch_credit(credit[303]), .ch_stall(stall[303]),
    .ch_payload(payload[42239:41207])
`ifdef CCV_TRACE
    , .ch_tid(tid[19455:19392])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(1033), .CHANNEL(13)) u_spm_miu_rsp_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[304]), .ch_credit(credit[304]), .ch_stall(stall[304]),
    .ch_payload(payload[43272:42240])
`ifdef CCV_TRACE
    , .ch_tid(tid[19519:19456])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(1033), .CHANNEL(13)) u_spm_miu_rsp_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[305]), .ch_credit(credit[305]), .ch_stall(stall[305]),
    .ch_payload(payload[44305:43273])
`ifdef CCV_TRACE
    , .ch_tid(tid[19583:19520])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(1033), .CHANNEL(13)) u_spm_miu_rsp_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[306]), .ch_credit(credit[306]), .ch_stall(stall[306]),
    .ch_payload(payload[45338:44306])
`ifdef CCV_TRACE
    , .ch_tid(tid[19647:19584])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_spm_miu_rsp_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[306:303]), .credit(credit[306:303]));
  ccv_credit_checker #(.PAYLOAD_W(1212), .CHANNEL(14)) u_miu_dcu_req_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[307]), .ch_credit(credit[307]), .ch_stall(stall[307]),
    .ch_payload(payload[46550:45339])
`ifdef CCV_TRACE
    , .ch_tid(tid[19711:19648])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(1212), .CHANNEL(14)) u_miu_dcu_req_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[308]), .ch_credit(credit[308]), .ch_stall(stall[308]),
    .ch_payload(payload[47762:46551])
`ifdef CCV_TRACE
    , .ch_tid(tid[19775:19712])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(1212), .CHANNEL(14)) u_miu_dcu_req_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[309]), .ch_credit(credit[309]), .ch_stall(stall[309]),
    .ch_payload(payload[48974:47763])
`ifdef CCV_TRACE
    , .ch_tid(tid[19839:19776])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(1212), .CHANNEL(14)) u_miu_dcu_req_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[310]), .ch_credit(credit[310]), .ch_stall(stall[310]),
    .ch_payload(payload[50186:48975])
`ifdef CCV_TRACE
    , .ch_tid(tid[19903:19840])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_miu_dcu_req_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[310:307]), .credit(credit[310:307]));
  ccv_credit_checker #(.PAYLOAD_W(1030), .CHANNEL(15)) u_dcu_miu_rsp_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[311]), .ch_credit(credit[311]), .ch_stall(stall[311]),
    .ch_payload(payload[51216:50187])
`ifdef CCV_TRACE
    , .ch_tid(tid[19967:19904])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(1030), .CHANNEL(15)) u_dcu_miu_rsp_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[312]), .ch_credit(credit[312]), .ch_stall(stall[312]),
    .ch_payload(payload[52246:51217])
`ifdef CCV_TRACE
    , .ch_tid(tid[20031:19968])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(1030), .CHANNEL(15)) u_dcu_miu_rsp_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[313]), .ch_credit(credit[313]), .ch_stall(stall[313]),
    .ch_payload(payload[53276:52247])
`ifdef CCV_TRACE
    , .ch_tid(tid[20095:20032])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(1030), .CHANNEL(15)) u_dcu_miu_rsp_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[314]), .ch_credit(credit[314]), .ch_stall(stall[314]),
    .ch_payload(payload[54306:53277])
`ifdef CCV_TRACE
    , .ch_tid(tid[20159:20096])
`endif
  );
  ccv_atomic_checker #(.N(4)) u_dcu_miu_rsp_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[314:311]), .credit(credit[314:311]));
  ccv_credit_checker #(.PAYLOAD_W(1082), .CHANNEL(16)) u_dcu_mlc_req_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[315]), .ch_credit(credit[315]), .ch_stall(stall[315]),
    .ch_payload(payload[55388:54307])
`ifdef CCV_TRACE
    , .ch_tid(tid[20223:20160])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(1030), .CHANNEL(17)) u_mlc_dcu_rsp_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[316]), .ch_credit(credit[316]), .ch_stall(stall[316]),
    .ch_payload(payload[56418:55389])
`ifdef CCV_TRACE
    , .ch_tid(tid[20287:20224])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(51), .CHANNEL(18)) u_mlc_dcu_probe_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[317]), .ch_credit(credit[317]), .ch_stall(stall[317]),
    .ch_payload(payload[56469:56419])
`ifdef CCV_TRACE
    , .ch_tid(tid[20351:20288])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(1027), .CHANNEL(19)) u_dcu_mlc_probe_ack_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[318]), .ch_credit(credit[318]), .ch_stall(stall[318]),
    .ch_payload(payload[57496:56470])
`ifdef CCV_TRACE
    , .ch_tid(tid[20415:20352])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(58), .CHANNEL(20)) u_fet_mlc_ifill_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[319]), .ch_credit(credit[319]), .ch_stall(stall[319]),
    .ch_payload(payload[57554:57497])
`ifdef CCV_TRACE
    , .ch_tid(tid[20479:20416])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(1026), .CHANNEL(21)) u_mlc_fet_ifill_rsp_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[320]), .ch_credit(credit[320]), .ch_stall(stall[320]),
    .ch_payload(payload[58580:57555])
`ifdef CCV_TRACE
    , .ch_tid(tid[20543:20480])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(64), .CHANNEL(22)) u_miu_fet_itlb_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[321]), .ch_credit(credit[321]), .ch_stall(stall[321]),
    .ch_payload(payload[58644:58581])
`ifdef CCV_TRACE
    , .ch_tid(tid[20607:20544])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(72), .CHANNEL(23)) u_fet_miu_itlb_req_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[322]), .ch_credit(credit[322]), .ch_stall(stall[322]),
    .ch_payload(payload[58716:58645])
`ifdef CCV_TRACE
    , .ch_tid(tid[20671:20608])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(1090), .CHANNEL(24)) u_mlc_exb_req_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[323]), .ch_credit(credit[323]), .ch_stall(stall[323]),
    .ch_payload(payload[59806:58717])
`ifdef CCV_TRACE
    , .ch_tid(tid[20735:20672])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(1082), .CHANNEL(25)) u_exb_mlc_rsp_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[324]), .ch_credit(credit[324]), .ch_stall(stall[324]),
    .ch_payload(payload[60888:59807])
`ifdef CCV_TRACE
    , .ch_tid(tid[20799:20736])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(1225), .CHANNEL(26)) u_exb_ext_out_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[325]), .ch_credit(credit[325]), .ch_stall(stall[325]),
    .ch_payload(payload[62113:60889])
`ifdef CCV_TRACE
    , .ch_tid(tid[20863:20800])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(184), .CHANNEL(27)) u_rau_fet_launch_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[326]), .ch_credit(credit[326]), .ch_stall(stall[326]),
    .ch_payload(payload[62297:62114])
`ifdef CCV_TRACE
    , .ch_tid(tid[20927:20864])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(59), .CHANNEL(28)) u_rau_ooe_alloc_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[327]), .ch_credit(credit[327]), .ch_stall(stall[327]),
    .ch_payload(payload[62356:62298])
`ifdef CCV_TRACE
    , .ch_tid(tid[20991:20928])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(16), .CHANNEL(29)) u_ooe_rau_status_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[328]), .ch_credit(credit[328]), .ch_stall(stall[328]),
    .ch_payload(payload[62372:62357])
`ifdef CCV_TRACE
    , .ch_tid(tid[21055:20992])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(6), .CHANNEL(30)) u_rau_ooe_demote_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[329]), .ch_credit(credit[329]), .ch_stall(stall[329]),
    .ch_payload(payload[62378:62373])
`ifdef CCV_TRACE
    , .ch_tid(tid[21119:21056])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(70), .CHANNEL(31)) u_ooe_rau_drained_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[330]), .ch_credit(credit[330]), .ch_stall(stall[330]),
    .ch_payload(payload[62448:62379])
`ifdef CCV_TRACE
    , .ch_tid(tid[21183:21120])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(9), .CHANNEL(32)) u_rau_rcu_mig_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[331]), .ch_credit(credit[331]), .ch_stall(stall[331]),
    .ch_payload(payload[62457:62449])
`ifdef CCV_TRACE
    , .ch_tid(tid[21247:21184])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(2057), .CHANNEL(33)) u_rcu_pca_mig_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[332]), .ch_credit(credit[332]), .ch_stall(stall[332]),
    .ch_payload(payload[64514:62458])
`ifdef CCV_TRACE
    , .ch_tid(tid[21311:21248])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(2057), .CHANNEL(34)) u_pca_rcu_mig_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[333]), .ch_credit(credit[333]), .ch_stall(stall[333]),
    .ch_payload(payload[66571:64515])
`ifdef CCV_TRACE
    , .ch_tid(tid[21375:21312])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(261), .CHANNEL(35)) u_fet_pca_mig_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[334]), .ch_credit(credit[334]), .ch_stall(stall[334]),
    .ch_payload(payload[66832:66572])
`ifdef CCV_TRACE
    , .ch_tid(tid[21439:21376])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(261), .CHANNEL(36)) u_pca_fet_mig_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[335]), .ch_credit(credit[335]), .ch_stall(stall[335]),
    .ch_payload(payload[67093:66833])
`ifdef CCV_TRACE
    , .ch_tid(tid[21503:21440])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(9), .CHANNEL(37)) u_rau_fet_mig_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[336]), .ch_credit(credit[336]), .ch_stall(stall[336]),
    .ch_payload(payload[67102:67094])
`ifdef CCV_TRACE
    , .ch_tid(tid[21567:21504])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(5), .CHANNEL(38)) u_pca_rau_mig_done_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[337]), .ch_credit(credit[337]), .ch_stall(stall[337]),
    .ch_payload(payload[67107:67103])
`ifdef CCV_TRACE
    , .ch_tid(tid[21631:21568])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(101), .CHANNEL(39)) u_rau_miu_cta_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[338]), .ch_credit(credit[338]), .ch_stall(stall[338]),
    .ch_payload(payload[67208:67108])
`ifdef CCV_TRACE
    , .ch_tid(tid[21695:21632])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(13), .CHANNEL(40)) u_ooe_syu_bar_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[339]), .ch_credit(credit[339]), .ch_stall(stall[339]),
    .ch_payload(payload[67221:67209])
`ifdef CCV_TRACE
    , .ch_tid(tid[21759:21696])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(36), .CHANNEL(41)) u_syu_ooe_rel_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[340]), .ch_credit(credit[340]), .ch_stall(stall[340]),
    .ch_payload(payload[67257:67222])
`ifdef CCV_TRACE
    , .ch_tid(tid[21823:21760])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(17), .CHANNEL(42)) u_rau_syu_alloc_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[341]), .ch_credit(credit[341]), .ch_stall(stall[341]),
    .ch_payload(payload[67274:67258])
`ifdef CCV_TRACE
    , .ch_tid(tid[21887:21824])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(172), .CHANNEL(43)) u_ooe_cru_fault_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[342]), .ch_credit(credit[342]), .ch_stall(stall[342]),
    .ch_payload(payload[67446:67275])
`ifdef CCV_TRACE
    , .ch_tid(tid[21951:21888])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(74), .CHANNEL(44)) u_cru_rau_cfg_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[343]), .ch_credit(credit[343]), .ch_stall(stall[343]),
    .ch_payload(payload[67520:67447])
`ifdef CCV_TRACE
    , .ch_tid(tid[22015:21952])
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(1176), .CHANNEL(45)) u_ext_exb_in_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[344]), .ch_credit(credit[344]), .ch_stall(stall[344]),
    .ch_payload(payload[68696:67521])
`ifdef CCV_TRACE
    , .ch_tid(tid[22079:22016])
`endif
  );
  ccv_binding_checker #(.N(8), .GROUP(2), .W(2)) u_fet_dec_instr_binding (
    .clk(clk), .rst_n(rst_n), .valid(valid[7:0]),
    .key({payload[970:969], payload[848:847], payload[726:725], payload[604:603], payload[482:481], payload[360:359], payload[238:237], payload[116:115]}));
  // The wake contract (Q-33): valid toward a gated receiver needs this
  // channel instance's wake at least CCV_WAKE_LAT cycles earlier.
  ccv_wake_checker u_fet_dec_instr_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[0]), .wake(wake[0]), .valid(|valid[7:0]));
  ccv_wake_checker u_dec_ooe_uop_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[1]), .wake(wake[1]), .valid(|valid[13:8]));
  ccv_wake_checker u_ooe_rcu_issue_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[2]), .wake(wake[2]), .valid(|valid[17:14]));
  ccv_wake_checker u_rcu_lane_ops_i0_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[3]), .wake(wake[3]), .valid(|valid[21:18]));
  ccv_wake_checker u_rcu_lane_ops_i1_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[4]), .wake(wake[4]), .valid(|valid[25:22]));
  ccv_wake_checker u_rcu_lane_ops_i2_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[5]), .wake(wake[5]), .valid(|valid[29:26]));
  ccv_wake_checker u_rcu_lane_ops_i3_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[6]), .wake(wake[6]), .valid(|valid[33:30]));
  ccv_wake_checker u_rcu_lane_ops_i4_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[7]), .wake(wake[7]), .valid(|valid[37:34]));
  ccv_wake_checker u_rcu_lane_ops_i5_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[8]), .wake(wake[8]), .valid(|valid[41:38]));
  ccv_wake_checker u_rcu_lane_ops_i6_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[9]), .wake(wake[9]), .valid(|valid[45:42]));
  ccv_wake_checker u_rcu_lane_ops_i7_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[10]), .wake(wake[10]), .valid(|valid[49:46]));
  ccv_wake_checker u_rcu_lane_ops_i8_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[11]), .wake(wake[11]), .valid(|valid[53:50]));
  ccv_wake_checker u_rcu_lane_ops_i9_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[12]), .wake(wake[12]), .valid(|valid[57:54]));
  ccv_wake_checker u_rcu_lane_ops_i10_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[13]), .wake(wake[13]), .valid(|valid[61:58]));
  ccv_wake_checker u_rcu_lane_ops_i11_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[14]), .wake(wake[14]), .valid(|valid[65:62]));
  ccv_wake_checker u_rcu_lane_ops_i12_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[15]), .wake(wake[15]), .valid(|valid[69:66]));
  ccv_wake_checker u_rcu_lane_ops_i13_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[16]), .wake(wake[16]), .valid(|valid[73:70]));
  ccv_wake_checker u_rcu_lane_ops_i14_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[17]), .wake(wake[17]), .valid(|valid[77:74]));
  ccv_wake_checker u_rcu_lane_ops_i15_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[18]), .wake(wake[18]), .valid(|valid[81:78]));
  ccv_wake_checker u_rcu_lane_ops_i16_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[19]), .wake(wake[19]), .valid(|valid[85:82]));
  ccv_wake_checker u_rcu_lane_ops_i17_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[20]), .wake(wake[20]), .valid(|valid[89:86]));
  ccv_wake_checker u_rcu_lane_ops_i18_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[21]), .wake(wake[21]), .valid(|valid[93:90]));
  ccv_wake_checker u_rcu_lane_ops_i19_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[22]), .wake(wake[22]), .valid(|valid[97:94]));
  ccv_wake_checker u_rcu_lane_ops_i20_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[23]), .wake(wake[23]), .valid(|valid[101:98]));
  ccv_wake_checker u_rcu_lane_ops_i21_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[24]), .wake(wake[24]), .valid(|valid[105:102]));
  ccv_wake_checker u_rcu_lane_ops_i22_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[25]), .wake(wake[25]), .valid(|valid[109:106]));
  ccv_wake_checker u_rcu_lane_ops_i23_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[26]), .wake(wake[26]), .valid(|valid[113:110]));
  ccv_wake_checker u_rcu_lane_ops_i24_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[27]), .wake(wake[27]), .valid(|valid[117:114]));
  ccv_wake_checker u_rcu_lane_ops_i25_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[28]), .wake(wake[28]), .valid(|valid[121:118]));
  ccv_wake_checker u_rcu_lane_ops_i26_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[29]), .wake(wake[29]), .valid(|valid[125:122]));
  ccv_wake_checker u_rcu_lane_ops_i27_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[30]), .wake(wake[30]), .valid(|valid[129:126]));
  ccv_wake_checker u_rcu_lane_ops_i28_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[31]), .wake(wake[31]), .valid(|valid[133:130]));
  ccv_wake_checker u_rcu_lane_ops_i29_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[32]), .wake(wake[32]), .valid(|valid[137:134]));
  ccv_wake_checker u_rcu_lane_ops_i30_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[33]), .wake(wake[33]), .valid(|valid[141:138]));
  ccv_wake_checker u_rcu_lane_ops_i31_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[34]), .wake(wake[34]), .valid(|valid[145:142]));
  ccv_wake_checker u_lane_rcu_res_i0_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[35]), .wake(wake[35]), .valid(|valid[149:146]));
  ccv_wake_checker u_lane_rcu_res_i1_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[36]), .wake(wake[36]), .valid(|valid[153:150]));
  ccv_wake_checker u_lane_rcu_res_i2_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[37]), .wake(wake[37]), .valid(|valid[157:154]));
  ccv_wake_checker u_lane_rcu_res_i3_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[38]), .wake(wake[38]), .valid(|valid[161:158]));
  ccv_wake_checker u_lane_rcu_res_i4_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[39]), .wake(wake[39]), .valid(|valid[165:162]));
  ccv_wake_checker u_lane_rcu_res_i5_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[40]), .wake(wake[40]), .valid(|valid[169:166]));
  ccv_wake_checker u_lane_rcu_res_i6_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[41]), .wake(wake[41]), .valid(|valid[173:170]));
  ccv_wake_checker u_lane_rcu_res_i7_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[42]), .wake(wake[42]), .valid(|valid[177:174]));
  ccv_wake_checker u_lane_rcu_res_i8_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[43]), .wake(wake[43]), .valid(|valid[181:178]));
  ccv_wake_checker u_lane_rcu_res_i9_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[44]), .wake(wake[44]), .valid(|valid[185:182]));
  ccv_wake_checker u_lane_rcu_res_i10_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[45]), .wake(wake[45]), .valid(|valid[189:186]));
  ccv_wake_checker u_lane_rcu_res_i11_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[46]), .wake(wake[46]), .valid(|valid[193:190]));
  ccv_wake_checker u_lane_rcu_res_i12_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[47]), .wake(wake[47]), .valid(|valid[197:194]));
  ccv_wake_checker u_lane_rcu_res_i13_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[48]), .wake(wake[48]), .valid(|valid[201:198]));
  ccv_wake_checker u_lane_rcu_res_i14_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[49]), .wake(wake[49]), .valid(|valid[205:202]));
  ccv_wake_checker u_lane_rcu_res_i15_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[50]), .wake(wake[50]), .valid(|valid[209:206]));
  ccv_wake_checker u_lane_rcu_res_i16_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[51]), .wake(wake[51]), .valid(|valid[213:210]));
  ccv_wake_checker u_lane_rcu_res_i17_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[52]), .wake(wake[52]), .valid(|valid[217:214]));
  ccv_wake_checker u_lane_rcu_res_i18_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[53]), .wake(wake[53]), .valid(|valid[221:218]));
  ccv_wake_checker u_lane_rcu_res_i19_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[54]), .wake(wake[54]), .valid(|valid[225:222]));
  ccv_wake_checker u_lane_rcu_res_i20_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[55]), .wake(wake[55]), .valid(|valid[229:226]));
  ccv_wake_checker u_lane_rcu_res_i21_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[56]), .wake(wake[56]), .valid(|valid[233:230]));
  ccv_wake_checker u_lane_rcu_res_i22_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[57]), .wake(wake[57]), .valid(|valid[237:234]));
  ccv_wake_checker u_lane_rcu_res_i23_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[58]), .wake(wake[58]), .valid(|valid[241:238]));
  ccv_wake_checker u_lane_rcu_res_i24_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[59]), .wake(wake[59]), .valid(|valid[245:242]));
  ccv_wake_checker u_lane_rcu_res_i25_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[60]), .wake(wake[60]), .valid(|valid[249:246]));
  ccv_wake_checker u_lane_rcu_res_i26_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[61]), .wake(wake[61]), .valid(|valid[253:250]));
  ccv_wake_checker u_lane_rcu_res_i27_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[62]), .wake(wake[62]), .valid(|valid[257:254]));
  ccv_wake_checker u_lane_rcu_res_i28_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[63]), .wake(wake[63]), .valid(|valid[261:258]));
  ccv_wake_checker u_lane_rcu_res_i29_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[64]), .wake(wake[64]), .valid(|valid[265:262]));
  ccv_wake_checker u_lane_rcu_res_i30_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[65]), .wake(wake[65]), .valid(|valid[269:266]));
  ccv_wake_checker u_lane_rcu_res_i31_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[66]), .wake(wake[66]), .valid(|valid[273:270]));
  ccv_wake_checker u_rcu_ooe_done_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[67]), .wake(wake[67]), .valid(|valid[277:274]));
  ccv_wake_checker u_rcu_miu_addr_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[68]), .wake(wake[68]), .valid(|valid[281:278]));
  ccv_wake_checker u_miu_rcu_data_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[69]), .wake(wake[69]), .valid(|valid[285:282]));
  ccv_wake_checker u_ooe_miu_memop_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[70]), .wake(wake[70]), .valid(|valid[289:286]));
  ccv_wake_checker u_miu_ooe_cmpl_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[71]), .wake(wake[71]), .valid(|valid[293:290]));
  ccv_wake_checker u_ooe_miu_retire_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[72]), .wake(wake[72]), .valid(|valid[297:294]));
  ccv_wake_checker u_ooe_fet_redirect_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[73]), .wake(wake[73]), .valid(|valid[298:298]));
  ccv_wake_checker u_miu_spm_req_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[74]), .wake(wake[74]), .valid(|valid[302:299]));
  ccv_wake_checker u_spm_miu_rsp_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[75]), .wake(wake[75]), .valid(|valid[306:303]));
  ccv_wake_checker u_miu_dcu_req_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[76]), .wake(wake[76]), .valid(|valid[310:307]));
  ccv_wake_checker u_dcu_miu_rsp_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[77]), .wake(wake[77]), .valid(|valid[314:311]));
  ccv_wake_checker u_dcu_mlc_req_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[78]), .wake(wake[78]), .valid(|valid[315:315]));
  ccv_wake_checker u_mlc_dcu_rsp_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[79]), .wake(wake[79]), .valid(|valid[316:316]));
  ccv_wake_checker u_mlc_dcu_probe_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[80]), .wake(wake[80]), .valid(|valid[317:317]));
  ccv_wake_checker u_dcu_mlc_probe_ack_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[81]), .wake(wake[81]), .valid(|valid[318:318]));
  ccv_wake_checker u_fet_mlc_ifill_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[82]), .wake(wake[82]), .valid(|valid[319:319]));
  ccv_wake_checker u_mlc_fet_ifill_rsp_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[83]), .wake(wake[83]), .valid(|valid[320:320]));
  ccv_wake_checker u_miu_fet_itlb_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[84]), .wake(wake[84]), .valid(|valid[321:321]));
  ccv_wake_checker u_fet_miu_itlb_req_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[85]), .wake(wake[85]), .valid(|valid[322:322]));
  ccv_wake_checker u_mlc_exb_req_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[86]), .wake(wake[86]), .valid(|valid[323:323]));
  ccv_wake_checker u_exb_mlc_rsp_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[87]), .wake(wake[87]), .valid(|valid[324:324]));
  ccv_wake_checker u_exb_ext_out_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[88]), .wake(wake[88]), .valid(|valid[325:325]));
  ccv_wake_checker u_rau_fet_launch_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[89]), .wake(wake[89]), .valid(|valid[326:326]));
  ccv_wake_checker u_rau_ooe_alloc_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[90]), .wake(wake[90]), .valid(|valid[327:327]));
  ccv_wake_checker u_ooe_rau_status_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[91]), .wake(wake[91]), .valid(|valid[328:328]));
  ccv_wake_checker u_rau_ooe_demote_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[92]), .wake(wake[92]), .valid(|valid[329:329]));
  ccv_wake_checker u_ooe_rau_drained_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[93]), .wake(wake[93]), .valid(|valid[330:330]));
  ccv_wake_checker u_rau_rcu_mig_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[94]), .wake(wake[94]), .valid(|valid[331:331]));
  ccv_wake_checker u_rcu_pca_mig_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[95]), .wake(wake[95]), .valid(|valid[332:332]));
  ccv_wake_checker u_pca_rcu_mig_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[96]), .wake(wake[96]), .valid(|valid[333:333]));
  ccv_wake_checker u_fet_pca_mig_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[97]), .wake(wake[97]), .valid(|valid[334:334]));
  ccv_wake_checker u_pca_fet_mig_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[98]), .wake(wake[98]), .valid(|valid[335:335]));
  ccv_wake_checker u_rau_fet_mig_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[99]), .wake(wake[99]), .valid(|valid[336:336]));
  ccv_wake_checker u_pca_rau_mig_done_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[100]), .wake(wake[100]), .valid(|valid[337:337]));
  ccv_wake_checker u_rau_miu_cta_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[101]), .wake(wake[101]), .valid(|valid[338:338]));
  ccv_wake_checker u_ooe_syu_bar_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[102]), .wake(wake[102]), .valid(|valid[339:339]));
  ccv_wake_checker u_syu_ooe_rel_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[103]), .wake(wake[103]), .valid(|valid[340:340]));
  ccv_wake_checker u_rau_syu_alloc_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[104]), .wake(wake[104]), .valid(|valid[341:341]));
  ccv_wake_checker u_ooe_cru_fault_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[105]), .wake(wake[105]), .valid(|valid[342:342]));
  ccv_wake_checker u_cru_rau_cfg_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[106]), .wake(wake[106]), .valid(|valid[343:343]));
  ccv_wake_checker u_ext_exb_in_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[107]), .wake(wake[107]), .valid(|valid[344:344]));
  ccv_outstanding_checker #(.MAX(1)) u_fet_miu_itlb_req_outstanding (
    .clk(clk), .rst_n(rst_n), .enable(pair_enable),
    .req_valid(valid[322]), .rsp_valid(valid[321]));  // ccv_miu_fet_itlb
  ccv_lockstep_checker #(.INSTS(32), .N(4)) u_rcu_lane_ops_lockstep (
    .clk(clk), .rst_n(rst_n),
    .valid(valid[145:18]), .credit(credit[145:18])
`ifdef CCV_TRACE
    , .tid(tid[9343:1152])
`endif
  );
  ccv_lockstep_checker #(.INSTS(32), .N(4)) u_lane_rcu_res_lockstep (
    .clk(clk), .rst_n(rst_n),
    .valid(valid[273:146]), .credit(credit[273:146])
`ifdef CCV_TRACE
    , .tid(tid[17535:9344])
`endif
  );

endmodule
