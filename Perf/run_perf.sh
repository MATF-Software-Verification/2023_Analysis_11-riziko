#!/usr/bin/bash

set -xe

cd ../11-riziko/build-riziko-Desktop-Debug
sudo perf record --call-graph dwarf ./riziko
mv perf.data ../../Perf/
cd ../../Perf

echo "Perf is finished with analysis. Report is generating."

sudo perf report
