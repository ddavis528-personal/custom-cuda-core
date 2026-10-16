// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-skel.py from schema/interfaces.json,
// params/blocks.json and params/ccv_params.json. Edit a source and
// regenerate; tools/verify.sh fails if this file is stale.


// One ccv_common_chk_credit per slot of every channel instance --
// 163 in all. Verilated into the C++ skeleton, which drives these
// ports from its channels every cycle, so the skeleton is judged
// by the same checker the RTL will be.
`include "ccv_if.svh"
`include "ccv_params_pkg.sv"

module ccv_common_chk_bank (
  input logic                 clk,
  input logic                 rst_n,
  input logic [162:0]          valid,
  input logic [162:0]          credit,
  input logic [162:0]          stall,
  input logic [62898:0]          payload,
  // Test override: switches EVERY multi-slot channel's atomic
  // check on. It can only add checks -- a channel the schema
  // marks atomic is checked whatever this says.
  input logic                 force_atomic,
  // Request/response pairs with an outstanding limit. Off only for
  // the S0 exerciser, whose synthetic traffic sends on each channel
  // independently; on for the functional stubs and in the SV top.
  input logic                 pair_enable,
  // Per channel instance: its _wake, and whether its receiver's clock
  // gate is closed -- the receiver's clk_gated observation port (Q-33).
  // The C++ skeleton drives both low -- no stub sleeps yet -- and the
  // SV top drives the real nets, so the first block that gates its
  // clock is held to the wake contract from its first cycle.
  input logic [109:0]          wake,
  input logic [109:0]          rx_gated
`ifdef CCV_TRACE
  ,
  // Trace-only message identity, 64 bits per slot. Absent
  // without CCV_TRACE, so synthesis never sees it.
  input logic [10431:0]          tid
`endif
);

  ccv_common_chk_credit #(.PAYLOAD_W(160), .CHANNEL(0)) u_fet_dec_instr_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[0]), .ch_credit(credit[0]), .ch_stall(stall[0]),
    .ch_payload(payload[159:0])
`ifdef CCV_TRACE
    , .ch_tid(tid[63:0])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(160), .CHANNEL(0)) u_fet_dec_instr_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[1]), .ch_credit(credit[1]), .ch_stall(stall[1]),
    .ch_payload(payload[319:160])
`ifdef CCV_TRACE
    , .ch_tid(tid[127:64])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(160), .CHANNEL(0)) u_fet_dec_instr_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[2]), .ch_credit(credit[2]), .ch_stall(stall[2]),
    .ch_payload(payload[479:320])
`ifdef CCV_TRACE
    , .ch_tid(tid[191:128])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(160), .CHANNEL(0)) u_fet_dec_instr_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[3]), .ch_credit(credit[3]), .ch_stall(stall[3]),
    .ch_payload(payload[639:480])
`ifdef CCV_TRACE
    , .ch_tid(tid[255:192])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(160), .CHANNEL(0)) u_fet_dec_instr_s4 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[4]), .ch_credit(credit[4]), .ch_stall(stall[4]),
    .ch_payload(payload[799:640])
`ifdef CCV_TRACE
    , .ch_tid(tid[319:256])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(160), .CHANNEL(0)) u_fet_dec_instr_s5 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[5]), .ch_credit(credit[5]), .ch_stall(stall[5]),
    .ch_payload(payload[959:800])
`ifdef CCV_TRACE
    , .ch_tid(tid[383:320])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(160), .CHANNEL(0)) u_fet_dec_instr_s6 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[6]), .ch_credit(credit[6]), .ch_stall(stall[6]),
    .ch_payload(payload[1119:960])
`ifdef CCV_TRACE
    , .ch_tid(tid[447:384])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(160), .CHANNEL(0)) u_fet_dec_instr_s7 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[7]), .ch_credit(credit[7]), .ch_stall(stall[7]),
    .ch_payload(payload[1279:1120])
`ifdef CCV_TRACE
    , .ch_tid(tid[511:448])
`endif
  );
  ccv_common_chk_atomic #(.N(8)) u_fet_dec_instr_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[7:0]), .credit(credit[7:0]));
  ccv_common_chk_credit #(.PAYLOAD_W(211), .CHANNEL(1)) u_dec_ooe_uop_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[8]), .ch_credit(credit[8]), .ch_stall(stall[8]),
    .ch_payload(payload[1490:1280])
`ifdef CCV_TRACE
    , .ch_tid(tid[575:512])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(211), .CHANNEL(1)) u_dec_ooe_uop_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[9]), .ch_credit(credit[9]), .ch_stall(stall[9]),
    .ch_payload(payload[1701:1491])
`ifdef CCV_TRACE
    , .ch_tid(tid[639:576])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(211), .CHANNEL(1)) u_dec_ooe_uop_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[10]), .ch_credit(credit[10]), .ch_stall(stall[10]),
    .ch_payload(payload[1912:1702])
`ifdef CCV_TRACE
    , .ch_tid(tid[703:640])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(211), .CHANNEL(1)) u_dec_ooe_uop_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[11]), .ch_credit(credit[11]), .ch_stall(stall[11]),
    .ch_payload(payload[2123:1913])
`ifdef CCV_TRACE
    , .ch_tid(tid[767:704])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(211), .CHANNEL(1)) u_dec_ooe_uop_s4 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[12]), .ch_credit(credit[12]), .ch_stall(stall[12]),
    .ch_payload(payload[2334:2124])
`ifdef CCV_TRACE
    , .ch_tid(tid[831:768])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(211), .CHANNEL(1)) u_dec_ooe_uop_s5 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[13]), .ch_credit(credit[13]), .ch_stall(stall[13]),
    .ch_payload(payload[2545:2335])
`ifdef CCV_TRACE
    , .ch_tid(tid[895:832])
`endif
  );
  ccv_common_chk_atomic #(.N(6)) u_dec_ooe_uop_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[13:8]), .credit(credit[13:8]));
  ccv_common_chk_credit #(.PAYLOAD_W(175), .CHANNEL(2), .FIXED_LAT(1)) u_ooe_rcu_issue_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[14]), .ch_credit(credit[14]), .ch_stall(stall[14]),
    .ch_payload(payload[2720:2546])
`ifdef CCV_TRACE
    , .ch_tid(tid[959:896])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(175), .CHANNEL(2), .FIXED_LAT(1)) u_ooe_rcu_issue_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[15]), .ch_credit(credit[15]), .ch_stall(stall[15]),
    .ch_payload(payload[2895:2721])
`ifdef CCV_TRACE
    , .ch_tid(tid[1023:960])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(175), .CHANNEL(2), .FIXED_LAT(1)) u_ooe_rcu_issue_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[16]), .ch_credit(credit[16]), .ch_stall(stall[16]),
    .ch_payload(payload[3070:2896])
`ifdef CCV_TRACE
    , .ch_tid(tid[1087:1024])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(175), .CHANNEL(2), .FIXED_LAT(1)) u_ooe_rcu_issue_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[17]), .ch_credit(credit[17]), .ch_stall(stall[17]),
    .ch_payload(payload[3245:3071])
`ifdef CCV_TRACE
    , .ch_tid(tid[1151:1088])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(175), .CHANNEL(2), .FIXED_LAT(1)) u_ooe_rcu_issue_s4 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[18]), .ch_credit(credit[18]), .ch_stall(stall[18]),
    .ch_payload(payload[3420:3246])
`ifdef CCV_TRACE
    , .ch_tid(tid[1215:1152])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(175), .CHANNEL(2), .FIXED_LAT(1)) u_ooe_rcu_issue_s5 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[19]), .ch_credit(credit[19]), .ch_stall(stall[19]),
    .ch_payload(payload[3595:3421])
`ifdef CCV_TRACE
    , .ch_tid(tid[1279:1216])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(175), .CHANNEL(2), .FIXED_LAT(1)) u_ooe_rcu_issue_s6 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[20]), .ch_credit(credit[20]), .ch_stall(stall[20]),
    .ch_payload(payload[3770:3596])
`ifdef CCV_TRACE
    , .ch_tid(tid[1343:1280])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(175), .CHANNEL(2), .FIXED_LAT(1)) u_ooe_rcu_issue_s7 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[21]), .ch_credit(credit[21]), .ch_stall(stall[21]),
    .ch_payload(payload[3945:3771])
`ifdef CCV_TRACE
    , .ch_tid(tid[1407:1344])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(175), .CHANNEL(2), .FIXED_LAT(1)) u_ooe_rcu_issue_s8 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[22]), .ch_credit(credit[22]), .ch_stall(stall[22]),
    .ch_payload(payload[4120:3946])
