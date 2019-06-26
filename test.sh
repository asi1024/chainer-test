#!/bin/bash -ex

CHAINER_TEST_ROOT=${PWD}

# Move to temporary directory
pushd `mktemp -d`

# Chainer setup script installs specific version of CuPy.
# We need to install Chainer first for test.
pip install --user ${CHAINER_TEST_ROOT}/chainer/

pip install --user -e ${CHAINER_TEST_ROOT}/cupy/

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

python -m pytest "${pytest_opts[@]}" ${CHAINER_TEST_ROOT}/chainer/tests/chainer_tests

# Submit coverage to Coveralls
python ${CHAINER_TEST_ROOT}/push_coveralls.py

popd

cd chainer

# Submit coverage to Codecov
# Codecov uses `coverage.xml` generated from `.coverage`
coverage xml
codecov
