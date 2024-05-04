#!/usr/bin/bash

set -xe

valgrind --show-leak-kinds=all --leak-check=full --track-origins=yes --log-file="memcheck_analysis.txt" ./riziko

echo "Memcheck is finished with analysis. You can check log file"
