#!/bin/bash

set -e

PRGNAM=rocWMMA

cd $ROCM_REL_DIR
wget https://github.com/ROCm/$PRGNAM/archive/rocm-$PKGVER.tar.gz
tar xf $PRGNAM-$LDIR.tar.gz
rm -rf $ROCM_BUILD_DIR/$PRGNAM
mkdir -p $ROCM_BUILD_DIR/$PRGNAM
cd $ROCM_BUILD_DIR/$PRGNAM

pushd .

DEST=$OUTPUT/package-$PRGNAM
NUMJOBS=${NUMJOBS:-" -j$(expr $(nproc) + 1) "}
BUILD=1

cmake \
    -Wno-dev \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_INSTALL_PREFIX=${ROCM_INSTALL_DIR} \
    -D CMAKE_CXX_COMPILER=/opt/rocm/bin/amdclang++ \
    -D OpenMP_CXX_FLAGS="-fopenmp -Wno-unused-command-line-argument" \
    -D OpenMP_CXX_LIB_NAMES="libomp;libgomp;libiomp5" \
    -D OpenMP_libomp_LIBRARY="/opt/rocm/lib/libomp.so" \
    -D OpenMP_libgomp_LIBRARY="/opt/rocm/lib/libgomp.so" \
    -D OpenMP_libiomp5_LIBRARY="/opt/rocm/lib/libiomp5.so" \
    -D ROCWMMA_BUILD_SAMPLES=OFF \
    -D ROCWMMA_BUILD_TESTS=OFF \
    -D ROCWMMA_BUILD_VALIDATION_TESTS=OFF \
    $ROCM_REL_DIR/$PRGNAM-$LDIR

cmake --build . $NUMJOBS
DESTDIR=$DEST cmake --install .

mkdir -p $DEST/install
cat >> $DEST/install/slack-desc << 'END'
# HOW TO EDIT THIS FILE:
# The "handy ruler" below makes it easier to edit a package description.
# Line up the first '|' above the ':' following the base package name, and
# the '|' on the right side marks the last column you can put a character in.
# You must make exactly 11 lines for the formatting to be correct.  It's also
# customary to leave one space after the ':' except on otherwise blank lines.

       |-----handy-ruler------------------------------------------------------|
rocWMMA: rocWMMA (rocWMMA)
rocWMMA:
rocWMMA: rocWMMA is C++ library for accelerating mixed-precision matrix
rocWMMA: multiply-accumulate (MMA) operations leveraging AMD GPU hardware.
rocWMMA: rocWMMA makes it easier to break down MMA problems into fragments and
rocWMMA: distribute block-wise MMA operations in parallel across GPU
rocWMMA: wavefronts. The API consists of a header library, that can be used to
rocWMMA: compile MMA acceleration directly into GPU kernel device code. This
rocWMMA: can benefit from compiler optimization in the generation of kernel
rocWMMA: assembly, and does not incur additional overhead costs of linking to
rocWMMA: external runtime libraries or having to launch separate kernels.
END

cd $DEST
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

popd
