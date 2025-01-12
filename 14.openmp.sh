#!/bin/bash

echo "Building ROCm OpenMP"

set -e

PRGNAM=rocm-OpenMP
rm -rf $ROCM_BUILD_DIR/$PRGNAM
mkdir -p $ROCM_BUILD_DIR/$PRGNAM
cd $ROCM_BUILD_DIR/$PRGNAM

LLVMNAM=llvm-project

BUILD=1
NUMJOBS=${NUMJOBS:-" -j$(expr $(nproc) + 1) "}
DEST=$OUTPUT/package-$PRGNAM
rm -rf $DEST

pushd .

cmake \
    -Wno-dev \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_INSTALL_PREFIX=${ROCM_INSTALL_DIR} \
    -D LIBOMPTARGET_OMPD_SUPPORT=ON \
    -D LIBOMP_OMPD_SUPPORT=ON \
    $ROCM_REL_DIR/$LLVMNAM-$LDIR/openmp

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
OpenMP: OpenMP (Open Multi-Processing)
OpenMP:
OpenMP: OpenMP (Open Multi-Processing) is an application programming interface
OpenMP: (API) that supports multi-platform shared-memory multiprocessing
OpenMP: programming in C, C++, and Fortran on many platforms, instruction-set
OpenMP: architectures and operating systems
OpenMP: It consists of a set of compiler directives, library routines, and
OpenMP: environment variables that influence run-time behavior.
OpenMP:
OpenMP:
OpenMP:
END

cd $DEST
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

popd