`ifdef CCV_TRACE
    , .ch_tid(tid[1471:1408])
`endif
  );
  ccv_common_chk_atomic #(.N(9)) u_ooe_rcu_issue_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[22:14]), .credit(credit[22:14]));
  ccv_common_chk_credit #(.PAYLOAD_W(344), .CHANNEL(3), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000), .FIXED_LAT(1)) u_rcu_lane_ops_i0_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[23]), .ch_credit(credit[23]), .ch_stall(stall[23]),
    .ch_payload(payload[4464:4121])
`ifdef CCV_TRACE
    , .ch_tid(tid[1535:1472])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(344), .CHANNEL(3), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000), .FIXED_LAT(1)) u_rcu_lane_ops_i1_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[24]), .ch_credit(credit[24]), .ch_stall(stall[24]),
    .ch_payload(payload[4808:4465])
`ifdef CCV_TRACE
    , .ch_tid(tid[1599:1536])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(344), .CHANNEL(3), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000), .FIXED_LAT(1)) u_rcu_lane_ops_i2_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[25]), .ch_credit(credit[25]), .ch_stall(stall[25]),
    .ch_payload(payload[5152:4809])
`ifdef CCV_TRACE
    , .ch_tid(tid[1663:1600])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(344), .CHANNEL(3), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000), .FIXED_LAT(1)) u_rcu_lane_ops_i3_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[26]), .ch_credit(credit[26]), .ch_stall(stall[26]),
    .ch_payload(payload[5496:5153])
`ifdef CCV_TRACE
    , .ch_tid(tid[1727:1664])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(344), .CHANNEL(3), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000), .FIXED_LAT(1)) u_rcu_lane_ops_i4_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[27]), .ch_credit(credit[27]), .ch_stall(stall[27]),
    .ch_payload(payload[5840:5497])
`ifdef CCV_TRACE
    , .ch_tid(tid[1791:1728])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(344), .CHANNEL(3), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000), .FIXED_LAT(1)) u_rcu_lane_ops_i5_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[28]), .ch_credit(credit[28]), .ch_stall(stall[28]),
    .ch_payload(payload[6184:5841])
`ifdef CCV_TRACE
    , .ch_tid(tid[1855:1792])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(344), .CHANNEL(3), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000), .FIXED_LAT(1)) u_rcu_lane_ops_i6_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[29]), .ch_credit(credit[29]), .ch_stall(stall[29]),
    .ch_payload(payload[6528:6185])
`ifdef CCV_TRACE
    , .ch_tid(tid[1919:1856])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(344), .CHANNEL(3), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000), .FIXED_LAT(1)) u_rcu_lane_ops_i7_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[30]), .ch_credit(credit[30]), .ch_stall(stall[30]),
    .ch_payload(payload[6872:6529])
`ifdef CCV_TRACE
    , .ch_tid(tid[1983:1920])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(344), .CHANNEL(3), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000), .FIXED_LAT(1)) u_rcu_lane_ops_i8_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[31]), .ch_credit(credit[31]), .ch_stall(stall[31]),
    .ch_payload(payload[7216:6873])
`ifdef CCV_TRACE
    , .ch_tid(tid[2047:1984])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(344), .CHANNEL(3), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000), .FIXED_LAT(1)) u_rcu_lane_ops_i9_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[32]), .ch_credit(credit[32]), .ch_stall(stall[32]),
    .ch_payload(payload[7560:7217])
`ifdef CCV_TRACE
    , .ch_tid(tid[2111:2048])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(344), .CHANNEL(3), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000), .FIXED_LAT(1)) u_rcu_lane_ops_i10_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[33]), .ch_credit(credit[33]), .ch_stall(stall[33]),
    .ch_payload(payload[7904:7561])
`ifdef CCV_TRACE
    , .ch_tid(tid[2175:2112])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(344), .CHANNEL(3), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000), .FIXED_LAT(1)) u_rcu_lane_ops_i11_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[34]), .ch_credit(credit[34]), .ch_stall(stall[34]),
    .ch_payload(payload[8248:7905])
`ifdef CCV_TRACE
    , .ch_tid(tid[2239:2176])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(344), .CHANNEL(3), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000), .FIXED_LAT(1)) u_rcu_lane_ops_i12_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[35]), .ch_credit(credit[35]), .ch_stall(stall[35]),
    .ch_payload(payload[8592:8249])
`ifdef CCV_TRACE
    , .ch_tid(tid[2303:2240])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(344), .CHANNEL(3), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000), .FIXED_LAT(1)) u_rcu_lane_ops_i13_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[36]), .ch_credit(credit[36]), .ch_stall(stall[36]),
    .ch_payload(payload[8936:8593])
`ifdef CCV_TRACE
    , .ch_tid(tid[2367:2304])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(344), .CHANNEL(3), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000), .FIXED_LAT(1)) u_rcu_lane_ops_i14_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[37]), .ch_credit(credit[37]), .ch_stall(stall[37]),
    .ch_payload(payload[9280:8937])
`ifdef CCV_TRACE
    , .ch_tid(tid[2431:2368])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(344), .CHANNEL(3), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000), .FIXED_LAT(1)) u_rcu_lane_ops_i15_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[38]), .ch_credit(credit[38]), .ch_stall(stall[38]),
    .ch_payload(payload[9624:9281])
`ifdef CCV_TRACE
    , .ch_tid(tid[2495:2432])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(344), .CHANNEL(3), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000), .FIXED_LAT(1)) u_rcu_lane_ops_i16_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[39]), .ch_credit(credit[39]), .ch_stall(stall[39]),
    .ch_payload(payload[9968:9625])
`ifdef CCV_TRACE
    , .ch_tid(tid[2559:2496])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(344), .CHANNEL(3), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000), .FIXED_LAT(1)) u_rcu_lane_ops_i17_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[40]), .ch_credit(credit[40]), .ch_stall(stall[40]),
    .ch_payload(payload[10312:9969])
`ifdef CCV_TRACE
    , .ch_tid(tid[2623:2560])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(344), .CHANNEL(3), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000), .FIXED_LAT(1)) u_rcu_lane_ops_i18_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[41]), .ch_credit(credit[41]), .ch_stall(stall[41]),
    .ch_payload(payload[10656:10313])
`ifdef CCV_TRACE
    , .ch_tid(tid[2687:2624])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(344), .CHANNEL(3), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000), .FIXED_LAT(1)) u_rcu_lane_ops_i19_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[42]), .ch_credit(credit[42]), .ch_stall(stall[42]),
    .ch_payload(payload[11000:10657])
`ifdef CCV_TRACE
    , .ch_tid(tid[2751:2688])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(344), .CHANNEL(3), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000), .FIXED_LAT(1)) u_rcu_lane_ops_i20_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[43]), .ch_credit(credit[43]), .ch_stall(stall[43]),
    .ch_payload(payload[11344:11001])
`ifdef CCV_TRACE
    , .ch_tid(tid[2815:2752])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(344), .CHANNEL(3), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000), .FIXED_LAT(1)) u_rcu_lane_ops_i21_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[44]), .ch_credit(credit[44]), .ch_stall(stall[44]),
    .ch_payload(payload[11688:11345])
`ifdef CCV_TRACE
    , .ch_tid(tid[2879:2816])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(344), .CHANNEL(3), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000), .FIXED_LAT(1)) u_rcu_lane_ops_i22_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[45]), .ch_credit(credit[45]), .ch_stall(stall[45]),
    .ch_payload(payload[12032:11689])
`ifdef CCV_TRACE
    , .ch_tid(tid[2943:2880])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(344), .CHANNEL(3), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000), .FIXED_LAT(1)) u_rcu_lane_ops_i23_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[46]), .ch_credit(credit[46]), .ch_stall(stall[46]),
    .ch_payload(payload[12376:12033])
`ifdef CCV_TRACE
    , .ch_tid(tid[3007:2944])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(344), .CHANNEL(3), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000), .FIXED_LAT(1)) u_rcu_lane_ops_i24_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[47]), .ch_credit(credit[47]), .ch_stall(stall[47]),
    .ch_payload(payload[12720:12377])
`ifdef CCV_TRACE
    , .ch_tid(tid[3071:3008])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(344), .CHANNEL(3), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000), .FIXED_LAT(1)) u_rcu_lane_ops_i25_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[48]), .ch_credit(credit[48]), .ch_stall(stall[48]),
    .ch_payload(payload[13064:12721])
`ifdef CCV_TRACE
    , .ch_tid(tid[3135:3072])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(344), .CHANNEL(3), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000), .FIXED_LAT(1)) u_rcu_lane_ops_i26_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[49]), .ch_credit(credit[49]), .ch_stall(stall[49]),
    .ch_payload(payload[13408:13065])
