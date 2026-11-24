import sys
p=sys.argv[1]+'/rtl/ooe/ooe_ratmap.sv'
s=open(p).read()
old="""  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) kv_cq05h <= 1'b0;
    else          kv_cq05h <= kv_cq04h;
    kw_w_cq05h <= kw_w_cq04h;              // read only with kv_cq05h
  end
"""
new="""  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) kv_cq05h <= 1'b0;
    else          kv_cq05h <= kv_cq04h;
  end
  // kw_w's flopped copy, written with the write (read only with kv_cq05h).
  logic kw5_en_cq04h;
  assign kw5_en_cq04h = kv_cq04h;
  always_ff @(posedge ooe_core_clk) begin
    if (kw5_en_cq04h) kw_w_cq05h <= kw_w_cq04h;
  end
"""
assert s.count(old)==1
open(p,'w').write(s.replace(old,new))
