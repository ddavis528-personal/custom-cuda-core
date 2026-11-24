# usage: trylead.sh '<json of reads entries>'
cd /home/user/wt-sw
S=/tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad
cp $S/fb_keep3.json rtl/ooe/ooe_rename.feedback.json; cp $S/cr_keep2.json rtl/conn-ratchet.json
python3 - "$1" <<'PY'
import json,sys,re,collections
p='rtl/ooe/ooe_rename.feedback.json'; cur=json.load(open(p),object_pairs_hook=collections.OrderedDict)
add=json.loads(sys.argv[1])
for k,v in add.items(): cur['reads'][k]=v
open(p,'w').write(json.dumps(cur,indent=2)+'\n')
p='rtl/conn-ratchet.json'; s=open(p).read()
for k in add:
  port=k.split('.')[1]
  m=re.search(r'\n  \{\n   "parent": "ooe_rename",\n   "instance": "u_gfree",\n   "port": "%s",.*?\n  \},'%port, s, re.S); s=s[:m.start()]+s[m.end():]
open(p,'w').write(s)
PY
python3 tools/lint-rtl.py 2>&1 | grep -v 'u_map' | tail -6 | cut -c1-600
cp $S/fb_keep3.json rtl/ooe/ooe_rename.feedback.json; cp $S/cr_keep2.json rtl/conn-ratchet.json
