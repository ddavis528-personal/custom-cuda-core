#!/usr/bin/env bash
# Build and run the OOE core's unit tests (sim/ooe/ooe_test.cpp): every
# recovery path the S1 kernels cannot reach yet, under the contracts, with
# the core's invariants on every cycle. Needs the generated parameters
# (python3 tools/gen-params.py). Usage: sim/ooe/run-tests.sh [--seeds N]
set -euo pipefail
cd "$(dirname "$0")/../.."
mkdir -p build/ooe
g++ -std=c++17 -O2 -Wall -Wextra -Werror -Isim/generated -Isim/ooe \
    sim/ooe/ooe_core.cpp sim/ooe/ooe_test.cpp -o build/ooe/ooe-test
build/ooe/ooe-test "$@"
