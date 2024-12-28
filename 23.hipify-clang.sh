#!/bin/bash

set -e

cd $ROCM_REL_DIR
wget https://github.com/ROCm-Developer-Tools/HIPIFY/archive/rocm-$PKGVER.tar.gz
tar xf HIPIFY-$LDIR.tar.gz
rm -rf $ROCM_BUILD_DIR/hipify-clang
mkdir -p $ROCM_BUILD_DIR/hipify-clang
cd $ROCM_BUILD_DIR/hipify-clang

DEST=$OUTPUT/package-hipify-clang
PRGNAM=hipify-clang
NUMJOBS=${NUMJOBS:-" -j$(expr $(nproc) + 1) "}
BUILD=1
rm -rf $DEST

pushd .

cmake \
    -Wno-dev \
    -D CMAKE_INSTALL_PREFIX=${ROCM_INSTALL_DIR} \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_PREFIX_PATH=${ROCM_INSTALL_DIR}/lib/llvm/lib/cmake \
    $ROCM_REL_DIR/HIPIFY-$LDIR

cmake --build . $NUMJOBS
DESTDIR=$DEST cmake --install . --strip

chmod +x $DEST/opt/rocm/bin/hipify-perl
chmod +x $DEST/opt/rocm/bin/hipify-clang

mkdir -p $DEST/install
cat >> $DEST/install/slack-desc << 'END'
# HOW TO EDIT THIS FILE:
# The "handy ruler" below makes it easier to edit a package description.
# Line up the first '|' above the ':' following the base package name, and
# the '|' on the right side marks the last column you can put a character in.
# You must make exactly 11 lines for the formatting to be correct.  It's also
# customary to leave one space after the ':' except on otherwise blank lines.

      |-----handy-ruler------------------------------------------------------|
hipify: hipify (Convert CUDA to Portable C++ Code)
hipify:
hipify: HIPIFY is a set of tools that you can use to automatically translate
hipify: CUDA source code into portable HIP C++.
hipify:
hipify:
hipify:
hipify:
hipify:
hipify:
hipify:
END

cd $DEST
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

popd

