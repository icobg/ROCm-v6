#!/bin/bash

set -e

PRGNAM=rocm-comgr
rm -rf $ROCM_BUILD_DIR/$PRGNAM
mkdir -p $ROCM_BUILD_DIR/$PRGNAM
cd $ROCM_BUILD_DIR/$PRGNAM

LLVMNAM=llvm-project
DESTCOMGR=$OUTPUT/package-$PRGNAM

NUMJOBS=${NUMJOBS:-" -j$(expr $(nproc) + 1) "}
BUILD=1

rm -rf $DESTCOMGR

echo "Building comgr"
mkdir -p $ROCM_BUILD_DIR/$PRGNAM
cd $ROCM_BUILD_DIR/$PRGNAM
cmake \
    -Wno-dev \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_INSTALL_PREFIX=$ROCM_INSTALL_DIR \
    -D CPACK_PACKAGING_INSTALL_PREFIX=$ROCM_INSTALL_DIR \
    -D FILE_REORG_BACKWARD_COMPATIBIL=ON \
    -D BUILD_TESTING=OFF \
    -D CMAKE_PREFIX_PATH="$ROCM_BUILD_DIR/build;$ROCM_BUILD_DIR/device-libs" \
    $ROCM_REL_DIR/$LLVMNAM-$LDIR/amd/comgr

cmake --build . $NUMJOBS
DESTDIR=$DESTCOMGR cmake --install . --strip

mkdir -p $DESTCOMGR/usr/lib64
ln -s /opt/rocm/lib64/libamd_comgr.so $DESTCOMGR/usr/lib64/libamd_comgr.so
ln -s /opt/rocm/lib64/libamd_comgr.so.3 $DESTCOMGR/usr/lib64/libamd_comgr.so.3
ln -s /opt/rocm/lib64/libamd_comgr.so.3.$ROCM_VERSION $DESTCOMGR/usr/lib64/libamd_comgr.so.3.0.$ROCM_VERSION

mkdir -p $DESTCOMGR/install
cat >> $DESTCOMGR/install/slack-desc << 'END'
# HOW TO EDIT THIS FILE:
# The "handy ruler" below makes it easier to edit a package description.
# Line up the first '|' above the ':' following the base package name, and
# the '|' on the right side marks the last column you can put a character in.
# You must make exactly 11 lines for the formatting to be correct.  It's also
# customary to leave one space after the ':' except on otherwise blank lines.

     |-----handy-ruler------------------------------------------------------|
comgr: Code Object Manager (comgr)
comgr:
comgr: The Comgr library provides APIs for compiling and inspecting AMDGPU
comgr: code objects.
comgr:
comgr:
comgr:
comgr:
comgr:
comgr:
comgr:
END

cd $DESTCOMGR
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz
