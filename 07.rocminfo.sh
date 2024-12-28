#!/bin/bash

set -e

cd $ROCM_REL_DIR
wget https://github.com/ROCm/rocminfo/archive/rocm-$PKGVER.tar.gz
tar xf rocminfo-$LDIR.tar.gz
rm -rf $ROCM_BUILD_DIR/rocminfo
mkdir -p $ROCM_BUILD_DIR/rocminfo
cd $ROCM_BUILD_DIR/rocminfo
DEST=$OUTPUT/package-rocminfo
PRGNAM=rocminfo
NUMJOBS=${NUMJOBS:-" -j$(expr $(nproc) + 1) "}
BUILD=1
rm -rf $DEST

pushd .

cmake \
    -Wno-dev \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_PREFIX_PATH=${ROCM_INSTALL_DIR} \
    -D ROCRTST_BLD_TYPE=Release \
    -D CMAKE_INSTALL_PREFIX=${ROCM_INSTALL_DIR} \
    -D CMAKE_INSTALL_LIBDIR=lib \
    $ROCM_REL_DIR/rocminfo-$LDIR/

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
rocminfo: rocminfo (ROCm Application for Reporting System Info)
rocminfo:
rocminfo: ROCm Application for Reporting System Info
rocminfo:
rocminfo:
rocminfo:
rocminfo:
rocminfo:
rocminfo:
rocminfo:
rocminfo:
END

cd $DEST
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

popd

