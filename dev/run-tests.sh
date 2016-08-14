#!/bin/bash

set -e
set -x

dzil listdeps --author --missing > /tmp/missing-deps.txt
cat /tmp/missing-deps.txt
cat /tmp/missing-deps.txt | cpanm --no-skip-satisfied
dzil test --author --release
