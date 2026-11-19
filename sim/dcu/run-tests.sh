#!/usr/bin/env bash
# Build and run the DCU model's unit tests (sim/dcu/dcu_test.cpp): the
# spec's cycles at the core's decoded interface and the never-happens
# conditions it must refuse. Needs the generated parameters
# (python3 tools/gen-params.py).
# Usage: sim/dcu/run-tests.sh [-v]
set -euo pipefail
cd "$(dirname "$0")/../.."
mkdir -p build/dcu
g++ -std=c++17 -O2 -Wall -Wextra -Werror -Isim/generated -Isim/dcu \
    sim/dcu/dcu_core.cpp sim/dcu/dcu_test.cpp -o build/dcu/dcu-test
build/dcu/dcu-test "$@"
