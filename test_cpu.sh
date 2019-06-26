#!/bin/bash -e


pip install --user -e chainer/

export CUPY_DUMP_CUDA_SOURCE_ON_ERROR=1

export CHAINER_TEST_GPU_LIMIT=0

export OMP_NUM_THREADS=1

pytest_opts=(
    -rfEX
    --timeout=300
    --junit-xml=result.xml
    --cov
    --showlocals  # Show local variables on error
)

pytest_marks=(
    not cudnn and not slow
)

if [ $IDEEP = none ]; then
  pytest_marks+=(and not ideep)
fi

pytest_opts+=(-m "${pytest_marks[*]}")

TESTS_DIR=${PWD}/chainer/tests/chainer_tests

# Move to temporary directory
pushd `mktemp -d`

python -m pytest "${pytest_opts[@]}" ${TESTS_DIR}

popd
