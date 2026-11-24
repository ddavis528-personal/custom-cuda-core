import sys,re
f,t0,t1=sys.argv[1],int(sys.argv[2]),int(sys.argv[3]); pats=sys.argv[4:]
ids={}; scope=[]
fh=open(f)
for line in fh:
    line=line.strip()+"\n"
    if line.startswith('$scope'): scope.append(line.split()[2])
    elif line.startswith('$upscope'): scope.pop()
    elif line.startswith('$var'):
        p=line.split(); name='.'.join(scope[1:]+[p[4]])
        if any(re.search(x,name) for x in pats): ids.setdefault(p[3],[]).append(name)
    elif line.startswith('$enddefinitions'): break
cur={}; t=0
def dump():
    if t0<=t<=t1:
        print(t, ' '.join(f"{n}={cur.get(i,'?')}" for i,ns in ids.items() for n in ns))
for line in fh:
    line=line.strip()+"\n"
    if line[0]=='#':
        nt=int(line[1:])
        if nt!=t: dump(); t=nt
        if t>t1: break
    elif line[0] in 'b':
        v,i=line[1:].split(); 
        if i in ids: cur[i]=hex(int(v,2)) if 'x' not in v else v
    elif line[0] in '01xz':
        i=line[1:].strip()
        if i in ids: cur[i]=line[0]
