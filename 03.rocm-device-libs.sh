#!/bin/bash

set -e

echo "Building ROCm Device Libraries"

PRGNAM=rocm-device-libs
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
    -D CMAKE_INSTALL_PREFIX=$ROCM_INSTALL_DIR \
    -D CMAKE_PREFIX_PATH="$ROCM_BUILD_DIR/build" \
    $ROCM_REL_DIR/$LLVMNAM-$LDIR/amd/device-libs
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
rocm-device-libs: ROCm Device Libraries
rocm-device-libs:
rocm-device-libs: rocm-device-libs is a collection of CMake modules for common build and
rocm-device-libs: development tasks within the ROCm project. It is therefore a build
rocm-device-libs: dependency for many of the libraries that comprise the ROCm platform.
rocm-device-libs:
rocm-device-libs: rocm-device-libs is not required for building libraries or programs that
rocm-device-libs: use ROCm; it is required for building some of the libraries that are
rocm-device-libs: a part of ROCm.
rocm-device-libs:
rocm-device-libs:
END

cd $DEST
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

popd
