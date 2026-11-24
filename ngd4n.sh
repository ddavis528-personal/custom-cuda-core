cd /tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad/wr4
export PATH="$PWD/tools/shim:$PATH"
python3 tools/check-ngd.py --unit ooe_rob_w > ../ngd-rob4n.log 2>&1
echo "EXIT $?" >> ../ngd-rob4n.log