`ifdef CCV_TRACE
    , .ch_tid(tid[3199:3136])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(344), .CHANNEL(3), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000), .FIXED_LAT(1)) u_rcu_lane_ops_i27_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[50]), .ch_credit(credit[50]), .ch_stall(stall[50]),
    .ch_payload(payload[13752:13409])
`ifdef CCV_TRACE
    , .ch_tid(tid[3263:3200])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(344), .CHANNEL(3), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000), .FIXED_LAT(1)) u_rcu_lane_ops_i28_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[51]), .ch_credit(credit[51]), .ch_stall(stall[51]),
    .ch_payload(payload[14096:13753])
`ifdef CCV_TRACE
    , .ch_tid(tid[3327:3264])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(344), .CHANNEL(3), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000), .FIXED_LAT(1)) u_rcu_lane_ops_i29_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[52]), .ch_credit(credit[52]), .ch_stall(stall[52]),
    .ch_payload(payload[14440:14097])
`ifdef CCV_TRACE
    , .ch_tid(tid[3391:3328])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(344), .CHANNEL(3), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000), .FIXED_LAT(1)) u_rcu_lane_ops_i30_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[53]), .ch_credit(credit[53]), .ch_stall(stall[53]),
    .ch_payload(payload[14784:14441])
`ifdef CCV_TRACE
    , .ch_tid(tid[3455:3392])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(344), .CHANNEL(3), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000), .FIXED_LAT(1)) u_rcu_lane_ops_i31_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[54]), .ch_credit(credit[54]), .ch_stall(stall[54]),
    .ch_payload(payload[15128:14785])
`ifdef CCV_TRACE
    , .ch_tid(tid[3519:3456])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(44), .CHANNEL(4), .FIXED_LAT(1)) u_lane_rcu_res_i0_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[55]), .ch_credit(credit[55]), .ch_stall(stall[55]),
    .ch_payload(payload[15172:15129])
`ifdef CCV_TRACE
    , .ch_tid(tid[3583:3520])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(44), .CHANNEL(4), .FIXED_LAT(1)) u_lane_rcu_res_i1_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[56]), .ch_credit(credit[56]), .ch_stall(stall[56]),
    .ch_payload(payload[15216:15173])
`ifdef CCV_TRACE
    , .ch_tid(tid[3647:3584])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(44), .CHANNEL(4), .FIXED_LAT(1)) u_lane_rcu_res_i2_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[57]), .ch_credit(credit[57]), .ch_stall(stall[57]),
    .ch_payload(payload[15260:15217])
`ifdef CCV_TRACE
    , .ch_tid(tid[3711:3648])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(44), .CHANNEL(4), .FIXED_LAT(1)) u_lane_rcu_res_i3_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[58]), .ch_credit(credit[58]), .ch_stall(stall[58]),
    .ch_payload(payload[15304:15261])
`ifdef CCV_TRACE
    , .ch_tid(tid[3775:3712])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(44), .CHANNEL(4), .FIXED_LAT(1)) u_lane_rcu_res_i4_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[59]), .ch_credit(credit[59]), .ch_stall(stall[59]),
    .ch_payload(payload[15348:15305])
`ifdef CCV_TRACE
    , .ch_tid(tid[3839:3776])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(44), .CHANNEL(4), .FIXED_LAT(1)) u_lane_rcu_res_i5_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[60]), .ch_credit(credit[60]), .ch_stall(stall[60]),
    .ch_payload(payload[15392:15349])
`ifdef CCV_TRACE
    , .ch_tid(tid[3903:3840])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(44), .CHANNEL(4), .FIXED_LAT(1)) u_lane_rcu_res_i6_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[61]), .ch_credit(credit[61]), .ch_stall(stall[61]),
    .ch_payload(payload[15436:15393])
`ifdef CCV_TRACE
    , .ch_tid(tid[3967:3904])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(44), .CHANNEL(4), .FIXED_LAT(1)) u_lane_rcu_res_i7_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[62]), .ch_credit(credit[62]), .ch_stall(stall[62]),
    .ch_payload(payload[15480:15437])
`ifdef CCV_TRACE
    , .ch_tid(tid[4031:3968])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(44), .CHANNEL(4), .FIXED_LAT(1)) u_lane_rcu_res_i8_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[63]), .ch_credit(credit[63]), .ch_stall(stall[63]),
    .ch_payload(payload[15524:15481])
`ifdef CCV_TRACE
    , .ch_tid(tid[4095:4032])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(44), .CHANNEL(4), .FIXED_LAT(1)) u_lane_rcu_res_i9_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[64]), .ch_credit(credit[64]), .ch_stall(stall[64]),
    .ch_payload(payload[15568:15525])
`ifdef CCV_TRACE
    , .ch_tid(tid[4159:4096])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(44), .CHANNEL(4), .FIXED_LAT(1)) u_lane_rcu_res_i10_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[65]), .ch_credit(credit[65]), .ch_stall(stall[65]),
    .ch_payload(payload[15612:15569])
`ifdef CCV_TRACE
    , .ch_tid(tid[4223:4160])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(44), .CHANNEL(4), .FIXED_LAT(1)) u_lane_rcu_res_i11_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[66]), .ch_credit(credit[66]), .ch_stall(stall[66]),
    .ch_payload(payload[15656:15613])
`ifdef CCV_TRACE
    , .ch_tid(tid[4287:4224])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(44), .CHANNEL(4), .FIXED_LAT(1)) u_lane_rcu_res_i12_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[67]), .ch_credit(credit[67]), .ch_stall(stall[67]),
    .ch_payload(payload[15700:15657])
`ifdef CCV_TRACE
    , .ch_tid(tid[4351:4288])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(44), .CHANNEL(4), .FIXED_LAT(1)) u_lane_rcu_res_i13_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[68]), .ch_credit(credit[68]), .ch_stall(stall[68]),
    .ch_payload(payload[15744:15701])
`ifdef CCV_TRACE
    , .ch_tid(tid[4415:4352])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(44), .CHANNEL(4), .FIXED_LAT(1)) u_lane_rcu_res_i14_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[69]), .ch_credit(credit[69]), .ch_stall(stall[69]),
    .ch_payload(payload[15788:15745])
`ifdef CCV_TRACE
    , .ch_tid(tid[4479:4416])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(44), .CHANNEL(4), .FIXED_LAT(1)) u_lane_rcu_res_i15_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[70]), .ch_credit(credit[70]), .ch_stall(stall[70]),
    .ch_payload(payload[15832:15789])
`ifdef CCV_TRACE
    , .ch_tid(tid[4543:4480])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(44), .CHANNEL(4), .FIXED_LAT(1)) u_lane_rcu_res_i16_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[71]), .ch_credit(credit[71]), .ch_stall(stall[71]),
    .ch_payload(payload[15876:15833])
`ifdef CCV_TRACE
    , .ch_tid(tid[4607:4544])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(44), .CHANNEL(4), .FIXED_LAT(1)) u_lane_rcu_res_i17_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[72]), .ch_credit(credit[72]), .ch_stall(stall[72]),
    .ch_payload(payload[15920:15877])
`ifdef CCV_TRACE
    , .ch_tid(tid[4671:4608])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(44), .CHANNEL(4), .FIXED_LAT(1)) u_lane_rcu_res_i18_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[73]), .ch_credit(credit[73]), .ch_stall(stall[73]),
    .ch_payload(payload[15964:15921])
`ifdef CCV_TRACE
    , .ch_tid(tid[4735:4672])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(44), .CHANNEL(4), .FIXED_LAT(1)) u_lane_rcu_res_i19_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[74]), .ch_credit(credit[74]), .ch_stall(stall[74]),
    .ch_payload(payload[16008:15965])
`ifdef CCV_TRACE
    , .ch_tid(tid[4799:4736])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(44), .CHANNEL(4), .FIXED_LAT(1)) u_lane_rcu_res_i20_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[75]), .ch_credit(credit[75]), .ch_stall(stall[75]),
    .ch_payload(payload[16052:16009])
`ifdef CCV_TRACE
    , .ch_tid(tid[4863:4800])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(44), .CHANNEL(4), .FIXED_LAT(1)) u_lane_rcu_res_i21_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[76]), .ch_credit(credit[76]), .ch_stall(stall[76]),
    .ch_payload(payload[16096:16053])
`ifdef CCV_TRACE
    , .ch_tid(tid[4927:4864])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(44), .CHANNEL(4), .FIXED_LAT(1)) u_lane_rcu_res_i22_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[77]), .ch_credit(credit[77]), .ch_stall(stall[77]),
    .ch_payload(payload[16140:16097])
`ifdef CCV_TRACE
    , .ch_tid(tid[4991:4928])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(44), .CHANNEL(4), .FIXED_LAT(1)) u_lane_rcu_res_i23_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[78]), .ch_credit(credit[78]), .ch_stall(stall[78]),
    .ch_payload(payload[16184:16141])
`ifdef CCV_TRACE
    , .ch_tid(tid[5055:4992])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(44), .CHANNEL(4), .FIXED_LAT(1)) u_lane_rcu_res_i24_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[79]), .ch_credit(credit[79]), .ch_stall(stall[79]),
    .ch_payload(payload[16228:16185])
