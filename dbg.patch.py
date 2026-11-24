p='test/ooe/slot_tb.cpp'; s=open(p).read()
old='''  max_al = std::max<unsigned long long>(max_al, e.alloc.size());'''
new='''  max_al = std::max<unsigned long long>(max_al, e.alloc.size());
  if (std::getenv("SLOT_DBG"))
    for (unsigned i = 0; i != e.alloc.size(); ++i)
      for (unsigned j = i + 1; j != e.alloc.size(); ++j)
        if (e.alloc[i].slot == e.alloc[j].slot)
          std::fprintf(stderr, "two on slot %u: ops %u then %u, warps %u %u\\n", e.alloc[i].slot, e.alloc[i].op, e.alloc[j].op, e.alloc[i].warp, e.alloc[j].warp);'''
s=s.replace(old,new); open(p,'w').write(s)
