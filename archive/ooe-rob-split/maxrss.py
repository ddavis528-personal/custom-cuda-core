#!/usr/bin/env python3
# maxrss.py CMD...: run CMD, then print its peak RSS (children) in MiB.
import resource, subprocess, sys
rc = subprocess.call(sys.argv[1:])
print(f"peak_rss_mib={resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss/1024:.0f}", file=sys.stderr)
sys.exit(rc)