`ifdef CCV_TRACE
    , .ch_tid(tid[5119:5056])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(44), .CHANNEL(4), .FIXED_LAT(1)) u_lane_rcu_res_i25_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[80]), .ch_credit(credit[80]), .ch_stall(stall[80]),
    .ch_payload(payload[16272:16229])
`ifdef CCV_TRACE
    , .ch_tid(tid[5183:5120])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(44), .CHANNEL(4), .FIXED_LAT(1)) u_lane_rcu_res_i26_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[81]), .ch_credit(credit[81]), .ch_stall(stall[81]),
    .ch_payload(payload[16316:16273])
`ifdef CCV_TRACE
    , .ch_tid(tid[5247:5184])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(44), .CHANNEL(4), .FIXED_LAT(1)) u_lane_rcu_res_i27_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[82]), .ch_credit(credit[82]), .ch_stall(stall[82]),
    .ch_payload(payload[16360:16317])
`ifdef CCV_TRACE
    , .ch_tid(tid[5311:5248])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(44), .CHANNEL(4), .FIXED_LAT(1)) u_lane_rcu_res_i28_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[83]), .ch_credit(credit[83]), .ch_stall(stall[83]),
    .ch_payload(payload[16404:16361])
`ifdef CCV_TRACE
    , .ch_tid(tid[5375:5312])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(44), .CHANNEL(4), .FIXED_LAT(1)) u_lane_rcu_res_i29_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[84]), .ch_credit(credit[84]), .ch_stall(stall[84]),
    .ch_payload(payload[16448:16405])
`ifdef CCV_TRACE
    , .ch_tid(tid[5439:5376])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(44), .CHANNEL(4), .FIXED_LAT(1)) u_lane_rcu_res_i30_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[85]), .ch_credit(credit[85]), .ch_stall(stall[85]),
    .ch_payload(payload[16492:16449])
`ifdef CCV_TRACE
    , .ch_tid(tid[5503:5440])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(44), .CHANNEL(4), .FIXED_LAT(1)) u_lane_rcu_res_i31_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[86]), .ch_credit(credit[86]), .ch_stall(stall[86]),
    .ch_payload(payload[16536:16493])
`ifdef CCV_TRACE
    , .ch_tid(tid[5567:5504])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(73), .CHANNEL(5), .FIXED_LAT(1)) u_rcu_ooe_done_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[87]), .ch_credit(credit[87]), .ch_stall(stall[87]),
    .ch_payload(payload[16609:16537])
`ifdef CCV_TRACE
    , .ch_tid(tid[5631:5568])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(73), .CHANNEL(5), .FIXED_LAT(1)) u_rcu_ooe_done_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[88]), .ch_credit(credit[88]), .ch_stall(stall[88]),
    .ch_payload(payload[16682:16610])
`ifdef CCV_TRACE
    , .ch_tid(tid[5695:5632])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(73), .CHANNEL(5), .FIXED_LAT(1)) u_rcu_ooe_done_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[89]), .ch_credit(credit[89]), .ch_stall(stall[89]),
    .ch_payload(payload[16755:16683])
`ifdef CCV_TRACE
    , .ch_tid(tid[5759:5696])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(73), .CHANNEL(5), .FIXED_LAT(1)) u_rcu_ooe_done_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[90]), .ch_credit(credit[90]), .ch_stall(stall[90]),
    .ch_payload(payload[16828:16756])
`ifdef CCV_TRACE
    , .ch_tid(tid[5823:5760])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(73), .CHANNEL(5), .FIXED_LAT(1)) u_rcu_ooe_done_s4 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[91]), .ch_credit(credit[91]), .ch_stall(stall[91]),
    .ch_payload(payload[16901:16829])
`ifdef CCV_TRACE
    , .ch_tid(tid[5887:5824])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(73), .CHANNEL(5), .FIXED_LAT(1)) u_rcu_ooe_done_s5 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[92]), .ch_credit(credit[92]), .ch_stall(stall[92]),
    .ch_payload(payload[16974:16902])
`ifdef CCV_TRACE
    , .ch_tid(tid[5951:5888])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(73), .CHANNEL(5), .FIXED_LAT(1)) u_rcu_ooe_done_s6 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[93]), .ch_credit(credit[93]), .ch_stall(stall[93]),
    .ch_payload(payload[17047:16975])
`ifdef CCV_TRACE
    , .ch_tid(tid[6015:5952])
`endif
  );
  ccv_common_chk_atomic #(.N(7)) u_rcu_ooe_done_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[93:87]), .credit(credit[93:87]));
  ccv_common_chk_credit #(.PAYLOAD_W(2151), .CHANNEL(6)) u_rcu_miu_addr_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[94]), .ch_credit(credit[94]), .ch_stall(stall[94]),
    .ch_payload(payload[19198:17048])
`ifdef CCV_TRACE
    , .ch_tid(tid[6079:6016])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(2151), .CHANNEL(6)) u_rcu_miu_addr_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[95]), .ch_credit(credit[95]), .ch_stall(stall[95]),
    .ch_payload(payload[21349:19199])
`ifdef CCV_TRACE
    , .ch_tid(tid[6143:6080])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(2151), .CHANNEL(6)) u_rcu_miu_addr_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[96]), .ch_credit(credit[96]), .ch_stall(stall[96]),
    .ch_payload(payload[23500:21350])
`ifdef CCV_TRACE
    , .ch_tid(tid[6207:6144])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(2151), .CHANNEL(6)) u_rcu_miu_addr_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[97]), .ch_credit(credit[97]), .ch_stall(stall[97]),
    .ch_payload(payload[25651:23501])
`ifdef CCV_TRACE
    , .ch_tid(tid[6271:6208])
`endif
  );
  ccv_common_chk_atomic #(.N(4)) u_rcu_miu_addr_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[97:94]), .credit(credit[97:94]));
  ccv_common_chk_credit #(.PAYLOAD_W(1114), .CHANNEL(7), .FIXED_LAT(1)) u_miu_rcu_data_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[98]), .ch_credit(credit[98]), .ch_stall(stall[98]),
    .ch_payload(payload[26765:25652])
`ifdef CCV_TRACE
    , .ch_tid(tid[6335:6272])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(1114), .CHANNEL(7), .FIXED_LAT(1)) u_miu_rcu_data_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[99]), .ch_credit(credit[99]), .ch_stall(stall[99]),
    .ch_payload(payload[27879:26766])
`ifdef CCV_TRACE
    , .ch_tid(tid[6399:6336])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(1114), .CHANNEL(7), .FIXED_LAT(1)) u_miu_rcu_data_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[100]), .ch_credit(credit[100]), .ch_stall(stall[100]),
    .ch_payload(payload[28993:27880])
`ifdef CCV_TRACE
    , .ch_tid(tid[6463:6400])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(1114), .CHANNEL(7), .FIXED_LAT(1)) u_miu_rcu_data_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[101]), .ch_credit(credit[101]), .ch_stall(stall[101]),
    .ch_payload(payload[30107:28994])
`ifdef CCV_TRACE
    , .ch_tid(tid[6527:6464])
`endif
  );
  ccv_common_chk_atomic #(.N(4)) u_miu_rcu_data_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[101:98]), .credit(credit[101:98]));
  ccv_common_chk_credit #(.PAYLOAD_W(97), .CHANNEL(8)) u_ooe_miu_memop_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[102]), .ch_credit(credit[102]), .ch_stall(stall[102]),
    .ch_payload(payload[30204:30108])
`ifdef CCV_TRACE
    , .ch_tid(tid[6591:6528])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(97), .CHANNEL(8)) u_ooe_miu_memop_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[103]), .ch_credit(credit[103]), .ch_stall(stall[103]),
    .ch_payload(payload[30301:30205])
`ifdef CCV_TRACE
    , .ch_tid(tid[6655:6592])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(97), .CHANNEL(8)) u_ooe_miu_memop_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[104]), .ch_credit(credit[104]), .ch_stall(stall[104]),
    .ch_payload(payload[30398:30302])
`ifdef CCV_TRACE
    , .ch_tid(tid[6719:6656])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(97), .CHANNEL(8)) u_ooe_miu_memop_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[105]), .ch_credit(credit[105]), .ch_stall(stall[105]),
    .ch_payload(payload[30495:30399])
`ifdef CCV_TRACE
    , .ch_tid(tid[6783:6720])
