#!/bin/bash

set -e
PRGNAM=rocSPARSE
cd $ROCM_REL_DIR
wget https://github.com/ROCmSoftwarePlatform/$PRGNAM/archive/rocm-$PKGVER.tar.gz
tar xf $PRGNAM-$LDIR.tar.gz
rm -rf $ROCM_BUILD_DIR/$PRGNAM
mkdir -p $ROCM_BUILD_DIR/$PRGNAM
cd $ROCM_BUILD_DIR/$PRGNAM

DEST=$OUTPUT/package-$PRGNAM

NUMJOBS=${NUMJOBS:-" -j$(expr $(nproc) + 1) "}
BUILD=1
rm -rf $DEST

pushd .

cmake \
    -Wno-dev \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_CXX_COMPILER=${ROCM_INSTALL_DIR}/bin/amdclang++ \
    -D CMAKE_CXX_FLAGS="${CXXFLAGS} -fcf-protection=none" \
    -D CMAKE_C_COMPILER=${ROCM_INSTALL_DIR}/bin/amdclang \
    -D CMAKE_INSTALL_PREFIX=${ROCM_INSTALL_DIR} \
    -D CMAKE_MODULE_PATH=${ROCM_INSTALL_DIR}/lib/cmake/hip \
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
rocSPARSE: rocSPARSE (BLAS for sparse computation on top of ROCm)
rocSPARSE:
rocSPARSE: rocSPARSE exposes a common interface that provides Basic Linear
rocSPARSE: Algebra Subroutines (BLAS) for sparse computation. Its implemented
rocSPARSE: on top of AMD ROCm runtime and toolchains. rocSPARSE is created
rocSPARSE: using the HIP programming language and optimized for AMDs latest
rocSPARSE: discrete GPUs.
rocSPARSE:
rocSPARSE:
rocSPARSE:
rocSPARSE:
END

cd $DEST
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

popd

