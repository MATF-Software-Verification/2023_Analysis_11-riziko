#!/usr/bin/bash

set -xe

valgrind --tool=callgrind --log-file="callgrind_analysis.txt" ./riziko

echo "Callgrind is finished with analysis. You can check log file"