`endif
  );
  ccv_common_chk_atomic #(.N(4)) u_ooe_miu_memop_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[105:102]), .credit(credit[105:102]));
  ccv_common_chk_credit #(.PAYLOAD_W(110), .CHANNEL(9), .FIXED_LAT(1)) u_miu_ooe_cmpl_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[106]), .ch_credit(credit[106]), .ch_stall(stall[106]),
    .ch_payload(payload[30605:30496])
`ifdef CCV_TRACE
    , .ch_tid(tid[6847:6784])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(110), .CHANNEL(9), .FIXED_LAT(1)) u_miu_ooe_cmpl_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[107]), .ch_credit(credit[107]), .ch_stall(stall[107]),
    .ch_payload(payload[30715:30606])
`ifdef CCV_TRACE
    , .ch_tid(tid[6911:6848])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(110), .CHANNEL(9), .FIXED_LAT(1)) u_miu_ooe_cmpl_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[108]), .ch_credit(credit[108]), .ch_stall(stall[108]),
    .ch_payload(payload[30825:30716])
`ifdef CCV_TRACE
    , .ch_tid(tid[6975:6912])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(110), .CHANNEL(9), .FIXED_LAT(1)) u_miu_ooe_cmpl_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[109]), .ch_credit(credit[109]), .ch_stall(stall[109]),
    .ch_payload(payload[30935:30826])
`ifdef CCV_TRACE
    , .ch_tid(tid[7039:6976])
`endif
  );
  ccv_common_chk_atomic #(.N(4)) u_miu_ooe_cmpl_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[109:106]), .credit(credit[109:106]));
  ccv_common_chk_credit #(.PAYLOAD_W(8), .CHANNEL(10)) u_ooe_miu_retire_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[110]), .ch_credit(credit[110]), .ch_stall(stall[110]),
    .ch_payload(payload[30943:30936])
`ifdef CCV_TRACE
    , .ch_tid(tid[7103:7040])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(8), .CHANNEL(10)) u_ooe_miu_retire_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[111]), .ch_credit(credit[111]), .ch_stall(stall[111]),
    .ch_payload(payload[30951:30944])
`ifdef CCV_TRACE
    , .ch_tid(tid[7167:7104])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(8), .CHANNEL(10)) u_ooe_miu_retire_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[112]), .ch_credit(credit[112]), .ch_stall(stall[112]),
    .ch_payload(payload[30959:30952])
`ifdef CCV_TRACE
    , .ch_tid(tid[7231:7168])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(8), .CHANNEL(10)) u_ooe_miu_retire_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[113]), .ch_credit(credit[113]), .ch_stall(stall[113]),
    .ch_payload(payload[30967:30960])
`ifdef CCV_TRACE
    , .ch_tid(tid[7295:7232])
`endif
  );
  ccv_common_chk_atomic #(.N(4)) u_ooe_miu_retire_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[113:110]), .credit(credit[113:110]));
  ccv_common_chk_credit #(.PAYLOAD_W(109), .CHANNEL(11), .FIXED_LAT(1)) u_ooe_fet_redirect_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[114]), .ch_credit(credit[114]), .ch_stall(stall[114]),
    .ch_payload(payload[31076:30968])
`ifdef CCV_TRACE
    , .ch_tid(tid[7359:7296])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(16), .CHANNEL(12), .FIXED_LAT(1)) u_ooe_fet_ckpt_free_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[115]), .ch_credit(credit[115]), .ch_stall(stall[115]),
    .ch_payload(payload[31092:31077])
`ifdef CCV_TRACE
    , .ch_tid(tid[7423:7360])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(1477), .CHANNEL(13)) u_miu_spm_req_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[116]), .ch_credit(credit[116]), .ch_stall(stall[116]),
    .ch_payload(payload[32569:31093])
`ifdef CCV_TRACE
    , .ch_tid(tid[7487:7424])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(1477), .CHANNEL(13)) u_miu_spm_req_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[117]), .ch_credit(credit[117]), .ch_stall(stall[117]),
    .ch_payload(payload[34046:32570])
`ifdef CCV_TRACE
    , .ch_tid(tid[7551:7488])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(1477), .CHANNEL(13)) u_miu_spm_req_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[118]), .ch_credit(credit[118]), .ch_stall(stall[118]),
    .ch_payload(payload[35523:34047])
`ifdef CCV_TRACE
    , .ch_tid(tid[7615:7552])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(1477), .CHANNEL(13)) u_miu_spm_req_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[119]), .ch_credit(credit[119]), .ch_stall(stall[119]),
    .ch_payload(payload[37000:35524])
`ifdef CCV_TRACE
    , .ch_tid(tid[7679:7616])
`endif
  );
  ccv_common_chk_atomic #(.N(4)) u_miu_spm_req_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[119:116]), .credit(credit[119:116]));
  ccv_common_chk_credit #(.PAYLOAD_W(1033), .CHANNEL(14)) u_spm_miu_rsp_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[120]), .ch_credit(credit[120]), .ch_stall(stall[120]),
    .ch_payload(payload[38033:37001])
`ifdef CCV_TRACE
    , .ch_tid(tid[7743:7680])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(1033), .CHANNEL(14)) u_spm_miu_rsp_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[121]), .ch_credit(credit[121]), .ch_stall(stall[121]),
    .ch_payload(payload[39066:38034])
`ifdef CCV_TRACE
    , .ch_tid(tid[7807:7744])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(1033), .CHANNEL(14)) u_spm_miu_rsp_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[122]), .ch_credit(credit[122]), .ch_stall(stall[122]),
    .ch_payload(payload[40099:39067])
`ifdef CCV_TRACE
    , .ch_tid(tid[7871:7808])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(1033), .CHANNEL(14)) u_spm_miu_rsp_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[123]), .ch_credit(credit[123]), .ch_stall(stall[123]),
    .ch_payload(payload[41132:40100])
`ifdef CCV_TRACE
    , .ch_tid(tid[7935:7872])
`endif
  );
  ccv_common_chk_atomic #(.N(4)) u_spm_miu_rsp_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[123:120]), .credit(credit[123:120]));
  ccv_common_chk_credit #(.PAYLOAD_W(1212), .CHANNEL(15)) u_miu_dcu_req_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[124]), .ch_credit(credit[124]), .ch_stall(stall[124]),
    .ch_payload(payload[42344:41133])
`ifdef CCV_TRACE
    , .ch_tid(tid[7999:7936])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(1212), .CHANNEL(15)) u_miu_dcu_req_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[125]), .ch_credit(credit[125]), .ch_stall(stall[125]),
    .ch_payload(payload[43556:42345])
`ifdef CCV_TRACE
    , .ch_tid(tid[8063:8000])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(1212), .CHANNEL(15)) u_miu_dcu_req_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[126]), .ch_credit(credit[126]), .ch_stall(stall[126]),
    .ch_payload(payload[44768:43557])
`ifdef CCV_TRACE
    , .ch_tid(tid[8127:8064])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(1212), .CHANNEL(15)) u_miu_dcu_req_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[127]), .ch_credit(credit[127]), .ch_stall(stall[127]),
    .ch_payload(payload[45980:44769])
`ifdef CCV_TRACE
    , .ch_tid(tid[8191:8128])
`endif
  );
  ccv_common_chk_atomic #(.N(4)) u_miu_dcu_req_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[127:124]), .credit(credit[127:124]));
  ccv_common_chk_credit #(.PAYLOAD_W(1031), .CHANNEL(16)) u_dcu_miu_rsp_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[128]), .ch_credit(credit[128]), .ch_stall(stall[128]),
    .ch_payload(payload[47011:45981])
`ifdef CCV_TRACE
    , .ch_tid(tid[8255:8192])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(1031), .CHANNEL(16)) u_dcu_miu_rsp_s1 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[129]), .ch_credit(credit[129]), .ch_stall(stall[129]),
    .ch_payload(payload[48042:47012])
`ifdef CCV_TRACE
    , .ch_tid(tid[8319:8256])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(1031), .CHANNEL(16)) u_dcu_miu_rsp_s2 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[130]), .ch_credit(credit[130]), .ch_stall(stall[130]),
    .ch_payload(payload[49073:48043])
`ifdef CCV_TRACE
    , .ch_tid(tid[8383:8320])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(1031), .CHANNEL(16)) u_dcu_miu_rsp_s3 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[131]), .ch_credit(credit[131]), .ch_stall(stall[131]),
    .ch_payload(payload[50104:49074])
`ifdef CCV_TRACE
    , .ch_tid(tid[8447:8384])
`endif
  );
  ccv_common_chk_atomic #(.N(4)) u_dcu_miu_rsp_atomic (
    .clk(clk), .rst_n(rst_n), .enable(1'b0 | force_atomic),
    .valid(valid[131:128]), .credit(credit[131:128]));
  ccv_common_chk_credit #(.PAYLOAD_W(1082), .CHANNEL(17)) u_dcu_mlc_req_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[132]), .ch_credit(credit[132]), .ch_stall(stall[132]),
    .ch_payload(payload[51186:50105])
`ifdef CCV_TRACE
    , .ch_tid(tid[8511:8448])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(1030), .CHANNEL(18)) u_mlc_dcu_rsp_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[133]), .ch_credit(credit[133]), .ch_stall(stall[133]),
    .ch_payload(payload[52216:51187])
