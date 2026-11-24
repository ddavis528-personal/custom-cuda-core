import json,sys,re
d=json.load(open(sys.argv[1]))
t=[x['text'] for x in d if x['text'].startswith('{')][0]
j,_=json.JSONDecoder().raw_decode(t); x=j['data']['xml']
print(j['data']['rev'], j['data'].get('next'))
for r in re.findall(r"<row .*?</row>",x,flags=re.S):
    cells=[ ''.join(re.findall(r"<text[^>]*>(.*?)</text>",c,flags=re.S)) for c in re.findall(r"<cell .*?</cell>",r,flags=re.S)]
    print('ROW',len(cells),[c[:2000] if i==len(cells)-1 or 'OI' in c else c[:150] for i,c in enumerate(cells)] if any('OI' in c for c in cells) else [c[:150] for c in cells][:4])
