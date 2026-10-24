#!/usr/bin/env python3
"""ooe_rename's bench parameters (test/ooe/ooe_rename_tb.sv), from
rtl/generated/ccv_params_pkg.sv: the -G values and the bench's matching -D
defines, as test/ooe/run-rtl.sh passes them (comma-separated, so a shell
read keeps each list in one word). Rename 1's (ren1-params.py) and the
free lists' sizes, the RS's and ooe_rendep's code table."""
import re
import subprocess
import sys

pkg = open('rtl/generated/ccv_params_pkg.sv').read()
def p(n): return int(re.search(r'localparam int %s = (\d+);' % n, pkg).group(1))
gw = p('CCV_P_W_PHYS_REG') + p('CCV_W_PHYS_POS')
pw = p('CCV_P_W_PHYS_PRED')
g = dict(S=p('CCV_TIER1_WARPS'), R=p('CCV_ISSUE_WIDTH'), RP=p('CCV_RETIRE_PER_ROB'), C=p('CCV_P_BR_CKPTS'),
         NG=p('CCV_P_PHYS_REGS'), NP=p('CCV_P_PRED_REGS'), GW=gw, PW=pw)
g.update(N=p('CCV_P_RS_RCU') + p('CCV_P_RS_MIU'), NR=p('CCV_P_RS_RCU'))
g.update(AG=p('CCV_GPRS'), AP=p('CCV_PREDS'), FLG=p('CCV_P_REN_FLOOR'), CLG=p('CCV_P_REN_CEIL'),
         FLP=p('CCV_P_PRED_REN_FLOOR'), CLP=p('CCV_P_PRED_REN_CEIL'))
# RENAME_FLOORS=<GPR floor>,<GPR ceiling>: a build at a directed test's
# (run-rtl.sh's ceiling build).
import os
if os.environ.get('RENAME_FLOORS'):
    g['FLG'], g['CLG'] = (int(x) for x in os.environ['RENAME_FLOORS'].split(','))
# RENAME_NAMES=<GPR rows>,<GPR ceiling>: scarce names (run-rtl.sh's scarce
# build), where the names' pool binds and its correction shows; the bench
# sets the model's alike (RENAME_SCARCE).
scarce = bool(os.environ.get('RENAME_NAMES'))
if scarce:
    g['NG'], g['CLG'] = (int(x) for x in os.environ['RENAME_NAMES'].split(','))
gs = ['-G%s=%d' % kv for kv in g.items()]
gs += ["-GGZERO=%d'd%d" % (gw, p('CCV_P_PHYS_ZERO') << p('CCV_W_PHYS_POS')),
       "-GPZERO=%d'd%d" % (pw, p('CCV_P_PRED_ZERO'))]
# ooe_rendep's code table, which ooe_rename passes it (rendep-params.py).
gs += subprocess.run([sys.executable, 'test/ooe/rendep-params.py'], check=True, capture_output=True,
                     text=True).stdout.strip().split(',')
print(','.join(gs) + ' ' + ','.join(['-DRENAME_%s=%d' % kv for kv in g.items()] + ['-DRENAME_SCARCE=%d' % scarce]))
