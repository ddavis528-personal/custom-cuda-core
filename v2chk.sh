#!/bin/bash
cd /home/user/custom-cuda-core
export PATH="$PWD/tools/shim:$PATH"
{ sed -n 1,53p test/ooe/run-rtl.sh; echo 'n=$((n_rcu + n_miu))'; sed -n 138p test/ooe/run-rtl.sh; sed -n 207p test/ooe/run-rtl.sh; sed -n 237p test/ooe/run-rtl.sh; sed -n 367p test/ooe/run-rtl.sh; sed -n '/^# ooe_select, with its two ooe_picks/,$p' test/ooe/run-rtl.sh; } > /tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad/selrtl2.sh
sed -i 's#cd "$(dirname "$0")/../.."#cd /home/user/custom-cuda-core#' /tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad/selrtl2.sh
echo "== benches"; bash /tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad/selrtl2.sh; echo "benches rc $?"
echo "== cg"; python3 tools/check-cg.py --unit ooe_sched > /tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad/cg-sched.log 2>&1; echo "cg rc $?"; grep -i "ooe_sched" /tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad/cg-sched.log | head -20
echo "== lint"; python3 tools/lint-rtl.py 2>&1 | tail -3
echo EXIT
