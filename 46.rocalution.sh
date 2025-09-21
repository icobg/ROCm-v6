#!/bin/bash

set -e
PRGNAM=rocALUTION
cd $ROCM_REL_DIR
wget https://github.com/ROCm/$PRGNAM/archive/rocm-$PKGVER.tar.gz
tar xf $PRGNAM-$LDIR.tar.gz
rm -rf $ROCM_BUILD_DIR/$PRGNAM
mkdir -p $ROCM_BUILD_DIR/$PRGNAM
cd $ROCM_BUILD_DIR/$PRGNAM

DEST=$OUTPUT/package-$PRGNAM

NUMJOBS=${NUMJOBS:-" -j$(expr $(nproc) + 1) "}
BUILD=1
rm -rf $DEST

pushd .

export HIPCC_COMPILE_FLAGS_APPEND="-parallel-jobs=$(nproc)"
export HIPCC_LINK_FLAGS_APPEND="-parallel-jobs=$(nproc)"

cmake \
    -Wno-dev \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_TOOLCHAIN_FILE="$ROCM_REL_DIR/$PRGNAM-$LDIR/toolchain-linux.cmake" \
    -D CMAKE_INSTALL_PREFIX=${ROCM_INSTALL_DIR} \
    -D ROCM_PATH=${ROCM_INSTALL_DIR} \
    -D SUPPORT_HIP=ON \
    -D BUILD_SHARED_LIBS=ON \
    -D BUILD_CLIENTS_TESTS=OFF \
    -D BUILD_CLIENTS_BENCHMARKS=OFF \
    -D BUILD_CLIENTS_SAMPLES=OFF \
    -D USE_HIPCXX=ON \
    -D OpenMP_C_FLAGS="-fopenmp -Wno-unused-command-line-argument" \
    -D OpenMP_C_LIB_NAMES="libomp;libgomp;libiomp5" \
    -D OpenMP_CXX_FLAGS="-fopenmp -Wno-unused-command-line-argument" \
    -D OpenMP_CXX_LIB_NAMES="libomp;libgomp;libiomp5" \
    -D OpenMP_libomp_LIBRARY="/opt/rocm/lib/libomp.so" \
    -D OpenMP_libgomp_LIBRARY="/opt/rocm/lib/libgomp.so" \
    -D OpenMP_libiomp5_LIBRARY="/opt/rocm/lib/libiomp5.so" \
    $ROCM_REL_DIR/$PRGNAM-$LDIR

cmake --build . $NUMJOBS
DESTDIR=$DEST cmake --install . --strip

mkdir -p $DEST/install
cat >> $DEST/install/slack-desc << 'END'
# HOW TO EDIT THIS FILE:
# The "handy ruler" below makes it easier to edit a package description.
# Line up the first '|' above the ':' following the base package name, and
# the '|' on the right side marks the last column you can put a character in.
# You must make exactly 11 lines for the formatting to be correct.  It's also
# customary to leave one space after the ':' except on otherwise blank lines.

          |-----handy-ruler------------------------------------------------------|
rocALUTION: rocALUTION (Next generation library for iterative sparse solvers)
rocALUTION:
rocALUTION: rocALUTION is a sparse linear algebra library that can be used to
rocALUTION: explore fine-grained parallelism on top of the ROCm platform runtime
rocALUTION: and toolchains. Based on C++ and HIP, rocALUTION provides a portable,
rocALUTION: generic, and flexible design that allows seamless integration with
rocALUTION: other scientific software packages.
rocALUTION:
rocALUTION:
rocALUTION:
END

cd $DEST
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

popd
