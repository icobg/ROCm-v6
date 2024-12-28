#!/bin/bash

set -e

cd $ROCM_REL_DIR
wget https://github.com/ROCm/hipCUB/archive/rocm-$PKGVER.tar.gz
tar xf hipCUB-$LDIR.tar.gz
rm -rf $ROCM_BUILD_DIR/hipcub
mkdir -p $ROCM_BUILD_DIR/hipcub
cd $ROCM_BUILD_DIR/hipcub

DEST=$OUTPUT/package-hipcub
PRGNAM=hipCUB
NUMJOBS=${NUMJOBS:-" -j$(expr $(nproc) + 1) "}
BUILD=1
rm -rf $DEST

pushd .

CXX=$ROCM_INSTALL_DIR/bin/hipcc cmake \
    -Wno-dev \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_INSTALL_PREFIX=${ROCM_INSTALL_DIR} \
    -D CMAKE_CXX_COMPILER=${ROCM_INSTALL_DIR}/bin/hipcc \
    -D CMAKE_CXX_FLAGS="${CXXFLAGS} -fcf-protection=none" \
    $ROCM_REL_DIR/hipCUB-$LDIR

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
hipCUB: hipCUB (Header-only library on top of rocPRIM or CUB)
hipCUB:
hipCUB: hipCUB is a thin wrapper library on top of rocPRIM or CUB. You can
hipCUB: use it to port a CUB project into HIP so you can use AMD hardware
hipCUB: (and ROCm software).
hipCUB:
hipCUB: In the ROCm environment, hipCUB uses the rocPRIM library as the
hipCUB: backend. On CUDA platforms, it uses CUB as the backend.
hipCUB:
hipCUB:
END

cd $DEST
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

popd

