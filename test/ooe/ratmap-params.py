#!/usr/bin/env python3
"""ooe_ratmap's parameters, from rtl/generated/ccv_params_pkg.sv: the -G
values and the bench's matching -D defines, as test/ooe/run-rtl.sh and
test/ooe/cg-build.sh pass them (comma-separated)."""
import re

pkg = open('rtl/generated/ccv_params_pkg.sv').read()
def p(n): return int(re.search(r'localparam int %s = (\d+);' % n, pkg).group(1))
g = dict(S=p('CCV_TIER1_WARPS'), GW=p('CCV_P_W_PHYS_REG') + p('CCV_W_PHYS_POS'), PB=p('CCV_W_PHYS_POS'),
         PW=p('CCV_P_W_PHYS_PRED'), WB=p('CCV_W_CHWIDTH'), LW=p('CCV_W_WARP_ID'))
print(','.join('-G%s=%d' % kv for kv in g.items()) + ' ' + ','.join('-DRATMAP_%s=%d' % kv for kv in g.items()))
