#!/bin/bash

set -e

cd $ROCM_REL_DIR
wget https://github.com/ROCm/half/archive/rocm-$PKGVER.tar.gz
tar xf half-$LDIR.tar.gz
rm -rf $ROCM_BUILD_DIR/half
mkdir -p $ROCM_BUILD_DIR/half
cd $ROCM_BUILD_DIR/half

DEST=$OUTPUT/package-half
PRGNAM=half
NUMJOBS=${NUMJOBS:-" -j$(expr $(nproc) + 1) "}
BUILD=1
rm -rf $DEST

pushd .

cmake $ROCM_REL_DIR/half-$LDIR
cmake --build . $NUMJOBS || exit 1
DESTDIR=$DEST cmake --install . --strip || exit 1

mkdir -p $DEST/install
cat >> $DEST/install/slack-desc << 'END'
# HOW TO EDIT THIS FILE:
# The "handy ruler" below makes it easier to edit a package description.
# Line up the first '|' above the ':' following the base package name, and
# the '|' on the right side marks the last column you can put a character in.
# You must make exactly 11 lines for the formatting to be correct.  It's also
# customary to leave one space after the ':' except on otherwise blank lines.

    |-----handy-ruler------------------------------------------------------|
half: half (HALF-PRECISION FLOATING POINT LIBRARY)
half:
half: This is a C++ header-only library to provide an IEEE 754 conformant
half: 16-bit half-precision floating point type along with corresponding
half: arithmetic operators, type conversions and common mathematical
half: functions. It aims for both efficiency and ease of use, trying to
half: accurately mimic the behaviour of the builtin floating point types at
half: the best performance possible.
half:
half:
half:
END

cd $DEST
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

popd

