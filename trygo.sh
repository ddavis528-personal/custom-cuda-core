# usage: trygo.sh <file of json reads entries>
cd /home/user/wt-sw
S=/tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad
cp $S/fb_keep4.json rtl/ooe/ooe_rename.feedback.json; cp $S/cr_keep3.json rtl/conn-ratchet.json
python3 - "$1" <<'PY'
import json,sys,collections
p='rtl/ooe/ooe_rename.feedback.json'; cur=json.load(open(p),object_pairs_hook=collections.OrderedDict)
add=json.load(open(sys.argv[1]),object_pairs_hook=collections.OrderedDict)
for k,v in add.items():
  v=collections.OrderedDict(v); v.setdefault('by','OA'); v.setdefault('date','2026-11-24'); v.setdefault('why','x')
  cur['reads'][k]=v
open(p,'w').write(json.dumps(cur,indent=2)+'\n')
p='rtl/conn-ratchet.json'; c=json.load(open(p))
keys={tuple(k.split('.')) for k in add}
c['entries']=[e for e in c['entries'] if not (e['parent']=='ooe_rename' and (e['instance'],e['port']) in keys)]
open(p,'w').write(json.dumps(c,indent=1)+'\n')
PY
python3 tools/${LINT:-lint-rtl.py} 2>&1 | tail -8 | cut -c1-900
cp $S/fb_keep4.json rtl/ooe/ooe_rename.feedback.json; cp $S/cr_keep3.json rtl/conn-ratchet.json
