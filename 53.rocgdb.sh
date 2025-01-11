#!/bin/bash

set -e
PRGNAM=ROCgdb
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

export PKG_CONFIG_PATH="/opt/rocm/share/pkgconfig:$PKG_CONFIG_PATH"
$ROCM_REL_DIR/$PRGNAM-$LDIR/configure \
        --prefix=/opt/rocm \
        --program-prefix=roc \
        --disable-binutils \
        --disable-gprofng \
        --disable-gprof \
        --enable-tui \
        --enable-64-bit-bfd \
        --enable-targets="amdgcn-amd-amdhsa" \
        --with-system-readline \
        --with-python=/usr/bin/python \
        --with-expat \
        --with-system-zlib \
        --with-lzma \
        --disable-gdbtk \
        --disable-ld \
        --disable-gas \
        --disable-gdbserver \
        --disable-sim

make $NUMJOBS
make DESTDIR=$DEST install

mkdir -p $DEST/install
cat >> $DEST/install/slack-desc << 'END'
# HOW TO EDIT THIS FILE:
# The "handy ruler" below makes it easier to edit a package description.
# Line up the first '|' above the ':' following the base package name, and
# the '|' on the right side marks the last column you can put a character in.
# You must make exactly 11 lines for the formatting to be correct.  It's also
# customary to leave one space after the ':' except on otherwise blank lines.

      |-----handy-ruler------------------------------------------------------|
ROCgdb: ROCgdb (ROCm source-level debugger for Linux, based on GDB)
ROCgdb:
ROCgdb:
ROCgdb:
ROCgdb:
ROCgdb:
ROCgdb:
ROCgdb:
ROCgdb:
ROCgdb:
ROCgdb:
END

cd $DEST
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

popd
