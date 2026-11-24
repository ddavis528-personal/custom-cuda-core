cd /tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad/wr4
export PATH="$PWD/tools/shim:$PATH"
for u in ooe_cmcap ooe_rob_w; do python3 tools/check-cg.py --unit $u; echo "rc $u $?"; done > ../cg-rob4.log 2>&1
echo EXIT >> ../cg-rob4.log
