#!/bin/bash

set -e
PRGNAM=MIVisionX
cd $ROCM_REL_DIR
wget https://github.com/ROCm/$PRGNAM/archive/rocm-$PKGVER.tar.gz
wget https://www.ixip.net/rocm/0003-ffmpeg5-6-build-fixes.patch
tar xf $PRGNAM-$LDIR.tar.gz
cd $PRGNAM-$LDIR

patch -Np1 -i $ROCM_REL_DIR/0003-ffmpeg5-6-build-fixes.patch

rm -rf $ROCM_BUILD_DIR/$PRGNAM
mkdir -p $ROCM_BUILD_DIR/$PRGNAM
cd $ROCM_BUILD_DIR/$PRGNAM

pushd .

DEST=$OUTPUT/package-$PRGNAM

NUMJOBS=${NUMJOBS:-" -j$(expr $(nproc) + 1) "}
BUILD=2

CXX=/opt/rocm/bin/amdclang cmake \
    -Wno-dev \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_INSTALL_PREFIX=${ROCM_INSTALL_DIR} \
    -D BUILD_TESTING=OFF \
    -D OpenMP_C_FLAGS="-fopenmp -Wno-unused-command-line-argument" \
    -D OpenMP_C_LIB_NAMES="libomp;libgomp;libiomp5" \
    -D OpenMP_CXX_FLAGS="-fopenmp -Wno-unused-command-line-argument" \
    -D OpenMP_CXX_LIB_NAMES="libomp;libgomp;libiomp5" \
    -D OpenMP_libomp_LIBRARY="/opt/rocm/lib/libomp.so" \
    -D OpenMP_libgomp_LIBRARY="/opt/rocm/lib/libgomp.so" \
    -D OpenMP_libiomp5_LIBRARY="/opt/rocm/lib/libiomp5.so" \
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
MIVisionX: MIVisionX (MIVisionX)
MIVisionX:
MIVisionX: MIVisionX toolkit is a set of comprehensive computer vision and
MIVisionX: machine intelligence libraries, utilities, and applications bundled
MIVisionX: into a single toolkit. AMD MIVisionX delivers highly optimized
MIVisionX: conformant open-source implementation of the Khronos OpenVX™ and
MIVisionX: OpenVX™ Extensions along with Convolution Neural Net Model Compiler
MIVisionX: & Optimizer supporting ONNX, and Khronos NNEF™ exchange formats. 
MIVisionX:
MIVisionX:
MIVisionX:
END

cd $DEST
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

popd
