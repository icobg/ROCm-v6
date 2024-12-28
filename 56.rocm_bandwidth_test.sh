#!/bin/bash

#!/bin/bash

set -e

cd $ROCM_REL_DIR
wget https://github.com/ROCm/rocm_bandwidth_test/archive/rocm-$PKGVER.tar.gz
tar xf rocm_bandwidth_test-$LDIR.tar.gz
rm -rf $ROCM_BUILD_DIR/rocm_bandwidth_test
mkdir -p $ROCM_BUILD_DIR/rocm_bandwidth_test
cd $ROCM_BUILD_DIR/rocm_bandwidth_test

DEST=$OUTPUT/package-rocm_bandwidth_test
PRGNAM=rocm_bandwidth_test
NUMJOBS=${NUMJOBS:-" -j$(expr $(nproc) + 1) "}
BUILD=1
rm -rf $DEST

pushd .

cmake \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_INSTALL_PREFIX=$ROCM_INSTALL_DIR \
    -D CPACK_PACKAGING_INSTALL_PREFIX=$ROCM_INSTALL_DIR \
    -D CMAKE_MODULE_PATH="$ROCM_REL_DIR/rocm_bandwidth_test-$LDIR/cmake_modules" \
    -D CMAKE_PREFIX_PATH=$ROCM_INSTALL_DIR \
    $ROCM_REL_DIR/rocm_bandwidth_test-$LDIR

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
rocm_bandwidth_test: ROCm Bandwidth Test
rocm_bandwidth_test:
rocm_bandwidth_test: ROCm Bandwidth Test is designed to capture the performance
rocm_bandwidth_test: characteristics of buffer copying and kernel read and write
rocm_bandwidth_test: operations. The benchmark help screen shows various options for
rocm_bandwidth_test: initiating copy, read, and write operations. In addition to this, you
rocm_bandwidth_test: can also query the system topology in terms of memory pools and their
rocm_bandwidth_test: agents.
rocm_bandwidth_test:
rocm_bandwidth_test:
rocm_bandwidth_test:
END

cd $DEST
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

popd

