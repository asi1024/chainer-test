#!/bin/bash -ex

# Chainer setup script installs specific version of CuPy.
# We need to install Chainer first for test.
pip install --user chainer/

pip install --user -e cupy/

export CUPY_DUMP_CUDA_SOURCE_ON_ERROR=1

pytest_opts=(
    --timeout=300
    --junit-xml=result.xml
    --cov
    --showlocals  # Show local variables on error
)

pytest_marks=(
    not slow
)

if [ $CUDNN = none ]; then
  pytest_marks+=(and not cudnn)
fi

if [ $IDEEP = none ]; then
  pytest_marks+=(and not ideep)
fi

pytest_opts+=(-m "${pytest_marks[*]}")

TESTS_DIR=${PWD}/chainer/tests/chainer_tests

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
