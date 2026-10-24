#!/usr/bin/env python3
"""Rename 1's bench parameters (test/ooe/ooe_ren1_tb.sv), from
rtl/generated/ccv_params_pkg.sv: the -G values and the bench's matching -D
defines, as test/ooe/run-rtl.sh passes them (comma-separated, so a shell
read keeps each list in one word)."""
import re

pkg = open('rtl/generated/ccv_params_pkg.sv').read()
def p(n): return int(re.search(r'localparam int %s = (\d+);' % n, pkg).group(1))
gw = p('CCV_P_W_PHYS_REG') + p('CCV_W_PHYS_POS')
pw = p('CCV_P_W_PHYS_PRED')
g = dict(S=p('CCV_TIER1_WARPS'), R=p('CCV_ISSUE_WIDTH'), RP=p('CCV_RETIRE_PER_ROB'), C=p('CCV_P_BR_CKPTS'),
         GW=gw, GR=p('CCV_P_W_PHYS_REG'), PW=pw)
gs = ['-G%s=%d' % kv for kv in g.items()]
gs += ["-GGZERO=%d'd%d" % (gw, p('CCV_P_PHYS_ZERO') << p('CCV_W_PHYS_POS')),
       "-GPZERO=%d'd%d" % (pw, p('CCV_P_PRED_ZERO'))]
print(','.join(gs) + ' ' + ','.join('-DREN1_%s=%d' % kv for kv in g.items()))
