#!/bin/bash -ex

pip install --user -e cupy/

export CUPY_DUMP_CUDA_SOURCE_ON_ERROR=1

pytest_opts=(
    -rfEX
    --timeout=300
    --junit-xml=result.xml
    --cov
    --showlocals  # Show local variables on error
)

if [ $CUDNN = none ]; then
  pytest_opts+=(-m 'not cudnn and not slow')
else
  pytest_opts+=(-m 'not slow')
fi

TESTS_DIR=${PWD}/cupy/tests

# Move to temporary directory
pushd `mktemp -d`

python -m pytest "${pytest_opts[@]}" ${TESTS_DIR}

popd

# Submit coverage to Coveralls
python push_coveralls.py

# Submit coverage to Codecov
# Codecov uses `coverage.xml` generated from `.coverage`
coverage xml
codecov
