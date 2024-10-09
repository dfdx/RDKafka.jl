#!/bin/bash
set -e

cd $RDKAFKA_TEST_DIR

sh scripts/run-test-kafka.sh
/opt/julia-${JULIA_VERSION}/bin/julia -e 'import Pkg; Pkg.activate("."); Pkg.test()'