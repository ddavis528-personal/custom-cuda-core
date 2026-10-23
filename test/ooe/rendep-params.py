#!/usr/bin/env python3
"""ooe_rendep's code table CT[unit][producer group][consumer group], from the
parameters and the model's default bypass table (Config::defaultByp,
bypWake, the sorted penalties): one -G list, comma-separated. A pair with a
bypass wake gets its penalty's index among the sorted penalties; any other
3, the late line. Used by test/ooe/run-rtl.sh and test/ooe/cg-build.sh."""
import re
pkg = open('rtl/generated/ccv_params_pkg.sv').read()
def p(n): return int(re.search(r'localparam int %s = (\d+);' % n, pkg).group(1))
NU, G = p('CCV_P_LAT_CLASSES'), p('CCV_P_BYP_GROUPS')
INT, FP, ADDR, SFU = 0, 1, 2, 3
same, intfp, sfu = p('CCV_LAT_BYP_PEN_SAME'), p('CCV_LAT_BYP_PEN_INT_FP'), p('CCV_LAT_BYP_PEN_SFU')
byp = [[None] * G for _ in range(G)]
byp[INT][INT] = byp[FP][FP] = byp[SFU][SFU] = same
byp[INT][FP] = byp[FP][INT] = intfp
byp[INT][SFU] = byp[FP][SFU] = byp[SFU][INT] = byp[SFU][FP] = sfu
pens = sorted({v for row in byp for v in row if v is not None})
lat = [p('CCV_LAT_RCU'), p('CCV_LAT_LANE'), 0, 0, p('CCV_LAT_SFU'), p('CCV_LAT_COLLECTIVE'), 0, 0]
fast = [0, p('CCV_LAT_LANE_BYP'), 0, 0, 0, 0, 0, 0]
ct = 0
for u in range(NU):
    for pg in range(G):
        for cg in range(G):
            c = 3
            b = byp[pg][cg]
            if b is not None and fast[u] and fast[u] + b < lat[u]:
                c = pens.index(b)
            ct |= c << (2 * ((u * G + pg) * G + cg))
print("-GNU=%d,-GG=%d,-GCT=%d'h%x" % (NU, G, 2 * NU * G * G, ct))
