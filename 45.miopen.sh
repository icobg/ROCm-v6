#!/bin/bash

#read -p "Compilation error 6.2.0, not solved yet"
set -e

cd $ROCM_REL_DIR
wget https://github.com/ROCm/MIOpen/archive/rocm-$PKGVER.tar.gz

tar xf MIOpen-$LDIR.tar.gz
rm -rf $ROCM_BUILD_DIR/miopen
mkdir -p $ROCM_BUILD_DIR/miopen
cd $ROCM_BUILD_DIR/miopen

pushd .

DEST=$OUTPUT/package-miopen
rm -rf $DEST

PRGNAM=MIOpen
NUMJOBS=${NUMJOBS:-" -j$(expr $(nproc) + 1) "}
BUILD=1

export CC=${ROCM_INSTALL_DIR}/llvm/bin/clang
export CXX=${ROCM_INSTALL_DIR}/llvm/bin/clang++

CXX=$ROCM_INSTALL_DIR/llvm/bin/clang++ cmake \
    -Wno-dev \
    -D CMAKE_CXX_FLAGS="${CXXFLAGS} -fcf-protection=none -DNDEBUG" \
    -D CMAKE_INSTALL_PREFIX=${ROCM_INSTALL_DIR} \
    -D CMAKE_BUILD_TYPE=Release \
    -D MIOPEN_BACKEND=HIP \
    -D MIOPEN_INSTALL_CXX_HEADERS=ON \
    -D HALF_INCLUDE_DIR=/usr/include/half \
    -D BUILD_TESTING=NO \
    -D Boost_USE_STATIC_LIBS=NO \
    $ROCM_REL_DIR/MIOpen-$LDIR

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
MIOpen: MIOpen (AMDs Machine Intelligence Library (HIP backend))
MIOpen:
MIOpen: MIOpen is AMDs library for high-performance machine learning
MIOpen: primitives.
MIOpen:
MIOpen:
MIOpen:
MIOpen:
MIOpen:
MIOpen:
MIOpen:
END

cd $DEST
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

popd
