#!/bin/bash

read -p "| Require 64+ GB of RAM memory and few hours |"
set -e

cd $ROCM_REL_DIR
wget https://github.com/ROCm/hipBLASLt/archive/rocm-$PKGVER.tar.gz
wget https://www.ixip.net/rocm/hipblaslt-find-msgpack5.patch
tar xf hipBLASLt-$LDIR.tar.gz
cd hipBLASLt-rocm-$PKGVER
patch -Np1 -i $ROCM_REL_DIR/hipblaslt-find-msgpack5.patch
rm -rf $ROCM_BUILD_DIR/hipblaslt
mkdir -p $ROCM_BUILD_DIR/hipblaslt
cd $ROCM_BUILD_DIR/hipblaslt

pushd .

DEST=$OUTPUT/package-hipblaslt
PRGNAM=hipBLASLt
NUMJOBS=${NUMJOBS:-" -j$(expr $(nproc) - 8) "}
BUILD=1
rm -rf $DEST

cmake \
    -Wno-dev \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_INSTALL_PREFIX=${ROCM_INSTALL_DIR} \
    -D CMAKE_CXX_COMPILER=${ROCM_INSTALL_DIR}/llvm/bin/amdclang \
    -D CMAKE_C_COMPILER=${ROCM_INSTALL_DIR}/llvm/bin/amdclang \
    -D AMDGPU_TARGETS="gfx900;gfx90a;gfx942;gfx1030;gfx1100;gfx1101;gfx1102;gfx1200;gfx1201" \
    -D Tensile_CODE_OBJECT_VERSION=default \
    $ROCM_REL_DIR/hipBLASLt-$LDIR

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
hipBLASLt: hipBLASLt (hipBLASLt)
hipBLASLt:
hipBLASLt: General matrix-matrix operations beyond a traditional BLAS library
hipBLASLt: hipBLASLt is exposed APIs in HIP programming language with an
hipBLASLt: an underlying optimized generator as a backend kernel provider.
hipBLASLt:
hipBLASLt: This library adds flexibility in matrix data layouts, input types,
hipBLASLt: compute types, and also in choosing the algorithmic implementations
hipBLASLt: and heuristics through parameter programmability. 
hipBLASLt:
hipBLASLt:
END

cd $DEST
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

popd
