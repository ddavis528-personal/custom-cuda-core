#!/bin/bash
cd /home/user/wt-sfu
export PATH="$PWD/tools/shim:$PATH" CCV_FOREGROUND=1
./tools/regen.sh > /root/ccv-logs/sfu-regen.out 2>&1; echo "regen rc $?"
./tools/check-kernel.sh > /root/ccv-logs/sfu-kernel.out 2>&1; echo "kernel rc $?"; tail -4 /root/ccv-logs/sfu-kernel.out
[ -x tools/check-ooe-unit.sh ] && { ./tools/check-ooe-unit.sh > /root/ccv-logs/sfu-ooeunit.out 2>&1; echo "ooe-unit rc $?"; }
bash test/ooe/run-rtl.sh > /root/ccv-logs/sfu-rtl.out 2>&1; echo "ooe rtl rc $?"
./tools/check-sv-hosted.sh > /root/ccv-logs/sfu-svh.out 2>&1; echo "svh rc $?"; tail -4 /root/ccv-logs/sfu-svh.out
