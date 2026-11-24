#!/bin/bash
cd /home/user/wt-sw; bash /tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad/swr.sh > /tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad/sw2.out 2>&1; grep -E "PASS|FAIL|MISSED|fail=" /tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad/sw2.out | cut -c1-120
