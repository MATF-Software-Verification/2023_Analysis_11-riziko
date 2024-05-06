#!/usr/bin/bash

set -xe

cd FlameGraph
sudo perf script -i ../perf.data | ./stackcollapse-perf.pl | ./flamegraph.pl > ../flame_graph.svg
cd ..

echo "Generating flame graph is finished.
