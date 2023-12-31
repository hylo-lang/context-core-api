#!/bin/bash

realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}
CURDIR=$(realpath $(dirname "$0"))
source ${CURDIR}/_test_common.sh

startTest "GCC compilation"

# Create a temporary directory to store results between runs
BUILDDIR="build/gh-checks/gcc/"
mkdir -p "${CURDIR}/../../${BUILDDIR}"

# Remove any cached version of conan profiles
rm -fR ${CURDIR}/../../build/gh-checks/conan-cache/profiles

# Run docker with action-cxx-toolkit to check our code
docker run ${DOCKER_RUN_PARAMS} \
    -e INPUT_BUILDDIR="/github/workspace/${BUILDDIR}" \
    -e INPUT_CC='gcc' \
    -e INPUT_CHECKS='build test install warnings' \
    -e INPUT_CONANFLAGS="--output-folder /github/workspace/${BUILDDIR} -o with_tests=True" \
    -e INPUT_CMAKEFLAGS="-DCMAKE_TOOLCHAIN_FILE=/github/workspace/${BUILDDIR}/build/Release/generators/conan_toolchain.cmake -DCMAKE_POLICY_DEFAULT_CMP0091=NEW -DCMAKE_BUILD_TYPE=Release" \
    -e INPUT_CTESTFLAGS="--test-dir /github/workspace/${BUILDDIR}/test/" \
    $IMAGENAME
status=$?
printStatus $status
