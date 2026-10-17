#!/usr/bin/env python3
"""ooe_wake's latencies, bypass points and penalties, from the parameters:
one line, the -G list then the -D list, comma-separated. Used by
test/ooe/run-rtl.sh and test/ooe/cg-build.sh, so the two cannot drift."""
import re
pkg = open('rtl/generated/ccv_params_pkg.sv').read()
def p(n): return int(re.search(r'localparam int %s = (\d+);' % n, pkg).group(1))
core = open('sim/ooe/ooe_core.h').read()
stages = int(re.search(r'unsigned payload_stages = (\d+);', core).group(1))
lat = [p('CCV_LAT_RCU'), p('CCV_LAT_LANE'), 0, 0, p('CCV_LAT_SFU'), p('CCV_LAT_COLLECTIVE'), 0, 0]
fast = [0, p('CCV_LAT_LANE_BYP'), 0, 0, 0, 0, 0, 0]
pens = sorted({p('CCV_LAT_BYP_PEN_SAME'), p('CCV_LAT_BYP_PEN_INT_FP'), p('CCV_LAT_BYP_PEN_SFU')})
pens3 = (pens + [0, 0, 0])[:3]
pack = lambda v, w: sum(x << (w * i) for i, x in enumerate(v))
g = dict(NR=p('CCV_P_RS_RCU'), N=p('CCV_P_RS_RCU') + p('CCV_P_RS_MIU'), NPEN=len(pens),
         LAT_COPY=p('CCV_LAT_LANE'), LAT_SPEC=p('CCV_LAT_L1_WAKE'),
         LAT_MISS=stages + p('CCV_LAT_L1_CMPL'), CMPL_DLY=p('CCV_LAT_L1_MISS_WAKE'))
gs = ' '.join('-G%s=%d' % kv for kv in g.items())
gs += " -GLAT=64'h%x -GFAST=64'h%x -GPEN=24'h%x" % (pack(lat, 8), pack(fast, 8), pack(pens3, 8))
d = {'WAKE_' + k: v for k, v in g.items()}
for i in range(8): d['WAKE_LAT%d' % i] = lat[i]; d['WAKE_FAST%d' % i] = fast[i]
for i in range(3): d['WAKE_PEN%d' % i] = pens3[i]
print(gs.replace(' ', ',') + ' ' + ','.join('-D%s=%d' % kv for kv in d.items()))
