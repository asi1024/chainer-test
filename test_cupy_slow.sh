#!/bin/bash -ex

CHAINER_TEST_ROOT=${PWD}

# Move to temporary directory
pushd `mktemp -d`

pip install --user -e ${CHAINER_TEST_ROOT}/cupy/

export CUPY_DUMP_CUDA_SOURCE_ON_ERROR=1

pytest_opts=(
    -rfEX
    --timeout=300
    --junit-xml=result.xml
    --cov
    --showlocals  # Show local variables on error
)

if [ $CUDNN = none ]; then
  pytest_opts+=(-m 'slow and not cudnn')
else
  pytest_opts+=(-m 'slow')
fi

python -m pytest "${pytest_opts[@]}" ${CHAINER_TEST_ROOT}/cupy/tests

popd
