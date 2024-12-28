#!/bin/bash

set -e

cd $ROCM_REL_DIR
wget https://github.com/ROCm/rocMLIR/archive/rocm-$PKGVER.tar.gz
tar xf rocMLIR-$LDIR.tar.gz
rm -rf $ROCM_BUILD_DIR/rocmlir
mkdir -p $ROCM_BUILD_DIR/rocmlir
cd $ROCM_BUILD_DIR/rocmlir

pushd .

DEST=$OUTPUT/package-rocmlir
PRGNAM=rocMLIR
NUMJOBS=${NUMJOBS:-" -j$(expr $(nproc) + 1) "}
BUILD=1
rm -rf $DEST

export CC=${ROCM_INSTALL_DIR}/llvm/bin/clang
export CXX=${ROCM_INSTALL_DIR}/llvm/bin/clang++

cmake \
    -Wno-dev \
    -D CMAKE_CXX_FLAGS="${CXXFLAGS} -fcf-protection=none" \
    -D CMAKE_INSTALL_PREFIX=${ROCM_INSTALL_DIR} \
    -D CMAKE_BUILD_TYPE=Release \
    -D FFI_INCLUDE_DIR=/usr/include \
    -D FFI_LIBRARY_DIR=/usr/lib64 \
    -D CMAKE_C_COMPILER=${ROCM_INSTALL_DIR}/llvm/bin/clang \
    -D CMAKE_CXX_COMPILER=${ROCM_INSTALL_DIR}/llvm/bin/clang++ \
    -D BUILD_FAT_LIBROCKCOMPILER=ON \
    $ROCM_REL_DIR/rocMLIR-$LDIR

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
rocMLIR: rocMLIR (MLIR-based convolution and GEMM kernel generator for ROCm)
rocMLIR:
rocMLIR: MLIR-based convolution and GEMM kernel generator targetting AMD
rocMLIR: hardware. This generator is mainly used from MIGraphX, but it can be
rocMLIR: used on a standalone basis.
rocMLIR:
rocMLIR:
rocMLIR:
rocMLIR:
rocMLIR:
rocMLIR:
END

cd $DEST
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

popd

