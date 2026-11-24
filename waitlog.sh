#!/bin/bash
# wait until a bg-run log has its end line, up to 110 min
for i in $(seq 1 660); do grep -q "CCV-JOB-EXIT\|^bg-run: done\|exit [0-9]" "$1" 2>/dev/null && break; sleep 10; done; cat "$1"
