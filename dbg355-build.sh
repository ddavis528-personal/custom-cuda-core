#!/usr/bin/env bash
set -x
cd /home/user/wt-dbg355
tools/regen.sh > build/regen.log 2>&1 || echo "regen rc=$?"
tools/check-skel.sh > build/skel.log 2>&1; echo "skel rc=$?"
tools/gen-oracle.sh coremark128 > build/oracle.log 2>&1; echo "oracle rc=$?"
ls -la build/skel/ccv-skel build/oracle/coremark128/ 2>&1 | head
