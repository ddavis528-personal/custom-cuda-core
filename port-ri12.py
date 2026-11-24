import sys,re
src='/tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad/wtx/'
dst=sys.argv[1].rstrip('/')+'/'
# header knob
h=open(dst+'sim/ooe/ooe_core.h').read()
a='  bool inject_cta_slot_zero = false;\n'
assert h.count(a)==1
sh=open(src+'sim/ooe/ooe_core.h').read()
i=sh.index(a)+len(a); j=sh.index('bool inject_keep_released_uops = false;',i)
k=sh.index('\n',j)+1
h=h.replace(a,a+sh[i:k]); open(dst+'sim/ooe/ooe_core.h','w').write(h)
# core fix
sc=open(src+'sim/ooe/ooe_core.cpp').read()
b0=sc.index('  if (!cfg_.inject_keep_released_uops) {')
anchor='  slot_of_[s.warp % kWarpIds] = -1;\n'
b1=sc.index(anchor,b0)
fix=sc[b0:b1]
c=open(dst+'sim/ooe/ooe_core.cpp').read()
assert c.count(anchor)==1
c=c.replace(anchor,fix+anchor); open(dst+'sim/ooe/ooe_core.cpp','w').write(c)
# test
st=open(src+'sim/ooe/ooe_test.cpp').read()
t0=st.index('/// RI-12 (RI\'s provswap'); t1=st.index('void testCtaSlot() {',t0)
t=open(dst+'sim/ooe/ooe_test.cpp').read()
assert t.count('void testCtaSlot() {')==1 and t.count('  testCtaSlot();\n')==1
t=t.replace('void testCtaSlot() {',st[t0:t1]+'void testCtaSlot() {').replace('  testCtaSlot();\n','  testCtaSlot();\n  testReleaseDrop();\n')
open(dst+'sim/ooe/ooe_test.cpp','w').write(t)
print('ported; fix:\n'+fix)
