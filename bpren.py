import re,sys
p=sys.argv[1]; s=open(p).read()
a=s.index("begin : g_bp"); b=s.index("// The picker's request", a)
blk=s[a:b]
for n in "wo wx wk wi wm wg wh".split():
    blk=re.sub(r'\b%s_cq02h\b'%n, 'f'+n+'_cq02h', blk)
open(p,'w').write(s[:a]+blk+s[b:])
