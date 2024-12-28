#!/bin/bash

set -e

cd $ROCM_REL_DIR
wget https://github.com/ROCm/hipBLAS/archive/rocm-$PKGVER.tar.gz
tar xf hipBLAS-$LDIR.tar.gz
rm -rf $ROCM_BUILD_DIR/hipblas
mkdir -p $ROCM_BUILD_DIR/hipblas
cd $ROCM_BUILD_DIR/hipblas

DEST=$OUTPUT/package-hipblas
PRGNAM=hipBLAS
NUMJOBS=${NUMJOBS:-" -j$(expr $(nproc) + 1) "}
BUILD=1
rm -rf $DEST

pushd .

CXX=$ROCM_INSTALL_DIR/bin/amdclang cmake \
    -Wno-dev \
    -D CMAKE_CXX_COMPILER=${ROCM_INSTALL_DIR}/bin/amdclang \
    -D CMAKE_C_COMPILER=${ROCM_INSTALL_DIR}/llvm/bin/amdclang \
    -D CMAKE_CXX_FLAGS="${CXXFLAGS} -fcf-protection=none" \
    -DCMAKE_BUILD_TYPE=Release \
    $ROCM_REL_DIR/hipBLAS-$LDIR

cmake --build . $NUMJOBS
DESTDIR=$DEST cmake --install . --strip

#    -D CMAKE_CXX_COMPILER=${ROCM_INSTALL_DIR}/bin/hipcc \

mkdir -p $DEST/install
cat >> $DEST/install/slack-desc << 'END'
# HOW TO EDIT THIS FILE:
# The "handy ruler" below makes it easier to edit a package description.
# Line up the first '|' above the ':' following the base package name, and
# the '|' on the right side marks the last column you can put a character in.
# You must make exactly 11 lines for the formatting to be correct.  It's also
# customary to leave one space after the ':' except on otherwise blank lines.

       |-----handy-ruler------------------------------------------------------|
hipBLAS: hipBLAS (Basic Linear Algebra Subprograms)
hipBLAS:
hipBLAS: hipBLAS is a Basic Linear Algebra Subprograms (BLAS) marshalling
hipBLAS: library with multiple supported backends. It sits between your 
hipBLAS: application and a worker BLAS library, where it marshals inputs to
hipBLAS: the backend library and marshals results to your application. hipBLAS
hipBLAS: exports an interface that doesnt require the client to change,
hipBLAS: regardless of the chosen backend. Currently, hipBLAS supports rocBLAS
hipBLAS: and cuBLAS backends.
hipBLAS:
END

cd $DEST
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

popd

