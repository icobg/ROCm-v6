#!/bin/bash

set -e

PRGNAM=rocm-cmake
cd $ROCM_REL_DIR
wget https://github.com/ROCm/$PRGNAMe/archive/rocm-$PKGVER.tar.gz
tar xf $PRGNAM-$LDIR.tar.gz
rm -rf $ROCM_BUILD_DIR/$PRGNAM
mkdir -p $ROCM_BUILD_DIR/$PRGNAM
cd $ROCM_BUILD_DIR/$PRGNAM

BUILD=1
DEST=$OUTPUT/package-$PRGNAM
rm -rf $DEST

pushd .

cmake \
    -Wno-dev \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_INSTALL_PREFIX=${ROCM_INSTALL_DIR} \
    $ROCM_REL_DIR/$PRGNAM-$LDIR
cmake --build .
DESTDIR=$DEST cmake --install . --strip


#"${NINJA:=ninja}" $NUMJOBS || exit 1
#DESTDIR=$DEST "$NINJA" install || exit 1

mkdir -p $DEST/install
cat >> $DEST/install/slack-desc << 'END'
# HOW TO EDIT THIS FILE:
# The "handy ruler" below makes it easier to edit a package description.
# Line up the first '|' above the ':' following the base package name, and
# the '|' on the right side marks the last column you can put a character in.
# You must make exactly 11 lines for the formatting to be correct.  It's also
# customary to leave one space after the ':' except on otherwise blank lines.

          |-----handy-ruler------------------------------------------------------|
rocm-cmake: rocm-cmake (ROCm cmake)
rocm-cmake:
rocm-cmake: rocm-cmake is a collection of CMake modules for common build and
rocm-cmake: development tasks within the ROCm project. It is therefore a build
rocm-cmake: dependency for many of the libraries that comprise the ROCm platform.
rocm-cmake:
rocm-cmake: rocm-cmake is not required for building libraries or programs that
rocm-cmake: use ROCm; it is required for building some of the libraries that are
rocm-cmake: a part of ROCm.
rocm-cmake:
rocm-cmake:
END

cd $DEST
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

popd
