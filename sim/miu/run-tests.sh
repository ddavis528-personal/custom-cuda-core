#!/usr/bin/env bash
# The MIU model's unit tests (the check-miu-unit job, MI-1): build and run
# sim/miu/miu_test.cpp. Exit 0 only if every check passes.
set -euo pipefail
cd "$(dirname "$0")/../.."
B="${CCV_BUILD:-build}/miu-unit"
mkdir -p "$B"
${CXX:-g++} -std=c++17 -O1 -Wall -Wextra -Werror -o "$B/miu_test" sim/miu/miu_test.cpp
"$B/miu_test"
