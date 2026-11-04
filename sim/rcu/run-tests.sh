#!/usr/bin/env bash
# Build and run the RCU model's unit tests (sim/rcu/rcu_test.cpp): the
# spec's cycles at the core's decoded interface and the hazards it must
# refuse. Needs the generated parameters (python3 tools/gen-params.py).
# Usage: sim/rcu/run-tests.sh [-v]
set -euo pipefail
cd "$(dirname "$0")/../.."
mkdir -p build/rcu
g++ -std=c++17 -O2 -Wall -Wextra -Werror -Isim/generated -Isim/rcu \
    sim/rcu/rcu_core.cpp sim/rcu/rcu_test.cpp -o build/rcu/rcu-test
build/rcu/rcu-test "$@"