`ifdef CCV_TRACE
    , .ch_tid(tid[8575:8512])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(51), .CHANNEL(19)) u_mlc_dcu_probe_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[134]), .ch_credit(credit[134]), .ch_stall(stall[134]),
    .ch_payload(payload[52267:52217])
`ifdef CCV_TRACE
    , .ch_tid(tid[8639:8576])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(1027), .CHANNEL(20)) u_dcu_mlc_probe_ack_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[135]), .ch_credit(credit[135]), .ch_stall(stall[135]),
    .ch_payload(payload[53294:52268])
`ifdef CCV_TRACE
    , .ch_tid(tid[8703:8640])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(50), .CHANNEL(21)) u_fet_mlc_ifill_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[136]), .ch_credit(credit[136]), .ch_stall(stall[136]),
    .ch_payload(payload[53344:53295])
`ifdef CCV_TRACE
    , .ch_tid(tid[8767:8704])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(1026), .CHANNEL(22)) u_mlc_fet_ifill_rsp_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[137]), .ch_credit(credit[137]), .ch_stall(stall[137]),
    .ch_payload(payload[54370:53345])
`ifdef CCV_TRACE
    , .ch_tid(tid[8831:8768])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(64), .CHANNEL(23)) u_miu_fet_itlb_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[138]), .ch_credit(credit[138]), .ch_stall(stall[138]),
    .ch_payload(payload[54434:54371])
`ifdef CCV_TRACE
    , .ch_tid(tid[8895:8832])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(60), .CHANNEL(24)) u_fet_miu_itlb_req_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[139]), .ch_credit(credit[139]), .ch_stall(stall[139]),
    .ch_payload(payload[54494:54435])
`ifdef CCV_TRACE
    , .ch_tid(tid[8959:8896])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(1090), .CHANNEL(25)) u_mlc_exb_req_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[140]), .ch_credit(credit[140]), .ch_stall(stall[140]),
    .ch_payload(payload[55584:54495])
`ifdef CCV_TRACE
    , .ch_tid(tid[9023:8960])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(1082), .CHANNEL(26)) u_exb_mlc_rsp_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[141]), .ch_credit(credit[141]), .ch_stall(stall[141]),
    .ch_payload(payload[56666:55585])
`ifdef CCV_TRACE
    , .ch_tid(tid[9087:9024])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(1225), .CHANNEL(27)) u_exb_ext_out_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[142]), .ch_credit(credit[142]), .ch_stall(stall[142]),
    .ch_payload(payload[57891:56667])
`ifdef CCV_TRACE
    , .ch_tid(tid[9151:9088])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(186), .CHANNEL(28)) u_rau_fet_launch_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[143]), .ch_credit(credit[143]), .ch_stall(stall[143]),
    .ch_payload(payload[58077:57892])
`ifdef CCV_TRACE
    , .ch_tid(tid[9215:9152])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(46), .CHANNEL(29)) u_rau_ooe_alloc_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[144]), .ch_credit(credit[144]), .ch_stall(stall[144]),
    .ch_payload(payload[58123:58078])
`ifdef CCV_TRACE
    , .ch_tid(tid[9279:9216])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(16), .CHANNEL(30)) u_ooe_rau_status_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[145]), .ch_credit(credit[145]), .ch_stall(stall[145]),
    .ch_payload(payload[58139:58124])
`ifdef CCV_TRACE
    , .ch_tid(tid[9343:9280])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(6), .CHANNEL(31)) u_rau_ooe_demote_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[146]), .ch_credit(credit[146]), .ch_stall(stall[146]),
    .ch_payload(payload[58145:58140])
`ifdef CCV_TRACE
    , .ch_tid(tid[9407:9344])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(70), .CHANNEL(32)) u_ooe_rau_drained_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[147]), .ch_credit(credit[147]), .ch_stall(stall[147]),
    .ch_payload(payload[58215:58146])
`ifdef CCV_TRACE
    , .ch_tid(tid[9471:9408])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(9), .CHANNEL(33)) u_rau_rcu_mig_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[148]), .ch_credit(credit[148]), .ch_stall(stall[148]),
    .ch_payload(payload[58224:58216])
`ifdef CCV_TRACE
    , .ch_tid(tid[9535:9472])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(222), .CHANNEL(34)) u_ooe_rcu_map_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[149]), .ch_credit(credit[149]), .ch_stall(stall[149]),
    .ch_payload(payload[58446:58225])
`ifdef CCV_TRACE
    , .ch_tid(tid[9599:9536])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(1034), .CHANNEL(35)) u_rcu_pca_mig_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[150]), .ch_credit(credit[150]), .ch_stall(stall[150]),
    .ch_payload(payload[59480:58447])
`ifdef CCV_TRACE
    , .ch_tid(tid[9663:9600])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(1034), .CHANNEL(36)) u_pca_rcu_mig_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[151]), .ch_credit(credit[151]), .ch_stall(stall[151]),
    .ch_payload(payload[60514:59481])
`ifdef CCV_TRACE
    , .ch_tid(tid[9727:9664])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(389), .CHANNEL(37)) u_fet_pca_mig_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[152]), .ch_credit(credit[152]), .ch_stall(stall[152]),
    .ch_payload(payload[60903:60515])
`ifdef CCV_TRACE
    , .ch_tid(tid[9791:9728])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(389), .CHANNEL(38)) u_pca_fet_mig_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[153]), .ch_credit(credit[153]), .ch_stall(stall[153]),
    .ch_payload(payload[61292:60904])
`ifdef CCV_TRACE
    , .ch_tid(tid[9855:9792])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(11), .CHANNEL(39)) u_rau_fet_mig_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[154]), .ch_credit(credit[154]), .ch_stall(stall[154]),
    .ch_payload(payload[61303:61293])
`ifdef CCV_TRACE
    , .ch_tid(tid[9919:9856])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(6), .CHANNEL(40)) u_pca_rau_mig_done_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[155]), .ch_credit(credit[155]), .ch_stall(stall[155]),
    .ch_payload(payload[61309:61304])
`ifdef CCV_TRACE
    , .ch_tid(tid[9983:9920])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(101), .CHANNEL(41)) u_rau_miu_cta_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[156]), .ch_credit(credit[156]), .ch_stall(stall[156]),
    .ch_payload(payload[61410:61310])
`ifdef CCV_TRACE
    , .ch_tid(tid[10047:9984])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(13), .CHANNEL(42)) u_ooe_syu_bar_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[157]), .ch_credit(credit[157]), .ch_stall(stall[157]),
    .ch_payload(payload[61423:61411])
`ifdef CCV_TRACE
    , .ch_tid(tid[10111:10048])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(36), .CHANNEL(43)) u_syu_ooe_rel_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[158]), .ch_credit(credit[158]), .ch_stall(stall[158]),
    .ch_payload(payload[61459:61424])
`ifdef CCV_TRACE
    , .ch_tid(tid[10175:10112])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(17), .CHANNEL(44)) u_rau_syu_alloc_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[159]), .ch_credit(credit[159]), .ch_stall(stall[159]),
    .ch_payload(payload[61476:61460])
`ifdef CCV_TRACE
    , .ch_tid(tid[10239:10176])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(172), .CHANNEL(45)) u_ooe_cru_fault_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[160]), .ch_credit(credit[160]), .ch_stall(stall[160]),
    .ch_payload(payload[61648:61477])
`ifdef CCV_TRACE
    , .ch_tid(tid[10303:10240])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(74), .CHANNEL(46)) u_cru_rau_cfg_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[161]), .ch_credit(credit[161]), .ch_stall(stall[161]),
    .ch_payload(payload[61722:61649])
`ifdef CCV_TRACE
    , .ch_tid(tid[10367:10304])
`endif
  );
  ccv_common_chk_credit #(.PAYLOAD_W(1176), .CHANNEL(47)) u_ext_exb_in_s0 (
    .clk(clk), .rst_n(rst_n), .ch_valid(valid[162]), .ch_credit(credit[162]), .ch_stall(stall[162]),
    .ch_payload(payload[62898:61723])
