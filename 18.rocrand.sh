#!/bin/bash

set -e

PRGNAM=rocRAND
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
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_TOOLCHAIN_FILE=toolchain-linux.cmake \
    -DCMAKE_CXX_COMPILER=${ROCM_INSTALL_DIR}/bin/amdclang++ \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS} -fcf-protection=none" \
    -DCMAKE_INSTALL_PREFIX=${ROCM_INSTALL_DIR} \
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
rocRAND: rocRAND (Pseudo-random and quasi-random number generator on ROCm)
rocRAND:
rocRAND: The rocRAND project provides functions that generate pseudorandom and
rocRAND: quasirandom numbers. The rocRAND library is implemented in the HIP
rocRAND: programming language and optimized for AMDs latest discrete GPUs.
rocRAND: It is designed to run on top of AMDs ROCm runtime, but it also works
rocRAND: on CUDA-enabled GPUs.
rocRAND:
rocRAND:
rocRAND:
rocRAND:
END

cd $DEST
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

popd
