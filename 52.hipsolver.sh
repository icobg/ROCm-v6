#!/bin/bash

set -e
PRGNAM=hipSOLVER
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

CXX=$ROCM_INSTALL_DIR/bin/amdclang cmake \
    -Wno-dev \
    -D CMAKE_CXX_COMPILER=${ROCM_INSTALL_DIR}/bin/amdclang \
    -D CMAKE_CXX_FLAGS="${CXXFLAGS} -fcf-protection=none" \
    -D CMAKE_INSTALL_PREFIX=${ROCM_INSTALL_DIR} \
    -DCMAKE_BUILD_TYPE=Release \
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
hipSOLVER: hipSOLVER (rocSOLVER marshalling library.)
hipSOLVER:
hipSOLVER: hipSOLVER is a LAPACK marshalling library, with multiple supported 
hipSOLVER: backends. It sits between the application and a worker LAPACK
hipSOLVER: library, marshalling inputs into the backend library and marshalling
hipSOLVER: results back to the application. hipSOLVER exports an interface that
hipSOLVER: does not require the client to change, regardless of the chosen
hipSOLVER: backend. Currently, hipSOLVER supports rocSOLVER and cuSOLVER as
hipSOLVER: backends.
hipSOLVER:
END

cd $DEST
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

popd