`ifdef CCV_TRACE
    , .ch_tid(tid[10431:10368])
`endif
  );
  ccv_common_chk_binding #(.N(8), .GROUP(2), .W(2)) u_fet_dec_instr_binding (
    .clk(clk), .rst_n(rst_n), .valid(valid[7:0]),
    .key({payload[1274:1273], payload[1114:1113], payload[954:953], payload[794:793], payload[634:633], payload[474:473], payload[314:313], payload[154:153]}));
  // The wake contract (Q-33): valid toward a gated receiver needs this
  // channel instance's wake at least CCV_WAKE_LAT cycles earlier.
  ccv_common_chk_wake u_fet_dec_instr_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[0]), .wake_seen(wake[0]), .valid_seen(|valid[7:0]));
  ccv_common_chk_wake u_dec_ooe_uop_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[1]), .wake_seen(wake[1]), .valid_seen(|valid[13:8]));
  ccv_common_chk_wake u_ooe_rcu_issue_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[2]), .wake_seen(wake[2]), .valid_seen(|valid[22:14]));
  ccv_common_chk_wake u_rcu_lane_ops_i0_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[3]), .wake_seen(wake[3]), .valid_seen(|valid[23:23]));
  ccv_common_chk_wake u_rcu_lane_ops_i1_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[4]), .wake_seen(wake[4]), .valid_seen(|valid[24:24]));
  ccv_common_chk_wake u_rcu_lane_ops_i2_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[5]), .wake_seen(wake[5]), .valid_seen(|valid[25:25]));
  ccv_common_chk_wake u_rcu_lane_ops_i3_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[6]), .wake_seen(wake[6]), .valid_seen(|valid[26:26]));
  ccv_common_chk_wake u_rcu_lane_ops_i4_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[7]), .wake_seen(wake[7]), .valid_seen(|valid[27:27]));
  ccv_common_chk_wake u_rcu_lane_ops_i5_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[8]), .wake_seen(wake[8]), .valid_seen(|valid[28:28]));
  ccv_common_chk_wake u_rcu_lane_ops_i6_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[9]), .wake_seen(wake[9]), .valid_seen(|valid[29:29]));
  ccv_common_chk_wake u_rcu_lane_ops_i7_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[10]), .wake_seen(wake[10]), .valid_seen(|valid[30:30]));
  ccv_common_chk_wake u_rcu_lane_ops_i8_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[11]), .wake_seen(wake[11]), .valid_seen(|valid[31:31]));
  ccv_common_chk_wake u_rcu_lane_ops_i9_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[12]), .wake_seen(wake[12]), .valid_seen(|valid[32:32]));
  ccv_common_chk_wake u_rcu_lane_ops_i10_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[13]), .wake_seen(wake[13]), .valid_seen(|valid[33:33]));
  ccv_common_chk_wake u_rcu_lane_ops_i11_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[14]), .wake_seen(wake[14]), .valid_seen(|valid[34:34]));
  ccv_common_chk_wake u_rcu_lane_ops_i12_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[15]), .wake_seen(wake[15]), .valid_seen(|valid[35:35]));
  ccv_common_chk_wake u_rcu_lane_ops_i13_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[16]), .wake_seen(wake[16]), .valid_seen(|valid[36:36]));
  ccv_common_chk_wake u_rcu_lane_ops_i14_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[17]), .wake_seen(wake[17]), .valid_seen(|valid[37:37]));
  ccv_common_chk_wake u_rcu_lane_ops_i15_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[18]), .wake_seen(wake[18]), .valid_seen(|valid[38:38]));
  ccv_common_chk_wake u_rcu_lane_ops_i16_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[19]), .wake_seen(wake[19]), .valid_seen(|valid[39:39]));
  ccv_common_chk_wake u_rcu_lane_ops_i17_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[20]), .wake_seen(wake[20]), .valid_seen(|valid[40:40]));
  ccv_common_chk_wake u_rcu_lane_ops_i18_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[21]), .wake_seen(wake[21]), .valid_seen(|valid[41:41]));
  ccv_common_chk_wake u_rcu_lane_ops_i19_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[22]), .wake_seen(wake[22]), .valid_seen(|valid[42:42]));
  ccv_common_chk_wake u_rcu_lane_ops_i20_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[23]), .wake_seen(wake[23]), .valid_seen(|valid[43:43]));
  ccv_common_chk_wake u_rcu_lane_ops_i21_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[24]), .wake_seen(wake[24]), .valid_seen(|valid[44:44]));
  ccv_common_chk_wake u_rcu_lane_ops_i22_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[25]), .wake_seen(wake[25]), .valid_seen(|valid[45:45]));
  ccv_common_chk_wake u_rcu_lane_ops_i23_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[26]), .wake_seen(wake[26]), .valid_seen(|valid[46:46]));
  ccv_common_chk_wake u_rcu_lane_ops_i24_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[27]), .wake_seen(wake[27]), .valid_seen(|valid[47:47]));
  ccv_common_chk_wake u_rcu_lane_ops_i25_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[28]), .wake_seen(wake[28]), .valid_seen(|valid[48:48]));
  ccv_common_chk_wake u_rcu_lane_ops_i26_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[29]), .wake_seen(wake[29]), .valid_seen(|valid[49:49]));
  ccv_common_chk_wake u_rcu_lane_ops_i27_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[30]), .wake_seen(wake[30]), .valid_seen(|valid[50:50]));
  ccv_common_chk_wake u_rcu_lane_ops_i28_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[31]), .wake_seen(wake[31]), .valid_seen(|valid[51:51]));
  ccv_common_chk_wake u_rcu_lane_ops_i29_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[32]), .wake_seen(wake[32]), .valid_seen(|valid[52:52]));
  ccv_common_chk_wake u_rcu_lane_ops_i30_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[33]), .wake_seen(wake[33]), .valid_seen(|valid[53:53]));
  ccv_common_chk_wake u_rcu_lane_ops_i31_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[34]), .wake_seen(wake[34]), .valid_seen(|valid[54:54]));
  ccv_common_chk_wake u_lane_rcu_res_i0_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[35]), .wake_seen(wake[35]), .valid_seen(|valid[55:55]));
  ccv_common_chk_wake u_lane_rcu_res_i1_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[36]), .wake_seen(wake[36]), .valid_seen(|valid[56:56]));
  ccv_common_chk_wake u_lane_rcu_res_i2_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[37]), .wake_seen(wake[37]), .valid_seen(|valid[57:57]));
  ccv_common_chk_wake u_lane_rcu_res_i3_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[38]), .wake_seen(wake[38]), .valid_seen(|valid[58:58]));
  ccv_common_chk_wake u_lane_rcu_res_i4_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[39]), .wake_seen(wake[39]), .valid_seen(|valid[59:59]));
  ccv_common_chk_wake u_lane_rcu_res_i5_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[40]), .wake_seen(wake[40]), .valid_seen(|valid[60:60]));
  ccv_common_chk_wake u_lane_rcu_res_i6_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[41]), .wake_seen(wake[41]), .valid_seen(|valid[61:61]));
  ccv_common_chk_wake u_lane_rcu_res_i7_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[42]), .wake_seen(wake[42]), .valid_seen(|valid[62:62]));
  ccv_common_chk_wake u_lane_rcu_res_i8_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[43]), .wake_seen(wake[43]), .valid_seen(|valid[63:63]));
  ccv_common_chk_wake u_lane_rcu_res_i9_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[44]), .wake_seen(wake[44]), .valid_seen(|valid[64:64]));
  ccv_common_chk_wake u_lane_rcu_res_i10_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[45]), .wake_seen(wake[45]), .valid_seen(|valid[65:65]));
  ccv_common_chk_wake u_lane_rcu_res_i11_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[46]), .wake_seen(wake[46]), .valid_seen(|valid[66:66]));
  ccv_common_chk_wake u_lane_rcu_res_i12_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[47]), .wake_seen(wake[47]), .valid_seen(|valid[67:67]));
  ccv_common_chk_wake u_lane_rcu_res_i13_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[48]), .wake_seen(wake[48]), .valid_seen(|valid[68:68]));
  ccv_common_chk_wake u_lane_rcu_res_i14_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[49]), .wake_seen(wake[49]), .valid_seen(|valid[69:69]));
  ccv_common_chk_wake u_lane_rcu_res_i15_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[50]), .wake_seen(wake[50]), .valid_seen(|valid[70:70]));
  ccv_common_chk_wake u_lane_rcu_res_i16_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[51]), .wake_seen(wake[51]), .valid_seen(|valid[71:71]));
  ccv_common_chk_wake u_lane_rcu_res_i17_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[52]), .wake_seen(wake[52]), .valid_seen(|valid[72:72]));
  ccv_common_chk_wake u_lane_rcu_res_i18_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[53]), .wake_seen(wake[53]), .valid_seen(|valid[73:73]));
  ccv_common_chk_wake u_lane_rcu_res_i19_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[54]), .wake_seen(wake[54]), .valid_seen(|valid[74:74]));
  ccv_common_chk_wake u_lane_rcu_res_i20_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[55]), .wake_seen(wake[55]), .valid_seen(|valid[75:75]));
  ccv_common_chk_wake u_lane_rcu_res_i21_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[56]), .wake_seen(wake[56]), .valid_seen(|valid[76:76]));
  ccv_common_chk_wake u_lane_rcu_res_i22_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[57]), .wake_seen(wake[57]), .valid_seen(|valid[77:77]));
  ccv_common_chk_wake u_lane_rcu_res_i23_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[58]), .wake_seen(wake[58]), .valid_seen(|valid[78:78]));
  ccv_common_chk_wake u_lane_rcu_res_i24_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[59]), .wake_seen(wake[59]), .valid_seen(|valid[79:79]));
  ccv_common_chk_wake u_lane_rcu_res_i25_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[60]), .wake_seen(wake[60]), .valid_seen(|valid[80:80]));
  ccv_common_chk_wake u_lane_rcu_res_i26_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[61]), .wake_seen(wake[61]), .valid_seen(|valid[81:81]));
  ccv_common_chk_wake u_lane_rcu_res_i27_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[62]), .wake_seen(wake[62]), .valid_seen(|valid[82:82]));
  ccv_common_chk_wake u_lane_rcu_res_i28_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[63]), .wake_seen(wake[63]), .valid_seen(|valid[83:83]));
  ccv_common_chk_wake u_lane_rcu_res_i29_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[64]), .wake_seen(wake[64]), .valid_seen(|valid[84:84]));
  ccv_common_chk_wake u_lane_rcu_res_i30_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[65]), .wake_seen(wake[65]), .valid_seen(|valid[85:85]));
  ccv_common_chk_wake u_lane_rcu_res_i31_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[66]), .wake_seen(wake[66]), .valid_seen(|valid[86:86]));
  ccv_common_chk_wake u_rcu_ooe_done_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[67]), .wake_seen(wake[67]), .valid_seen(|valid[93:87]));
  ccv_common_chk_wake u_rcu_miu_addr_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[68]), .wake_seen(wake[68]), .valid_seen(|valid[97:94]));
  ccv_common_chk_wake u_miu_rcu_data_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[69]), .wake_seen(wake[69]), .valid_seen(|valid[101:98]));
  ccv_common_chk_wake u_ooe_miu_memop_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[70]), .wake_seen(wake[70]), .valid_seen(|valid[105:102]));
  ccv_common_chk_wake u_miu_ooe_cmpl_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[71]), .wake_seen(wake[71]), .valid_seen(|valid[109:106]));
  ccv_common_chk_wake u_ooe_miu_retire_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[72]), .wake_seen(wake[72]), .valid_seen(|valid[113:110]));
  ccv_common_chk_wake u_ooe_fet_redirect_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[73]), .wake_seen(wake[73]), .valid_seen(|valid[114:114]));
  ccv_common_chk_wake u_ooe_fet_ckpt_free_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[74]), .wake_seen(wake[74]), .valid_seen(|valid[115:115]));
  ccv_common_chk_wake u_miu_spm_req_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[75]), .wake_seen(wake[75]), .valid_seen(|valid[119:116]));
  ccv_common_chk_wake u_spm_miu_rsp_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[76]), .wake_seen(wake[76]), .valid_seen(|valid[123:120]));
  ccv_common_chk_wake u_miu_dcu_req_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[77]), .wake_seen(wake[77]), .valid_seen(|valid[127:124]));
  ccv_common_chk_wake u_dcu_miu_rsp_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[78]), .wake_seen(wake[78]), .valid_seen(|valid[131:128]));
  ccv_common_chk_wake u_dcu_mlc_req_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[79]), .wake_seen(wake[79]), .valid_seen(|valid[132:132]));
  ccv_common_chk_wake u_mlc_dcu_rsp_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[80]), .wake_seen(wake[80]), .valid_seen(|valid[133:133]));
  ccv_common_chk_wake u_mlc_dcu_probe_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[81]), .wake_seen(wake[81]), .valid_seen(|valid[134:134]));
  ccv_common_chk_wake u_dcu_mlc_probe_ack_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[82]), .wake_seen(wake[82]), .valid_seen(|valid[135:135]));
  ccv_common_chk_wake u_fet_mlc_ifill_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[83]), .wake_seen(wake[83]), .valid_seen(|valid[136:136]));
  ccv_common_chk_wake u_mlc_fet_ifill_rsp_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[84]), .wake_seen(wake[84]), .valid_seen(|valid[137:137]));
  ccv_common_chk_wake u_miu_fet_itlb_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[85]), .wake_seen(wake[85]), .valid_seen(|valid[138:138]));
  ccv_common_chk_wake u_fet_miu_itlb_req_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[86]), .wake_seen(wake[86]), .valid_seen(|valid[139:139]));
  ccv_common_chk_wake u_mlc_exb_req_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[87]), .wake_seen(wake[87]), .valid_seen(|valid[140:140]));
  ccv_common_chk_wake u_exb_mlc_rsp_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[88]), .wake_seen(wake[88]), .valid_seen(|valid[141:141]));
  ccv_common_chk_wake u_exb_ext_out_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[89]), .wake_seen(wake[89]), .valid_seen(|valid[142:142]));
  ccv_common_chk_wake u_rau_fet_launch_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[90]), .wake_seen(wake[90]), .valid_seen(|valid[143:143]));
  ccv_common_chk_wake u_rau_ooe_alloc_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[91]), .wake_seen(wake[91]), .valid_seen(|valid[144:144]));
  ccv_common_chk_wake u_ooe_rau_status_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[92]), .wake_seen(wake[92]), .valid_seen(|valid[145:145]));
  ccv_common_chk_wake u_rau_ooe_demote_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[93]), .wake_seen(wake[93]), .valid_seen(|valid[146:146]));
  ccv_common_chk_wake u_ooe_rau_drained_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[94]), .wake_seen(wake[94]), .valid_seen(|valid[147:147]));
  ccv_common_chk_wake u_rau_rcu_mig_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[95]), .wake_seen(wake[95]), .valid_seen(|valid[148:148]));
  ccv_common_chk_wake u_ooe_rcu_map_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[96]), .wake_seen(wake[96]), .valid_seen(|valid[149:149]));
  ccv_common_chk_wake u_rcu_pca_mig_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[97]), .wake_seen(wake[97]), .valid_seen(|valid[150:150]));
  ccv_common_chk_wake u_pca_rcu_mig_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[98]), .wake_seen(wake[98]), .valid_seen(|valid[151:151]));
  ccv_common_chk_wake u_fet_pca_mig_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[99]), .wake_seen(wake[99]), .valid_seen(|valid[152:152]));
  ccv_common_chk_wake u_pca_fet_mig_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[100]), .wake_seen(wake[100]), .valid_seen(|valid[153:153]));
  ccv_common_chk_wake u_rau_fet_mig_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[101]), .wake_seen(wake[101]), .valid_seen(|valid[154:154]));
  ccv_common_chk_wake u_pca_rau_mig_done_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[102]), .wake_seen(wake[102]), .valid_seen(|valid[155:155]));
  ccv_common_chk_wake u_rau_miu_cta_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[103]), .wake_seen(wake[103]), .valid_seen(|valid[156:156]));
  ccv_common_chk_wake u_ooe_syu_bar_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[104]), .wake_seen(wake[104]), .valid_seen(|valid[157:157]));
  ccv_common_chk_wake u_syu_ooe_rel_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[105]), .wake_seen(wake[105]), .valid_seen(|valid[158:158]));
  ccv_common_chk_wake u_rau_syu_alloc_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[106]), .wake_seen(wake[106]), .valid_seen(|valid[159:159]));
  ccv_common_chk_wake u_ooe_cru_fault_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[107]), .wake_seen(wake[107]), .valid_seen(|valid[160:160]));
  ccv_common_chk_wake u_cru_rau_cfg_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[108]), .wake_seen(wake[108]), .valid_seen(|valid[161:161]));
  ccv_common_chk_wake u_ext_exb_in_wake (.clk(clk), .rst_n(rst_n), .rx_gated(rx_gated[109]), .wake_seen(wake[109]), .valid_seen(|valid[162:162]));
  ccv_common_chk_outstanding #(.MAX(1)) u_fet_miu_itlb_req_outstanding (
    .clk(clk), .rst_n(rst_n), .enable(pair_enable),
    .req_valid(valid[139]), .rsp_valid(valid[138]));  // ccv_miu_fet_itlb
  ccv_common_chk_lockstep #(.INSTS(32), .N(1)) u_rcu_lane_ops_lockstep (
    .clk(clk), .rst_n(rst_n),
    .valid(valid[54:23]), .credit(credit[54:23])
`ifdef CCV_TRACE
    , .tid(tid[3519:1472])
`endif
  );
  ccv_common_chk_lockstep #(.INSTS(32), .N(1)) u_lane_rcu_res_lockstep (
    .clk(clk), .rst_n(rst_n),
    .valid(valid[86:55]), .credit(credit[86:55])
`ifdef CCV_TRACE
    , .tid(tid[5567:3520])
`endif
  );

endmodule
