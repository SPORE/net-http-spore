#!/bin/bash

set -e
set -x

dzil authordeps --missing > /tmp/missing-deps.txt
cat /tmp/missing-deps.txt
cat /tmp/missing-deps.txt | cpanm --no-skip-satisfied
