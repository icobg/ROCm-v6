#!/bin/bash

set -e

cd $ROCM_REL_DIR
wget https://github.com/ROCm/hipfort/archive/rocm-$PKGVER.tar.gz
tar xf hipfort-$LDIR.tar.gz
rm -rf $ROCM_BUILD_DIR/hipfort
mkdir -p $ROCM_BUILD_DIR/hipfort
cd $ROCM_BUILD_DIR/hipfort

DEST=$OUTPUT/package-hipfort
PRGNAM=hipfort
NUMJOBS=${NUMJOBS:-" -j$(expr $(nproc) + 1) "}
BUILD=1
rm -rf $DEST

pushd .

CXX=$ROCM_INSTALL_DIR/bin/amdclang cmake \
    -D CMAKE_BUILD_TYPE=Release \
    -D CPACK_PACKAGING_INSTALL_PREFIX=$ROCM_INSTALL_DIR \
    -D HIPFORT_INSTALL_DIR=${ROCM_INSTALL_DIR} \
    -G "Unix Makefiles" \
    $ROCM_REL_DIR/hipfort-$LDIR

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
hipfort: hipfort (Fortran Interface For GPU Kernel Libraries)
hipfort:
hipfort: This is a FORTRAN interface library for accessing GPU Kernels.
hipfort:
hipfort:
hipfort:
hipfort:
hipfort:
hipfort:
hipfort:
hipfort:
END

cd $DEST
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

popd

