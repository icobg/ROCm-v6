#!/bin/bash

set -e
PRGNAM=rocm_smi_lib
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

cmake \
    -Wno-dev \
    -D CMAKE_INSTALL_PREFIX=${ROCM_INSTALL_DIR} \
    -D CMAKE_BUILD_TYPE=Release \
    -D ROCM_DEP_ROCMCORE=ON \
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
rocm-smi-lib: rocm-smi-lib (ROCm System Management Interface Library)
rocm-smi-lib:
rocm-smi-lib: The ROCm System Management Interface Library, or ROCm SMI library, is
rocm-smi-lib: part of the Radeon Open Compute ROCm software stack . It is a C
rocm-smi-lib: library for Linux that provides a user space interface for
rocm-smi-lib: applications to monitor and control GPU applications.
rocm-smi-lib:
rocm-smi-lib:
rocm-smi-lib:
rocm-smi-lib:
rocm-smi-lib:
END

cd $DEST
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

popd

