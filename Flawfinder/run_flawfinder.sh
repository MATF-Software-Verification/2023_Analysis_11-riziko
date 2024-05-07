#!/usr/bin/bash

set -xe

flawfinder --html ../11-riziko > flawfinder_result.html

echo "Flawfinder is finished with analysis."
